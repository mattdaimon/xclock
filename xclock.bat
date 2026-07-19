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
set "XCLOCK_URL_PATH=%XCLOCK_HTML:\=/%"

if "%SHOW_SECONDS%"=="1" (
  set "XCLOCK_QUERY=?seconds=1"
)

if not exist "%CHROME%" (
  echo Google Chrome was not found:
  echo %CHROME%
  pause
  exit /b 1
)

if not exist "%XCLOCK_HTML%" (
  echo index.html was not found:
  echo %XCLOCK_HTML%
  pause
  exit /b 1
)

start "" "%CHROME%" ^
  --user-data-dir="%XCLOCK_PROFILE%" ^
  --window-size=%WINDOW_WIDTH%,%WINDOW_HEIGHT% ^
  --app="file:///%XCLOCK_URL_PATH%%XCLOCK_QUERY%"

endlocal
