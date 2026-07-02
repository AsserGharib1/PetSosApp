# PetSOS — Lost & Found Pet Rescue App (Flutter + Firebase)

Cross-platform Flutter application for reporting and finding lost or abandoned pets: geolocated photo reports on a live map, in-app chat between finders and owners, and an admin dashboard.

## Features

- **13 screens** covering onboarding, auth, report creation, browsing, and admin flows
- **Real-time map** with geolocated pet pins and routing to a reported pet's location
- **Photo reports** stored in Firebase Storage with Cloud Firestore metadata
- **In-app chat** between users about a reported pet
- **Admin dashboard** for managing users and reports
- **Localization** and full form validation

## Architecture & stack

- **MVVM** with `Provider` — clean separation of `models/`, `viewmodels/`, `views/`
- **Firebase**: Authentication (incl. Google Sign-In), Cloud Firestore, Storage
- Repository + service layer (`models/data/`) for chat, location, routing, and storage
- **Tests**: unit and widget tests with `mockito` across four suites — models, validators, and view models (`test/`)

## Getting started

```bash
flutter pub get
# connect your own Firebase project (google-services.json / firebase_options.dart
# are intentionally not committed):
dart pub global activate flutterfire_cli
flutterfire configure
flutter run
```

```bash
flutter test   # run the test suites
```
