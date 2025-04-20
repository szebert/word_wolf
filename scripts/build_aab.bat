@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ---- Resolve project root --------------------------------------
REM %~dp0 is the folder of this .bat; go up one level
cd /d "%~dp0\.."

REM ---- Extract version from pubspec.yaml -------------------------
for /f "tokens=2 delims=: " %%A in ('findstr /b "version:" pubspec.yaml') do set "version=%%A"
REM Trim spaces (in case of "1.0.0+1 ")
set "version=%version: =%"

REM ---- Generate timestamp (YYYYMMDD_HHMM) using DATE and TIME variables ----
set "datestamp=%date:~10,4%%date:~4,2%%date:~7,2%"
set "timestamp=%time:~0,2%%time:~3,2%"
set "timestamp=%timestamp: =0%"
set "datetimestamp=%datestamp%_%timestamp%"

REM ---- Prepare output directory ----------------------------------
set "OUTDIR=%CD%\symbol-archives\android\%version%_%datetimestamp%"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM ---- Build AAB with obfuscation & split-debug-info -------------
echo [BUILD] Building Android AAB to: %OUTDIR%
flutter build appbundle --obfuscate --split-debug-info="%OUTDIR%"
echo [DEBUG] Flutter build complete, errorlevel=%errorlevel%

REM ---- Copy ProGuard/R8 mapping.txt ------------------------------
echo [DEBUG] About to check for mapping.txt
set "mappingSrc=%CD%\android\app\build\outputs\mapping\release\mapping.txt"
echo [DEBUG] Looking for mapping at: %mappingSrc%
if exist "%mappingSrc%" (
  echo [DEBUG] Found mapping file
  copy /y "%mappingSrc%" "%OUTDIR%\mapping.txt" >nul
  echo [OK] Copied mapping.txt
) else (
  echo [WARNING] mapping.txt not found at %mappingSrc%
)

echo [DONE] Android symbols + mapping saved to: %OUTDIR%
endlocal
