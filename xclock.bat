@echo off
setlocal

set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
set "XCLOCK_PROFILE=%LOCALAPPDATA%\xclock-chrome-profile"
set "XCLOCK_HTML=%~dp0index.html"

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
  --window-size=200,200 ^
  --app="file:///%XCLOCK_HTML:\=/%"

endlocal
