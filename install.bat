@echo off
rem Staves installer for HorizonXI. Runs install.ps1 from next to this file
rem when it is there (the zip), otherwise fetches the latest from the repo.
setlocal
set "HERE=%~dp0"
if exist "%HERE%install.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%install.ps1" %*
    echo.
    pause
    exit /b
)
set "PS=%TEMP%\staves-install.ps1"
echo.
echo   Fetching the Staves installer...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/lost-rabbit/luashitacast-profiles/main/install.ps1' -OutFile '%PS%'"
if errorlevel 1 (
    echo   Could not download the installer. Check your connection and try again.
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS%" %*
del "%PS%" >nul 2>&1
echo.
pause
