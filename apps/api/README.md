# MedBill API

FastAPI backend using SQLite.

## Run

```bash
cd ..\..
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

API docs are available at `http://localhost:7860/docs`.

## Environment

Copy `apps/api/.env.example` if you want local overrides:

- `PORT`
- `SQLITE_PATH`
- `AUTH_SECRET`
- `CORS_ORIGINS`
