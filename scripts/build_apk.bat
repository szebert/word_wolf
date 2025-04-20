@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ─── Resolve project root ─────────────────────────────────────────────
REM %~dp0 is the folder of this .bat; go up one level
cd /d "%~dp0\.."

REM ─── Extract version from pubspec.yaml ────────────────────────────────
for /f "tokens=2 delims=: " %%A in ('findstr /b "version:" pubspec.yaml') do set "version=%%A"
REM Trim spaces (in case of "1.0.0+1 ")
set "version=%version: =%"

REM ─── Generate timestamp (YYYYMMDD_HHMM) ────────────────────────────────
for /f "skip=1 tokens=1" %%X in ('wmic os get LocalDateTime') do (
  set "ldt=%%X"
  goto :gotldt
)
:gotldt
set "timestamp=%ldt:~0,8%_%ldt:~8,4%"

REM ─── Prepare output directory ─────────────────────────────────────────
set "OUTDIR=%CD%\symbol-archives\android\%version%_%timestamp%"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM ─── Build APK with obfuscation & split‑debug‑info ─────────────────────
echo 🔨 Building Android APK → %OUTDIR%
flutter build apk --obfuscate --split-debug-info="%OUTDIR%"

REM ─── Copy ProGuard/R8 mapping.txt ────────────────────────────────────
set "mappingSrc=%CD%\android\app\build\outputs\mapping\release\mapping.txt"
if exist "%mappingSrc%" (
  copy /y "%mappingSrc%" "%OUTDIR%\mapping.txt" >nul
  echo ✅ Copied mapping.txt
) else (
  echo ⚠️ mapping.txt not found at %mappingSrc%
)

echo ✅ Android symbols + mapping saved to: %OUTDIR%
endlocal
