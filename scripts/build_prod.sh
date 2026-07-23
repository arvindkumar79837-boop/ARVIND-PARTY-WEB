#!/bin/bash
# ARVIND PARTY WEB - Production Build Script
# Usage: ./scripts/build_prod.sh [--analyze]
# All secrets are injected via --dart-define at build time.
# CI should use secret manager for all values below.

set -euo pipefail

echo "=== Building ARVIND PARTY WEB Panel (Production) ==="

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
ANALYZE="${1:-}"

if [ "$ANALYZE" = "--analyze" ]; then
  echo ">>> Running flutter analyze..."
  $FLUTTER_BIN analyze lib/
fi

echo ">>> Running flutter build web..."
$FLUTTER_BIN build web \
  --release \
  --dart-define=API_BASE_URL=https://api.arvindparty.com/api \
  --dart-define=SOCKET_URL=https://api.arvindparty.com \
  --dart-define=FIREBASE_API_KEY="${FIREBASE_API_KEY:-}" \
  --dart-define=FIREBASE_AUTH_DOMAIN="${FIREBASE_AUTH_DOMAIN:-}" \
  --dart-define=FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-}" \
  --dart-define=FIREBASE_STORAGE_BUCKET="${FIREBASE_STORAGE_BUCKET:-}" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="${FIREBASE_MESSAGING_SENDER_ID:-}" \
  --dart-define=FIREBASE_APP_ID="${FIREBASE_APP_ID:-}" \
  --dart-define=FIREBASE_MEASUREMENT_ID="${FIREBASE_MEASUREMENT_ID:-}" \
  --dart-define=LIVEKIT_URL="${LIVEKIT_URL:-wss://livekit.arvindparty.com}" \
  --dart-define=RAZORPAY_KEY_ID="${RAZORPAY_KEY_ID:-}"

echo "=== Build complete ==="
echo "Output: build/web/"
