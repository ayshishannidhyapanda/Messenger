@echo off
title Messenger Server + ngrok
echo ============================================
echo    Messenger - Start Server + ngrok Tunnel
echo ============================================
echo.

echo [1/2] Starting Spring Boot server...
start "Messenger Backend" cmd /c "cd /d %~dp0 && gradlew.bat bootRun"

echo Waiting 15 seconds for server to start...
timeout /t 15 /nobreak >nul

echo.
echo [2/2] Starting ngrok tunnel on port 8080...
echo.
echo ============================================
echo   Share the ngrok URL with other users!
echo   They enter it in the app Settings screen.
echo ============================================
echo.

ngrok http 8080
