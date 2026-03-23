@echo off
setlocal EnableDelayedExpansion
rem Always search from this script's folder. "Run as administrator" and some
rem launch methods leave the current directory as System32, so for /r "."
rem would find nothing and fail silently.
set "_root=%~dp0"
set /a _count=0
for /r "%_root%" %%F in (details.html) do (
  if exist "%%~fF" (
    copy /y "%_root%adbreak.html" "%%~fF" >nul
    if not errorlevel 1 (
      set /a _count+=1
      echo Replaced: %%~fF
    )
  )
)
if !_count! equ 0 (
  echo No details.html files found under:
  echo   %_root%
  echo Put replace.bat next to adbreak.html inside your copied .assets tree, then run again.
) else (
  echo.
  echo Done. Replaced !_count! file^(s^).
)
endlocal