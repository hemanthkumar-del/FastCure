# 🏥 FastCure — Premium Healthcare Assistant App

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.12.2-blue?logo=flutter)](https://flutter.dev)
[![Firebase Integration](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-orange?logo=firebase)](https://firebase.google.com)
[![Platform Support](https://img.shields.io/badge/Platform-Android-green?logo=android)](https://www.android.com)
[![GitHub Release](https://img.shields.io/badge/Release-v2.0.0-teal?logo=github)](https://github.com/hemanthkumar-del/FastCure/releases/tag/v2.0.0)

FastCure is a premium, feature-rich modern healthcare application designed to bridge the gap between patients, doctors, and clinics. Built on top of **Flutter** and **Firebase**, FastCure v2.0 introduces a state-of-the-art Material 3 design system, integrated clinical AI tools, secure Role-Based Access Control (RBAC), automatic session persistence, and real-time clinical document compiling (PDF prescription building and sharing).

---

## 🚀 Key Features

### 🔐 Authentication & Session Persistence
* **Firebase Authentication**: Integrated secure Email/Password registration and login.
* **Google Sign-In**: Single-tap authentication utilizing Google Sign-in API credentials.
* **Persistent Sessions**: Automated background token validation. Users remain logged in even after removing the application from recent tasks.
* **Email Verification**: Mandatory email verification filter block for patient profiles.

### 👥 Role-Based Access Control (RBAC)
* **Administrative Flow**: Shows clinic statistics cards (revenue summaries, registered patient lists, monthly earnings bar charts, and appointment status pie charts).
* **Patient Flow**: Restricts navigation access to standard widgets (wellness summaries, upcoming calendar reminders, and quick action cards).
* **Route Guards (`AdminGuard`)**: Protects administrative endpoints at the routing layer, displaying access-denied warnings and redirecting unauthorized requests.

### 🩺 Advanced AI Health Assistant
* **Smart Wellness Guide**: AI chatbot to explain prescriptions, search pill metadata, check symptoms, or suggest daily diets.
* **Triage Symptom Warning**: Pinned emergency alert banners if the assistant detects life-threatening indicators (such as chest pains, severe bleeding, or stroke signs).
* **Dictation Waves**: Audio waveforms visualizer showing bounced wave elements during voice dictation simulation.

### 📅 Booking & Doctor Directory
* **Horizontal Specialty Chips**: Horizontally scrollable chips for General Medicine, Cardiology, Neurology, Orthopedics, Pediatrics, and Dentistry.
* **Availability Badges**: Dynamically calculated tags showing `Available Today`, `Tomorrow`, or `Unavailable`.
* **Appointment Timelines**: Progress tracking flow in detail views.

### 📄 Clinical PDF Compilation & Share
* **A4 PDF Engine**: Compiles beautiful vector PDF prescription documents complete with clinic headers, patient metadata tables, and medicine instructions.
* **Offline Path Saver**: Writes generated documents directly into `Downloads/FastCure/` on the device.
* **Native Share Sheet**: Integrates native share wrappers to transmit PDFs via email, message, or other mobile clients.

---

## 🛠 Technology Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter / Dart | High-performance multi-platform UI engine |
| **Theme System** | Material 3 | Premium dark mode and light mode configuration |
| **Backend Database** | Cloud Firestore | Real-time database schemas for doctor directories and patients |
| **Authentication** | Firebase Auth / Google OAuth | Session persistence and social sign-in |
| **State Management** | Provider | Reactive data states and notification updates |
| **PDF Compiler** | `pdf` Package | Vector-graphic A4 prescription generators |
| **File Systems** | `path_provider` | Directory mapping for local device downloads |
| **Platform Share** | `share_plus` | Triggering native mobile share sheets |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/    # Theme colors, assets path, strings, and constants
│   ├── routes/       # Declarative router map and route constants
│   ├── services/     # Firebase services and AI backend integration
│   ├── theme/        # Material 3 light/dark color schemes
│   └── utils/        # Logger services
└── features/
    ├── ai/           # AI Health Assistant views, prompts, and providers
    ├── appointment/  # Scheduling grid, detail timelines, and bookings
    ├── auth/         # Login, registrations, wrappers, and provider
    ├── billing/      # Revenue billing trackers
    ├── dashboard/    # Admin and patient dashboard view adapters
    ├── doctor/       # Doctor specialization directory and admin management
    ├── medicine/     # Medicine inventory
    ├── notifications/# Notifications UI
    ├── patient/      # Patient directories
    ├── prescription/ # Prescription details, PDF writers, and list views
    ├── profile/      # User profile edit panels and sign-out logic
    └── settings/     # Admin configurations
```

---

## 📲 APK Installation Guide

### 📦 APK Download
You can download the production-signed Android package for FastCure v2.0 directly from our release page:
👉 **[Download FastCure v2.0.0 APK](https://github.com/hemanthkumar-del/FastCure/releases/download/v2.0.0/app-release.apk)**

* **APK Version**: `v2.0.0 (Release)`
* **File Size**: `58.2 MB` (61,021,516 bytes)
* **SHA-256 Checksum**: `F9D4B052DFB15146B3F8DC249DAFF940BC71B58D4C7E4EC2420DE065E5960490`

### ⚙️ Prerequisites & Setup
To run the project from source, ensure you have the following configured:
1. **Flutter SDK**: `^3.12.2`
2. **Java JDK**: `11` or higher
3. **Android Studio** (with Android SDK configuration)
4. A configured **Firebase Project** containing:
   * Firestore Database initialized in Native mode.
   * Email/Password and Google enabled under Sign-in Providers.
   * Downloaded `google-services.json` placed under `android/app/`.

### 🛠 Build from Source
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/hemanthkumar-del/FastCure.git
   cd FastCure
   ```
2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run Code Analyzer**:
   ```bash
   flutter analyze
   ```
4. **Compile Release APK**:
   ```bash
   flutter build apk --release
   ```

---

## 🔮 Future Improvements
* [ ] **Biometric Sign-In**: Integration of FaceID and fingerprint sensors for quick access.
* [ ] **Video Consultation**: Real-time WebRTC channels for video calls between doctors and patients.
* [ ] **Offline Mode Sync**: Local SQLite caching using `drift` for offline viewing of prescriptions.
* [ ] **Google Fit / Apple Health kit Integration**: Auto-importing step counts, sleep patterns, and vitals.

---

## 👤 Developer
* **Repository Owner**: [Hemanth Kumar](https://github.com/hemanthkumar-del)
* **Status**: Feature-Complete (v2.0 Production Release)

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
