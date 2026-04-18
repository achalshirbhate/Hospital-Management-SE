@echo off
echo ========================================
echo  TelePatient APK Builder
echo ========================================
echo.

cd tele_patient_app

echo [1/4] Cleaning previous build...
call flutter clean
echo.

echo [2/4] Getting dependencies...
call flutter pub get
echo.

echo [3/4] Building Release APK...
echo This may take 5-10 minutes...
call flutter build apk --release
echo.

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo [4/4] SUCCESS! APK built successfully!
    echo.
    echo ========================================
    echo  APK Location:
    echo  %CD%\build\app\outputs\flutter-apk\app-release.apk
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Copy the APK file to your phone
    echo 2. Install it on your phone
    echo 3. Make sure backend server is running
    echo 4. Update API URL if needed (see BUILD_APK_GUIDE.md)
    echo.
    explorer build\app\outputs\flutter-apk
) else (
    echo [4/4] FAILED! APK build failed.
    echo.
    echo Please check the error messages above.
    echo See BUILD_APK_GUIDE.md for troubleshooting.
)

echo.
pause
