// ═══════════════════════════════════════════════════════════════════════════
// ARVIND PARTY WEB PANEL - Environment Configuration
// ═══════════════════════════════════════════════════════════════════════════
//
// HOW TO CONFIGURE:
//   All secrets and URLs are injected at build time via --dart-define.
//   Pass ALL required values on every build. Example:
//
//   flutter run -d chrome \
//     --dart-define=API_BASE_URL=http://localhost:5000/api \
//     --dart-define=SOCKET_URL=http://localhost:5000 \
//     --dart-define=FIREBASE_API_KEY=AIza... \
//     --dart-define=FIREBASE_AUTH_DOMAIN=project.firebaseapp.com \
//     --dart-define=FIREBASE_PROJECT_ID=project-id \
//     --dart-define=FIREBASE_STORAGE_BUCKET=project.firebasestorage.app \
//     --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456 \
//     --dart-define=FIREBASE_APP_ID=1:123456:web:abc \
//     --dart-define=FIREBASE_MEASUREMENT_ID=G-XXXXXXX \
//     --dart-define=LIVEKIT_URL=wss://livekit.example.com \
//     --dart-define=RAZORPAY_KEY_ID=rzp_live_...
//
//   For a release build, use the prod defaults (no overrides needed):
//     flutter build web
//
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart' show kReleaseMode;

class EnvConfig {
  // ─── BASE URL (auto-switches based on build mode) ───────────────────
  //
  // NOTE: When deploying to production, make sure the backend has SSL set up.
  //       Without it, browsers will throw Mixed Content errors.
  //
  static const String _devBaseUrl = 'http://localhost:5000';
  static const String _prodBaseUrl = 'https://api.arvindparty.com';

  /// Returns the effective base URL (HTTP in debug, HTTPS in release).
  static String get _effectiveBaseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;

  // ─── API BASE URL ───────────────────────────────────────────────────
  static String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',  // Empty = use _effectiveBaseUrl fallback
  ).isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : '$_effectiveBaseUrl/api';

  // ─── SOCKET.IO URL ──────────────────────────────────────────────────
  static String get socketUrl => const String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: '',
  ).isNotEmpty
      ? const String.fromEnvironment('SOCKET_URL')
      : _effectiveBaseUrl;

  // ─── FIREBASE CONFIG ────────────────────────────────────────────────
  // Values must be provided via --dart-define at build time.
  static final Map<String, dynamic> firebaseConfig = {
    'apiKey': const String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: '',
    ),
    'authDomain': const String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: '',
    ),
    'projectId': const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    ),
    'storageBucket': const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: '',
    ),
    'messagingSenderId': const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    'appId': const String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '',
    ),
    'measurementId': const String.fromEnvironment(
      'FIREBASE_MEASUREMENT_ID',
      defaultValue: '',
    ),
  };

  // ─── RAZORPAY ───────────────────────────────────────────────────────
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  // ─── LIVEKIT ────────────────────────────────────────────────────────
  static const String liveKitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: '',
  );

  // ─── APP DEFAULTS ───────────────────────────────────────────────────
  static const String appName = 'Arvind Party Admin';
  static const String appVersion = '1.0.0';
  static const int pageSize = 20;
  static const int requestTimeoutSeconds = 30;
}
