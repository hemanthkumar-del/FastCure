# FastCure Build & Deployment Guidelines

This document outlines the processes to build, package, and release FastCure on Android.

---

## 🛠️ Production Build Instructions

Before building the production bundle, ensure the Flutter local development environment is synced:

```bash
# 1. Fetch package dependencies
flutter pub get

# 2. Run static analyzer validation
flutter analyze

# 3. Execute unit tests
flutter test
```

### 1. Build Standalone APK
Generates a signed, self-contained installation package (`.apk`):
```bash
flutter build apk --release
```
*   **Path**: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Android App Bundle (AAB)
Generates the Play Store optimized publishing format (`.aab`):
```bash
flutter build appbundle
```
*   **Path**: `build/app/outputs/bundle/release/app-release.aab`

---

## ⚙️ Proguard / R8 Shrinking & Minification

FastCure is configured with automated resource shrinking and code minification during release compiling. If custom configurations are needed, append configurations directly into:
*   `android/app/proguard-rules.pro`

```proguard
# Keep Firebase structures
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
```

---

## 🔑 Release Key Signing Configurations

For Google Play store deployment, replace key configurations inside `android/key.properties`:

```properties
storePassword=yourstorepassword
keyPassword=yourkeypassword
keyAlias=upload
storeFile=C:/Users/DELL/upload-keystore.jks
```
These properties are automatically parsed during the `bundleRelease` and `assembleRelease` Gradle tasks.
