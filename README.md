# ARVIND PARTY WEB PANEL

Admin & Owner Panel for the Arvind Party luxury social streaming platform.
Built with Flutter Web + GetX.

## Prerequisites

- Flutter SDK >=3.10.0
- Dart SDK >=3.10.0
- A running backend (Node.js) at the configured API URL

## Setup

```bash
# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs
```

## Run (Development)

```bash
# Option A: Use the helper script (Unix)
./scripts/run_dev.sh

# Option B: Use the helper script (Windows)
scripts\run_dev.bat

# Option C: Pass flags manually
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:5000/api \
  --dart-define=SOCKET_URL=http://localhost:5000 \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456 \
  --dart-define=FIREBASE_APP_ID=1:123456:web:abc \
  --dart-define=FIREBASE_MEASUREMENT_ID=G-XXXXXXX \
  --dart-define=LIVEKIT_URL=wss://livekit.arvindparty.com \
  --dart-define=RAZORPAY_KEY_ID=rzp_live_...
```

## Build (Production)

Release build uses HTTPS production URLs automatically. Provide Firebase flags:

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.arvindparty.com/api \
  --dart-define=SOCKET_URL=https://api.arvindparty.com \
  # ... (same Firebase flags as above)
```

## Run Tests

```bash
flutter test
```

## Folder Structure

```
lib/
  main.dart              Entry point
  core/                  Shared services (API, Socket, Auth, Theme)
  modules/               Feature modules (40+)
  routes/                Route definitions
test/                    Unit tests
web/                     Web shell & assets
scripts/                 Development helpers
```

## Key Dependencies

- **State Management:** GetX
- **Networking:** http, Dio, Socket.IO
- **Auth:** Firebase Auth, Google Sign-In
- **UI:** Google Fonts, Flutter SVG, Cached Network Images
- **Data:** Syncfusion DataGrid, fl_chart, data_table_2
- **Export:** PDF, Excel, CSV
