@echo off

echo Attempting to overwrite ad files...
setlocal
for /r "." %%F in (details.html) do (
  if exist "%%~fF" (
    copy /y "%~dp0adbreak.html" "%%~fF" >nul
  )
)
endlocal

if %ERRORLEVEL% EQU 0 (
    echo Adbreak injected correctly! Eject the device and tap on any ad.
) else (
    echo Probably failed to inject Adbreak [%ERRORLEVEL%]
)

echo.
echo Press any key to exit...
pause >nul
