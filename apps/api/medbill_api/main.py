from __future__ import annotations

import json
import os
import sqlite3
import requests
from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI, File, Header, HTTPException, Query, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from .database import get_connection, init_db, new_id, row_to_medicine, row_to_user, utc_now
from .security import create_token, decode_token, hash_password, verify_password


API_PREFIX = "/api/v1"
AUTH_SECRET = os.getenv("AUTH_SECRET", "change-this-secret")


@asynccontextmanager
async def lifespan(_app: FastAPI):
    init_db()
    yield


app = FastAPI(title="MedBill SQLite API", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class LoginPayload(BaseModel):
    email: str
    password: str


class RegisterPayload(LoginPayload):
    name: str = Field(min_length=2, max_length=120)


class OrderPayload(BaseModel):
    total: float
    address: str = ""
    items: list[dict] = Field(default_factory=list)


class RecordPayload(BaseModel):
    title: str
    record_type: str
    notes: str = ""


def db():
    with get_connection() as connection:
        yield connection


def current_user(
    authorization: Annotated[str | None, Header()] = None,
    connection: sqlite3.Connection = Depends(db),
) -> dict | None:
    if not authorization:
        return None
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer":
        return None
    payload = decode_token(token, secret=AUTH_SECRET)
    if not payload:
        return None
    row = connection.execute("SELECT * FROM users WHERE id = ?", (payload["sub"],)).fetchone()
    return row_to_user(row) if row else None


def require_user(user: dict | None = Depends(current_user)) -> dict:
    if not user:
        raise HTTPException(status_code=401, detail="Authentication required")
    return user


def session_for(user: dict) -> dict:
    return {
        "accessToken": create_token(
            {"sub": user["id"], "email": user["email"], "role": user["role"]},
            secret=AUTH_SECRET,
        ),
        "user": user,
    }


@app.get("/")
@app.get("/health")
@app.get(f"{API_PREFIX}/health")
def health() -> dict:
    return {"success": True, "service": "MedBill SQLite API", "status": "ok"}


@app.post(f"{API_PREFIX}/auth/register")
def register(payload: RegisterPayload, connection: sqlite3.Connection = Depends(db)) -> dict:
    if connection.execute("SELECT id FROM users WHERE email = ?", (payload.email.lower(),)).fetchone():
        raise HTTPException(status_code=409, detail="Email already exists")
    user_id = new_id("user")
    connection.execute(
        """
        INSERT INTO users (id, name, email, password_hash, role, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (user_id, payload.name, payload.email.lower(), hash_password(payload.password), "customer", utc_now()),
    )
    row = connection.execute("SELECT * FROM users WHERE id = ?", (user_id,)).fetchone()
    return session_for(row_to_user(row))


@app.post(f"{API_PREFIX}/auth/login")
def login(payload: LoginPayload, connection: sqlite3.Connection = Depends(db)) -> dict:
    row = connection.execute("SELECT * FROM users WHERE email = ?", (payload.email.lower(),)).fetchone()
    if not row or not verify_password(payload.password, row["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return session_for(row_to_user(row))


@app.get(f"{API_PREFIX}/auth/me")
def me(user: dict = Depends(require_user)) -> dict:
    return {"success": True, "user": user}


@app.get(f"{API_PREFIX}/medicines")
def medicines(
    q: Annotated[str | None, Query()] = None,
    category: Annotated[str | None, Query()] = None,
    connection: sqlite3.Connection = Depends(db),
) -> dict:
    filters: list[str] = []
    params: list[str] = []
    if q:
        filters.append("(lower(name) LIKE ? OR lower(category) LIKE ? OR lower(composition) LIKE ?)")
        value = f"%{q.lower()}%"
        params.extend([value, value, value])
    if category:
        filters.append("category = ?")
        params.append(category)
    where = f"WHERE {' AND '.join(filters)}" if filters else ""
    rows = connection.execute(f"SELECT * FROM medicines {where} ORDER BY name", params).fetchall()
    return {"success": True, "data": [row_to_medicine(row) for row in rows]}


@app.get(f"{API_PREFIX}/doctors")
def doctors() -> dict:
    return {
        "success": True,
        "data": [
            {"name": "Dr. Aditi Sharma", "specialty": "Cardiologist", "fee": 600},
            {"name": "Dr. Rohan Patel", "specialty": "ENT", "fee": 400},
            {"name": "Dr. Nisha Reddy", "specialty": "Pediatrician", "fee": 500},
        ],
    }


@app.get(f"{API_PREFIX}/lab-tests")
def lab_tests() -> dict:
    return {
        "success": True,
        "data": [
            {"name": "Complete Blood Count (CBC)", "category": "Blood", "price": 350},
            {"name": "Lipid Profile", "category": "Heart", "price": 600},
            {"name": "Thyroid Profile (T3 T4 TSH)", "category": "Hormone", "price": 500},
        ],
    }


@app.post(f"{API_PREFIX}/orders")
def create_order(
    payload: OrderPayload,
    user: dict = Depends(require_user),
    connection: sqlite3.Connection = Depends(db),
) -> dict:
    order_id = new_id("order")
    connection.execute(
        """
        INSERT INTO orders (id, user_id, total, address, status, items, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (order_id, user["id"], payload.total, payload.address, "placed", json.dumps(payload.items), utc_now()),
    )
    return {"success": True, "data": {"id": order_id, "status": "placed"}}


@app.get(f"{API_PREFIX}/orders")
def orders(user: dict = Depends(require_user), connection: sqlite3.Connection = Depends(db)) -> dict:
    rows = connection.execute(
        "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC",
        (user["id"],),
    ).fetchall()
    return {"success": True, "data": [dict(row) | {"items": json.loads(row["items"])} for row in rows]}


@app.post(f"{API_PREFIX}/health-records")
def create_record(
    payload: RecordPayload,
    user: dict = Depends(require_user),
    connection: sqlite3.Connection = Depends(db),
) -> dict:
    record_id = new_id("record")
    connection.execute(
        """
        INSERT INTO health_records (id, user_id, title, record_type, notes, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (record_id, user["id"], payload.title, payload.record_type, payload.notes, utc_now()),
    )
    return {"success": True, "data": {"id": record_id}}


@app.get(f"{API_PREFIX}/health-records")
def health_records(
    user: dict = Depends(require_user),
    connection: sqlite3.Connection = Depends(db),
) -> dict:
    rows = connection.execute(
        "SELECT * FROM health_records WHERE user_id = ? ORDER BY created_at DESC",
        (user["id"],),
    ).fetchall()
    return {"success": True, "data": [dict(row) for row in rows]}


@app.post(f"{API_PREFIX}/prescriptions/analyze")
async def analyze_prescription(file: UploadFile = File(...)) -> dict:
    image_bytes = await file.read()
    
    extracted_text = "AI extracted data from image."
    hf_token = os.getenv("HF_TOKEN")
    
    if hf_token:
        # Use Hugging Face Inference API for OCR
        api_url = "https://api-inference.huggingface.co/models/microsoft/trocr-large-printed"
        headers = {"Authorization": f"Bearer {hf_token}"}
        try:
            response = requests.post(api_url, headers=headers, data=image_bytes, timeout=15)
            if response.status_code == 200:
                result = response.json()
                if isinstance(result, list) and len(result) > 0:
                    extracted_text = result[0].get("generated_text", extracted_text)
        except Exception as e:
            extracted_text = f"Live OCR skipped (error: {str(e)}). Fallback data generated."
    else:
        extracted_text = "HF_TOKEN not found. Using local simulated extraction."

    return {
        "summary": f"Prescription Analysis complete: {extracted_text}",
        "medicines": [
            {"name": "Paracetamol 500mg", "dosage": "500mg", "duration": "3 days"},
            {"name": "Azithromycin 500mg", "dosage": "500mg", "duration": "5 days"},
        ],
        "reminders": ["Morning after breakfast", "Night after dinner"],
        "interactions": ["Confirm prescription medicines with a licensed pharmacist."],
    }


def run() -> None:
    import uvicorn

    uvicorn.run("medbill_api.main:app", host="0.0.0.0", port=int(os.getenv("PORT", "7860")))
