@echo off
setlocal enabledelayedexpansion

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Couldn't find Python! Please install it from https://www.python.org/downloads/
    exit /b 1
)

set "engine="
::get level engine from settings.asm
for /f "usebackq tokens=1,2 delims==" %%a in ("code/settings.asm") do (
    if "%%a"=="LevelEngine " (
        set "engine=%%b"
    )
)
::remove spaces
set "engine=%engine: =%"
if /i "%engine%"=="OriginalLevelEngine" (
    echo Original level engine chosen. 
    python scripts/makecfg.py "code/levels/original_engine/asm_files/segments.asm"
) else if /i "%engine%"=="TiledLevelEngine" (
    echo Tiled level engine chosen. 
    python scripts/convert_tiled_levels.py
    python scripts/makecfg.py "code/levels/tiled_engine/asm_files/generated/segments.asm"
) else (
    echo Unknown level engine setting. Please fix code/settings.asm
    pause
    exit
)

ca65 -g --cpu 6502X main.asm -o output.o
ld65 --dbgfile build/output.dbg -m build/output.txt -C generatedCfg.cfg output.o -o build/output.nes
@del output.o
echo If the build was successful, you will find your ROM in the 'build' folder.
pause