This folder will only be useful for you if you
have Famistudio defined (enabled) in code/settings.asm!

By default, the tempo mode is 'Famistudio'.
Make sure your music file uses the 'Famistudio' tempo mode.
If you wish to use the 'Famitracker' tempo mode, 
edit 'FAMISTUDIO_USE_FAMITRACKER_TEMPO' in settings.asm

To update ingame music, open your music.fms music file in Famistudio
and export your music as 'Famistudio Music Code'. Make sure you've
set the format to ca65 and included all of your songs.
To update SFX, you do the same with sfx.fms, except you export
as 'Famistudio SFX Coded'.

The music driver features and limitations can be configured
in settings.asm. Do note that enabling more features might
make your game laggier!