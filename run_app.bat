@echo off
title MyJourneys — Running

:: Add Flutter to PATH if needed
if not exist "C:\flutter\bin\flutter.bat" (
    echo [ERROR] Flutter not found at C:\flutter
    echo Please run setup_and_run.bat first.
    pause
    exit /b 1
)
set "PATH=C:\flutter\bin;%PATH%"

echo.
echo ================================================
echo   Starting MyJourneys in Chrome...
echo   Keep this window open while using the app.
echo   Press Ctrl+C to stop.
echo ================================================
echo.

cd /d "%~dp0"
flutter run -d chrome --web-port 8080

pause
