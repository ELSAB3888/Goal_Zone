# Implementation Plan: API Integration

**Branch**: `002-api-integration` | **Date**: 2026-06-05 | **Spec**: [spec.md](file:///c:/src/flutter_App/Goal_Zone/specs/002-api-integration/spec.md)
**Input**: Feature specification from `/specs/002-api-integration/spec.md`

## Summary

Integrate REST APIs into the Goal Zone Flutter App based on the live backend service (`https://goalzone-api.vercel.app/api`). This includes migrating from mock data to real HTTP requests, setting up a secure persistent session token via `shared_preferences` and attaching it to outgoing calls using `dio` interceptors, implementing Stadium lists/filters, managing bookings, and downloading reservation tickets with QR code.

## Technical Context

- **Language/Version**: Dart (Flutter SDK 3.38.3)
- **Primary Dependencies**: `dio`, `provider`, `shared_preferences`, `qr_flutter`, `image_gallery_saver_plus`
- **Storage**: Key-value persistent storage (`shared_preferences` for JWT session tokens and user state)
- **Testing**: `flutter test` (widget tests and unit tests with mocked API endpoints via Dio interceptors)
- **Target Platform**: Android, iOS
- **Project Type**: Mobile Application
- **Performance Goals**: Live API calls completed under 2 seconds, smooth list animations
- **Constraints**: Secure JWT token persistence, graceful offline state display, handling server timeouts

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Requirement Compliance**: Checked. Feature requirements match spec constraints.
- **Language & Stack**: Dart & Flutter. Done.
- **Testing Gate**: Unit tests implemented and passing. Done.

## Project Structure

### Documentation (this feature)

```text
specs/002-api-integration/
├── plan.md              # This file
├── spec.md              # Feature specification
├── checklists/
│   └── requirements.md  # Requirements completeness checklist
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── models/
│   │   ├── booking_model.dart
│   │   └── stadium_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── booking_provider.dart
│   │   ├── locale_provider.dart
│   │   ├── navigation_provider.dart
│   │   └── stadium_provider.dart
│   ├── services/
│   │   └── api_service.dart
│   └── utils/
│       └── ticket_downloader.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── ...
│   ├── booking/
│   │   ├── booking_summary_screen.dart
│   │   ├── my_bookings_screen.dart
│   │   └── ticket_screen.dart
│   ├── court/
│   └── stadium/
└── widgets/
```

**Structure Decision**: Single Flutter project structure using Provider pattern for state management and Dio for HTTP/REST services.

## Proposed Changes & Status

Most changes are already implemented in the working copy:
- `ApiService` is fully integrated with Dio, setting up base URL and Bearer Token header interceptors.
- `AuthProvider`, `StadiumProvider`, and `BookingProvider` contain methods to fetch data from the server.
- Auth screens (Login, Signup, Reset Password, etc.) are wired to `AuthProvider`.
- Booking summary and ticket generation (with QR code and download capabilities via `image_gallery_saver_plus`) are implemented.
- Widget tests have been updated with `SharedPreferences` mock setup and automatic `Dio` request interception to verify the app launches successfully under tests.

## Verification Plan

### Automated Tests
- Run unit/widget tests:
  ```bash
  flutter test
  ```

### Manual Verification
- Deploy to physical Android/iOS devices or emulators:
  ```bash
  flutter run
  ```
- Test registration, login, loading playgrounds, picking slot, booking confirmation, viewing booking lists, ticket download, and logout.
