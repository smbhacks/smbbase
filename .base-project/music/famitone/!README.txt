This folder will only be useful for you if you
have Famitone defined (enabled) in code/settings.asm!

When making songs in Famitracker, don't use ROWS = 256. text2data 
(or any variation) won't work right, and will only output empty songs.

To update ingame music, export music.ftm as text in Famitracker (File->Export TXT...) and then execute UPDATE MUSIC.bat
Same thing with SFX, except you have to export as NSF. (File->Create NSF...)

LIMITATIONS FOR FAMITONE 5 MUSIC: (pasted from nesdev.org)

Full note range
Instrument: volume, arpeggio, and pitch envelopes. Pitch limited to accumulated distance of 63 units in each direction. No release phase.
Effects: Fxx, Dxx, Bxx, 1xx, 2xx, 3xx, 4xx, Qxx, Rxx
DPCM for instrument 0 only (Not supported by this base as of right now)
Limit of 64 instruments, 17 songs, and 16 KiB of DPCM