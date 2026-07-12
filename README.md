# FastCure

[![Flutter](https://img.shields.io/badge/Flutter-v3.44.4--stable-blue.svg?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Services-orange.svg?logo=firebase)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/hemanthkumar-del/FastCure.svg?style=social)](https://github.com/hemanthkumar-del/FastCure)

FastCure is a production-grade Clinical & Hospital Operations Management System built using **Flutter (Material 3)** and **Firebase**.

---

## Features

- **Firebase Authentication**: Dynamic onboarding validation and session caching.
- **Google Sign-In**: Integrated social login workflows.
- **Doctor Management**: Profiles directory, specialization choices, and fees setup.
- **Patient Management**: Profiles listing, allergy wrapper chips, and medical history trackers.
- **Appointment Booking**: Form scheduler matching active lists, calendar filters, and instant action approvals.
- **Prescription Management**: Issue drugs builder checking stock levels in real time.
- **Medicine Inventory**: Live pharmacy stock trackers with red alerts for low items.
- **Billing System**: Cost summation tables, paid toggles, and payment method modals.
- **Dashboard Analytics**: M3 metrics grid panels, Circular Pie charts, and Monthly earnings Bar graphs.
- **Firebase Cloud Messaging**: Integrated token authorization and messaging services.
- **Firebase Storage**: Photo profile uploads targeting doctor buckets.
- **Material 3 UI**: Premium responsive components, micro-animations, and theme configs.
- **Provider State Management**: Clean ChangeNotifier decoupling presentation and repos.
- **Offline Firestore Cache**: Native offline persistent caches supporting network drops.

---

## Technology Stack

*   **UI/Core**: Flutter & Dart (Material 3)
*   **Database**: Cloud Firestore
*   **Authentication**: Firebase Authentication
*   **Storage**: Firebase Storage
*   **Push Messages**: Firebase Cloud Messaging (FCM)
*   **State Management**: Provider
*   **VCS/Hosting**: Git & GitHub

---

## Project Architecture

FastCure applies a clean separation of concerns split into layers:

*   **Presentation Layer**: User interfaces consisting of stateless/stateful Flutter widgets listening to state changes.
*   **State Management (Provider)**: Interacts with repositories to fetch/save data and notifies listeners to redraw components.
*   **Domain Layer (Repository contracts)**: Abstract definitions separating core logic from network modules.
*   **Data Layer (Repository implementations)**: Connects to underlying database frameworks, maps models, and parses errors.
*   **Service Layer**: Singleton wrappers managing third-party initializations (`FirebaseService`, `AIService`).

---

## Folder Structure

```text
lib/
├── core/
│   ├── constants/       # Global constants (colors, layouts, strings)
│   ├── routes/          # Static paths and AppRouter fade routes
│   ├── services/        # Firebase configuration singletons and AI calls
│   ├── theme/           # Color palettes matching Material 3 rules
│   └── utils/           # Custom AppLogger
└── features/
    ├── ai/              # AI Health Chatbot module
    ├── appointment/     # Appointment scheduler module
    ├── auth/            # Authentication flow controllers
    ├── billing/         # Billing invoices calculators
    ├── dashboard/       # Main overview screen and custom charts
    ├── doctor/          # Doctors directories and profiles
    ├── medicine/        # Pharmacy inventory tables
    ├── patient/         # Patients medical directories
    ├── prescription/    # Prescribing drug wizards
    ├── profile/         # Profile edits screen
    ├── settings/        # App modes setup
    └── splash/          # Splash animation launcher
```

---

## Screenshots

Below are placeholders illustrating FastCure UI layouts. Real screenshots will be updated following staging uploads:

| Module / View | UI Mockup Placeholder |
| :--- | :--- |
| **Splash Screen** | `![Splash Screen](docs/screenshots/splash_placeholder.png)` |
| **Login View** | `![Login Screen](docs/screenshots/login_placeholder.png)` |
| **Dashboard** | `![Dashboard Screen](docs/screenshots/dashboard_placeholder.png)` |
| **Doctor Module** | `![Doctor Directory](docs/screenshots/doctor_placeholder.png)` |
| **Patient Module** | `![Patient Directory](docs/screenshots/patient_placeholder.png)` |
| **Appointment Module** | `![Appointment Booking](docs/screenshots/appointment_placeholder.png)` |
| **Billing System** | `![Billing Details](docs/screenshots/billing_placeholder.png)` |
| **AI Assistant** | `![AI Chat Screen](docs/screenshots/ai_chat_placeholder.png)` |

---

## Installation

To run FastCure locally on your workstation, follow these steps:

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/hemanthkumar-del/FastCure.git
    cd FastCure
    ```
2.  **Download Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

---

## Firebase Setup

To connect your own Firebase environment to this project:

1.  Create a project on the [Firebase Console](https://console.firebase.google.com).
2.  Install the FlutterFire CLI globally and log in:
    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```
3.  Ensure your generated `google-services.json` is placed inside `android/app/`.
4.  Configure the following services on Firebase Console:
    *   **Firebase Authentication**: Enable Email/Password and Google login providers.
    *   **Cloud Firestore**: Start in test mode, then deploy security rules.
    *   **Firebase Storage**: Configure default storage buckets for profile photos.

---

## Build

To compile release builds, run the following Flutter compiler commands:

### 1. Production APK
Generates a signed standalone Android APK:
```bash
flutter build apk --release
```
*   Output path: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Production App Bundle (AAB)
Generates the Google Play Store optimized upload bundle:
```bash
flutter build appbundle
```
*   Output path: `build/app/outputs/bundle/release/app-release.aab`

---

## Future Enhancements

*   **Telemedicine**: Secure peer-to-peer webRTC video consult integrations.
*   **Lab Integrations**: PDF scanning, parsing, and storing lab diagnostic reports.
*   **Payment Channels**: Direct digital wallet payment gateways (Razorpay, Stripe).
*   **AI Diagnosis Model**: Advanced custom model analysis linking patient symptoms.
*   **Wearable Integration**: Syncing real-time heart rate and activity metrics from smartwatches.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
