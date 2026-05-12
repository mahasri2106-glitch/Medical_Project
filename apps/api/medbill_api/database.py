from __future__ import annotations

import json
import os
import sqlite3
import uuid
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterator

from .security import hash_password


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def new_id(prefix: str) -> str:
    return f"{prefix}_{uuid.uuid4().hex[:16]}"


def database_path() -> Path:
    return Path(os.getenv("SQLITE_PATH", "data/medbill.sqlite3")).expanduser()


def connect() -> sqlite3.Connection:
    path = database_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    connection = sqlite3.connect(path, check_same_thread=False)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    return connection


@contextmanager
def get_connection() -> Iterator[sqlite3.Connection]:
    connection = connect()
    try:
        yield connection
        connection.commit()
    finally:
        connection.close()


SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'customer',
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS medicines (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  brand TEXT,
  category TEXT NOT NULL,
  composition TEXT NOT NULL,
  price REAL NOT NULL,
  mrp REAL,
  rating REAL NOT NULL DEFAULT 4.5,
  stock INTEGER NOT NULL DEFAULT 100,
  prescription_required INTEGER NOT NULL DEFAULT 0,
  uses TEXT NOT NULL DEFAULT '[]',
  side_effects TEXT NOT NULL DEFAULT '[]',
  safety_advice TEXT NOT NULL DEFAULT '',
  manufacturer TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  total REAL NOT NULL,
  address TEXT,
  status TEXT NOT NULL DEFAULT 'placed',
  items TEXT NOT NULL DEFAULT '[]',
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS health_records (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  title TEXT NOT NULL,
  record_type TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS appointments (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  doctor_name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  fee REAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
"""


MEDICINES = [
    ("prod-001", "Paracetamol 500mg", "MedBill", "Fever & Pain", "Pack of 10 tablets", 25, 30, 0),
    ("prod-002", "Azithromycin 500mg", "MedBill", "Antibiotics", "Pack of 5 tablets", 90, 110, 1),
    ("prod-003", "Cetirizine 10mg", "MedBill", "Allergy", "Pack of 10 tablets", 35, 42, 0),
    ("prod-004", "Vitamin D3 60K", "MedBill", "Vitamins", "Pack of 4 sachets", 120, 150, 0),
    ("prod-005", "Pantoprazole 40mg", "MedBill", "Acidity", "Pack of 15 tablets", 75, 95, 0),
    ("prod-006", "Insulin Glargine", "MedBill", "Diabetes", "3ml cartridge", 850, 950, 1),
    ("prod-007", "Amlodipine 5mg", "MedBill", "Heart Care", "Pack of 10 tablets", 45, 55, 1),
    ("prod-008", "Multivitamin", "MedBill", "Vitamins", "Pack of 30 tablets", 220, 280, 0),
    ("prod-009", "Cough Syrup", "MedBill", "Cold & Cough", "100ml bottle", 95, 120, 0),
    ("prod-010", "ORS Sachet", "MedBill", "Hydration", "Pack of 5 sachets", 50, 60, 0),
]


def init_db() -> None:
    with get_connection() as connection:
        connection.executescript(SCHEMA)
        seed_data(connection)


def seed_data(connection: sqlite3.Connection) -> None:
    now = utc_now()
    connection.execute(
        """
        INSERT OR IGNORE INTO users (id, name, email, password_hash, role, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (
            "user-demo-aarav",
            "Aarav Mehta",
            "aarav@medbill.com",
            hash_password("Secure@123"),
            "customer",
            now,
        ),
    )
    connection.execute(
        """
        INSERT OR IGNORE INTO users (id, name, email, password_hash, role, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (
            "user-demo-admin",
            "System Admin",
            "admin@medbill.com",
            hash_password("Secure@123"),
            "admin",
            now,
        ),
    )
    for item in MEDICINES:
        connection.execute(
            """
            INSERT OR IGNORE INTO medicines (
              id, name, brand, category, composition, price, mrp,
              prescription_required, uses, side_effects, safety_advice, manufacturer
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                *item,
                json.dumps(["Fever", "Pain relief"]),
                json.dumps(["Nausea", "Stomach discomfort"]),
                "Use as directed by a physician.",
                "MedBill Pharmacy",
            ),
        )
    connection.execute(
        """
        INSERT OR IGNORE INTO health_records (id, user_id, title, record_type, notes, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (
            "record-demo-001",
            "user-demo-aarav",
            "Prescription",
            "Prescription",
            "AI extracted 3 medicines",
            now,
        ),
    )


def row_to_user(row: sqlite3.Row) -> dict:
    return {
        "_id": row["id"],
        "id": row["id"],
        "name": row["name"],
        "email": row["email"],
        "role": row["role"],
    }


def row_to_medicine(row: sqlite3.Row) -> dict:
    return {
        "_id": row["id"],
        "id": row["id"],
        "name": row["name"],
        "brand": row["brand"],
        "category": row["category"],
        "composition": row["composition"],
        "price": row["price"],
        "mrp": row["mrp"],
        "rating": row["rating"],
        "stock": row["stock"],
        "prescriptionRequired": bool(row["prescription_required"]),
        "uses": json.loads(row["uses"]),
        "sideEffects": json.loads(row["side_effects"]),
        "safetyAdvice": row["safety_advice"],
        "manufacturer": row["manufacturer"],
    }
