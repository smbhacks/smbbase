@echo off
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Couldn't find Python! Please install it from https://www.python.org/downloads/
    exit /b 1
)
python scripts/makecfg.py
ca65 -g --cpu 6502X main.asm -o output.o
ld65 --dbgfile build/output.dbg -m build/output.txt -C generatedCfg.cfg output.o -o build/output.nes
@del output.o
@del generatedCfg.cfg
echo If the build was successful, you will find your ROM in the 'build' folder.
pause