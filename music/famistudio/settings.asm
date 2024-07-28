
;======================================================================================================================
; 1) SUPPORTED FEATURES CONFIGURATION
;
; Every feature supported in FamiStudio is supported by this sound engine. If you know for sure that you are not using
; specific features in your music, you can disable them to save memory/processing time. Using a feature in your song
; and failing to enable it will likely lead to crashes (BRK), or undefined behavior. They all have the form
; FAMISTUDIO_USE_XXX.
;======================================================================================================================

; Must be enabled if the songs you will be importing have been created using FamiTracker tempo mode. If you are using
; FamiStudio tempo mode, this must be undefined. You cannot mix and match tempo modes, the engine can only run in one
; mode or the other. 
; More information at: https://famistudio.org/doc/song/#tempo-modes
; FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1

; Must be enabled if the songs uses delayed notes or delayed cuts. This is obviously only available when using
; FamiTracker tempo mode as FamiStudio tempo mode does not need this.
; FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS = 1

; Must be enabled if the songs uses release notes. 
; More information at: https://famistudio.org/doc/pianoroll/#release-point
FAMISTUDIO_USE_RELEASE_NOTES = 1

; Must be enabled if any song uses the volume track. The volume track allows manipulating the volume at the track level
; independently from instruments.
; More information at: https://famistudio.org/doc/pianoroll/#editing-volume-tracks-effects
FAMISTUDIO_USE_VOLUME_TRACK      = 1

; Must be enabled if any song uses slides on the volume track. Volume track must be enabled too.
; More information at: https://famistudio.org/doc/pianoroll/#editing-volume-tracks-effects
; FAMISTUDIO_USE_VOLUME_SLIDES     = 1

; Must be enabled if any song uses the pitch track. The pitch track allows manipulating the pitch at the track level
; independently from instruments.
; More information at: https://famistudio.org/doc/pianoroll/#pitch
FAMISTUDIO_USE_PITCH_TRACK       = 1

; Must be enabled if any song uses slide notes. Slide notes allows portamento and slide effects.
; More information at: https://famistudio.org/doc/pianoroll/#slide-notes
FAMISTUDIO_USE_SLIDE_NOTES       = 1

; Must be enabled if any song uses slide notes on the noise channel too. 
; More information at: https://famistudio.org/doc/pianoroll/#slide-notes
; FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 1

; Must be enabled if any song uses the vibrato speed/depth effect track. 
; More information at: https://famistudio.org/doc/pianoroll/#vibrato-depth-speed
FAMISTUDIO_USE_VIBRATO           = 1

; Must be enabled if any song uses arpeggios (not to be confused with instrument arpeggio envelopes, those are always
; supported).
; More information at: (TODO)
FAMISTUDIO_USE_ARPEGGIO          = 1

; Must be enabled if any song uses the "Duty Cycle" effect (equivalent of FamiTracker Vxx, also called "Timbre").  
; FAMISTUDIO_USE_DUTYCYCLE_EFFECT  = 1

; Must be enabled if any song uses the DPCM delta counter. Only makes sense if DPCM samples
; are enabled (FAMISTUDIO_CFG_DPCM_SUPPORT).
; More information at: (TODO)
; FAMISTUDIO_USE_DELTA_COUNTER     = 1

; Must be enabled if your project uses more than 1 bank of DPCM samples.
; When using this, you must implement the "famistudio_dpcm_bank_callback" callback 
; and switch to the correct bank every time a sample is played.
; FAMISTUDIO_USE_DPCM_BANKSWITCHING = 1

; Must be enabled if your project uses more than 63 unique DPCM mappings (a mapping is DPCM sample
; assigned to a note, with a specific pitch/loop, etc.). Implied when using FAMISTUDIO_USE_DPCM_BANKSWITCHING.
; FAMISTUDIO_USE_DPCM_EXTENDED_RANGE = 1

