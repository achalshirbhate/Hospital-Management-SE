# 📱 Update API URL for Phone

## ⚠️ IMPORTANT: Before Installing on Phone

The app currently points to `localhost` which won't work on a real phone. You need to update it to your computer's IP address.

---

## 🔍 Step 1: Find Your Computer's IP Address

### On Windows:
```bash
ipconfig
```

Look for **IPv4 Address** under your WiFi adapter. Example: `192.168.1.100`

### On Mac/Linux:
```bash
ifconfig
```

Look for **inet** under your WiFi adapter. Example: `192.168.1.100`

---

## ✏️ Step 2: Update API Constants

1. Open file: `tele_patient_app/lib/core/constants/api_constants.dart`

2. Find this code:
```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:8081/api';
  static const String wsUrl = 'ws://localhost:8081/ws';
}
```

3. Replace with your computer's IP:
```dart
class ApiConstants {
  // Replace 192.168.1.100 with YOUR computer's IP
  static const String baseUrl = 'http://192.168.1.100:8081/api';
  static const String wsUrl = 'ws://192.168.1.100:8081/ws';
}
```

---

## 🔧 Step 3: Rebuild APK

After updating the IP address:

```bash
cd tele_patient_app
flutter build apk --release
```

---

## 📡 Step 4: Ensure Network Connectivity

### Requirements:
- ✅ Phone and computer on **same WiFi network**
- ✅ Backend server running on computer
- ✅ Firewall allows port 8081

### Test Backend Access:
On your phone's browser, visit:
```
http://YOUR_COMPUTER_IP:8081/api/auth/login
```

You should see a response (even if it's an error - that's OK, it means the server is reachable).

---

## 🚀 Quick Update Script

I'll create the updated file for you. Just tell me your computer's IP address!

**Example IPs:**
- Home WiFi: Usually `192.168.1.x` or `192.168.0.x`
- Office WiFi: Varies
- Mobile Hotspot: Usually `192.168.43.x`

---

## 🔥 Firewall Configuration (If Needed)

### Windows Firewall:
1. Open Windows Defender Firewall
2. Click "Advanced settings"
3. Click "Inbound Rules" → "New Rule"
4. Select "Port" → Next
5. Enter port `8081` → Next
6. Allow the connection → Next
7. Apply to all profiles → Next
8. Name it "TelePatient Backend" → Finish

### Quick Command (Windows):
```bash
netsh advfirewall firewall add rule name="TelePatient Backend" dir=in action=allow protocol=TCP localport=8081
```

---

## ✅ Verification Checklist

Before using app on phone:
- [ ] Found computer's IP address
- [ ] Updated api_constants.dart with IP
- [ ] Rebuilt APK
- [ ] Phone and computer on same WiFi
- [ ] Backend server is running
- [ ] Firewall allows port 8081
- [ ] Tested backend URL in phone browser

---

## 🎯 Complete Example

**Your Computer IP:** `192.168.1.105`

**Update api_constants.dart:**
```dart
class ApiConstants {
  static const String baseUrl = 'http://192.168.1.105:8081/api';
  static const String wsUrl = 'ws://192.168.1.105:8081/ws';
}
```

**Test in phone browser:**
```
http://192.168.1.105:8081/api/auth/login
```

**Rebuild:**
```bash
cd tele_patient_app
flutter build apk --release
```

**Install on phone and enjoy!** 🎉

---

*Need help? Check BUILD_APK_GUIDE.md for more details.*
