# Changelog

All notable changes to this project will be documented in this file.

---

## [v1.0.0] - 2026-07-12

### Added
- **Core Engine Bootstrap**: Complete application shell with Firebase Core configuration, offline Firestore persistence caches, and FCM permissions.
- **Dynamic Onboarding Authentication**: Firebase Email/Password login, Sign Up validation forms, and direct Google Sign-In authentication.
- **Live Stream Dashboard**: Active metrics counters (Doctors, Patients, Appointments, Earnings) drawing dynamically from Firestore collection streams.
- **Collapsing Sliver Doctor Directories**: Detail views showing qualifications, fee settings, and specialty ChoiceChips selectors.
- **Demographics Patient Directories**: Medical history cards, blood group entries, and allergies wrap chips.
- **Datepicker Schedule Calendar**: Search schedules, choose time slots, and click instant Cancel/Approve/Reject buttons.
- **Pharmacy Stock Manager**: Product tables highlighting low-stock warning chips in red if quantity falls below 20.
- **Multiple Medication Prescription Wizard**: Drug item lists validation checking stock bounds, and transaction updates.
- **Clinics Billing Engine**: Invoices tracking doctor fees, medicine totals, lab tests, and payment method modals.
- **AI Symptom Chatbot Assistant**: Embedded Gemini 1.5 HTTP call client, offline symptom diagnostics fallback data, and message logs saved to SharedPreferences.
- **Release Packages**: Production signed APK compilation and optimized Android App Bundle formats.
