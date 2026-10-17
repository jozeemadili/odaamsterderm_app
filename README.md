# DukaFlow (Flutter)

Mobile app for DukaFlow Tanzania, talking to the [dukaflow](https://github.com/jozeemadili/dukaflow) Laravel backend's v1 REST API (see that repo's `api-collection/` for the full endpoint reference — Postman and Bruno collections, generated from the same source as this app should stay aligned against).

## Stack

- **State management**: Riverpod (`flutter_riverpod`, classic provider API — no codegen)
- **Navigation**: `go_router`, auth-gated via a redirect that watches `authControllerProvider`
- **HTTP**: `dio`, with a bearer-token interceptor reading from `flutter_secure_storage`
- **Auth**: email/password, and Google Sign-In (native SDK, ID-token verified server-side)
- **Media**: `image_picker` (camera or gallery — same upload endpoint either way), `mobile_scanner` (barcode scanning)

## Running

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://dukaflow-production-lfgbd3.laravel.cloud/api/v1
```

Against a local Laravel instance instead:

```bash
# Android emulator (10.0.2.2 reaches the host machine's localhost)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001/api/v1

# iOS simulator (shares the host's localhost directly)
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8001/api/v1
```

Google sign-in works out of the box — the Android and iOS OAuth clients are already set up in the same Google Cloud project as the web app (see "Google Sign-In setup" below). Only pass `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` if the backend's web client ID ever changes.

## Google Sign-In setup

All three OAuth clients live in the same Google Cloud project as the web portal (`loginwithgmail-507208`):

| Platform | Identifier registered | Client ID |
|---|---|---|
| Web (backend) | — | `201989877749-s6kaif6n2vlfps0gnhkqkpd0ru7ju3ed.apps.googleusercontent.com` |
| Android | package `com.dukaflow.dukaflow_app`, debug SHA-1 `8C:7F:5A:4C:6E:B8:0A:03:75:03:06:D4:9B:82:5A:43:D7:5E:44:C0` | `201989877749-t6129vpat283n4clrteach2s6avga22m.apps.googleusercontent.com` |
| iOS | bundle ID `com.dukaflow.dukaflowApp` | `201989877749-rlcpkkmlv0mr5pu9mk70d2tutf5cl9c2.apps.googleusercontent.com` (wired into `ios/Runner/Info.plist` as `GIDClientID` + URL scheme) |

The app itself only ever references the **web** client ID (as `serverClientId`) — that's what makes the ID token's audience match what the Laravel backend expects. The Android/iOS client IDs aren't referenced in code; Google matches sign-in requests to them automatically via package name/SHA-1 (Android) or bundle ID (iOS).

**Before a Play Store release**: the Android client above is only registered for the *debug* keystore's SHA-1. Once there's a release/upload keystore, add its SHA-1 as an additional entry on that same Android OAuth client in Google Cloud Console, or sign-in will fail on release builds with a DEVELOPER_ERROR.

## Structure

```
lib/
  app/            MaterialApp, theme, go_router config
  core/
    api/          Dio client + error normalization
    storage/      Secure token storage
  features/
    auth/         Login, register, Google sign-in, session state
    dashboard/    Home screen (stats, low-stock/expiring alerts)
    ...           (inventory, pos, invoices, etc. as they're built)
```

Each feature follows `data/` (models + repository calling the API) and `presentation/` (Riverpod controllers + screens).

## Status

Phase 1 scaffold: auth (register, login, Google sign-in scaffolding) and a read-only dashboard, wired against the real API. See the development plan shared alongside this repo for what's next.
