@echo off
asm6f_64.exe main.asm rom.nes -l -q -m -c
if %ERRORLEVEL% NEQ 0 (
    echo Error building the ROM. Use the error messages above to fix the issues.
) else (
    echo Build successful. You can close this window.
)
pause