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

## Notes

- The legacy web prototype files were removed.
- The MedBill visual structure was ported to Flutter: branded header, horizontal service nav, green hero, service grid, specialties, category chips, medicine cards, Circle, Insurance, Labs, Doctors, Records, Cart, Checkout, Orders and Profile.
- The app falls back to local catalog data if the backend is not running, but login/order APIs need the backend.

🤗 How to Deploy to Hugging Face (Live Backend)
To make your application "Live" so anyone can use it from an Android phone, follow these steps to host your FastAPI backend on Hugging Face:

Step 1: Create a Hugging Face Space
Go to huggingface.co/spaces.
Click "Create new Space".
Name: mediscan-api (or any name).
SDK: Select Docker.
Template: Choose "Blank".
Public/Private: Set to Public.
Step 2: Upload Your Files
Upload the following files from your local Medical_Project folder to the Space:

app.py (The main entry point)
requirements.txt
The entire apps/api/medbill_api/ folder.
Create a new file named Dockerfile in the root of the Space with this content:
dockerfile
FROM python:3.10
WORKDIR /code
COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt
COPY . .
# Hugging Face Spaces run on port 7860
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"]
Step 3: Connect Your Flutter App
Once the Space is "Running", look for the "Embed this Space" or the URL in the address bar. It will look like: https://yourname-mediscan-api.hf.space.
Important: Your API base URL for the Flutter app will be: https://yourname-mediscan-api.hf.space/api/v1.
Build your APK using this live URL:
bash
flutter build apk --release --dart-define=API_BASE_URL=https://yourname-mediscan-api.hf.space/api/v1
🚀 Action Required to See Fixed Images:
Please Stop and Restart your Flutter app to clear the old image cache:

Press Ctrl+C in the terminal.
Run: flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:7860/api/v1
You should now see clear, professional medicine images instead of nature photos!