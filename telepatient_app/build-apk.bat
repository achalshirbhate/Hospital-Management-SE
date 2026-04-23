@echo off
echo ========================================
echo  TelePatient Mobile App - APK Builder
echo ========================================
echo.

echo [1/4] Cleaning previous builds...
call flutter clean
echo.

echo [2/4] Getting dependencies...
call flutter pub get
echo.

echo [3/4] Building APK (this may take 3-5 minutes)...
call flutter build apk --release
echo.

echo [4/4] Build complete!
echo.

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ========================================
    echo  SUCCESS! APK Built Successfully
    echo ========================================
    echo.
    echo APK Location:
    echo %CD%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Opening folder...
    explorer build\app\outputs\flutter-apk
    echo.
    echo You can now:
    echo 1. Copy app-release.apk to your Android phone
    echo 2. Install it on your device
    echo 3. Test the app!
    echo.
) else (
    echo ========================================
    echo  BUILD FAILED
    echo ========================================
    echo Please check the error messages above.
    echo.
)

pause
