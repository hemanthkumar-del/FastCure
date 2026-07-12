# FastCure - Clinical Operations & AI Health Assistant

FastCure is a modern, responsive, production-ready healthcare management application built with **Flutter (Material 3)** and **Firebase (Firestore & Storage)**. It integrates automated patient workflows, pharmacy stock management, clinical invoicing, scheduling engines, and an intelligent **AI symptom checker & drug advisory chatbot** powered by Google Gemini.

---

## 🚀 Key Modules & Features

1. **Authentication Suite**: Dynamic onboarding with Email/Password and Google Sign-In, profile validation, forgot password flow, and automatic login caching.
2. **Dashboard Analytics**: M3 landing panel displaying statistics (Total Doctors, Registered Patients, Today's Appointments, Net Earnings) loaded via live Firestore streams. Includes custom painted circular pie charts and monthly financial bar charts.
3. **Doctor Directory**: Manage doctor listings with consulting fields, qualifications, fee setups, specialty filters, and profile photo uploads to Firebase Storage.
4. **Patient Directory**: Comprehensive patient profile management, covering demographics, age, address, blood group, allergies wrap, and medical history.
5. **Appointment Scheduling**: Form scheduler matching live doctor/patient profiles. Features calendar date filters, booking time slot chips, and instant Doctor approval/rejection actions.
6. **Pharmacy Inventory**: Live inventory dashboard showing stock counts, warning alerts (stock <= 20) in red, and search features.
7. **Medication Prescriptions**: Issuing panel supporting multiple medicine additions, automatic quantity bounds checks, and mock PDF invoice printing actions.
8. **Clinical Invoicing & Billing**: Cost breakdown tables (doctor fees, medicine fees, lab tests), automatic totals calculation, payment method selectors (Cash, Card, UPI, Insurance), and status paid toggle.
9. **AI Health Assistant**: Empathetic conversational clinical assistant utilizing direct Gemini 1.5 HTTP API queries. Falls back to a local rules symptom-checker and medicine reference book when offline or key is unconfigured. Saves histories to SharedPreferences.

---

## 📂 Project Directory Structure & Architecture

FastCure implements a Clean Architectural style separating core services, configurations, and feature domains:

```text
lib/
├── core/
│   ├── constants/       # AppColors, AppStrings, AppConstants definitions
│   ├── routes/          # AppRouter, AppRoutes configurations
│   ├── services/        # FirebaseService, AIService (Gemini endpoints)
│   ├── theme/           # AppTheme Light/Dark modes
│   └── utils/           # Logger utilities
└── features/
    ├── ai/              # ChatMessage model, ChatProvider, Chat bubble views
    ├── appointment/     # Book appointment form, list calendars
    ├── auth/            # AuthRepository, AuthProvider, Login/Register screens
    ├── billing/         # BillModel, BillProvider, Invoices details tables
    ├── dashboard/       # Stat cards, PieChart, BarChart dashboard
    ├── doctor/          # Doctor list and details collapsing silver app bars
    ├── medicine/        # Pharmacy inventory tables and item edit forms
    ├── patient/         # Demographics profiles, allergies wrap, CRUD repo
    ├── prescription/    # Issuing prescriptions, drug items table
    ├── profile/         # Settings profile screen
    ├── settings/        # Mode selectors
    └── splash/          # Splash animation entry
```

---

## 🏛️ Core API Data Schemas

### 1. Doctor Model (`doctors` collection)
*   `doctorId`: String (Unique document ID)
*   `fullName`: String
*   `email`: String
*   `phoneNumber`: String
*   `specialization`: String
*   `qualification`: String
*   `experience`: Integer (years)
*   `consultationFee`: Double
*   `hospitalName`: String
*   `department`: String
*   `bio`: String
*   `profileImage`: String (Firebase Storage URL)
*   `availableDays`: List<String>
*   `availableTimeSlots`: List<String>
*   `status`: String (Active/Inactive)

### 2. Patient Model (`patients` collection)
*   `patientId`: String
*   `fullName`: String
*   `email`: String
*   `phone`: String
*   `gender`: String
*   `dob`: DateTime
*   `bloodGroup`: String
*   `address`: String
*   `medicalHistory`: List<String>
*   `allergies`: List<String>
*   `profileImage`: String

### 3. Appointment Model (`appointments` collection)
*   `appointmentId`: String
*   `doctorId`: String
*   `patientId`: String
*   `date`: DateTime (Timestamp)
*   `time`: String (time slot)
*   `status`: String (Pending / Approved / Cancelled / Rejected)
*   `reason`: String
*   `notes`: String
*   `createdAt`: DateTime

### 4. Bill Model (`bills` collection)
*   `billId`: String
*   `patientId`: String
*   `appointmentId`: String
*   `doctorFee`: Double
*   `medicineFee`: Double
*   `labFee`: Double
*   `total`: Double (Sum of doctorFee + medicineFee + labFee)
*   `paymentMethod`: String (Cash / Card / UPI / Insurance)
*   `status`: String (Pending / Paid)
*   `createdAt`: DateTime

---

## ⚙️ Running & Building

### 1. Prerequisites
*   Flutter SDK (^3.44.4-stable)
*   Java JDK 17
*   Android SDK

### 2. Running in Debug Mode
To run the debug application on an emulator or connected device:
```bash
flutter run
```

### 3. Running Unit Tests
To run unit test suites:
```bash
flutter test
```

### 4. Compiling Production APK
Generates a signed standalone release APK:
```bash
flutter build apk --release
```
Output path: `build/app/outputs/flutter-apk/app-release.apk`

### 5. Compiling Android App Bundle (AAB)
Generates the final optimized release App Bundle ready for Google Play Store upload:
```bash
flutter build appbundle
```
Output path: `build/app/outputs/bundle/release/app-release.aab`
