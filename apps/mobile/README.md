# MedBill Flutter App

Flutter mobile implementation of the MedBill healthcare UI:

- Riverpod state management
- Material 3 light and dark themes
- Responsive dashboard, pharmacy, prescription, cart, doctor, lab, Circle, insurance, record, order and profile screens
- API client with bearer token injection
- Secure storage for access tokens
- Prescription image/PDF upload flow connected to the SQLite backend

## First Run

If platform folders are not present yet, generate them with Flutter from this directory:

```bash
flutter create . --platforms android,ios,web --org com.mediscan --project-name mediscan_ai
```

Then restore dependencies and run:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:7860/api/v1
```
