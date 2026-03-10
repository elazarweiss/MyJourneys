@echo off
setlocal enabledelayedexpansion
title MyJourneys — Setup and Run

echo.
echo ================================================
echo   MyJourneys — Flutter App Setup
echo ================================================
echo.

:: ---- Check if Flutter is already installed ----
where flutter >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Flutter found in PATH.
    goto :flutter_found
)

:: Check common install locations
if exist "C:\flutter\bin\flutter.bat" (
    echo [OK] Flutter found at C:\flutter
    set "PATH=C:\flutter\bin;%PATH%"
    goto :flutter_found
)
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    echo [OK] Flutter found at %USERPROFILE%\flutter
    set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
    goto :flutter_found
)
if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" (
    echo [OK] Flutter found at %LOCALAPPDATA%\flutter
    set "PATH=%LOCALAPPDATA%\flutter\bin;%PATH%"
    goto :flutter_found
)

:: ---- Flutter not found — download it ----
echo [!] Flutter not found. Downloading Flutter SDK...
echo     This will take a few minutes (about 1 GB download).
echo.

set FLUTTER_ZIP=%TEMP%\flutter_windows.zip
set FLUTTER_DIR=C:\flutter

echo Downloading from storage.googleapis.com...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.4-stable.zip' -OutFile '%FLUTTER_ZIP%' -UseBasicParsing}"

if not exist "%FLUTTER_ZIP%" (
    echo.
    echo [ERROR] Download failed. Please install Flutter manually:
    echo   1. Go to https://docs.flutter.dev/get-started/install/windows/web
    echo   2. Download the Flutter SDK
    echo   3. Extract to C:\flutter
    echo   4. Run this script again
    pause
    exit /b 1
)

echo Extracting Flutter SDK to C:\flutter ...
powershell -Command "Expand-Archive -Path '%FLUTTER_ZIP%' -DestinationPath 'C:\' -Force"
del "%FLUTTER_ZIP%"

if not exist "C:\flutter\bin\flutter.bat" (
    echo [ERROR] Extraction failed.
    pause
    exit /b 1
)

set "PATH=C:\flutter\bin;%PATH%"
echo [OK] Flutter installed to C:\flutter

:flutter_found

echo.
echo ---- Flutter version ----
flutter --version
echo.

:: ---- Create platform scaffolding ----
echo ---- Creating Flutter project scaffolding ----
flutter create . --project-name my_journeys --org com.myjourneysapp --platforms web,android,ios 2>&1
echo.

:: ---- Enable web ----
echo ---- Enabling web support ----
flutter config --enable-web
echo.

:: ---- Get packages ----
echo ---- Installing packages ----
flutter pub get
echo.

:: ---- Check doctor ----
echo ---- Flutter doctor ----
flutter doctor
echo.

:: ---- Run in Chrome ----
echo ================================================
echo   Launching app in Chrome...
echo   (Press Ctrl+C in this window to stop)
echo ================================================
echo.
flutter run -d chrome

pause
