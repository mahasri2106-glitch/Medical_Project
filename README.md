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

Demo account:

- Email: `aarav@medbill.com`
- Password: `Secure@123`

## Flutter

```bash
cd apps/mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:7860/api/v1
```

For Flutter web testing on the same machine:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:7860/api/v1
```

## Notes

- The legacy web prototype files were removed.
- The MedBill visual structure was ported to Flutter: branded header, horizontal service nav, green hero, service grid, specialties, category chips, medicine cards, Circle, Insurance, Labs, Doctors, Records, Cart, Checkout, Orders and Profile.
- The app falls back to local catalog data if the backend is not running, but login/order APIs need the backend.
