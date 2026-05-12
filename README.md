# MedBill Flutter + SQLite

Flutter mobile application with the same MedBill UI design from the original app, backed by a lightweight SQLite API.

## Stack

- `apps/mobile` - Flutter app
- `apps/api` - FastAPI backend
- SQLite database file generated at `data/medbill.sqlite3`

## Backend

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Backend runs at `http://localhost:7860`.

**Demo Accounts (Use these to test):**

*Employee (User) Login:*
- Email: `aarav@medbill.com`
- Password: `Secure@123`

*Admin Login:*
- Email: `admin@medbill.com` (or any email when Admin is toggled)
- Password: `Secure@123`

## Flutter

```bash
cd apps/mobile
flutter pub get
flutter run -d chrome
```

For Flutter web testing on the same machine, if you experience connection timeouts or CORS issues, ensure you specify your local API URL correctly:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:7860/api/v1
```


cd C:\Users\essai\OneDrive\Desktop\Medical_Project\apps\mobile
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://mahasri006-mediscan-api.hf.space/api/v1