@echo off
title Sheekh Xuseen Cali Jabuuti - Mobile View
echo ========================================================
echo  Furitaanka Sheekh Xuseen Cali Jabuuti App - Mobile View
echo ========================================================

set APP_URL=http://127.0.0.1:8080/
set CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe

echo Hubinta server-ka 127.0.0.1:8080...
netstat -ano | findstr :8080 >nul
if errorlevel 1 (
    echo Server-ka ma shaqeynayo, hadda ayaa la bilaabayaa
    start "Sheekh App Server" /min node server.js
    timeout /t 2 /nobreak >nul
)

if exist "%CHROME_PATH%" (
    echo Furitaanka Chrome shaashadda mobilka...
    start "" "%CHROME_PATH%" --app="%APP_URL%" --window-size=412,892 --window-position=500,50
) else (
    echo Browser-ka caadiga ah ayaa lagu furayaa...
    start "" "%APP_URL%"
)

echo Hawshu waa guulaysatay!
