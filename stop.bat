@echo off
echo ========================================
echo   Tele Patient System - Stopping...
echo ========================================
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8081" ^| findstr "LISTENING"') do (
    echo Killing process on port 8081 (PID: %%a)
    taskkill /PID %%a /F
)
echo Done.
pause
