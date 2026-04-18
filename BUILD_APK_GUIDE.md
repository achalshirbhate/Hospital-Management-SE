# 📱 Build APK Guide for TelePatient App

## 🎯 Quick Build Instructions

### Option 1: Build Release APK (Recommended for Phone)
```bash
cd tele_patient_app
flutter clean
flutter pub get
flutter build apk --release
```

**APK Location:** `tele_patient_app/build/app/outputs/flutter-apk/app-release.apk`

### Option 2: Build Debug APK (Faster, Larger Size)
```bash
cd tele_patient_app
flutter clean
flutter pub get
flutter build apk --debug
```

**APK Location:** `tele_patient_app/build/app/outputs/flutter-apk/app-debug.apk`

### Option 3: Build Split APKs (Smaller Size)
```bash
cd tele_patient_app
flutter build apk --split-per-abi
```

**APK Locations:**
- `app-armeabi-v7a-release.apk` (32-bit ARM - Most phones)
- `app-arm64-v8a-release.apk` (64-bit ARM - Modern phones)
- `app-x86_64-release.apk` (Intel processors)

---

## 📋 Prerequisites

### 1. Check Flutter Installation
```bash
flutter doctor
```

**Required:**
- ✅ Flutter SDK installed
- ✅ Android toolchain installed
- ✅ Android SDK installed

### 2. Check Android SDK
```bash
flutter doctor --android-licenses
```

Accept all licenses if prompted.

---

## 🔧 Troubleshooting

### Issue: "Build failed with network error"
**Solution:** Check your internet connection and retry:
```bash
flutter clean
flutter pub get --verbose
flutter build apk --release
```

### Issue: "Gradle build failed"
**Solution:** Clear Gradle cache:
```bash
cd tele_patient_app/android
./gradlew clean
cd ..
flutter build apk --release
```

### Issue: "NDK not found"
**Solution:** Flutter will auto-download NDK. Wait for it to complete.

### Issue: "Build takes too long"
**Solution:** Build debug APK instead (faster):
```bash
flutter build apk --debug
```

---

## 📲 Install APK on Phone

### Method 1: USB Cable
1. Enable **Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   
2. Enable **USB Debugging**:
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

3. Connect phone to computer via USB

4. Install APK:
```bash
cd tele_patient_app
flutter install
```

### Method 2: Transfer APK File
1. Build the APK (see above)
2. Copy APK from `build/app/outputs/flutter-apk/app-release.apk`
3. Transfer to phone via:
   - USB cable (copy to phone storage)
   - Email (send to yourself)
   - Cloud storage (Google Drive, Dropbox)
   - Bluetooth
   - WhatsApp (send to yourself)

4. On phone:
   - Open file manager
   - Find the APK file
   - Tap to install
   - Allow "Install from Unknown Sources" if prompted

### Method 3: Direct Install (Phone Connected)
```bash
cd tele_patient_app
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚙️ Build Configuration

### Current Configuration
- **App Name:** Tele Patient
- **Package:** com.telepatient.app
- **Min SDK:** 21 (Android 5.0+)
- **Target SDK:** Latest
- **Version:** 1.0.0

### Permissions Included
- ✅ Internet (API calls)
- ✅ Camera (Video calls)
- ✅ Microphone (Audio calls)
- ✅ Storage (Upload/Download files)

---

## 📊 APK Size Comparison

| Build Type | Size | Use Case |
|------------|------|----------|
| Release APK | ~50-80 MB | Production, sharing |
| Debug APK | ~80-120 MB | Testing only |
| Split APK (arm64) | ~30-40 MB | Specific device |

---

## 🚀 Build Commands Reference

### Clean Build
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Build with Verbose Output
```bash
flutter build apk --release --verbose
```

### Build for Specific Architecture
```bash
# For most modern phones (64-bit ARM)
flutter build apk --target-platform android-arm64

# For older phones (32-bit ARM)
flutter build apk --target-platform android-arm
```

### Build App Bundle (For Play Store)
```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## 📝 Important Notes

### ⚠️ Backend Configuration
The app is configured to connect to:
- **Backend URL:** `http://10.0.2.2:8081/api` (Android Emulator)
- **Backend URL:** `http://localhost:8081/api` (Web)

**For Real Phone:** You need to update the API URL in the app:

1. Open `tele_patient_app/lib/core/constants/api_constants.dart`

2. Change the base URL to your computer's IP address:
```dart
class ApiConstants {
  // Replace with your computer's IP address
  static const String baseUrl = 'http://192.168.1.100:8081/api';
  static const String wsUrl = 'ws://192.168.1.100:8081/ws';
}
```

3. Find your computer's IP:
   - **Windows:** `ipconfig` (look for IPv4 Address)
   - **Mac/Linux:** `ifconfig` (look for inet)

4. Rebuild the APK after changing the URL

### 🔒 Security Notes
- Debug APKs are signed with debug keys (not for production)
- Release APKs are signed with debug keys (for testing)
- For Play Store, you need to create a proper signing key

---

## 🎯 Quick Start After Install

1. **Start Backend Server:**
```bash
cd auth-service
mvn spring-boot:run
```

2. **Ensure phone and computer are on same WiFi network**

3. **Update API URL in app** (see above)

4. **Install APK on phone**

5. **Open app and login:**
   - MD: `md@test.com`
   - Doctor: `doctor@test.com`
   - Patient: `patient@test.com`

---

## 📞 Need Help?

### Check Build Status
```bash
flutter doctor -v
```

### Check Connected Devices
```bash
flutter devices
```

### Check APK Info
```bash
cd tele_patient_app/build/app/outputs/flutter-apk
ls -lh *.apk
```

---

## ✅ Build Checklist

Before building APK:
- [ ] Backend server is working
- [ ] Flutter doctor shows no errors
- [ ] Android toolchain is installed
- [ ] Internet connection is stable
- [ ] Updated API URL for phone (if needed)

After building APK:
- [ ] APK file exists in build folder
- [ ] APK size is reasonable (50-120 MB)
- [ ] Transfer APK to phone
- [ ] Install on phone
- [ ] Test login and features

---

## 🎉 Success!

Once built, you'll have:
- ✅ Installable APK file
- ✅ Works on Android 5.0+ devices
- ✅ All features included
- ✅ Ready to use on your phone

---

*Last Updated: April 18, 2026*
*Build Status: Ready to Build*
*Network Issue: Temporary - Retry when stable*
