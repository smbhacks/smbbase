If you want to use Famitone instead of the original SMB music engine, open up main.asm,
put a semicolon (;) before CustomMusicDriver EQU OriginalSMBMusic
and remove the semicolon before CustomMusicDriver EQU Famitone5Music
Read further instructions after this in the Famitone folder -> !README.txt

Before you can start building your rom, you need to make an output.asm in the levels folder.
If you want to use the original levels, then rename vanilla.asm to output.asm
If you want to use levels from another ROM, then read the readme in the levels folder.