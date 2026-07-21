@echo off
setlocal

rem ============================================================
rem xclock display settings
rem ============================================================
set "WINDOW_WIDTH=200"
set "WINDOW_HEIGHT=200"
set "SHOW_SECONDS=0"

rem ============================================================
rem Google Chrome settings
rem ============================================================
set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
set "XCLOCK_PROFILE=%LOCALAPPDATA%\xclock-chrome-profile"

rem ============================================================
rem xclock file settings
rem ============================================================
set "XCLOCK_HTML=%~dp0index.html"

rem ============================================================
rem Internal processing
rem Normally, do not edit below this line
rem ============================================================
set "XCLOCK_QUERY="

if "%SHOW_SECONDS%"=="1" (
  set "XCLOCK_QUERY=?seconds=1"
)

if not exist "%CHROME%" (
  echo Google Chrome was not found:
  echo "%CHROME%"
  pause
  exit /b 1
)

if not exist "%XCLOCK_HTML%" (
  echo index.html was not found:
  echo "%XCLOCK_HTML%"
  pause
  exit /b 1
)

rem Convert the Windows path to an encoded file URL.
for /f "usebackq delims=" %%I in (`
  powershell.exe -NoProfile -Command ^
  "[System.Uri]::new((Get-Item -LiteralPath $env:XCLOCK_HTML).FullName).AbsoluteUri"
`) do set "XCLOCK_URL=%%I"

if not defined XCLOCK_URL (
  echo Failed to create the file URL:
  echo "%XCLOCK_HTML%"
  pause
  exit /b 1
)

start "" "%CHROME%" ^
  --user-data-dir="%XCLOCK_PROFILE%" ^
  --window-size=%WINDOW_WIDTH%,%WINDOW_HEIGHT% ^
  --app="%XCLOCK_URL%%XCLOCK_QUERY%"

endlocal
