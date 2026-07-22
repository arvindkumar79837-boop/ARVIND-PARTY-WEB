#!/usr/bin/env bash
# ===============================================================
# ARVIND PARTY WEB PANEL — Development Run Script
# ===============================================================
# Usage:  ./scripts/run_dev.sh
# Prereq: flutter SDK installed, `flutter pub get` done
# ===============================================================

set -euo pipefail

# ---- Fill in your Firebase values below or source .env ----
if [ -f .env ]; then
  set -a; source .env; set +a
fi

flutter run -d chrome \
  --dart-define=API_BASE_URL="${API_BASE_URL:-http://localhost:5000/api}" \
  --dart-define=SOCKET_URL="${SOCKET_URL:-http://localhost:5000}" \
  --dart-define=FIREBASE_API_KEY="${FIREBASE_API_KEY:-}" \
  --dart-define=FIREBASE_AUTH_DOMAIN="${FIREBASE_AUTH_DOMAIN:-}" \
  --dart-define=FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-}" \
  --dart-define=FIREBASE_STORAGE_BUCKET="${FIREBASE_STORAGE_BUCKET:-}" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="${FIREBASE_MESSAGING_SENDER_ID:-}" \
  --dart-define=FIREBASE_APP_ID="${FIREBASE_APP_ID:-}" \
  --dart-define=FIREBASE_MEASUREMENT_ID="${FIREBASE_MEASUREMENT_ID:-}" \
  --dart-define=LIVEKIT_URL="${LIVEKIT_URL:-wss://livekit.arvindparty.com}" \
  --dart-define=RAZORPAY_KEY_ID="${RAZORPAY_KEY_ID:-rzp_live_...}"