; Allows having up to 256 instrument at the cost of slightly higher CPU usage when switching instrument.
; When this is off, the limit is 64 for regular instruments and 32 for expansion instrumnets.
; FAMISTUDIO_USE_INSTRUMENT_EXTENDED_RANGE = 1

; Must be enabled if your project uses the "Phase Reset" effect.
; FAMISTUDIO_USE_PHASE_RESET = 1

; Must be enabled if your project uses the FDS expansion and at least one instrument with FDS Auto-Mod enabled.
; FAMISTUDIO_USE_FDS_AUTOMOD  = 1


;======================================================================================================================
; 2) GLOBAL ENGINE CONFIGURATION
;
; These are parameters that configures the engine, but are independent of the data you will be importing, such as
; which platform (PAL/NTSC) you want to support playback for, whether SFX are enabled or not, etc. They all have the
; form FAMISTUDIO_CFG_XXX.
;======================================================================================================================

; One of these MUST be defined (PAL or NTSC playback). Note that only NTSC support is supported when using any of the audio expansions.
; FAMISTUDIO_CFG_PAL_SUPPORT   = 1
FAMISTUDIO_CFG_NTSC_SUPPORT  = 1

; Support for sound effects playback + number of SFX that can play at once.
FAMISTUDIO_CFG_SFX_SUPPORT   = 1 
FAMISTUDIO_CFG_SFX_STREAMS   = 4

; Blaarg's smooth vibrato technique. Eliminates phase resets ("pops") on square channels. 
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1 

; Enables DPCM playback support.
;FAMISTUDIO_CFG_DPCM_SUPPORT   = 1

; Must be enabled if you are calling sound effects from a different thread than the sound engine update.
; FAMISTUDIO_CFG_THREAD         = 1     

; Enable to use the CC65 compatible entrypoints via the provided header file
; FAMISTUDIO_CFG_C_BINDINGS   = 1

;======================================================================================================================
; 3) AUDIO EXPANSION CONFIGURATION
;
; (SMBBASE: By default the base uses the mapper MMC3 which doesn't support any expansion audio.
; If you wish to use expansion audio, you need to change the mapper of this base completely, which will probably
; involve modifying banking logic.)
; You can enable up to one audio expansion (FAMISTUDIO_EXP_XXX). Enabling more than one expansion will lead to
; undefined behavior. Memory usage goes up as more complex expansions are used. The audio expansion you choose
; **MUST MATCH** with the data you will load in the engine. Loading a FDS song while enabling VRC6 will lead to
; undefined behavior.
;======================================================================================================================

; Konami VRC6 (2 extra square + saw)
; FAMISTUDIO_EXP_VRC6          = 1

; Rainbow-Net (homebrew clone of VRC6)
; FAMISTUDIO_EXP_RAINBOW       = 1

; Konami VRC7 (6 FM channels)
; FAMISTUDIO_EXP_VRC7          = 1 

; Nintendo MMC5 (2 extra squares, extra DPCM not supported)
; FAMISTUDIO_EXP_MMC5          = 1 

; Sunsoft S5B (2 extra squares, advanced features not supported.)
; FAMISTUDIO_EXP_S5B           = 1 

; Famicom Disk System (extra wavetable channel)
; FAMISTUDIO_EXP_FDS           = 1 

; Namco 163 (between 1 and 8 extra wavetable channels) + number of channels.
; FAMISTUDIO_EXP_N163          = 1 
; FAMISTUDIO_EXP_N163_CHN_CNT  = 4

; EPSM (Expansion Port Sound Module)
; FAMISTUDIO_EXP_EPSM          = 1
; Fine-tune control for enabling specific channels
; Default values for the channels are to enable all channels.
; FAMISTUDIO_EXP_EPSM_SSG_CHN_CNT     = 3
; FAMISTUDIO_EXP_EPSM_FM_CHN_CNT      = 6
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN1_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN2_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN3_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN4_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN5_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN6_ENABLE = 1