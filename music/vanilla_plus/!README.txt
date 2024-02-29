The importer's repository: https://github.com/smbhacks/smb1musicimport/
To import your songs, export a txt from the music.ftm file with
Famitracker or Famistudio. 

Here are the constraints:
	- You can see your note range in the pitch_table.asm file. You can edit this file if you wish
	  to alter the pitch table and the importer will automatically adjust to it. Do note that at the moment
	  changing pitch values here might mess with the SFX (todo: make it not)
	- D00 or Bxx effects can be used on the SQ2 channel
	- No volume coloumn
	- Tempo must be 150, Speed must be below 8 (using Speed 1 is possible but not recommended)
	- You mustn't modify the first 5 instruments
	- Square instruments can only have volume and duty envelopes (No looping or release phase)
	- Do not change the order of the songs!
	- You can use the I14 sweep effect on SQ1, but you can't turn it off: It will automatically turn off at the start of the next pattern
	- SQ1 and SQ2 don't support "nothing notes" (only cut-off notes) and every pattern must start with a note
		-> Side-effect: If you start a square pattern without a note, the importer will automatically start it with a cut-off note
		-> Side-effect: Sometimes your note could get cut-off unexpectedly: to prevent this, you can make the Speed value higher