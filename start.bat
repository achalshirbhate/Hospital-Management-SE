@echo off
echo ========================================
echo   Tele Patient System - Starting...
echo ========================================
cd /d "%~dp0auth-service"
call mvn clean spring-boot:run
pause
