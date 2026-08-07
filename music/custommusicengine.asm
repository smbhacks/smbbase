BRICK = 1		-1
BREATH = 2		-1
COIN = 3		-1
GROWPU = 4		-1
VINE = 5		-1
BLAST = 6		-1
GROW = 7		-1
EXTRALIFE = 8	-1
BJUMP = 9		-1
BUMP = 10		-1
STOMP = 11		-1
SMACK = 12		-1
INJURY = 13		-1
FIREBALL = 14	-1
FLAGPOLE = 15	-1
SJUMP = 16		-1
TIMER = 17		-1
BOWS_FALL = 18	-1
PAUSE_= 19		-1

noise_sfx_table:
      .byte BRICK      ,SFX_CH2
      .byte BREATH     ,SFX_CH2
      .byte PAUSE_     ,SFX_CH3 ;put pause here cuz i can

sq2_sfx_table:
      .byte COIN       ,SFX_CH1
      .byte GROWPU     ,SFX_CH1
      .byte VINE       ,SFX_CH1
      .byte BLAST      ,SFX_CH1
      .byte TIMER      ,SFX_CH1
      .byte GROW       ,SFX_CH1
.if CustomMusicDriver = FamistudioMusic
      .byte EXTRALIFE  ,SFX_CH1
.else
      .byte EXTRALIFE  ,SFX_CH3
.endif
      .byte BOWS_FALL  ,SFX_CH1

sq1_sfx_table:
      .byte BJUMP      ,SFX_CH0
      .byte BUMP       ,SFX_CH0
      .byte STOMP      ,SFX_CH0
      .byte SMACK      ,SFX_CH0
      .byte INJURY     ,SFX_CH0
      .byte FIREBALL   ,SFX_CH0
      .byte FLAGPOLE   ,SFX_CH0
      .byte SJUMP      ,SFX_CH0

.proc CustomMusicEngine
	ldx AreaMusicQueue
	beq AreaMusQueueEmpty
	stx AreaMusicBuffer
	lda #0
	sta AreaMusicQueue
    jmp LoadMusic
AreaMusQueueEmpty:
	ldx EventMusicQueue
	beq QueuesProcessed
	stx EventMusicBuffer
	lda #0
	sta EventMusicQueue
LoadMusic:
    lda SongBankLut-1,x
    sta songBank
    lda SongAddressLoLut-1,x
    sta $00
    lda SongAddressHiLut-1,x
    tay
	lda #1
	sta songPlaying
    ldx songBank
    jsr switchBNK_A000BFFF_fast      
	ldx $00 ;load low into x
    ;high is already in y
	jsr CustomAudioInit
	ldx #<sounds
	ldy #>sounds
	jsr CustomAudioSfxInit
    lda #0
	jsr CustomAudioMusicPlay
QueuesProcessed:
	lda Square2SoundQueue
	beq noSQ2
	jsr countBITS_asl
	lda sq2_sfx_table,y
	ldx sq2_sfx_table+1,y
	jsr CustomAudioSfxPlay
	lda #0
	sta Square2SoundQueue
noSQ2:
	lda Square1SoundQueue
	beq noSQ1
	jsr countBITS_asl
	lda sq1_sfx_table,y
	ldx sq1_sfx_table+1,y
	jsr CustomAudioSfxPlay
	lda #0
	sta Square1SoundQueue
noSQ1:
	lda NoiseSoundQueue
	beq noNOI
	jsr countBITS_asl
	lda noise_sfx_table,y
	ldx noise_sfx_table+1,y
	jsr CustomAudioSfxPlay
	lda #0
	sta NoiseSoundQueue
noNOI:
	jmp CustomAudioUpdate
.endproc

countBITS_asl:
	ldx #$ff
	sec
:
	inx
	ror
	bcc :-
	txa
	asl
	tay
	rts