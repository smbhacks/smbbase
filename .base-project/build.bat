@echo off
ca65 -g --cpu 6502X -l output.lst main.asm -o output.o
ld65 --dbgfile output.dbg -m map.txt -C main.cfg output.o -o output.nes
@del output.o
pause