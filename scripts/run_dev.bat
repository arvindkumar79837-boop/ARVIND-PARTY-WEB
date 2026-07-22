@echo off
REM ===========================================================
REM ARVIND PARTY WEB PANEL — Development Run Script (Windows)
REM ===========================================================
REM Usage:  scripts\run_dev.bat
REM Prereq: flutter SDK installed, `flutter pub get` done
REM ===========================================================

REM ---- Fill in your Firebase values below ----
set API_BASE_URL=http://localhost:5000/api
set SOCKET_URL=http://localhost:5000
set FIREBASE_API_KEY=
set FIREBASE_AUTH_DOMAIN=
set FIREBASE_PROJECT_ID=
set FIREBASE_STORAGE_BUCKET=
set FIREBASE_MESSAGING_SENDER_ID=
set FIREBASE_APP_ID=
set FIREBASE_MEASUREMENT_ID=
set LIVEKIT_URL=wss://livekit.arvindparty.com
set RAZORPAY_KEY_ID=rzp_live_...

flutter run -d chrome ^
  --dart-define=API_BASE_URL=%API_BASE_URL% ^
  --dart-define=SOCKET_URL=%SOCKET_URL% ^
  --dart-define=FIREBASE_API_KEY=%FIREBASE_API_KEY% ^
  --dart-define=FIREBASE_AUTH_DOMAIN=%FIREBASE_AUTH_DOMAIN% ^
  --dart-define=FIREBASE_PROJECT_ID=%FIREBASE_PROJECT_ID% ^
  --dart-define=FIREBASE_STORAGE_BUCKET=%FIREBASE_STORAGE_BUCKET% ^
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=%FIREBASE_MESSAGING_SENDER_ID% ^
  --dart-define=FIREBASE_APP_ID=%FIREBASE_APP_ID% ^
  --dart-define=FIREBASE_MEASUREMENT_ID=%FIREBASE_MEASUREMENT_ID% ^
  --dart-define=LIVEKIT_URL=%LIVEKIT_URL% ^
  --dart-define=RAZORPAY_KEY_ID=%RAZORPAY_KEY_ID%
