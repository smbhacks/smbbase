;-------------------------------------------------------------------------------------
;This is a modified version of the disassembly.
;-------------------------------------------------------------------------------------

;SMBDIS.ASM - A COMPREHENSIVE SUPER MARIO BROS. DISASSEMBLY
;by doppelganger (doppelheathen@gmail.com)

;This file is provided for your own use as-is.  It will require the character rom data
;and an iNES file header to get it to work.

;There are so many people I have to thank for this, that taking all the credit for
;myself would be an unforgivable act of arrogance. Without their help this would
;probably not be possible.  So I thank all the peeps in the nesdev scene whose insight into
;the 6502 and the NES helped me learn how it works (you guys know who you are, there's no 
;way I could have done this without your help), as well as the authors of x816 and SMB 
;Utility, and the reverse-engineers who did the original Super Mario Bros. Hacking Project, 
;which I compared notes with but did not copy from.  Last but certainly not least, I thank
;Nintendo for creating this game and the NES, without which this disassembly would
;only be theory.

;Assembles with x816.
;-------------------------------------------------------------------------------------
;iNES HEADER
  .db $4E,$45,$53,$1A                           ;  magic signature
  .db 4                                         ;  PRG ROM size in 16384 byte units
  .db 1                                         ;      CHR
  .db $41                                       ;  mirroring type and mapper number lower nibble
  .db %00001000                                 ;  mapper number upper nibble and nes 2.0 id
  .db $00
  .db $00
  .db $07                                       ; set 8kb PRG RAM (64 << 7)
  .db $00,$00,$00,$00,$00
  .org $8000
;-------------------------------------------------------------------------------------
;MACROS

macro Switch_Bank arg1
	pha
	lda #arg1
	sta bank0
	jsr switchBNK
	pla
endm

macro Bank_NoSave arg1
	pha
	lda #arg1
	jsr switchBNK
	pla
endm

macro Original_Bank
	pha
	lda bank0
	jsr switchBNK
	pla
endm

macro jcc address
	.db $b0, 3
	jmp address
endm

macro jcs address
	.db $90, 3
	jmp address
endm

;-------------------------------------------------------------------------------------
;DEFINES

.include "code/defines.asm"
.include "code/settings.asm"

;-------------------------------------------------------------------------------------
;CODE

.base $8000	;bank 0-1 mapped to $8000-$BFFF
	.include "code/bank0.asm"
.pad $c000

.base $8000	;bank 2-3 mapped to $8000-$BFFF

if CustomMusicDriver == Famitone5Music
	CustomAudioInit 		EQU FamiToneInit
	CustomAudioSfxInit 		EQU FamiToneSfxInit
	CustomAudioSfxPlay 		EQU FamiToneSfxPlay
	CustomAudioMusicPlay 	EQU FamiToneMusicPlay
	CustomAudioMusicPause 	EQU FamiToneMusicPause
	CustomAudioUpdate 		EQU FamiToneUpdate
	music_data      		EQU music_music_data
	SFX_CH0 EQU FT_SFX_CH0
	SFX_CH1 EQU FT_SFX_CH1
	SFX_CH2 EQU FT_SFX_CH2
	SFX_CH3 EQU FT_SFX_CH3
	.include "music/famitone/famitone5_asm6.asm"
	.include "music/famitone/music.asm"
	.include "music/famitone/sfx.asm"
endif
if CustomMusicDriver == FamistudioMusic
	CustomAudioInit 		EQU famistudio_init
	CustomAudioSfxInit 		EQU famistudio_sfx_init 
	CustomAudioSfxPlay 		EQU famistudio_sfx_play 
	CustomAudioMusicPlay 	EQU famistudio_music_play
	CustomAudioMusicPause 	EQU famistudio_music_pause 
	CustomAudioUpdate 		EQU famistudio_update 
	music_data      		EQU music_data_
	SFX_CH0 EQU FAMISTUDIO_SFX_CH0
	SFX_CH1 EQU FAMISTUDIO_SFX_CH1
	SFX_CH2 EQU FAMISTUDIO_SFX_CH2
	SFX_CH3 EQU FAMISTUDIO_SFX_CH3
	.include "music/famistudio/famistudio_asm6.asm"
	.include "music/famistudio/music.asm"
	.include "music/famistudio/sfx.asm"
endif
if CustomMusicDriver == OriginalSMBMusic
	MusicHeaderOffsetData = MusicHeaderData - 1
	MHD = MusicHeaderData
	.include "music/vanilla/smb1music.asm"
endif

if CustomMusicDriver == VanillaPlusMusic
	MusicHeaderOffsetData = MusicHeaderData - 1
	MHD = MusicHeaderData
	.include "music/vanilla_plus/smb1music.asm"
endif

if CustomMusicDriver == Famitone5Music || CustomMusicDriver == FamistudioMusic
; When the music driver is completes playback (and before it loops)
; we create a custom callback that will run to clear out the queue
; and set song playing to 0
CustomMusicLoopCallback:
	lda #0
	sta songPlaying
	lda EventMusicBuffer
	cmp #$40
	bne +
	lda #0
	sta EventMusicBuffer
	lda AreaMusicBuffer
	sta AreaMusicQueue
	+
	rts
endif

.pad $c000


.base $8000 ;bank 4-5 mapped to $8000-$BFFF
	.include "levels/output.asm"
.pad $c000


.pad $c000 ;fixed bank at $c000-$ffff
	.include "code/fixed.asm"
	.include "code/text.asm"
.pad $ff50
	.include "code/startup.asm"
.pad $fffa
;-------------------------------------------------------------------------------------
;INTERRUPT VECTORS

;.segment "VECTORS"
      .dw NonMaskableInterrupt
      .dw Start
      .dw IRQ  ;unused

;.segment "CHRROM"
.incbin "graphics/smb_chr.chr"

