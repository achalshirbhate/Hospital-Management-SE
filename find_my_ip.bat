@echo off
echo ========================================
echo  Finding Your Computer's IP Address
echo ========================================
echo.

echo Your IP Addresses:
echo.
ipconfig | findstr /i "IPv4"

echo.
echo ========================================
echo  Instructions:
echo ========================================
echo.
echo 1. Look for "IPv4 Address" above
echo 2. Find the one that looks like: 192.168.x.x
echo 3. Copy that IP address
echo 4. Update tele_patient_app/lib/core/constants/api_constants.dart
echo 5. Replace "localhost" with your IP address
echo 6. Rebuild the APK
echo.
echo See UPDATE_API_FOR_PHONE.md for detailed instructions.
echo.
pause
