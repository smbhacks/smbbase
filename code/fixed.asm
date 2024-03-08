IRQ:
      sta MMC3_IRQ_DISABLE
      pha
      bit PPU_STATUS
      lda ScrollH
      sta PPU_SCROLL_REG
      sta PPU_SCROLL_REG
      lda ScrollBit
      sta PPU_CTRL_REG1
      pla
      rti

GetHalfwayPageNumber:
      Switch_Bank 4
      ldy HalfwayPageNybbles,x
      Switch_Bank 0
      rts

.if CHR_Feature = CHR_Animated
AnimCHRBaseValues:
      .byte animated_chr, animated_chr+2, animated_chr+4, animated_chr+5, animated_chr+6, animated_chr+7

AnimateCHR:
      lda CHRAnimWait
      beq @set_chr
      dec CHRAnimWait
      rts
@set_chr:
      lda #ANIMATION_SPEED-1
      sta CHRAnimWait

      inc CHRAnimCounter
      lda CHRAnimCounter
      cmp #ANIMATION_FRAMES
      bcc @ok
      lda #0
      sta CHRAnimCounter
@ok:
      asl
      asl
      asl
      sta $00
      ldx #5
@loop:
      lda AnimCHRBaseValues,x
      clc
      adc $00
      sta CHR0,x
      dex
      bpl @loop
      rts
.endif

;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low, also used for pseudorandom bit
;$01 - vram buffer address table high

VRAM_AddrTable_Low:
      .byte <VRAM_Buffer1, <WaterPaletteData, <GroundPaletteData
      .byte <UndergroundPaletteData, <CastlePaletteData, <VRAM_Buffer1_Offset
      .byte <VRAM_Buffer2, <VRAM_Buffer2, <BowserPaletteData
      .byte <DaySnowPaletteData, <NightSnowPaletteData, <MushroomPaletteData
      .byte <MarioThanksMessage, <LuigiThanksMessage, <MushroomRetainerSaved
      .byte <PrincessSaved1, <PrincessSaved2, <WorldSelectMessage1
      .byte <WorldSelectMessage2

VRAM_AddrTable_High:
      .byte >VRAM_Buffer1, >WaterPaletteData, >GroundPaletteData
      .byte >UndergroundPaletteData, >CastlePaletteData, >VRAM_Buffer1_Offset
      .byte >VRAM_Buffer2, >VRAM_Buffer2, >BowserPaletteData
      .byte >DaySnowPaletteData, >NightSnowPaletteData, >MushroomPaletteData
      .byte >MarioThanksMessage, >LuigiThanksMessage, >MushroomRetainerSaved
      .byte >PrincessSaved1, >PrincessSaved2, >WorldSelectMessage1
      .byte >WorldSelectMessage2

VRAM_Buffer_Offset:
      .byte <VRAM_Buffer1_Offset, <VRAM_Buffer2_Offset

PauseRoutine:
               lda OperMode           ;are we in victory mode?
               cmp #VictoryModeValue  ;if so, go ahead
               beq ChkPauseTimer
               cmp #GameModeValue     ;are we in game mode?
               bne ExitPause          ;if not, leave
               lda OperMode_Task      ;if we are in game mode, are we running game engine?
               cmp #$03
               bne ExitPause          ;if not, leave
ChkPauseTimer: lda GamePauseTimer     ;check if pause timer is still counting down
               beq ChkStart
               dec GamePauseTimer     ;if so, decrement and leave
               rts
ChkStart:      lda SavedJoypad1Bits   ;check to see if start is pressed
               and #Start_Button      ;on controller 1
               beq ClrPauseTimer
               lda GamePauseStatus    ;check to see if timer flag is set
               and #%10000000         ;and if so, do not reset timer (residual,
               bne ExitPause          ;joypad reading routine makes this unnecessary)
               lda #$2b               ;set pause timer
               sta GamePauseTimer
               lda GamePauseStatus
               tay
               iny                    ;set pause sfx queue for next pause mode
               sty PauseSoundQueue
.if CustomMusicDriver = Famitone5Music || CustomMusicDriver = FamistudioMusic
		   pha
		   lda #4
		   sta NoiseSoundQueue
		   lda #0
		   cpy #1
		   bne :+
		   lda #1
:
		   Switch_Bank 2
		   jsr CustomAudioMusicPause
		   Switch_Bank 0
		   pla
.endif
               eor #%00000001         ;invert d0 and set d7
               ora #%10000000
               bne SetPause           ;unconditional branch
ClrPauseTimer: lda GamePauseStatus    ;clear timer flag if timer is at zero and start button
               and #%01111111         ;is not pressed
SetPause:      sta GamePauseStatus
ExitPause:     rts

.if CustomMusicDriver = Famitone5Music || CustomMusicDriver = FamistudioMusic
;Enter music number here (Famitracker music number - 1)
GroundMus        =  0
WaterMus         =  1
CaveMus          =  2
CastleMus        =  3
CloudMus         =  4
PipeMus          =  5
StarmanMus       =  6
DeathMus         =  7
GameOverMus      =  8
PrincessMus      =  9
CastleFinishMus  =  10
LevelFinishMus   =  11
HurryMus         =  12

MusicLUT:
      .byte GroundMus, WaterMus, CaveMus, CastleMus, CloudMus, PipeMus, StarmanMus,	-1
      .byte DeathMus, GameOverMus, PrincessMus, CastleFinishMus, 0, LevelFinishMus, HurryMus, -1

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
      .byte EXTRALIFE  ,SFX_CH3
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

CustomMusicEngine:
	lda EventMusicQueue
	ora AreaMusicQueue
	beq NoTrigger
	lda AreaMusicQueue
	beq :++
	sta AreaMusicBuffer
	ldx #-1
:
	inx
	lsr
	bcc :-
	ldy #0
	sty AreaMusicQueue
:
	lda EventMusicQueue
	beq :++
	sta EventMusicBuffer
	ldx #7
:
	inx
	lsr
	bcc :-
	ldy #0
	sty EventMusicQueue
:
	lda MusicLUT,x
	pha
	ldx #<music_data
	ldy #>music_data
	lda #1
	sta songPlaying
	jsr CustomAudioInit
	ldx #<sounds
	ldy #>sounds
	jsr CustomAudioSfxInit
	pla
	jsr CustomAudioMusicPlay
NoTrigger:
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
.endif

SetHUDScroll:
	lda Sprite0HitDetectFlag
	beq @skipIRQ
	lda #$1f
	sta MMC3_IRQ_LATCH
	sta MMC3_IRQ_RELOAD
	sta MMC3_IRQ_ENABLE
	cli
@skipIRQ:
	lda Mirror_PPU_CTRL_REG1
	and #%11111110
	sta PPU_CTRL_REG1
	lda #0
	sta PPU_SCROLL_REG
	sta PPU_SCROLL_REG
      rts

LagFrameTasks:
	;pha
	txa
	pha
	tya
	pha

	lda $00
	pha
	lda $01
	pha
	lda $02
	pha
	lda $03
	pha
	lda $04
	pha
	lda $05
	pha
	lda $06
	pha
	lda $07
	pha

      jsr SetHUDScroll

      Bank_NoSave 2
.if CustomMusicDriver = OriginalSMBMusic || CustomMusicDriver = VanillaPlusMusic
      jsr SoundEngine
.else
      jsr CustomMusicEngine
.endif
      Original_Bank

      pla
      sta $07
      pla
      sta $06
      pla
      sta $05
      pla
      sta $04
      pla
      sta $03
      pla
      sta $02
      pla
      sta $01
      pla
      sta $00

      pla
      tay
      pla
      tax
      pla
      rti

NonMaskableInterrupt:
      pha
      lda processinggame
      bne LagFrameTasks
      lda processingnmi
      beq :+
      jsr SetHUDScroll
      pla
      rti
:
      inc processingnmi
      pla
      lda Mirror_PPU_CTRL_REG1  ;disable NMIs in mirror reg
      ;and #%01111111            ;save all other bits
      ;sta Mirror_PPU_CTRL_REG1
      and #%11111110            ;alter name table address to be $2800
      sta PPU_CTRL_REG1         ;(essentially $2000) but save other bits
      lda Mirror_PPU_CTRL_REG2  ;disable OAM and background display by default
      and #%11100110
      ldy DisableScreenFlag     ;get screen disable flag
      bne ScreenOff             ;if set, used bits as-is
      lda Mirror_PPU_CTRL_REG2  ;otherwise reenable bits and save them
      ora #%00011110
ScreenOff:     
      sta Mirror_PPU_CTRL_REG2  ;save bits for later but not in register at the moment
      and #%11100111            ;disable screen for now
      sta PPU_CTRL_REG2
      ldx PPU_STATUS            ;reset flip-flop and reset scroll registers to zero
      lda #$00
      jsr InitScroll
      sta PPU_SPR_ADDR          ;reset spr-ram address register
      lda #$02                  ;perform spr-ram DMA access on $0200-$02ff
      sta SPR_DMA
      ldx VRAM_Buffer_AddrCtrl  ;load control for pointer to buffer contents
      lda VRAM_AddrTable_Low,x  ;set indirect at $00 to pointer
      sta $00
      lda VRAM_AddrTable_High,x
      sta $01
      jsr UpdateScreen          ;update screen with buffer contents
      ldy #$00
      ldx VRAM_Buffer_AddrCtrl  ;check for usage of $0341
      cpx #$06
      bne InitBuffer
      iny                       ;get offset based on usage
InitBuffer:    
      ldx VRAM_Buffer_Offset,y
      lda #$00                  ;clear buffer header at last location
      sta VRAM_Buffer1_Offset,x
      sta VRAM_Buffer1,x
      sta VRAM_Buffer_AddrCtrl  ;reinit address control to $0301
      lda Mirror_PPU_CTRL_REG2  ;copy mirror of $2001 to register
      sta PPU_CTRL_REG2

.if CHR_Feature <> No_Feature
      ldx #5
@update_chr:
      stx MMC3_BANK_SELECT
      lda CHR0,x
      sta MMC3_BANK_DATA
      dex
      bpl @update_chr
.endif

	lda Sprite0HitDetectFlag
	beq @skipIRQ
	lda #$1f
	sta MMC3_IRQ_LATCH
	sta MMC3_IRQ_RELOAD
	sta MMC3_IRQ_ENABLE
	cli
@skipIRQ:

	lda HorizontalScroll
	sta ScrollH
	lda Mirror_PPU_CTRL_REG1
	sta ScrollBit

	Switch_Bank 2
.if CustomMusicDriver = OriginalSMBMusic || CustomMusicDriver = VanillaPlusMusic
      jsr SoundEngine           ;play sound
.else
	jsr CustomMusicEngine
.endif
	Switch_Bank 0

      jsr ReadJoypads           ;read joypads
      jsr PauseRoutine          ;handle pause
      jsr UpdateTopScore
      lda GamePauseStatus       ;check for pause status
      lsr
      bcs PauseSkip
      lda TimerControl          ;if master timer control not set, decrement
      beq DecTimers             ;all frame and interval timers
      dec TimerControl
      bne NoDecTimers
DecTimers:     
      ldx #$14                  ;load end offset for end of frame timers
      dec IntervalTimerControl  ;decrement interval timer control,
      bpl DecTimersLoop         ;if not expired, only frame timers will decrement
      lda #$14
      sta IntervalTimerControl  ;if control for interval timers expired,
      ldx #$23                  ;interval timers will decrement along with frame timers
DecTimersLoop: 
      lda Timers,x              ;check current timer
      beq SkipExpTimer          ;if current timer expired, branch to skip,
      dec Timers,x              ;otherwise decrement the current timer
SkipExpTimer:  
      dex                       ;move onto next timer
      bpl DecTimersLoop         ;do this until all timers are dealt with
NoDecTimers:   
      inc FrameCounter          ;increment frame counter
PauseSkip:     
      ldx #$00
      ldy #$07
      lda PseudoRandomBitReg    ;get first memory location of LSFR bytes
      and #%00000010            ;mask out all but d1
      sta $00                   ;save here
      lda PseudoRandomBitReg+1  ;get second memory location
      and #%00000010            ;mask out all but d1
      eor $00                   ;perform exclusive-OR on d1 from first and second bytes
      clc                       ;if neither or both are set, carry will be clear
      beq RotPRandomBit
      sec                       ;if one or the other is set, carry will be set
RotPRandomBit: 
      ror PseudoRandomBitReg,x  ;rotate carry into d7, and rotate last bit into carry
      inx                       ;increment to next byte
      dey                       ;decrement for loop
      bne RotPRandomBit
      lda Sprite0HitDetectFlag  ;check for flag here
      beq SkipSprite0
;Sprite0Clr:   
;      lda PPU_STATUS            ;wait for sprite 0 flag to clear, which will
;      and #%01000000            ;not happen until vblank has ended
;      bne Sprite0Clr
      lda GamePauseStatus       ;if in pause mode, do not bother with sprites at all
      lsr
      bcs SkipSprite0
      jsr MoveSpritesOffscreen
      jsr SpriteShuffler
;Sprite0Hit:    
;      lda PPU_STATUS            ;do sprite #0 hit detection
;      and #%01000000
;      beq Sprite0Hit
;      ldy #$14                  ;small delay, to wait until we hit horizontal blank time
;HBlankDelay:   
;      dey
;      bne HBlankDelay
SkipSprite0:   
;      lda HorizontalScroll      ;set scroll registers from variables
;      sta PPU_SCROLL_REG
;      lda VerticalScroll
;      sta PPU_SCROLL_REG
;      lda Mirror_PPU_CTRL_REG1  ;load saved mirror of $2000
;      pha
;      sta PPU_CTRL_REG1

      lda GamePauseStatus       ;if in pause mode, do not perform operation mode stuff
      lsr
      bcs DoneNMI
	inc processinggame
      jsr OperModeExecutionTree ;otherwise do one of many, many possible subroutines
	dec processinggame

DoneNMI:
      dec processingnmi
      rti                       ;we are done until the next frame!

WriteGameText:
               pha                      ;save text number to stack
               asl
               tay                      ;multiply by 2 and use as offset
               cpy #$04                 ;if set to do top status bar or world/lives display,
               bcc LdGameText           ;branch to use current offset as-is
               cpy #$08                 ;if set to do time-up or game over,
               bcc Chk2Players          ;branch to check players
               ldy #$08                 ;otherwise warp zone, therefore set offset
Chk2Players:   lda NumberOfPlayers      ;check for number of players
               bne LdGameText           ;if there are two, use current offset to also print name
               iny                      ;otherwise increment offset by one to not print name
LdGameText:    ldx GameTextOffsets,y    ;get offset to message we want to print
               ldy #$00
GameTextLoop:  lda TopStatusBarLine,x   ;load message data
               cmp #$ff                 ;check for terminator
               beq EndGameText          ;branch to end text if found
               sta VRAM_Buffer1,y       ;otherwise write data to buffer
               inx                      ;and increment increment
               iny
               bne GameTextLoop         ;do this for 256 bytes if no terminator found
EndGameText:   lda #$00                 ;put null terminator at end
               sta VRAM_Buffer1,y
               pla                      ;pull original text number from stack
               tax
               cmp #$04                 ;are we printing warp zone?
               bcs PrintWarpZoneNumbers
               dex                      ;are we printing the world/lives display?
               bne CheckPlayerName      ;if not, branch to check player's name
               lda NumberofLives        ;otherwise, check number of lives
               clc                      ;and increment by one for display
               adc #$01
               cmp #10                  ;more than 9 lives?
               bcc PutLives
               sbc #10                  ;if so, subtract 10 and put a crown tile
               ldy #$2d                 ;next to the difference...strange things happen if
               sty VRAM_Buffer1+7       ;the number of lives exceeds 19
PutLives:      sta VRAM_Buffer1+8
               ldy WorldNumber          ;write world and level numbers (incremented for display)
               iny                      ;to the buffer in the spaces surrounding the dash
               sty VRAM_Buffer1+19
               ldy LevelNumber
               iny
               sty VRAM_Buffer1+21      ;we're done here
               rts

CheckPlayerName:
             lda NumberOfPlayers    ;check number of players
             beq ExitChkName        ;if only 1 player, leave
             lda CurrentPlayer      ;load current player
             dex                    ;check to see if current message number is for time up
             bne ChkLuigi
             ldy OperMode           ;check for game over mode
             cpy #GameOverModeValue
             beq ChkLuigi
             eor #%00000001         ;if not, must be time up, invert d0 to do other player
ChkLuigi:    lsr
             bcc ExitChkName        ;if mario is current player, do not change the name
             ldy #$04
NameLoop:    lda LuigiName,y        ;otherwise, replace "MARIO" with "LUIGI"
             sta VRAM_Buffer1+3,y
             dey
             bpl NameLoop           ;do this until each letter is replaced
ExitChkName: rts

PrintWarpZoneNumbers:
             sbc #$04               ;subtract 4 and then shift to the left
             asl                    ;twice to get proper warp zone number
             asl                    ;offset
             tax
             ldy #$00
WarpNumLoop: lda WarpZoneNumbers,x  ;print warp zone numbers into the
             sta VRAM_Buffer1+27,y  ;placeholders from earlier
             inx
             iny                    ;put a number in every fourth space
             iny
             iny
             iny
             cpy #$0c
             bcc WarpNumLoop
             lda #$2c               ;load new buffer pointer at end of message
			 sta VRAM_Buffer1_Offset
			 rts
             ;jmp SetVRAMOffset

;-------------------------------------------------------------------------------------

ProcessEnemyData_:
		Switch_Bank 4
		jsr ProcessEnemyData
		Switch_Bank 0
		rts
;--------------------------------
;$06 - used to hold page location of extended right boundary
;$07 - used to hold high nybble of position of extended right boundary

ProcessEnemyData:
        ldy EnemyDataOffset      ;get offset of enemy object data
        lda (EnemyData),y        ;load first byte
        cmp #$ff                 ;check for EOD terminator
        bne CheckEndofBuffer
        jmp CheckFrenzyBuffer    ;if found, jump to check frenzy buffer, otherwise

CheckEndofBuffer:
        and #%00001111           ;check for special row $0e
        cmp #$0e
        beq CheckRightBounds     ;if found, branch, otherwise
        cpx #$05                 ;check for end of buffer
        bcc CheckRightBounds     ;if not at end of buffer, branch
        iny
        lda (EnemyData),y        ;check for specific value here
        and #%00111111           ;not sure what this was intended for, exactly
        cmp #$2e                 ;this part is quite possibly residual code
        beq CheckRightBounds     ;but it has the effect of keeping enemies out of
        rts                      ;the sixth slot

CheckRightBounds:
        lda ScreenRight_X_Pos    ;add 48 to pixel coordinate of right boundary
        clc
        adc #$30
        and #%11110000           ;store high nybble
        sta $07
        lda ScreenRight_PageLoc  ;add carry to page location of right boundary
        adc #$00
        sta $06                  ;store page location + carry
        ldy EnemyDataOffset
        iny
        lda (EnemyData),y        ;if MSB of enemy object is clear, branch to check for row $0f
        asl
        bcc CheckPageCtrlRow
        lda EnemyObjectPageSel   ;if page select already set, do not set again
        bne CheckPageCtrlRow
        inc EnemyObjectPageSel   ;otherwise, if MSB is set, set page select
        inc EnemyObjectPageLoc   ;and increment page control

CheckPageCtrlRow:
        dey
        lda (EnemyData),y        ;reread first byte
        and #$0f
        cmp #$0f                 ;check for special row $0f
        bne PositionEnemyObj     ;if not found, branch to position enemy object
        lda EnemyObjectPageSel   ;if page select set,
        bne PositionEnemyObj     ;branch without reading second byte
        iny
        lda (EnemyData),y        ;otherwise, get second byte, mask out 2 MSB
        and #%00111111
        sta EnemyObjectPageLoc   ;store as page control for enemy object data
        inc EnemyDataOffset      ;increment enemy object data offset 2 bytes
        inc EnemyDataOffset
        inc EnemyObjectPageSel   ;set page select for enemy object data and
        jmp ProcLoopCommand      ;jump back to process loop commands again

PositionEnemyObj:
        lda EnemyObjectPageLoc   ;store page control as page location
        sta Enemy_PageLoc,x      ;for enemy object
        lda (EnemyData),y        ;get first byte of enemy object
        and #%11110000
        sta Enemy_X_Position,x   ;store column position
        cmp ScreenRight_X_Pos    ;check column position against right boundary
        lda Enemy_PageLoc,x      ;without subtracting, then subtract borrow
        sbc ScreenRight_PageLoc  ;from page location
        bcs CheckRightExtBounds  ;if enemy object beyond or at boundary, branch
        lda (EnemyData),y
        and #%00001111           ;check for special row $0e
        cmp #$0e                 ;if found, jump elsewhere
        beq ParseRow0e
        jmp CheckThreeBytes      ;if not found, unconditional jump

CheckRightExtBounds:
        lda $07                  ;check right boundary + 48 against
        cmp Enemy_X_Position,x   ;column position without subtracting,
        lda $06                  ;then subtract borrow from page control temp
        sbc Enemy_PageLoc,x      ;plus carry
        bcc CheckFrenzyBuffer    ;if enemy object beyond extended boundary, branch
        lda #$01                 ;store value in vertical high byte
        sta Enemy_Y_HighPos,x
        lda (EnemyData),y        ;get first byte again
        asl                      ;multiply by four to get the vertical
        asl                      ;coordinate
        asl
        asl
        sta Enemy_Y_Position,x
        cmp #$e0                 ;do one last check for special row $0e
        beq ParseRow0e           ;(necessary if branched to $c1cb)
        iny
        lda (EnemyData),y        ;get second byte of object
        and #%01000000           ;check to see if hard mode bit is set
        beq CheckForEnemyGroup   ;if not, branch to check for group enemy objects
        lda SecondaryHardMode    ;if set, check to see if secondary hard mode flag
        beq Inc2B                ;is on, and if not, branch to skip this object completely

CheckForEnemyGroup:
        lda (EnemyData),y      ;get second byte and mask out 2 MSB
        and #%00111111
        cmp #$37               ;check for value below $37
        bcc BuzzyBeetleMutate
        cmp #$3f               ;if $37 or greater, check for value
        bcc DoGroup            ;below $3f, branch if below $3f

BuzzyBeetleMutate:
        cmp #Goomba          ;if below $37, check for goomba
        bne StrID            ;value ($3f or more always fails)
        ldy PrimaryHardMode  ;check if primary hard mode flag is set
        beq StrID            ;and if so, change goomba to buzzy beetle
        lda #BuzzyBeetle
StrID:  sta Enemy_ID,x       ;store enemy object number into buffer
        lda #$01
        sta Enemy_Flag,x     ;set flag for enemy in buffer
        jsr InitEnemyObject
        lda Enemy_Flag,x     ;check to see if flag is set
        bne Inc2B            ;if not, leave, otherwise branch
        rts

CheckFrenzyBuffer:
        lda EnemyFrenzyBuffer    ;if enemy object stored in frenzy buffer
        bne StrFre               ;then branch ahead to store in enemy object buffer
        lda VineFlagOffset       ;otherwise check vine flag offset
        cmp #$01
        bne ExEPar               ;if other value <> 1, leave
        lda #VineObject          ;otherwise put vine in enemy identifier
StrFre: sta Enemy_ID,x           ;store contents of frenzy buffer into enemy identifier value

InitEnemyObject:
        lda #$00                 ;initialize enemy state
        sta Enemy_State,x
        jsr CheckpointEnemyID    ;jump ahead to run jump engine and subroutines
ExEPar: rts                      ;then leave

DoGroup:
        jmp HandleGroupEnemies   ;handle enemy group objects

ParseRow0e:
        iny                      ;increment Y to load third byte of object
        iny
        lda (EnemyData),y
        lsr                      ;move 3 MSB to the bottom, effectively
        lsr                      ;making %xxx00000 into %00000xxx
        lsr
        lsr
        lsr
        cmp WorldNumber          ;is it the same world number as we're on?
        bne NotUse               ;if not, do not use (this allows multiple uses
        dey                      ;of the same area, like the underground bonus areas)
        lda (EnemyData),y        ;otherwise, get second byte and use as offset
        sta AreaPointer          ;to addresses for level and enemy object data
        iny
        lda (EnemyData),y        ;get third byte again, and this time mask out
        and #%00011111           ;the 3 MSB from before, save as page number to be
        sta EntrancePage         ;used upon entry to area, if area is entered
NotUse: jmp Inc3B

CheckThreeBytes:
        ldy EnemyDataOffset      ;load current offset for enemy object data
        lda (EnemyData),y        ;get first byte
        and #%00001111           ;check for special row $0e
        cmp #$0e
        bne Inc2B
Inc3B:  inc EnemyDataOffset      ;if row = $0e, increment three bytes
Inc2B:  inc EnemyDataOffset      ;otherwise increment two bytes
        inc EnemyDataOffset
        lda #$00                 ;init page select for enemy objects
        sta EnemyObjectPageSel
        ldx ObjectOffset         ;reload current offset in enemy buffers
        rts                      ;and leave

CheckpointEnemyID:
        lda Enemy_ID,x
        cmp #$15                     ;check enemy object identifier for $15 or greater
        bcs InitEnemyRoutines        ;and branch straight to the jump engine if found
        tay                          ;save identifier in Y register for now
        lda Enemy_Y_Position,x
        adc #$08                     ;add eight pixels to what will eventually be the
        sta Enemy_Y_Position,x       ;enemy object's vertical coordinate ($00-$14 only)
        lda #$01
        sta EnemyOffscrBitsMasked,x  ;set offscreen masked bit
        tya                          ;get identifier back and use as offset for jump engine

InitEnemyRoutines:
        jsr JumpEngine

;jump engine table for newly loaded enemy objects

      .word InitNormalEnemy  ;for objects $00-$0f
      .word InitNormalEnemy
      .word InitNormalEnemy
      .word InitRedKoopa
      .word NoInitCode
      .word InitHammerBro
      .word InitGoomba
      .word InitBloober
      .word InitBulletBill
      .word NoInitCode
      .word InitCheepCheep
      .word InitCheepCheep
      .word InitPodoboo
      .word InitPiranhaPlant
      .word InitJumpGPTroopa
      .word InitRedPTroopa

      .word InitHorizFlySwimEnemy  ;for objects $10-$1f
      .word InitLakitu
      .word InitEnemyFrenzy
      .word NoInitCode
      .word InitEnemyFrenzy
      .word InitEnemyFrenzy
      .word InitEnemyFrenzy
      .word InitEnemyFrenzy
      .word EndFrenzy
      .word NoInitCode
      .word NoInitCode
      .word InitShortFirebar
      .word InitShortFirebar
      .word InitShortFirebar
      .word InitShortFirebar
      .word InitLongFirebar

      .word NoInitCode ;for objects $20-$2f
      .word NoInitCode
      .word NoInitCode
      .word NoInitCode
      .word InitBalPlatform
      .word InitVertPlatform
      .word LargeLiftUp
      .word LargeLiftDown
      .word InitHoriPlatform
      .word InitDropPlatform
      .word InitHoriPlatform
      .word PlatLiftUp
      .word PlatLiftDown
      .word InitBowser
      .word PwrUpJmp   ;possibly dummy value
      .word Setup_Vine

      .word NoInitCode ;for objects $30-$36
      .word NoInitCode
      .word NoInitCode
      .word NoInitCode
      .word NoInitCode
      .word InitRetainerObj
      .word EndOfEnemyInitCode

;-------------------------------------------------------------------------------------

NoInitCode:
      rts               ;this executed when enemy object has no init code

;--------------------------------

InitGoomba:
      jsr InitNormalEnemy  ;set appropriate horizontal speed
      jmp SmallBBox        ;set $09 as bounding box control, set other values

;--------------------------------

InitPodoboo:
      lda #$02                  ;set enemy position to below
      sta Enemy_Y_HighPos,x     ;the bottom of the screen
      sta Enemy_Y_Position,x
      lsr
      sta EnemyIntervalTimer,x  ;set timer for enemy
      lsr
      sta Enemy_State,x         ;initialize enemy state, then jump to use
      jmp SmallBBox             ;$09 as bounding box size and set other things

;--------------------------------

InitRetainerObj:
      lda #$b8                ;set fixed vertical position for
      sta Enemy_Y_Position,x  ;princess/mushroom retainer object
      rts

;--------------------------------

Setup_Vine:
        lda #VineObject          ;load identifier for vine object
        sta Enemy_ID,x           ;store in buffer
        lda #$01
        sta Enemy_Flag,x         ;set flag for enemy object buffer
        lda Block_PageLoc,y
        sta Enemy_PageLoc,x      ;copy page location from previous object
        lda Block_X_Position,y
        sta Enemy_X_Position,x   ;copy horizontal coordinate from previous object
        lda Block_Y_Position,y
        sta Enemy_Y_Position,x   ;copy vertical coordinate from previous object
        ldy VineFlagOffset       ;load vine flag/offset to next available vine slot
        bne NextVO               ;if set at all, don't bother to store vertical
        sta VineStart_Y_Position ;otherwise store vertical coordinate here
NextVO: txa                      ;store object offset to next available vine slot
        sta VineObjOffset,y      ;using vine flag as offset
        inc VineFlagOffset       ;increment vine flag offset
        lda #Sfx_GrowVine
        sta Square2SoundQueue    ;load vine grow sound
        rts

;--------------------------------

NormalXSpdData:
      .byte $f8, $f4

InitNormalEnemy:
         ldy #$01              ;load offset of 1 by default
         lda PrimaryHardMode   ;check for primary hard mode flag set
         bne GetESpd
         dey                   ;if not set, decrement offset
GetESpd: lda NormalXSpdData,y  ;get appropriate horizontal speed
SetESpd: sta Enemy_X_Speed,x   ;store as speed for enemy object
         jmp TallBBox          ;branch to set bounding box control and other data

;--------------------------------

InitRedKoopa:
      jsr InitNormalEnemy   ;load appropriate horizontal speed
      lda #$01              ;set enemy state for red koopa troopa $03
      sta Enemy_State,x
      rts

;--------------------------------

HBroWalkingTimerData:
      .byte $80, $50

InitHammerBro:
      lda #$00                    ;init horizontal speed and timer used by hammer bro
      sta HammerThrowingTimer,x   ;apparently to time hammer throwing
      sta Enemy_X_Speed,x
      ldy SecondaryHardMode       ;get secondary hard mode flag
      lda HBroWalkingTimerData,y
      sta EnemyIntervalTimer,x    ;set value as delay for hammer bro to walk left
      lda #$0b                    ;set specific value for bounding box size control
      jmp SetBBox

;--------------------------------

InitHorizFlySwimEnemy:
      lda #$00        ;initialize horizontal speed
      jmp SetESpd

;--------------------------------

InitBloober:
           lda #$00               ;initialize horizontal speed
           sta BlooperMoveSpeed,x
SmallBBox: lda #$09               ;set specific bounding box size control
           bne SetBBox            ;unconditional branch

;--------------------------------

InitRedPTroopa:
          ldy #$30                    ;load central position adder for 48 pixels down
          lda Enemy_Y_Position,x      ;set vertical coordinate into location to
          sta RedPTroopaOrigXPos,x    ;be used as original vertical coordinate
          bpl GetCent                 ;if vertical coordinate < $80
          ldy #$e0                    ;if => $80, load position adder for 32 pixels up
GetCent:  tya                         ;send central position adder to A
          adc Enemy_Y_Position,x      ;add to current vertical coordinate
          sta RedPTroopaCenterYPos,x  ;store as central vertical coordinate
TallBBox: lda #$03                    ;set specific bounding box size control
SetBBox:  sta Enemy_BoundBoxCtrl,x    ;set bounding box control here
          lda #$02                    ;set moving direction for left
          sta Enemy_MovingDir,x
InitVStf: lda #$00                    ;initialize vertical speed
          sta Enemy_Y_Speed,x         ;and movement force
          sta Enemy_Y_MoveForce,x
          rts

;--------------------------------

InitBulletBill:
      lda #$02                  ;set moving direction for left
      sta Enemy_MovingDir,x
      lda #$09                  ;set bounding box control for $09
      sta Enemy_BoundBoxCtrl,x
      rts

;--------------------------------

InitCheepCheep:
      jsr SmallBBox              ;set vertical bounding box, speed, init others
      lda PseudoRandomBitReg,x   ;check one portion of LSFR
      and #%00010000             ;get d4 from it
      sta CheepCheepMoveMFlag,x  ;save as movement flag of some sort
      lda Enemy_Y_Position,x
      sta CheepCheepOrigYPos,x   ;save original vertical coordinate here
      rts

;--------------------------------

InitLakitu:
      lda EnemyFrenzyBuffer      ;check to see if an enemy is already in
      bne KillLakitu             ;the frenzy buffer, and branch to kill lakitu if so

SetupLakitu:
      lda #$00                   ;erase counter for lakitu's reappearance
      sta LakituReappearTimer
      jsr InitHorizFlySwimEnemy  ;set $03 as bounding box, set other attributes
      jmp TallBBox2              ;set $03 as bounding box again (not necessary) and leave

KillLakitu:
      jmp EraseEnemyObject

;--------------------------------
;$01-$03 - used to hold pseudorandom difference adjusters

PRDiffAdjustData:
      .byte $26, $2c, $32, $38
      .byte $20, $22, $24, $26
      .byte $13, $14, $15, $16

LakituAndSpinyHandler:
          lda FrenzyEnemyTimer    ;if timer here not expired, leave
          bne ExLSHand
          cpx #$05                ;if we are on the special use slot, leave
          bcs ExLSHand
          lda #$80                ;set timer
          sta FrenzyEnemyTimer
          ldy #$04                ;start with the last enemy slot
ChkLak:   lda Enemy_ID,y          ;check all enemy slots to see
          cmp #Lakitu             ;if lakitu is on one of them
          beq CreateSpiny         ;if so, branch out of this loop
          dey                     ;otherwise check another slot
          bpl ChkLak              ;loop until all slots are checked
          inc LakituReappearTimer ;increment reappearance timer
          lda LakituReappearTimer
          cmp #$07                ;check to see if we're up to a certain value yet
          bcc ExLSHand            ;if not, leave
          ldx #$04                ;start with the last enemy slot again
ChkNoEn:  lda Enemy_Flag,x        ;check enemy buffer flag for non-active enemy slot
          beq CreateL             ;branch out of loop if found
          dex                     ;otherwise check next slot
          bpl ChkNoEn             ;branch until all slots are checked
          bmi RetEOfs             ;if no empty slots were found, branch to leave
CreateL:  lda #$00                ;initialize enemy state
          sta Enemy_State,x
          lda #Lakitu             ;create lakitu enemy object
          sta Enemy_ID,x
          jsr SetupLakitu         ;do a sub to set up lakitu
          lda #$20
          jsr PutAtRightExtent    ;finish setting up lakitu
RetEOfs:  ldx ObjectOffset        ;get enemy object buffer offset again and leave
ExLSHand: rts

;--------------------------------

CreateSpiny:
          lda Player_Y_Position      ;if player above a certain point, branch to leave
          cmp #$2c
          bcc ExLSHand
          lda Enemy_State,y          ;if lakitu is not in normal state, branch to leave
          bne ExLSHand
          lda Enemy_PageLoc,y        ;store horizontal coordinates (high and low) of lakitu
          sta Enemy_PageLoc,x        ;into the coordinates of the spiny we're going to create
          lda Enemy_X_Position,y
          sta Enemy_X_Position,x
          lda #$01                   ;put spiny within vertical screen unit
          sta Enemy_Y_HighPos,x
          lda Enemy_Y_Position,y     ;put spiny eight pixels above where lakitu is
          sec
          sbc #$08
          sta Enemy_Y_Position,x
          lda PseudoRandomBitReg,x   ;get 2 LSB of LSFR and save to Y
          and #%00000011
          tay
          ldx #$02
DifLoop:  lda PRDiffAdjustData,y     ;get three values and save them
          sta $01,x                  ;to $01-$03
          iny
          iny                        ;increment Y four bytes for each value
          iny
          iny
          dex                        ;decrement X for each one
          bpl DifLoop                ;loop until all three are written
          ldx ObjectOffset           ;get enemy object buffer offset
          jsr PlayerLakituDiff       ;move enemy, change direction, get value - difference
          ldy Player_X_Speed         ;check player's horizontal speed
          cpy #$08
          bcs SetSpSpd               ;if moving faster than a certain amount, branch elsewhere
          tay                        ;otherwise save value in A to Y for now
          lda PseudoRandomBitReg+1,x
          and #%00000011             ;get one of the LSFR parts and save the 2 LSB
          beq UsePosv                ;branch if neither bits are set
          tya
          eor #%11111111             ;otherwise get two's compliment of Y
          tay
          iny
UsePosv:  tya                        ;put value from A in Y back to A (they will be lost anyway)
SetSpSpd: jsr SmallBBox              ;set bounding box control, init attributes, lose contents of A
          ldy #$02
          sta Enemy_X_Speed,x        ;set horizontal speed to zero because previous contents
          cmp #$00                   ;of A were lost...branch here will never be taken for
          bmi SpinyRte               ;the same reason
          dey
SpinyRte: sty Enemy_MovingDir,x      ;set moving direction to the right
          lda #$fd
          sta Enemy_Y_Speed,x        ;set vertical speed to move upwards
          lda #$01
          sta Enemy_Flag,x           ;enable enemy object by setting flag
          lda #$05
          sta Enemy_State,x          ;put spiny in egg state and leave
ChpChpEx: rts

;--------------------------------

FirebarSpinSpdData:
      .byte $28, $38, $28, $38, $28

FirebarSpinDirData:
      .byte $00, $00, $10, $10, $00

InitLongFirebar:
      jsr DuplicateEnemyObj       ;create enemy object for long firebar

InitShortFirebar:
      lda #$00                    ;initialize low byte of spin state
      sta FirebarSpinState_Low,x
      lda Enemy_ID,x              ;subtract $1b from enemy identifier
      sec                         ;to get proper offset for firebar data
      sbc #$1b
      tay
      lda FirebarSpinSpdData,y    ;get spinning speed of firebar
      sta FirebarSpinSpeed,x
      lda FirebarSpinDirData,y    ;get spinning direction of firebar
      sta FirebarSpinDirection,x
      lda Enemy_Y_Position,x
      clc                         ;add four pixels to vertical coordinate
      adc #$04
      sta Enemy_Y_Position,x
      lda Enemy_X_Position,x
      clc                         ;add four pixels to horizontal coordinate
      adc #$04
      sta Enemy_X_Position,x
      lda Enemy_PageLoc,x
      adc #$00                    ;add carry to page location
      sta Enemy_PageLoc,x
      jmp TallBBox2               ;set bounding box control (not used) and leave

;--------------------------------
;$00-$01 - used to hold pseudorandom bits

FlyCCXPositionData:
      .byte $80, $30, $40, $80
      .byte $30, $50, $50, $70
      .byte $20, $40, $80, $a0
      .byte $70, $40, $90, $68

FlyCCXSpeedData:
      .byte $0e, $05, $06, $0e
      .byte $1c, $20, $10, $0c
      .byte $1e, $22, $18, $14

FlyCCTimerData:
      .byte $10, $60, $20, $48

InitFlyingCheepCheep:
         lda FrenzyEnemyTimer       ;if timer here not expired yet, branch to leave
         bne ChpChpEx
         jsr SmallBBox              ;jump to set bounding box size $09 and init other values
         lda PseudoRandomBitReg+1,x
         and #%00000011             ;set pseudorandom offset here
         tay
         lda FlyCCTimerData,y       ;load timer with pseudorandom offset
         sta FrenzyEnemyTimer
         ldy #$03                   ;load Y with default value
         lda SecondaryHardMode
         beq MaxCC                  ;if secondary hard mode flag not set, do not increment Y
         iny                        ;otherwise, increment Y to allow as many as four onscreen
MaxCC:   sty $00                    ;store whatever pseudorandom bits are in Y
         cpx $00                    ;compare enemy object buffer offset with Y
         bcs ChpChpEx               ;if X => Y, branch to leave
         lda PseudoRandomBitReg,x
         and #%00000011             ;get last two bits of LSFR, first part
         sta $00                    ;and store in two places
         sta $01
         lda #$fb                   ;set vertical speed for cheep-cheep
         sta Enemy_Y_Speed,x
         lda #$00                   ;load default value
         ldy Player_X_Speed         ;check player's horizontal speed
         beq GSeed                  ;if player not moving left or right, skip this part
         lda #$04
         cpy #$19                   ;if moving to the right but not very quickly,
         bcc GSeed                  ;do not change A
         asl                        ;otherwise, multiply A by 2
GSeed:   pha                        ;save to stack
         clc
         adc $00                    ;add to last two bits of LSFR we saved earlier
         sta $00                    ;save it there
         lda PseudoRandomBitReg+1,x
         and #%00000011             ;if neither of the last two bits of second LSFR set,
         beq RSeed                  ;skip this part and save contents of $00
         lda PseudoRandomBitReg+2,x
         and #%00001111             ;otherwise overwrite with lower nybble of
         sta $00                    ;third LSFR part
RSeed:   pla                        ;get value from stack we saved earlier
         clc
         adc $01                    ;add to last two bits of LSFR we saved in other place
         tay                        ;use as pseudorandom offset here
         lda FlyCCXSpeedData,y      ;get horizontal speed using pseudorandom offset
         sta Enemy_X_Speed,x
         lda #$01                   ;set to move towards the right
         sta Enemy_MovingDir,x
         lda Player_X_Speed         ;if player moving left or right, branch ahead of this part
         bne D2XPos1
         ldy $00                    ;get first LSFR or third LSFR lower nybble
         tya                        ;and check for d1 set
         and #%00000010
         beq D2XPos1                ;if d1 not set, branch
         lda Enemy_X_Speed,x
         eor #$ff                   ;if d1 set, change horizontal speed
         clc                        ;into two's compliment, thus moving in the opposite
         adc #$01                   ;direction
         sta Enemy_X_Speed,x
         inc Enemy_MovingDir,x      ;increment to move towards the left
D2XPos1: tya                        ;get first LSFR or third LSFR lower nybble again
         and #%00000010
         beq D2XPos2                ;check for d1 set again, branch again if not set
         lda Player_X_Position      ;get player's horizontal position
         clc
         adc FlyCCXPositionData,y   ;if d1 set, add value obtained from pseudorandom offset
         sta Enemy_X_Position,x     ;and save as enemy's horizontal position
         lda Player_PageLoc         ;get player's page location
         adc #$00                   ;add carry and jump past this part
         jmp FinCCSt
D2XPos2: lda Player_X_Position      ;get player's horizontal position
         sec
         sbc FlyCCXPositionData,y   ;if d1 not set, subtract value obtained from pseudorandom
         sta Enemy_X_Position,x     ;offset and save as enemy's horizontal position
         lda Player_PageLoc         ;get player's page location
         sbc #$00                   ;subtract borrow
FinCCSt: sta Enemy_PageLoc,x        ;save as enemy's page location
         lda #$01
         sta Enemy_Flag,x           ;set enemy's buffer flag
         sta Enemy_Y_HighPos,x      ;set enemy's high vertical byte
         lda #$f8
         sta Enemy_Y_Position,x     ;put enemy below the screen, and we are done
         rts

;--------------------------------

InitBowser:
      jsr DuplicateEnemyObj     ;jump to create another bowser object
      stx BowserFront_Offset    ;save offset of first here
      lda #$00
      sta BowserBodyControls    ;initialize bowser's body controls
      sta BridgeCollapseOffset  ;and bridge collapse offset
      lda Enemy_X_Position,x
      sta BowserOrigXPos        ;store original horizontal position here
      lda #$df
      sta BowserFireBreathTimer ;store something here
      sta Enemy_MovingDir,x     ;and in moving direction
      lda #$20
      sta BowserFeetCounter     ;set bowser's feet timer and in enemy timer
      sta EnemyFrameTimer,x
      lda #$05
      sta BowserHitPoints       ;give bowser 5 hit points
      lsr
      sta BowserMovementSpeed   ;set default movement speed here
      rts

;--------------------------------

DuplicateEnemyObj:
        ldy #$ff                ;start at beginning of enemy slots
FSLoop: iny                     ;increment one slot
        lda Enemy_Flag,y        ;check enemy buffer flag for empty slot
        bne FSLoop              ;if set, branch and keep checking
        sty DuplicateObj_Offset ;otherwise set offset here
        txa                     ;transfer original enemy buffer offset
        ora #%10000000          ;store with d7 set as flag in new enemy
        sta Enemy_Flag,y        ;slot as well as enemy offset
        lda Enemy_PageLoc,x
        sta Enemy_PageLoc,y     ;copy page location and horizontal coordinates
        lda Enemy_X_Position,x  ;from original enemy to new enemy
        sta Enemy_X_Position,y
        lda #$01
        sta Enemy_Flag,x        ;set flag as normal for original enemy
        sta Enemy_Y_HighPos,y   ;set high vertical byte for new enemy
        lda Enemy_Y_Position,x
        sta Enemy_Y_Position,y  ;copy vertical coordinate from original to new
FlmEx:  rts                     ;and then leave

;--------------------------------

FlameYPosData:
      .byte $90, $80, $70, $90

FlameYMFAdderData:
      .byte $ff, $01

InitBowserFlame:
        lda FrenzyEnemyTimer        ;if timer not expired yet, branch to leave
        bne FlmEx
        sta Enemy_Y_MoveForce,x     ;reset something here
        lda NoiseSoundQueue
        ora #Sfx_BowserFlame        ;load bowser's flame sound into queue
        sta NoiseSoundQueue
        ldy BowserFront_Offset      ;get bowser's buffer offset
        lda Enemy_ID,y              ;check for bowser
        cmp #Bowser
        beq SpawnFromMouth          ;branch if found
        jsr SetFlameTimer           ;get timer data based on flame counter
        clc
        adc #$20                    ;add 32 frames by default
        ldy SecondaryHardMode
        beq SetFrT                  ;if secondary mode flag not set, use as timer setting
        sec
        sbc #$10                    ;otherwise subtract 16 frames for secondary hard mode
SetFrT: sta FrenzyEnemyTimer        ;set timer accordingly
        lda PseudoRandomBitReg,x
        and #%00000011              ;get 2 LSB from first part of LSFR
        sta BowserFlamePRandomOfs,x ;set here
        tay                         ;use as offset
        lda FlameYPosData,y         ;load vertical position based on pseudorandom offset

PutAtRightExtent:
      sta Enemy_Y_Position,x    ;set vertical position
      lda ScreenRight_X_Pos
      clc
      adc #$20                  ;place enemy 32 pixels beyond right side of screen
      sta Enemy_X_Position,x
      lda ScreenRight_PageLoc
      adc #$00                  ;add carry
      sta Enemy_PageLoc,x
      jmp FinishFlame           ;skip this part to finish setting values

SpawnFromMouth:
       lda Enemy_X_Position,y    ;get bowser's horizontal position
       sec
       sbc #$0e                  ;subtract 14 pixels
       sta Enemy_X_Position,x    ;save as flame's horizontal position
       lda Enemy_PageLoc,y
       sta Enemy_PageLoc,x       ;copy page location from bowser to flame
       lda Enemy_Y_Position,y
       clc                       ;add 8 pixels to bowser's vertical position
       adc #$08
       sta Enemy_Y_Position,x    ;save as flame's vertical position
       lda PseudoRandomBitReg,x
       and #%00000011            ;get 2 LSB from first part of LSFR
       sta Enemy_YMF_Dummy,x     ;save here
       tay                       ;use as offset
       lda FlameYPosData,y       ;get value here using bits as offset
       ldy #$00                  ;load default offset
       cmp Enemy_Y_Position,x    ;compare value to flame's current vertical position
       bcc SetMF                 ;if less, do not increment offset
       iny                       ;otherwise increment now
SetMF: lda FlameYMFAdderData,y   ;get value here and save
       sta Enemy_Y_MoveForce,x   ;to vertical movement force
       lda #$00
       sta EnemyFrenzyBuffer     ;clear enemy frenzy buffer

FinishFlame:
      lda #$08                 ;set $08 for bounding box control
      sta Enemy_BoundBoxCtrl,x
      lda #$01                 ;set high byte of vertical and
      sta Enemy_Y_HighPos,x    ;enemy buffer flag
      sta Enemy_Flag,x
      lsr
      sta Enemy_X_MoveForce,x  ;initialize horizontal movement force, and
      sta Enemy_State,x        ;enemy state
      rts

;--------------------------------

FireworksXPosData:
      .byte $00, $30, $60, $60, $00, $20

FireworksYPosData:
      .byte $60, $40, $70, $40, $60, $30

InitFireworks:
          lda FrenzyEnemyTimer         ;if timer not expired yet, branch to leave
          bne ExitFWk
          lda #$20                     ;otherwise reset timer
          sta FrenzyEnemyTimer
          dec FireworksCounter         ;decrement for each explosion
          ldy #$06                     ;start at last slot
StarFChk: dey
          lda Enemy_ID,y               ;check for presence of star flag object
          cmp #StarFlagObject          ;if there isn't a star flag object,
          bne StarFChk                 ;routine goes into infinite loop = crash
          lda Enemy_X_Position,y
          sec                          ;get horizontal coordinate of star flag object, then
          sbc #$30                     ;subtract 48 pixels from it and save to
          pha                          ;the stack
          lda Enemy_PageLoc,y
          sbc #$00                     ;subtract the carry from the page location
          sta $00                      ;of the star flag object
          lda FireworksCounter         ;get fireworks counter
          clc
          adc Enemy_State,y            ;add state of star flag object (possibly not necessary)
          tay                          ;use as offset
          pla                          ;get saved horizontal coordinate of star flag - 48 pixels
          clc
          adc FireworksXPosData,y      ;add number based on offset of fireworks counter
          sta Enemy_X_Position,x       ;store as the fireworks object horizontal coordinate
          lda $00
          adc #$00                     ;add carry and store as page location for
          sta Enemy_PageLoc,x          ;the fireworks object
          lda FireworksYPosData,y      ;get vertical position using same offset
          sta Enemy_Y_Position,x       ;and store as vertical coordinate for fireworks object
          lda #$01
          sta Enemy_Y_HighPos,x        ;store in vertical high byte
          sta Enemy_Flag,x             ;and activate enemy buffer flag
          lsr
          sta ExplosionGfxCounter,x    ;initialize explosion counter
          lda #$08
          sta ExplosionTimerCounter,x  ;set explosion timing counter
ExitFWk:  rts

;--------------------------------

Bitmasks:
      .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

Enemy17YPosData:
      .byte $40, $30, $90, $50, $20, $60, $a0, $70

SwimCC_IDData:
      .byte $0a, $0b

BulletBillCheepCheep:
         lda FrenzyEnemyTimer      ;if timer not expired yet, branch to leave
         bne ExF17
         lda AreaType              ;are we in a water-type level?
         bne DoBulletBills         ;if not, branch elsewhere
         cpx #$03                  ;are we past third enemy slot?
         bcs ExF17                 ;if so, branch to leave
         ldy #$00                  ;load default offset
         lda PseudoRandomBitReg,x
         cmp #$aa                  ;check first part of LSFR against preset value
         bcc ChkW2                 ;if less than preset, do not increment offset
         iny                       ;otherwise increment
ChkW2:   lda WorldNumber           ;check world number
         cmp #World2
         beq Get17ID               ;if we're on world 2, do not increment offset
         iny                       ;otherwise increment
Get17ID: tya
         and #%00000001            ;mask out all but last bit of offset
         tay
         lda SwimCC_IDData,y       ;load identifier for cheep-cheeps
Set17ID: sta Enemy_ID,x            ;store whatever's in A as enemy identifier
         lda BitMFilter
         cmp #$ff                  ;if not all bits set, skip init part and compare bits
         bne GetRBit
         lda #$00                  ;initialize vertical position filter
         sta BitMFilter
GetRBit: lda PseudoRandomBitReg,x  ;get first part of LSFR
         and #%00000111            ;mask out all but 3 LSB
ChkRBit: tay                       ;use as offset
         lda Bitmasks,y            ;load bitmask
         bit BitMFilter            ;perform AND on filter without changing it
         beq AddFBit
         iny                       ;increment offset
         tya
         and #%00000111            ;mask out all but 3 LSB thus keeping it 0-7
         jmp ChkRBit               ;do another check
AddFBit: ora BitMFilter            ;add bit to already set bits in filter
         sta BitMFilter            ;and store
         lda Enemy17YPosData,y     ;load vertical position using offset
         jsr PutAtRightExtent      ;set vertical position and other values
         sta Enemy_YMF_Dummy,x     ;initialize dummy variable
         lda #$20                  ;set timer
         sta FrenzyEnemyTimer
         jmp CheckpointEnemyID     ;process our new enemy object

DoBulletBills:
          ldy #$ff                   ;start at beginning of enemy slots
BB_SLoop: iny                        ;move onto the next slot
          cpy #$05                   ;branch to play sound if we've done all slots
          bcs FireBulletBill
          lda Enemy_Flag,y           ;if enemy buffer flag not set,
          beq BB_SLoop               ;loop back and check another slot
          lda Enemy_ID,y
          cmp #BulletBill_FrenzyVar  ;check enemy identifier for
          bne BB_SLoop               ;bullet bill object (frenzy variant)
ExF17:    rts                        ;if found, leave

FireBulletBill:
      lda Square2SoundQueue
      ora #Sfx_Blast            ;play fireworks/gunfire sound
      sta Square2SoundQueue
      lda #BulletBill_FrenzyVar ;load identifier for bullet bill object
      bne Set17ID               ;unconditional branch

;--------------------------------
;$00 - used to store Y position of group enemies
;$01 - used to store enemy ID
;$02 - used to store page location of right side of screen
;$03 - used to store X position of right side of screen

HandleGroupEnemies:
        ldy #$00                  ;load value for green koopa troopa
        sec
        sbc #$37                  ;subtract $37 from second byte read
        pha                       ;save result in stack for now
        cmp #$04                  ;was byte in $3b-$3e range?
        bcs SnglID                ;if so, branch
        pha                       ;save another copy to stack
        ldy #Goomba               ;load value for goomba enemy
        lda PrimaryHardMode       ;if primary hard mode flag not set,
        beq PullID                ;branch, otherwise change to value
        ldy #BuzzyBeetle          ;for buzzy beetle
PullID: pla                       ;get second copy from stack
SnglID: sty $01                   ;save enemy id here
        ldy #$b0                  ;load default y coordinate
        and #$02                  ;check to see if d1 was set
        beq SetYGp                ;if so, move y coordinate up,
        ldy #$70                  ;otherwise branch and use default
SetYGp: sty $00                   ;save y coordinate here
        lda ScreenRight_PageLoc   ;get page number of right edge of screen
        sta $02                   ;save here
        lda ScreenRight_X_Pos     ;get pixel coordinate of right edge
        sta $03                   ;save here
        ldy #$02                  ;load two enemies by default
        pla                       ;get first copy from stack
        lsr                       ;check to see if d0 was set
        bcc CntGrp                ;if not, use default value
        iny                       ;otherwise increment to three enemies
CntGrp: sty NumberofGroupEnemies  ;save number of enemies here
GrLoop: ldx #$ff                  ;start at beginning of enemy buffers
GSltLp: inx                       ;increment and branch if past
        cpx #$05                  ;end of buffers
        bcs NextED
        lda Enemy_Flag,x          ;check to see if enemy is already
        bne GSltLp                ;stored in buffer, and branch if so
        lda $01
        sta Enemy_ID,x            ;store enemy object identifier
        lda $02
        sta Enemy_PageLoc,x       ;store page location for enemy object
        lda $03
        sta Enemy_X_Position,x    ;store x coordinate for enemy object
        clc
        adc #$18                  ;add 24 pixels for next enemy
        sta $03
        lda $02                   ;add carry to page location for
        adc #$00                  ;next enemy
        sta $02
        lda $00                   ;store y coordinate for enemy object
        sta Enemy_Y_Position,x
        lda #$01                  ;activate flag for buffer, and
        sta Enemy_Y_HighPos,x     ;put enemy within the screen vertically
        sta Enemy_Flag,x
        jsr CheckpointEnemyID     ;process each enemy object separately
        dec NumberofGroupEnemies  ;do this until we run out of enemy objects
        bne GrLoop
NextED: jmp Inc2B                 ;jump to increment data offset and leave

;--------------------------------

InitPiranhaPlant:
      lda #$01                     ;set initial speed
      sta PiranhaPlant_Y_Speed,x
      lsr
      sta Enemy_State,x            ;initialize enemy state and what would normally
      sta PiranhaPlant_MoveFlag,x  ;be used as vertical speed, but not in this case
      lda Enemy_Y_Position,x
      sta PiranhaPlantDownYPos,x   ;save original vertical coordinate here
      sec
      sbc #$18
      sta PiranhaPlantUpYPos,x     ;save original vertical coordinate - 24 pixels here
      lda #$09
      jmp SetBBox2                 ;set specific value for bounding box control

;--------------------------------

InitEnemyFrenzy:
      lda Enemy_ID,x        ;load enemy identifier
      sta EnemyFrenzyBuffer ;save in enemy frenzy buffer
      sec
      sbc #$12              ;subtract 12 and use as offset for jump engine
      jsr JumpEngine

;frenzy object jump table
      .word LakituAndSpinyHandler
      .word NoFrenzyCode
      .word InitFlyingCheepCheep
      .word InitBowserFlame
      .word InitFireworks
      .word BulletBillCheepCheep

;--------------------------------

NoFrenzyCode:
      rts

;--------------------------------

EndFrenzy:
           ldy #$05               ;start at last slot
LakituChk: lda Enemy_ID,y         ;check enemy identifiers
           cmp #Lakitu            ;for lakitu
           bne NextFSlot
           lda #$01               ;if found, set state
           sta Enemy_State,y
NextFSlot: dey                    ;move onto the next slot
           bpl LakituChk          ;do this until all slots are checked
           lda #$00
           sta EnemyFrenzyBuffer  ;empty enemy frenzy buffer
           sta Enemy_Flag,x       ;disable enemy buffer flag for this object
           rts

;--------------------------------

InitJumpGPTroopa:
           lda #$02                  ;set for movement to the left
           sta Enemy_MovingDir,x
           lda #$f8                  ;set horizontal speed
           sta Enemy_X_Speed,x
TallBBox2: lda #$03                  ;set specific value for bounding box control
SetBBox2:  sta Enemy_BoundBoxCtrl,x  ;set bounding box control then leave
           rts

;--------------------------------

InitBalPlatform:
        dec Enemy_Y_Position,x    ;raise vertical position by two pixels
        dec Enemy_Y_Position,x
        ldy SecondaryHardMode     ;if secondary hard mode flag not set,
        bne AlignP                ;branch ahead
        ldy #$02                  ;otherwise set value here
        jsr PosPlatform           ;do a sub to add or subtract pixels
AlignP: ldy #$ff                  ;set default value here for now
        lda BalPlatformAlignment  ;get current balance platform alignment
        sta Enemy_State,x         ;set platform alignment to object state here
        bpl SetBPA                ;if old alignment $ff, put $ff as alignment for negative
        txa                       ;if old contents already $ff, put
        tay                       ;object offset as alignment to make next positive
SetBPA: sty BalPlatformAlignment  ;store whatever value's in Y here
        lda #$00
        sta Enemy_MovingDir,x     ;init moving direction
        tay                       ;init Y
        jsr PosPlatform           ;do a sub to add 8 pixels, then run shared code here

;--------------------------------

InitDropPlatform:
      lda #$ff
      sta PlatformCollisionFlag,x  ;set some value here
      jmp CommonPlatCode           ;then jump ahead to execute more code

;--------------------------------

InitHoriPlatform:
      lda #$00
      sta XMoveSecondaryCounter,x  ;init one of the moving counters
      jmp CommonPlatCode           ;jump ahead to execute more code

;--------------------------------

InitVertPlatform:
       ldy #$40                    ;set default value here
       lda Enemy_Y_Position,x      ;check vertical position
       bpl SetYO                   ;if above a certain point, skip this part
       eor #$ff
       clc                         ;otherwise get two's compliment
       adc #$01
       ldy #$c0                    ;get alternate value to add to vertical position
SetYO: sta YPlatformTopYPos,x      ;save as top vertical position
       tya
       clc                         ;load value from earlier, add number of pixels
       adc Enemy_Y_Position,x      ;to vertical position
       sta YPlatformCenterYPos,x   ;save result as central vertical position

;--------------------------------

CommonPlatCode:
        jsr InitVStf              ;do a sub to init certain other values
SPBBox: lda #$05                  ;set default bounding box size control
        ldy AreaType
        cpy #$03                  ;check for castle-type level
        beq CasPBB                ;use default value if found
        ldy SecondaryHardMode     ;otherwise check for secondary hard mode flag
        bne CasPBB                ;if set, use default value
        lda #$06                  ;use alternate value if not castle or secondary not set
CasPBB: sta Enemy_BoundBoxCtrl,x  ;set bounding box size control here and leave
        rts

;--------------------------------

LargeLiftUp:
      jsr PlatLiftUp       ;execute code for platforms going up
      jmp LargeLiftBBox    ;overwrite bounding box for large platforms

LargeLiftDown:
      jsr PlatLiftDown     ;execute code for platforms going down

LargeLiftBBox:
      jmp SPBBox           ;jump to overwrite bounding box size control

;--------------------------------

PlatLiftUp:
      lda #lift_speed_up       ;set movement amount here
      sta Enemy_Y_MoveForce,x
      lda #$ff                 ;set moving speed for platforms going up
      sta Enemy_Y_Speed,x
      jmp CommonSmallLift      ;skip ahead to part we should be executing

;--------------------------------

PlatLiftDown:
      lda #lift_speed_down    ;set movement amount here
      sta Enemy_Y_MoveForce,x
      lda #$00                 ;set moving speed for platforms going down
      sta Enemy_Y_Speed,x

;--------------------------------

CommonSmallLift:
      ldy #$01
      jsr PosPlatform           ;do a sub to add 12 pixels due to preset value
      lda #$04
      sta Enemy_BoundBoxCtrl,x  ;set bounding box control for small platforms
      rts

;--------------------------------

PlatPosDataLow:
      .byte $08,$0c,$f8

PlatPosDataHigh:
      .byte $00,$00,$ff

PosPlatform:
      lda Enemy_X_Position,x  ;get horizontal coordinate
      clc
      adc PlatPosDataLow,y    ;add or subtract pixels depending on offset
      sta Enemy_X_Position,x  ;store as new horizontal coordinate
      lda Enemy_PageLoc,x
      adc PlatPosDataHigh,y   ;add or subtract page location depending on offset
      sta Enemy_PageLoc,x     ;store as new page location
      rts                     ;and go back

;--------------------------------

EndOfEnemyInitCode:
      rts

;-------------------------------------------------------------------------------------
;$04 - address low to jump address
;$05 - address high to jump address
;$06 - jump address low
;$07 - jump address high

JumpEngine:
       asl          ;shift bit from contents of A
       tay
       pla          ;pull saved return address from stack
       sta $04      ;save to indirect
       pla
       sta $05
       iny
       lda ($04),y  ;load pointer from indirect
       sta $06      ;note that if an RTS is performed in next routine
       iny          ;it will return to the execution before the sub
       lda ($04),y  ;that called this routine
       sta $07
       jmp ($06)    ;jump to the address we loaded

;-------------------------------------------------------------------------------------
ProcessAreaData_:
			Switch_Bank 4
			jsr ProcessAreaData
			Switch_Bank 0
			rts

;-------------------------------------------------------------------------------------

ProcessAreaData:
            ldx #$02                 ;start at the end of area object buffer
ProcADLoop: stx ObjectOffset
            lda #$00                 ;reset flag
            sta BehindAreaParserFlag
            ldy AreaDataOffset       ;get offset of area data pointer
            lda (AreaData),y         ;get first byte of area object
            cmp #$fd                 ;if end-of-area, skip all this crap
            beq RdyDecode
            lda AreaObjectLength,x   ;check area object buffer flag
            bpl RdyDecode            ;if buffer not negative, branch, otherwise
            iny
            lda (AreaData),y         ;get second byte of area object
            asl                      ;check for page select bit (d7), branch if not set
            bcc Chk1Row13
            lda AreaObjectPageSel    ;check page select
            bne Chk1Row13
            inc AreaObjectPageSel    ;if not already set, set it now
            inc AreaObjectPageLoc    ;and increment page location
Chk1Row13:  dey
            lda (AreaData),y         ;reread first byte of level object
            and #$0f                 ;mask out high nybble
            cmp #$0d                 ;row 13?
            bne Chk1Row14
            iny                      ;if so, reread second byte of level object
            lda (AreaData),y
            dey                      ;decrement to get ready to read first byte
            and #%01000000           ;check for d6 set (if not, object is page control)
            bne CheckRear
            lda AreaObjectPageSel    ;if page select is set, do not reread
            bne CheckRear
            iny                      ;if d6 not set, reread second byte
            lda (AreaData),y
            and #%00011111           ;mask out all but 5 LSB and store in page control
            sta AreaObjectPageLoc
            inc AreaObjectPageSel    ;increment page select
            jmp NextAObj
Chk1Row14:  cmp #$0e                 ;row 14?
            bne CheckRear
            lda BackloadingFlag      ;check flag for saved page number and branch if set
            bne RdyDecode            ;to render the object (otherwise bg might not look right)
CheckRear:  lda AreaObjectPageLoc    ;check to see if current page of level object is
            cmp CurrentPageLoc       ;behind current page of renderer
            bcc SetBehind            ;if so branch
RdyDecode:  jsr DecodeAreaData       ;do sub and do not turn on flag
            jmp ChkLength
SetBehind:  inc BehindAreaParserFlag ;turn on flag if object is behind renderer
NextAObj:   jsr IncAreaObjOffset     ;increment buffer offset and move on
ChkLength:  ldx ObjectOffset         ;get buffer offset
            lda AreaObjectLength,x   ;check object length for anything stored here
            bmi ProcLoopb            ;if not, branch to handle loopback
            dec AreaObjectLength,x   ;otherwise decrement length or get rid of it
ProcLoopb:  dex                      ;decrement buffer offset
            bpl ProcADLoop           ;and loopback unless exceeded buffer
            lda BehindAreaParserFlag ;check for flag set if objects were behind renderer
            bne ProcessAreaData      ;branch if true to load more level data, otherwise
            lda BackloadingFlag      ;check for flag set if starting right of page $00
            bne ProcessAreaData      ;branch if true to load more level data, otherwise leave
EndAParse:  rts

IncAreaObjOffset:
      inc AreaDataOffset    ;increment offset of level pointer
      inc AreaDataOffset
      lda #$00              ;reset page select
      sta AreaObjectPageSel
      rts

DecodeAreaData:
          lda AreaObjectLength,x     ;check current buffer flag
          bmi Chk1stB
          ldy AreaObjOffsetBuffer,x  ;if not, get offset from buffer
Chk1stB:  ldx #$10                   ;load offset of 16 for special row 15
          lda (AreaData),y           ;get first byte of level object again
          cmp #$fd
          beq EndAParse              ;if end of level, leave this routine
          and #$0f                   ;otherwise, mask out low nybble
          cmp #$0f                   ;row 15?
          beq ChkRow14               ;if so, keep the offset of 16
          ldx #$08                   ;otherwise load offset of 8 for special row 12
          cmp #$0c                   ;row 12?
          beq ChkRow14               ;if so, keep the offset value of 8
          ldx #$00                   ;otherwise nullify value by default
ChkRow14: stx $07                    ;store whatever value we just loaded here
          ldx ObjectOffset           ;get object offset again
          cmp #$0e                   ;row 14?
          bne ChkRow13
          lda #$00                   ;if so, load offset with $00
          sta $07
          lda #$2e                   ;and load A with another value
          bne NormObj                ;unconditional branch
ChkRow13: cmp #$0d                   ;row 13?
          bne ChkSRows
          lda #$22                   ;if so, load offset with 34
          sta $07
          iny                        ;get next byte
          lda (AreaData),y
          and #%01000000             ;mask out all but d6 (page control obj bit)
          beq LeavePar               ;if d6 clear, branch to leave (we handled this earlier)
          lda (AreaData),y           ;otherwise, get byte again
          and #%01111111             ;mask out d7
          cmp #$4b                   ;check for loop command in low nybble
          bne Mask2MSB               ;(plus d6 set for object other than page control)
          inc LoopCommand            ;if loop command, set loop command flag
Mask2MSB: and #%00111111             ;mask out d7 and d6
          jmp NormObj                ;and jump
ChkSRows: cmp #$0c                   ;row 12-15?
          bcs SpecObj
          iny                        ;if not, get second byte of level object
          lda (AreaData),y
          and #%01110000             ;mask out all but d6-d4
          bne LrgObj                 ;if any bits set, branch to handle large object
          lda #$16
          sta $07                    ;otherwise set offset of 24 for small object
          lda (AreaData),y           ;reload second byte of level object
          and #%00001111             ;mask out higher nybble and jump
          jmp NormObj
LrgObj:   sta $00                    ;store value here (branch for large objects)
          cmp #$70                   ;check for vertical pipe object
          bne NotWPipe
          lda (AreaData),y           ;if not, reload second byte
          and #%00001000             ;mask out all but d3 (usage control bit)
          beq NotWPipe               ;if d3 clear, branch to get original value
          lda #$00                   ;otherwise, nullify value for warp pipe
          sta $00
NotWPipe: lda $00                    ;get value and jump ahead
          jmp MoveAOId
SpecObj:  iny                        ;branch here for rows 12-15
          lda (AreaData),y
          and #%01110000             ;get next byte and mask out all but d6-d4
MoveAOId: lsr                        ;move d6-d4 to lower nybble
          lsr
          lsr
          lsr
NormObj:  sta $00                    ;store value here (branch for small objects and rows 13 and 14)
          lda AreaObjectLength,x     ;is there something stored here already?
          bpl RunAObj                ;if so, branch to do its particular sub
          lda AreaObjectPageLoc      ;otherwise check to see if the object we've loaded is on the
          cmp CurrentPageLoc         ;same page as the renderer, and if so, branch
          beq InitRear
          ldy AreaDataOffset         ;if not, get old offset of level pointer
          lda (AreaData),y           ;and reload first byte
          and #%00001111
          cmp #$0e                   ;row 14?
          bne LeavePar
          lda BackloadingFlag        ;if so, check backloading flag
          bne StrAObj                ;if set, branch to render object, else leave
LeavePar: rts
InitRear: lda BackloadingFlag        ;check backloading flag to see if it's been initialized
          beq BackColC               ;branch to column-wise check
          lda #$00                   ;if not, initialize both backloading and
          sta BackloadingFlag        ;behind-renderer flags and leave
          sta BehindAreaParserFlag
          sta ObjectOffset
LoopCmdE: rts
BackColC: ldy AreaDataOffset         ;get first byte again
          lda (AreaData),y
          and #%11110000             ;mask out low nybble and move high to low
          lsr
          lsr
          lsr
          lsr
          cmp CurrentColumnPos       ;is this where we're at?
          bne LeavePar               ;if not, branch to leave
StrAObj:  lda AreaDataOffset         ;if so, load area obj offset and store in buffer
          sta AreaObjOffsetBuffer,x
          jsr IncAreaObjOffset       ;do sub to increment to next object data
RunAObj:  lda $00                    ;get stored value and add offset to it
          clc                        ;then use the jump engine with current contents of A
          adc $07
          jsr JumpEngine

;large objects (rows $00-$0b or 00-11, d6-d4 set)
      .word VerticalPipe         ;used by warp pipes
      .word AreaStyleObject
      .word RowOfBricks
      .word RowOfSolidBlocks
      .word RowOfCoins
      .word ColumnOfBricks
      .word ColumnOfSolidBlocks
      .word VerticalPipe         ;used by decoration pipes

;objects for special row $0c or 12
      .word Hole_Empty
      .word PulleyRopeObject
      .word Bridge_High
      .word Bridge_Middle
      .word Bridge_Low
      .word Hole_Water
      .word QuestionBlockRow_High
      .word QuestionBlockRow_Low

;objects for special row $0f or 15
      .word EndlessRope
      .word BalancePlatRope
      .word CastleObject
      .word StaircaseObject
      .word ExitPipe
      .word FlagBalls_Residual

;small objects (rows $00-$0b or 00-11, d6-d4 all clear)
      .word QuestionBlock     ;power-up
      .word QuestionBlock     ;coin
      .word QuestionBlock     ;hidden, coin
      .word Hidden1UpBlock    ;hidden, 1-up
      .word BrickWithItem     ;brick, power-up
      .word BrickWithItem     ;brick, vine
      .word BrickWithItem     ;brick, star
      .word BrickWithCoins    ;brick, coins
      .word BrickWithItem     ;brick, 1-up
      .word WaterPipe
      .word EmptyBlock
      .word Jumpspring

;objects for special row $0d or 13 (d6 set)
      .word IntroPipe
      .word FlagpoleObject
      .word AxeObj
      .word ChainObj
      .word CastleBridgeObj
      .word ScrollLockObject_Warp
      .word ScrollLockObject
      .word ScrollLockObject
      .word AreaFrenzy            ;flying cheep-cheeps
      .word AreaFrenzy            ;bullet bills or swimming cheep-cheeps
      .word AreaFrenzy            ;stop frenzy
      .word LoopCmdE

;object for special row $0e or 14
      .word AlterAreaAttributes

;-------------------------------------------------------------------------------------
;(these apply to all area object subroutines in this section unless otherwise stated)
;$00 - used to store offset used to find object code
;$07 - starts with adder from area parser, used to store row offset

AlterAreaAttributes:
         ldy AreaObjOffsetBuffer,x ;load offset for level object data saved in buffer
         iny                       ;load second byte
         lda (AreaData),y
         pha                       ;save in stack for now
         and #%01000000
         bne Alter2                ;branch if d6 is set
         pla
         pha                       ;pull and push offset to copy to A
         and #%00001111            ;mask out high nybble and store as
         sta TerrainControl        ;new terrain height type bits
         pla
         and #%00110000            ;pull and mask out all but d5 and d4
         lsr                       ;move bits to lower nybble and store
         lsr                       ;as new background scenery bits
         lsr
         lsr
         sta BackgroundScenery     ;then leave
         rts
Alter2:  pla
         and #%00000111            ;mask out all but 3 LSB
         cmp #$04                  ;if four or greater, set color control bits
         bcc SetFore               ;and nullify foreground scenery bits
         sta BackgroundColorCtrl
         lda #$00
SetFore: sta ForegroundScenery     ;otherwise set new foreground scenery bits
         rts

;--------------------------------

ScrollLockObject_Warp:
         ldx #$04            ;load value of 4 for game text routine as default
         lda WorldNumber     ;warp zone (4-3-2), then check world number
         beq WarpNum
         inx                 ;if world number > 1, increment for next warp zone (5)
         ldy AreaType        ;check area type
         dey
         bne WarpNum         ;if ground area type, increment for last warp zone
         inx                 ;(8-7-6) and move on
WarpNum: txa
         sta WarpZoneControl ;store number here to be used by warp zone routine
         jsr WriteGameText   ;print text and warp zone numbers
         lda #PiranhaPlant
         jsr KillEnemies     ;load identifier for piranha plants and do sub

ScrollLockObject:
      lda ScrollLock      ;invert scroll lock to turn it on
      eor #%00000001
      sta ScrollLock
      rts

;--------------------------------
;$00 - used to store enemy identifier in KillEnemies

KillEnemies:
           sta $00           ;store identifier here
           lda #$00
           ldx #$04          ;check for identifier in enemy object buffer
KillELoop: ldy Enemy_ID,x
           cpy $00           ;if not found, branch
           bne NoKillE
           sta Enemy_Flag,x  ;if found, deactivate enemy object flag
NoKillE:   dex               ;do this until all slots are checked
           bpl KillELoop
           rts

;--------------------------------

FrenzyIDData:
      .byte FlyCheepCheepFrenzy, BBill_CCheep_Frenzy, Stop_Frenzy

AreaFrenzy:  ldx $00               ;use area object identifier bit as offset
             lda FrenzyIDData-8,x  ;note that it starts at 8, thus weird address here
             ldy #$05
FreCompLoop: dey                   ;check regular slots of enemy object buffer
             bmi ExitAFrenzy       ;if all slots checked and enemy object not found, branch to store
             cmp Enemy_ID,y    ;check for enemy object in buffer versus frenzy object
             bne FreCompLoop
             lda #$00              ;if enemy object already present, nullify queue and leave
ExitAFrenzy: sta EnemyFrenzyQueue  ;store enemy into frenzy queue
             rts

;--------------------------------
;$06 - used by MushroomLedge to store length

AreaStyleObject:
      lda AreaStyle        ;load level object style and jump to the right sub
      jsr JumpEngine
      .word TreeLedge        ;also used for cloud type levels
      .word MushroomLedge
      .word BulletBillCannon

TreeLedge:
          jsr GetLrgObjAttrib     ;get row and length of green ledge
          lda AreaObjectLength,x  ;check length counter for expiration
          beq EndTreeL
          bpl MidTreeL
          tya
          sta AreaObjectLength,x  ;store lower nybble into buffer flag as length of ledge
          lda CurrentPageLoc
          ora CurrentColumnPos    ;are we at the start of the level?
          beq MidTreeL
          lda #$16                ;render start of tree ledge
          jmp NoUnder
MidTreeL: ldx $07
          lda #$17                ;render middle of tree ledge
          sta MetatileBuffer,x    ;note that this is also used if ledge position is
          lda #$4c                ;at the start of level for continuous effect
          jmp AllUnder            ;now render the part underneath
EndTreeL: lda #$18                ;render end of tree ledge
          jmp NoUnder

MushroomLedge:
          jsr ChkLrgObjLength        ;get shroom dimensions
          sty $06                    ;store length here for now
          bcc EndMushL
          lda AreaObjectLength,x     ;divide length by 2 and store elsewhere
          lsr
          sta MushroomLedgeHalfLen,x
          lda #$19                   ;render start of mushroom
          jmp NoUnder
EndMushL: lda #$1b                   ;if at the end, render end of mushroom
          ldy AreaObjectLength,x
          beq NoUnder
          lda MushroomLedgeHalfLen,x ;get divided length and store where length
          sta $06                    ;was stored originally
          ldx $07
          lda #$1a
          sta MetatileBuffer,x       ;render middle of mushroom
          cpy $06                    ;are we smack dab in the center?
          bne MushLExit              ;if not, branch to leave
          inx
          lda #$4f
          sta MetatileBuffer,x       ;render stem top of mushroom underneath the middle
          lda #$50
AllUnder: inx
          ldy #$0f                   ;set $0f to render all way down
          jmp RenderUnderPart       ;now render the stem of mushroom
NoUnder:  ldx $07                    ;load row of ledge
          ldy #$00                   ;set 0 for no bottom on this part
          jmp RenderUnderPart

;--------------------------------

;tiles used by pulleys and rope object
PulleyRopeMetatiles:
      .byte $42, $41, $43

PulleyRopeObject:
           jsr ChkLrgObjLength       ;get length of pulley/rope object
           ldy #$00                  ;initialize metatile offset
           bcs RenderPul             ;if starting, render left pulley
           iny
           lda AreaObjectLength,x    ;if not at the end, render rope
           bne RenderPul
           iny                       ;otherwise render right pulley
RenderPul: lda PulleyRopeMetatiles,y
           sta MetatileBuffer        ;render at the top of the screen
MushLExit: rts                       ;and leave

;--------------------------------
;$06 - used to store upper limit of rows for CastleObject

CastleMetatiles:
      .byte $00, $45, $45, $45, $00
      .byte $00, $48, $47, $46, $00
      .byte $45, $49, $49, $49, $45
      .byte $47, $47, $4a, $47, $47
      .byte $47, $47, $4b, $47, $47
      .byte $49, $49, $49, $49, $49
      .byte $47, $4a, $47, $4a, $47
      .byte $47, $4b, $47, $4b, $47
      .byte $47, $47, $47, $47, $47
      .byte $4a, $47, $4a, $47, $4a
      .byte $4b, $47, $4b, $47, $4b

CastleObject:
            jsr GetLrgObjAttrib      ;save lower nybble as starting row
            sty $07                  ;if starting row is above $0a, game will crash!!!
            ldy #$04
            jsr ChkLrgObjFixedLength ;load length of castle if not already loaded
            txa
            pha                      ;save obj buffer offset to stack
            ldy AreaObjectLength,x   ;use current length as offset for castle data
            ldx $07                  ;begin at starting row
            lda #$0b
            sta $06                  ;load upper limit of number of rows to print
CRendLoop:  lda CastleMetatiles,y    ;load current byte using offset
            sta MetatileBuffer,x
            inx                      ;store in buffer and increment buffer offset
            lda $06
            beq ChkCFloor            ;have we reached upper limit yet?
            iny                      ;if not, increment column-wise
            iny                      ;to byte in next row
            iny
            iny
            iny
            dec $06                  ;move closer to upper limit
ChkCFloor:  cpx #$0b                 ;have we reached the row just before floor?
            bne CRendLoop            ;if not, go back and do another row
            pla
            tax                      ;get obj buffer offset from before
            lda CurrentPageLoc
            beq ExitCastle           ;if we're at page 0, we do not need to do anything else
            lda AreaObjectLength,x   ;check length
            cmp #$01                 ;if length almost about to expire, put brick at floor
            beq PlayerStop
            ldy $07                  ;check starting row for tall castle ($00)
            bne NotTall
            cmp #$03                 ;if found, then check to see if we're at the second column
            beq PlayerStop
NotTall:    cmp #$02                 ;if not tall castle, check to see if we're at the third column
            bne ExitCastle           ;if we aren't and the castle is tall, don't create flag yet
            jsr GetAreaObjXPosition  ;otherwise, obtain and save horizontal pixel coordinate
            pha
            jsr FindEmptyEnemySlot   ;find an empty place on the enemy object buffer
            pla
            sta Enemy_X_Position,x   ;then write horizontal coordinate for star flag
            lda CurrentPageLoc
            sta Enemy_PageLoc,x      ;set page location for star flag
            lda #$01
            sta Enemy_Y_HighPos,x    ;set vertical high byte
            sta Enemy_Flag,x         ;set flag for buffer
            lda #$90
            sta Enemy_Y_Position,x   ;set vertical coordinate
            lda #StarFlagObject      ;set star flag value in buffer itself
            sta Enemy_ID,x
            rts
PlayerStop: ldy #$52                 ;put brick at floor to stop player at end of level
            sty MetatileBuffer+10    ;this is only done if we're on the second column
ExitCastle: rts

;--------------------------------

WaterPipe:
      jsr GetLrgObjAttrib     ;get row and lower nybble
      ldy AreaObjectLength,x  ;get length (residual code, water pipe is 1 col thick)
      ldx $07                 ;get row
      lda #$6b
      sta MetatileBuffer,x    ;draw something here and below it
      lda #$6c
      sta MetatileBuffer+1,x
      rts

;--------------------------------
;$05 - used to store length of vertical shaft in RenderSidewaysPipe
;$06 - used to store leftover horizontal length in RenderSidewaysPipe
; and vertical length in VerticalPipe and GetPipeHeight

IntroPipe:
               ldy #$03                 ;check if length set, if not set, set it
               jsr ChkLrgObjFixedLength
               ldy #$0a                 ;set fixed value and render the sideways part
               jsr RenderSidewaysPipe
               bcs NoBlankP             ;if carry flag set, not time to draw vertical pipe part
               ldx #$06                 ;blank everything above the vertical pipe part
VPipeSectLoop: lda #$00                 ;all the way to the top of the screen
               sta MetatileBuffer,x     ;because otherwise it will look like exit pipe
               dex
               bpl VPipeSectLoop
               lda VerticalPipeData,y   ;draw the end of the vertical pipe part
               sta MetatileBuffer+7
NoBlankP:      rts

SidePipeShaftData:
      .byte $15, $14  ;used to control whether or not vertical pipe shaft
      .byte $00, $00  ;is drawn, and if so, controls the metatile number
SidePipeTopPart:
      .byte $15, $1e  ;top part of sideways part of pipe
      .byte $1d, $1c
SidePipeBottomPart:
      .byte $15, $21  ;bottom part of sideways part of pipe
      .byte $20, $1f

ExitPipe:
      ldy #$03                 ;check if length set, if not set, set it
      jsr ChkLrgObjFixedLength
      jsr GetLrgObjAttrib      ;get vertical length, then plow on through RenderSidewaysPipe

RenderSidewaysPipe:
              dey                       ;decrement twice to make room for shaft at bottom
              dey                       ;and store here for now as vertical length
              sty $05
              ldy AreaObjectLength,x    ;get length left over and store here
              sty $06
              ldx $05                   ;get vertical length plus one, use as buffer offset
              inx
              lda SidePipeShaftData,y   ;check for value $00 based on horizontal offset
              cmp #$00
              beq DrawSidePart          ;if found, do not draw the vertical pipe shaft
              ldx #$00
              ldy $05                   ;init buffer offset and get vertical length
              jsr RenderUnderPart       ;and render vertical shaft using tile number in A
              clc                       ;clear carry flag to be used by IntroPipe
DrawSidePart: ldy $06                   ;render side pipe part at the bottom
              lda SidePipeTopPart,y
              sta MetatileBuffer,x      ;note that the pipe parts are stored
              lda SidePipeBottomPart,y  ;backwards horizontally
              sta MetatileBuffer+1,x
              rts

VerticalPipeData:
      .byte $11, $10 ;used by pipes that lead somewhere
      .byte $15, $14
      .byte $13, $12 ;used by decoration pipes
      .byte $15, $14

VerticalPipe:
          jsr GetPipeHeight
          lda $00                  ;check to see if value was nullified earlier
          beq WarpPipe             ;(if d3, the usage control bit of second byte, was set)
          iny
          iny
          iny
          iny                      ;add four if usage control bit was not set
WarpPipe: tya                      ;save value in stack
          pha
          lda AreaNumber
          ora WorldNumber          ;if at world 1-1, do not add piranha plant ever
          beq DrawPipe
          ldy AreaObjectLength,x   ;if on second column of pipe, branch
          beq DrawPipe             ;(because we only need to do this once)
          jsr FindEmptyEnemySlot   ;check for an empty moving data buffer space
          bcs DrawPipe             ;if not found, too many enemies, thus skip
          jsr GetAreaObjXPosition  ;get horizontal pixel coordinate
          clc
          adc #$08                 ;add eight to put the piranha plant in the center
          sta Enemy_X_Position,x   ;store as enemy's horizontal coordinate
          lda CurrentPageLoc       ;add carry to current page number
          adc #$00
          sta Enemy_PageLoc,x      ;store as enemy's page coordinate
          lda #$01
          sta Enemy_Y_HighPos,x
          sta Enemy_Flag,x         ;activate enemy flag
          jsr GetAreaObjYPosition  ;get piranha plant's vertical coordinate and store here
          sta Enemy_Y_Position,x
          lda #PiranhaPlant        ;write piranha plant's value into buffer
          sta Enemy_ID,x
          jsr InitPiranhaPlant
DrawPipe: pla                      ;get value saved earlier and use as Y
          tay
          ldx $07                  ;get buffer offset
          lda VerticalPipeData,y   ;draw the appropriate pipe with the Y we loaded earlier
          sta MetatileBuffer,x     ;render the top of the pipe
          inx
          lda VerticalPipeData+2,y ;render the rest of the pipe
          ldy $06                  ;subtract one from length and render the part underneath
          dey
          jmp RenderUnderPart

GetPipeHeight:
      ldy #$01       ;check for length loaded, if not, load
      jsr ChkLrgObjFixedLength ;pipe length of 2 (horizontal)
      jsr GetLrgObjAttrib
      tya            ;get saved lower nybble as height
      and #$07       ;save only the three lower bits as
      sta $06        ;vertical length, then load Y with
      ldy AreaObjectLength,x    ;length left over
      rts

FindEmptyEnemySlot:
              ldx #$00          ;start at first enemy slot
EmptyChkLoop: clc               ;clear carry flag by default
              lda Enemy_Flag,x  ;check enemy buffer for nonzero
              beq ExitEmptyChk  ;if zero, leave
              inx
              cpx #$05          ;if nonzero, check next value
              bne EmptyChkLoop
ExitEmptyChk: rts               ;if all values nonzero, carry flag is set

;--------------------------------

Hole_Water:
      jsr ChkLrgObjLength   ;get low nybble and save as length
      lda #$86              ;render waves
      sta MetatileBuffer+10
      ldx #$0b
      ldy #$01              ;now render the water underneath
      lda #$87
      jmp RenderUnderPart

;--------------------------------

QuestionBlockRow_High:
      lda #$03    ;start on the fourth row
      .byte $2c     ;BIT instruction opcode

QuestionBlockRow_Low:
      lda #$07             ;start on the eighth row
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render question boxes with coins
      lda #$c0
      sta MetatileBuffer,x
      rts

;--------------------------------

Bridge_High:
      lda #$06  ;start on the seventh row from top of screen
      .byte $2c   ;BIT instruction opcode

Bridge_Middle:
      lda #$07  ;start on the eighth row
      .byte $2c   ;BIT instruction opcode

Bridge_Low:
      lda #$09             ;start on the tenth row
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render bridge railing
      lda #$0b
      sta MetatileBuffer,x
      inx
      ldy #$00             ;now render the bridge itself
      lda #$63
      jmp RenderUnderPart

;--------------------------------

FlagBalls_Residual:
      jsr GetLrgObjAttrib  ;get low nybble from object byte
      ldx #$02             ;render flag balls on third row from top
      lda #$6d             ;of screen downwards based on low nybble
      jmp RenderUnderPart

;--------------------------------

FlagpoleObject:
      lda #$24                 ;render flagpole ball on top
      sta MetatileBuffer
      ldx #$01                 ;now render the flagpole shaft
      ldy #$08
      lda #$25
      jsr RenderUnderPart
      lda #$61                 ;render solid block at the bottom
      sta MetatileBuffer+10
      jsr GetAreaObjXPosition
      sec                      ;get pixel coordinate of where the flagpole is,
      sbc #$08                 ;subtract eight pixels and use as horizontal
      sta Enemy_X_Position+5   ;coordinate for the flag
      lda CurrentPageLoc
      sbc #$00                 ;subtract borrow from page location and use as
      sta Enemy_PageLoc+5      ;page location for the flag
      lda #$30
      sta Enemy_Y_Position+5   ;set vertical coordinate for flag
      lda #$b0
      sta FlagpoleFNum_Y_Pos   ;set initial vertical coordinate for flagpole's floatey number
      lda #FlagpoleFlagObject
      sta Enemy_ID+5           ;set flag identifier, note that identifier and coordinates
      inc Enemy_Flag+5         ;use last space in enemy object buffer
      rts

;--------------------------------

EndlessRope:
      ldx #$00       ;render rope from the top to the bottom of screen
      ldy #$0f
      jmp DrawRope

BalancePlatRope:
          txa                 ;save object buffer offset for now
          pha
          ldx #$01            ;blank out all from second row to the bottom
          ldy #$0f            ;with blank used for balance platform rope
          lda #$44
          jsr RenderUnderPart
          pla                 ;get back object buffer offset
          tax
          jsr GetLrgObjAttrib ;get vertical length from lower nybble
          ldx #$01
DrawRope: lda #$40            ;render the actual rope
          jmp RenderUnderPart

;--------------------------------

CoinMetatileData:
      .byte $c3, $c2, $c2, $c2

RowOfCoins:
      ldy AreaType            ;get area type
      lda CoinMetatileData,y  ;load appropriate coin metatile
      jmp GetRow

;--------------------------------

C_ObjectRow:
      .byte $06, $07, $08

C_ObjectMetatile:
      .byte $c5, $0c, $89

CastleBridgeObj:
      ldy #$0c                  ;load length of 13 columns
      jsr ChkLrgObjFixedLength
      jmp ChainObj

AxeObj:
      lda #$08                  ;load bowser's palette into sprite portion of palette
      sta VRAM_Buffer_AddrCtrl

ChainObj:
      ldy $00                   ;get value loaded earlier from decoder
      ldx C_ObjectRow-2,y       ;get appropriate row and metatile for object
      lda C_ObjectMetatile-2,y
      jmp ColObj

EmptyBlock:
        jsr GetLrgObjAttrib  ;get row location
        ldx $07
        lda #$c4
ColObj: ldy #$00             ;column length of 1
        jmp RenderUnderPart

;--------------------------------

SolidBlockMetatiles:
      .byte $69, $61, $61, $62

BrickMetatiles:
      .byte $22, $51, $52, $52
      .byte $88 ;used only by row of bricks object

RowOfBricks:
            ldy AreaType           ;load area type obtained from area offset pointer
            lda CloudTypeOverride  ;check for cloud type override
            beq DrawBricks
            ldy #$04               ;if cloud type, override area type
DrawBricks: lda BrickMetatiles,y   ;get appropriate metatile
            jmp GetRow             ;and go render it

RowOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset pointer
         lda SolidBlockMetatiles,y  ;get metatile
GetRow:  pha                        ;store metatile here
         jsr ChkLrgObjLength        ;get row number, load length
DrawRow: ldx $07
         ldy #$00                   ;set vertical height of 1
         pla
         jmp RenderUnderPart        ;render object

ColumnOfBricks:
      ldy AreaType          ;load area type obtained from area offset
      lda BrickMetatiles,y  ;get metatile (no cloud override as for row)
      jmp GetRow2

ColumnOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset
         lda SolidBlockMetatiles,y  ;get metatile
GetRow2: pha                        ;save metatile to stack for now
         jsr GetLrgObjAttrib        ;get length and row
         pla                        ;restore metatile
         ldx $07                    ;get starting row
         jmp RenderUnderPart        ;now render the column

;--------------------------------

BulletBillCannon:
             jsr GetLrgObjAttrib      ;get row and length of bullet bill cannon
             ldx $07                  ;start at first row
             lda #$64                 ;render bullet bill cannon
             sta MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             lda #$65                 ;if not, render middle part
             sta MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             lda #$66                 ;if not, render bottom until length expires
             jsr RenderUnderPart
SetupCannon: ldx Cannon_Offset        ;get offset for data used by cannons and whirlpools
             jsr GetAreaObjYPosition  ;get proper vertical coordinate for cannon
             sta Cannon_Y_Position,x  ;and store it here
             lda CurrentPageLoc
             sta Cannon_PageLoc,x     ;store page number for cannon here
             jsr GetAreaObjXPosition  ;get proper horizontal coordinate for cannon
             sta Cannon_X_Position,x  ;and store it here
             inx
             cpx #$06                 ;increment and check offset
             bcc StrCOffset           ;if not yet reached sixth cannon, branch to save offset
             ldx #$00                 ;otherwise initialize it
StrCOffset:  stx Cannon_Offset        ;save new offset and leave
             rts

;--------------------------------

StaircaseHeightData:
      .byte $07, $07, $06, $05, $04, $03, $02, $01, $00

StaircaseRowData:
      .byte $03, $03, $04, $05, $06, $07, $08, $09, $0a

StaircaseObject:
           jsr ChkLrgObjLength       ;check and load length
           bcc NextStair             ;if length already loaded, skip init part
           lda #$09                  ;start past the end for the bottom
           sta StaircaseControl      ;of the staircase
NextStair: dec StaircaseControl      ;move onto next step (or first if starting)
           ldy StaircaseControl
           ldx StaircaseRowData,y    ;get starting row and height to render
           lda StaircaseHeightData,y
           tay
           lda #$61                  ;now render solid block staircase
           jmp RenderUnderPart

;--------------------------------

Jumpspring:
      jsr GetLrgObjAttrib
      jsr FindEmptyEnemySlot      ;find empty space in enemy object buffer
      jsr GetAreaObjXPosition     ;get horizontal coordinate for jumpspring
      sta Enemy_X_Position,x      ;and store
      lda CurrentPageLoc          ;store page location of jumpspring
      sta Enemy_PageLoc,x
      jsr GetAreaObjYPosition     ;get vertical coordinate for jumpspring
      sta Enemy_Y_Position,x      ;and store
      sta Jumpspring_FixedYPos,x  ;store as permanent coordinate here
      lda #JumpspringObject
      sta Enemy_ID,x              ;write jumpspring object to enemy object buffer
      ldy #$01
      sty Enemy_Y_HighPos,x       ;store vertical high byte
      inc Enemy_Flag,x            ;set flag for enemy object buffer
      ldx $07
      lda #$67                    ;draw metatiles in two rows where jumpspring is
      sta MetatileBuffer,x
      lda #$68
      sta MetatileBuffer+1,x
      rts

;--------------------------------

BrickQBlockMetatiles:
      .byte $c1, $c0, $5f, $60 ;used by question blocks

      ;these two sets are functionally identical, but look different
      .byte $55, $56, $57, $58, $59 ;used by ground level types
      .byte $5a, $5b, $5c, $5d, $5e ;used by other level types

;--------------------------------
;$07 - used to save ID of brick object

Hidden1UpBlock:
.if _1up_always = 0
      lda Hidden1UpFlag  ;if flag not set, do not render object
      beq ExitDecBlock
      lda #$00           ;if set, init for the next one
      sta Hidden1UpFlag
.endif
      jmp BrickWithItem  ;jump to code shared with unbreakable bricks

QuestionBlock:
      jsr GetAreaObjectID ;get value from level decoder routine
      jmp DrawQBlk        ;go to render it

BrickWithCoins:
      lda #$00                 ;initialize multi-coin timer flag
      sta BrickCoinTimerFlag

BrickWithItem:
          jsr GetAreaObjectID         ;save area object ID
          sty $07
          lda #$00                    ;load default adder for bricks with lines
          ldy AreaType                ;check level type for ground level
          dey
          beq BWithL                  ;if ground type, do not start with 5
          lda #$05                    ;otherwise use adder for bricks without lines
BWithL:   clc                         ;add object ID to adder
          adc $07
          tay                         ;use as offset for metatile
DrawQBlk: lda BrickQBlockMetatiles,y  ;get appropriate metatile for brick (question block
          pha                         ;if branched to here from question block routine)
          jsr GetLrgObjAttrib         ;get row from location byte
          jmp DrawRow                 ;now render the object

GetAreaObjectID:
              lda $00    ;get value saved from area parser routine
              sec
              sbc #$00   ;possibly residual code
              tay        ;save to Y
ExitDecBlock: rts

;--------------------------------

HoleMetatiles:
      .byte $87, $00, $00, $00

Hole_Empty:
            jsr ChkLrgObjLength          ;get lower nybble and save as length
            bcc NoWhirlP                 ;skip this part if length already loaded
            lda AreaType                 ;check for water type level
            bne NoWhirlP                 ;if not water type, skip this part
            ldx Whirlpool_Offset         ;get offset for data used by cannons and whirlpools
            jsr GetAreaObjXPosition      ;get proper vertical coordinate of where we're at
            sec
            sbc #$10                     ;subtract 16 pixels
            sta Whirlpool_LeftExtent,x   ;store as left extent of whirlpool
            lda CurrentPageLoc           ;get page location of where we're at
            sbc #$00                     ;subtract borrow
            sta Whirlpool_PageLoc,x      ;save as page location of whirlpool
            iny
            iny                          ;increment length by 2
            tya
            asl                          ;multiply by 16 to get size of whirlpool
            asl                          ;note that whirlpool will always be
            asl                          ;two blocks bigger than actual size of hole
            asl                          ;and extend one block beyond each edge
            sta Whirlpool_Length,x       ;save size of whirlpool here
            inx
            cpx #$05                     ;increment and check offset
            bcc StrWOffset               ;if not yet reached fifth whirlpool, branch to save offset
            ldx #$00                     ;otherwise initialize it
StrWOffset: stx Whirlpool_Offset         ;save new offset here
NoWhirlP:   ldx AreaType                 ;get appropriate metatile, then
            lda HoleMetatiles,x          ;render the hole proper
            ldx #$08
            ldy #$0f                     ;start at ninth row and go to bottom, run RenderUnderPart

;--------------------------------

RenderUnderPart:
             sty AreaObjectHeight  ;store vertical length to render
             ldy MetatileBuffer,x  ;check current spot to see if there's something
             beq DrawThisRow       ;we need to keep, if nothing, go ahead
             cpy #$17
             beq WaitOneRow        ;if middle part (tree ledge), wait until next row
             cpy #$1a
             beq WaitOneRow        ;if middle part (mushroom ledge), wait until next row
             cpy #$c0
             beq DrawThisRow       ;if question block w/ coin, overwrite
             cpy #$c0
             bcs WaitOneRow        ;if any other metatile with palette 3, wait until next row
             cpy #$54
             bne DrawThisRow       ;if cracked rock terrain, overwrite
             cmp #$50
             beq WaitOneRow        ;if stem top of mushroom, wait until next row
DrawThisRow: sta MetatileBuffer,x  ;render contents of A from routine that called this
WaitOneRow:  inx
             cpx #$0d              ;stop rendering if we're at the bottom of the screen
             bcs ExitUPartR
             ldy AreaObjectHeight  ;decrement, and stop rendering if there is no more length
             dey
             bpl RenderUnderPart
ExitUPartR:  rts

;--------------------------------

ChkLrgObjLength:
        jsr GetLrgObjAttrib     ;get row location and size (length if branched to from here)

ChkLrgObjFixedLength:
        lda AreaObjectLength,x  ;check for set length counter
        clc                     ;clear carry flag for not just starting
        bpl LenSet              ;if counter not set, load it, otherwise leave alone
        tya                     ;save length into length counter
        sta AreaObjectLength,x
        sec                     ;set carry flag if just starting
LenSet: rts


GetLrgObjAttrib:
      ldy AreaObjOffsetBuffer,x ;get offset saved from area obj decoding routine
      lda (AreaData),y          ;get first byte of level object
      and #%00001111
      sta $07                   ;save row location
      iny
      lda (AreaData),y          ;get next byte, save lower nybble (length or height)
      and #%00001111            ;as Y, then leave
      tay
      rts

;--------------------------------

GetAreaObjXPosition:
      lda CurrentColumnPos    ;multiply current offset where we're at by 16
      asl                     ;to obtain horizontal pixel coordinate
      asl
      asl
      asl
      rts

;--------------------------------

GetAreaObjYPosition:
      lda $07  ;multiply value by 16
      asl
      asl      ;this will give us the proper vertical pixel coordinate
      asl
      asl
      clc
      adc #32  ;add 32 pixels for the status bar
      rts

;-------------------------------------------------------------------------------------
;$06-$07 - used to store block buffer address used as indirect

BlockBufferAddr:
      .byte <Block_Buffer_1, <Block_Buffer_2
      .byte >Block_Buffer_1, >Block_Buffer_2

GetBlockBufferAddr:
      pha                      ;take value of A, save
      lsr                      ;move high nybble to low
      lsr
      lsr
      lsr
      tay                      ;use nybble as pointer to high byte
      lda BlockBufferAddr+2,y  ;of indirect here
      sta $07
      pla
      and #%00001111           ;pull from stack, mask out high nybble
      clc
      adc BlockBufferAddr,y    ;add to low byte
      sta $06                  ;store here and leave
      rts

;-------------------------------------------------------------------------------------

;unused space
      .byte $ff, $ff

;-------------------------------------------------------------------------------------

AreaDataOfsLoopback:
      .byte $12, $36, $0e, $0e, $0e, $32, $32, $32, $0a, $26, $40

;-------------------------------------------------------------------------------------

WarpZoneNumbers:
  .byte $04, $03, $02, $00         ; warp zone numbers, note spaces on middle
  .byte $24, $05, $24, $00         ; zone, partly responsible for
  .byte $08, $07, $06, $00         ; the minus world

HandlePipeEntry:
		 Switch_Bank 4
         lda Up_Down_Buttons       ;check saved controller bits from earlier
         and #%00000100            ;for pressing down
         beq ExPipeE               ;if not pressing down, branch to leave
         lda $00
         cmp #$11                  ;check right foot metatile for warp pipe right metatile
         bne ExPipeE               ;branch to leave if not found
         lda $01
         cmp #$10                  ;check left foot metatile for warp pipe left metatile
         bne ExPipeE               ;branch to leave if not found
         lda #$30
         sta ChangeAreaTimer       ;set timer for change of area
         lda #$03
         sta GameEngineSubroutine  ;set to run vertical pipe entry routine on next frame
         lda #Sfx_PipeDown_Injury
         sta Square1SoundQueue     ;load pipedown/injury sound
         lda #%00100000
         sta Player_SprAttrib      ;set background priority bit in player's attributes
         lda WarpZoneControl       ;check warp zone control
         beq ExPipeE               ;branch to leave if none found
         and #%00000011            ;mask out all but 2 LSB
         asl
         asl                       ;multiply by four
         tax                       ;save as offset to warp zone numbers (starts at left pipe)
         lda Player_X_Position     ;get player's horizontal position
         cmp #$60
         bcc GetWNum               ;if player at left, not near middle, use offset and skip ahead
         inx                       ;otherwise increment for middle pipe
         cmp #$a0
         bcc GetWNum               ;if player at middle, but not too far right, use offset and skip
         inx                       ;otherwise increment for last pipe
GetWNum: ldy WarpZoneNumbers,x     ;get warp zone numbers
         dey                       ;decrement for use as world number
         sty WorldNumber           ;store as world number and offset
         ldx WorldAddrOffsets,y    ;get offset to where this world's area offsets are
         lda AreaAddrOffsets,x     ;get area offset based on world offset
         sta AreaPointer           ;store area offset here to be used to change areas
         lda #Silence
         sta EventMusicQueue       ;silence music
         lda #$00
         sta EntrancePage          ;initialize starting page number
         sta AreaNumber            ;initialize area number used for area address offset
         sta LevelNumber           ;initialize level number used for world display
         sta AltEntranceControl    ;initialize mode of entry
         inc Hidden1UpFlag         ;set flag for hidden 1-up blocks
         inc FetchNewGameTimerFlag ;set flag to load new game timer
ExPipeE: Switch_Bank 0
		 rts                       ;leave!!!

;-------------------------------------------------------------------------------------

LoadAreaPointer:
             jsr FindAreaPointer  ;find it and store it here
             sta AreaPointer
GetAreaType: and #%01100000       ;mask out all but d6 and d5
             asl
             rol
             rol
             rol                  ;make %0xx00000 into %000000xx
             sta AreaType         ;save 2 MSB as area type
             rts

FindAreaPointer:
	  Switch_Bank 4
      ldy WorldNumber        ;load offset from world variable
      lda WorldAddrOffsets,y
      clc                    ;add area number used to find data
      adc AreaNumber
      tay
      lda AreaAddrOffsets,y  ;from there we have our area pointer
	  Switch_Bank 0
      rts


GetAreaDataAddrs:
			Switch_Bank 4
            lda AreaPointer          ;use 2 MSB for Y
            jsr GetAreaType
            tay
            lda AreaPointer          ;mask out all but 5 LSB
            and #%00011111
            sta AreaAddrsLOffset     ;save as low offset
            lda EnemyAddrHOffsets,y  ;load base value with 2 altered MSB,
            clc                      ;then add base value to 5 LSB, result
            adc AreaAddrsLOffset     ;becomes offset for level data
            tay
            lda EnemyDataAddrLow,y   ;use offset to load pointer
            sta EnemyDataLow
            lda EnemyDataAddrHigh,y
            sta EnemyDataHigh
            ldy AreaType             ;use area type as offset
            lda AreaDataHOffsets,y   ;do the same thing but with different base value
            clc
            adc AreaAddrsLOffset
            tay
            lda AreaDataAddrLow,y    ;use this offset to load another pointer
            sta AreaDataLow
            lda AreaDataAddrHigh,y
            sta AreaDataHigh
            ldy #$00                 ;load first byte of header
            lda (AreaData),y
            pha                      ;save it to the stack for now
            and #%00000111           ;save 3 LSB for foreground scenery or bg color control
            cmp #$04
            bcc StoreFore
            sta BackgroundColorCtrl  ;if 4 or greater, save value here as bg color control
            lda #$00
StoreFore:  sta ForegroundScenery    ;if less, save value here as foreground scenery
            pla                      ;pull byte from stack and push it back
            pha
            and #%00111000           ;save player entrance control bits
            lsr                      ;shift bits over to LSBs
            lsr
            lsr
            sta PlayerEntranceCtrl       ;save value here as player entrance control
            pla                      ;pull byte again but do not push it back
            and #%11000000           ;save 2 MSB for game timer setting
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            sta GameTimerSetting     ;save value here as game timer setting
            iny
            lda (AreaData),y         ;load second byte of header
            pha                      ;save to stack
            and #%00001111           ;mask out all but lower nybble
            sta TerrainControl
            pla                      ;pull and push byte to copy it to A
            pha
            and #%00110000           ;save 2 MSB for background scenery type
            lsr
            lsr                      ;shift bits to LSBs
            lsr
            lsr
            sta BackgroundScenery    ;save as background scenery
            pla
            and #%11000000
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            cmp #%00000011           ;if set to 3, store here
            bne StoreStyle           ;and nullify other value
            sta CloudTypeOverride    ;otherwise store value in other place
            lda #$00
StoreStyle: sta AreaStyle
            lda AreaDataLow          ;increment area data address by 2 bytes
            clc
            adc #$02
            sta AreaDataLow
            lda AreaDataHigh
            adc #$00
            sta AreaDataHigh
			Switch_Bank 0
            rts

;-------------------------------------------------------------------------------------

EnemiesAndLoopsCore:
            lda Enemy_Flag,x         ;check data here for MSB set
            pha                      ;save in stack
            asl
            bcs ChkBowserF           ;if MSB set in enemy flag, branch ahead of jumps
            pla                      ;get from stack
            beq ChkAreaTsk           ;if data zero, branch
            jmp RunEnemyObjectsCore  ;otherwise, jump to run enemy subroutines
ChkAreaTsk: lda AreaParserTaskNum    ;check number of tasks to perform
            and #$07
            cmp #$07                 ;if at a specific task, jump and leave
            beq ExitELCore
            jmp ProcLoopCommand      ;otherwise, jump to process loop command/load enemies
ChkBowserF: pla                      ;get data from stack
            and #%00001111           ;mask out high nybble
            tay
            lda Enemy_Flag,y         ;use as pointer and load same place with different offset
            bne ExitELCore
            sta Enemy_Flag,x         ;if second enemy flag not set, also clear first one
ExitELCore: rts

;--------------------------------

;loop command data
LoopCmdWorldNumber:
      .byte $03, $03, $06, $06, $06, $06, $06, $06, $07, $07, $07

LoopCmdPageNumber:
      .byte $05, $09, $04, $05, $06, $08, $09, $0a, $06, $0b, $10

LoopCmdYPosition:
      .byte $40, $b0, $b0, $80, $40, $40, $80, $40, $f0, $f0, $f0

ExecGameLoopback:
      lda Player_PageLoc        ;send player back four pages
      sec
      sbc #$04
      sta Player_PageLoc
      lda CurrentPageLoc        ;send current page back four pages
      sec
      sbc #$04
      sta CurrentPageLoc
      lda ScreenLeft_PageLoc    ;subtract four from page location
      sec                       ;of screen's left border
      sbc #$04
      sta ScreenLeft_PageLoc
      lda ScreenRight_PageLoc   ;do the same for the page location
      sec                       ;of screen's right border
      sbc #$04
      sta ScreenRight_PageLoc
      lda AreaObjectPageLoc     ;subtract four from page control
      sec                       ;for area objects
      sbc #$04
      sta AreaObjectPageLoc
      lda #$00                  ;initialize page select for both
      sta EnemyObjectPageSel    ;area and enemy objects
      sta AreaObjectPageSel
      sta EnemyDataOffset       ;initialize enemy object data offset
      sta EnemyObjectPageLoc    ;and enemy object page control
      lda AreaDataOfsLoopback,y ;adjust area object offset based on
      sta AreaDataOffset        ;which loop command we encountered
      rts

ProcLoopCommand:
          lda LoopCommand           ;check if loop command was found
          beq ChkEnemyFrenzy
          lda CurrentColumnPos      ;check to see if we're still on the first page
          bne ChkEnemyFrenzy        ;if not, do not loop yet
          ldy #$0b                  ;start at the end of each set of loop data
FindLoop: dey
          bmi ChkEnemyFrenzy        ;if all data is checked and not match, do not loop
          lda WorldNumber           ;check to see if one of the world numbers
          cmp LoopCmdWorldNumber,y  ;matches our current world number
          bne FindLoop
          lda CurrentPageLoc        ;check to see if one of the page numbers
          cmp LoopCmdPageNumber,y   ;matches the page we're currently on
          bne FindLoop
          lda Player_Y_Position     ;check to see if the player is at the correct position
          cmp LoopCmdYPosition,y    ;if not, branch to check for world 7
          bne WrongChk
          lda Player_State          ;check to see if the player is
          cmp #$00                  ;on solid ground (i.e. not jumping or falling)
          bne WrongChk              ;if not, player fails to pass loop, and loopback
          lda WorldNumber           ;are we in world 7? (check performed on correct
          cmp #World7               ;vertical position and on solid ground)
          bne InitMLp               ;if not, initialize flags used there, otherwise
          inc MultiLoopCorrectCntr  ;increment counter for correct progression
IncMLoop: inc MultiLoopPassCntr     ;increment master multi-part counter
          lda MultiLoopPassCntr     ;have we done all three parts?
          cmp #$03
          bne InitLCmd              ;if not, skip this part
          lda MultiLoopCorrectCntr  ;if so, have we done them all correctly?
          cmp #$03
          beq InitMLp               ;if so, branch past unnecessary check here
          bne DoLpBack              ;unconditional branch if previous branch fails
WrongChk: lda WorldNumber           ;are we in world 7? (check performed on
          cmp #World7               ;incorrect vertical position or not on solid ground)
          beq IncMLoop
DoLpBack: jsr ExecGameLoopback      ;if player is not in right place, loop back
          jsr KillAllEnemies
InitMLp:  lda #$00                  ;initialize counters used for multi-part loop commands
          sta MultiLoopPassCntr
          sta MultiLoopCorrectCntr
InitLCmd: lda #$00                  ;initialize loop command flag
          sta LoopCommand

;--------------------------------

ChkEnemyFrenzy:
      lda EnemyFrenzyQueue  ;check for enemy object in frenzy queue
      bne :+
	jmp ProcessEnemyData_
:
      sta Enemy_ID,x        ;store as enemy object identifier here
      lda #$01
      sta Enemy_Flag,x      ;activate enemy object flag
      lda #$00
      sta Enemy_State,x     ;initialize state and frenzy queue
      sta EnemyFrenzyQueue
      jmp InitEnemyObject   ;and then jump to deal with this enemy

;-------------------------------------------------------------------------------------

RunEnemyObjectsCore:
       ldx ObjectOffset  ;get offset for enemy object buffer
       lda #$00          ;load value 0 for jump engine by default
       ldy Enemy_ID,x
       cpy #$15          ;if enemy object < $15, use default value
       bcc JmpEO
       tya               ;otherwise subtract $14 from the value and use
       sbc #$14          ;as value for jump engine
JmpEO: jsr JumpEngine

      .word RunNormalEnemies  ;for objects $00-$14

      .word RunBowserFlame    ;for objects $15-$1f
      .word RunFireworks
      .word NoRunCode
      .word NoRunCode
      .word NoRunCode
      .word NoRunCode
      .word RunFirebarObj
      .word RunFirebarObj
      .word RunFirebarObj
      .word RunFirebarObj
      .word RunFirebarObj

      .word RunFirebarObj     ;for objects $20-$2f
      .word RunFirebarObj
      .word RunFirebarObj
      .word NoRunCode
      .word RunLargePlatform
      .word RunLargePlatform
      .word RunLargePlatform
      .word RunLargePlatform
      .word RunLargePlatform
      .word RunLargePlatform
      .word RunLargePlatform
      .word RunSmallPlatform
      .word RunSmallPlatform
      .word RunBowser
      .word PowerUpObjHandler
      .word VineObjectHandler

      .word NoRunCode         ;for objects $30-$35
      .word RunStarFlagObj
      .word JumpspringHandler
      .word NoRunCode
      .word WarpZoneObject
      .word RunRetainerObj

;--------------------------------

NoRunCode:
      rts

;--------------------------------

RunRetainerObj:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jmp EnemyGfxHandler

;--------------------------------

RunNormalEnemies:
          lda #$00                  ;init sprite attributes
          sta Enemy_SprAttrib,x
          jsr GetEnemyOffscreenBits
          jsr RelativeEnemyPosition
          jsr EnemyGfxHandler
          jsr GetEnemyBoundBox
          jsr EnemyToBGCollisionDet
          jsr EnemiesCollision
          jsr PlayerEnemyCollision
          ldy TimerControl          ;if master timer control set, skip to last routine
          bne SkipMove
          jsr EnemyMovementSubs
SkipMove: jmp OffscreenBoundsCheck

EnemyMovementSubs:
      lda Enemy_ID,x
      jsr JumpEngine

      .word MoveNormalEnemy      ;only objects $00-$14 use this table
      .word MoveNormalEnemy
      .word MoveNormalEnemy
      .word MoveNormalEnemy
      .word MoveNormalEnemy
      .word ProcHammerBro
      .word MoveNormalEnemy
      .word MoveBloober
      .word MoveBulletBill
      .word NoMoveCode
      .word MoveSwimmingCheepCheep
      .word MoveSwimmingCheepCheep
      .word MovePodoboo
      .word MovePiranhaPlant
      .word MoveJumpingEnemy
      .word ProcMoveRedPTroopa
      .word MoveFlyGreenPTroopa
      .word MoveLakitu
      .word MoveNormalEnemy
      .word NoMoveCode   ;dummy
      .word MoveFlyingCheepCheep

;--------------------------------

NoMoveCode:
      rts

;--------------------------------

RunBowserFlame:
      jsr ProcBowserFlame
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr GetEnemyBoundBox
      jsr PlayerEnemyCollision
      jmp OffscreenBoundsCheck

;--------------------------------

RunFirebarObj:
      jsr ProcFirebar
      jmp OffscreenBoundsCheck

;--------------------------------

RunSmallPlatform:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr SmallPlatformBoundBox
      jsr SmallPlatformCollision
      jsr RelativeEnemyPosition
      jsr DrawSmallPlatform
      jsr MoveSmallPlatform
      jmp OffscreenBoundsCheck

;--------------------------------

RunLargePlatform:
        jsr GetEnemyOffscreenBits
        jsr RelativeEnemyPosition
        jsr LargePlatformBoundBox
        jsr LargePlatformCollision
        lda TimerControl             ;if master timer control set,
        bne SkipPT                   ;skip subroutine tree
        jsr LargePlatformSubroutines
SkipPT: jsr RelativeEnemyPosition
        jsr DrawLargePlatform
        jmp OffscreenBoundsCheck

;--------------------------------

LargePlatformSubroutines:
      lda Enemy_ID,x  ;subtract $24 to get proper offset for jump table
      sec
      sbc #$24
      jsr JumpEngine

      .word BalancePlatform   ;table used by objects $24-$2a
      .word YMovingPlatform
      .word MoveLargeLiftPlat
      .word MoveLargeLiftPlat
      .word XMovingPlatform
      .word DropPlatform
      .word RightPlatform

;-------------------------------------------------------------------------------------

EraseEnemyObject:
      lda #$00                 ;clear all enemy object variables
      sta Enemy_Flag,x
      sta Enemy_ID,x
      sta Enemy_State,x
      sta FloateyNum_Control,x
      sta EnemyIntervalTimer,x
      sta ShellChainCounter,x
      sta Enemy_SprAttrib,x
      sta EnemyFrameTimer,x
      rts

;-------------------------------------------------------------------------------------

MovePodoboo:
      lda EnemyIntervalTimer,x   ;check enemy timer
      bne PdbM                   ;branch to move enemy if not expired
      jsr InitPodoboo            ;otherwise set up podoboo again
      lda PseudoRandomBitReg+1,x ;get part of LSFR
      ora #%10000000             ;set d7
      sta Enemy_Y_MoveForce,x    ;store as movement force
      and #%00001111             ;mask out high nybble
      ora #$06                   ;set for at least six intervals
      sta EnemyIntervalTimer,x   ;store as new enemy timer
      lda #$f9
      sta Enemy_Y_Speed,x        ;set vertical speed to move podoboo upwards
PdbM: jmp MoveJ_EnemyVertically  ;branch to impose gravity on podoboo

;--------------------------------
;$00 - used in HammerBroJumpCode as bitmask

HammerThrowTmrData:
      .byte $30, $1c

XSpeedAdderData:
      .byte $00, $e8, $00, $18

RevivedXSpeed:
      .byte $08, $f8, $0c, $f4

ProcHammerBro:
       lda Enemy_State,x          ;check hammer bro's enemy state for d5 set
       and #%00100000
       beq ChkJH                  ;if not set, go ahead with code
       jmp MoveDefeatedEnemy      ;otherwise jump to something else
ChkJH: lda HammerBroJumpTimer,x   ;check jump timer
       beq HammerBroJumpCode      ;if expired, branch to jump
       dec HammerBroJumpTimer,x   ;otherwise decrement jump timer
       lda Enemy_OffscreenBits
       and #%00001100             ;check offscreen bits
       bne MoveHammerBroXDir      ;if hammer bro a little offscreen, skip to movement code
       lda HammerThrowingTimer,x  ;check hammer throwing timer
       bne DecHT                  ;if not expired, skip ahead, do not throw hammer
       ldy SecondaryHardMode      ;otherwise get secondary hard mode flag
       lda HammerThrowTmrData,y   ;get timer data using flag as offset
       sta HammerThrowingTimer,x  ;set as new timer
       jsr SpawnHammerObj         ;do a sub here to spawn hammer object
       bcc DecHT                  ;if carry clear, hammer not spawned, skip to decrement timer
       lda Enemy_State,x
       ora #%00001000             ;set d3 in enemy state for hammer throw
       sta Enemy_State,x
       jmp MoveHammerBroXDir      ;jump to move hammer bro
DecHT: dec HammerThrowingTimer,x  ;decrement timer
       jmp MoveHammerBroXDir      ;jump to move hammer bro

HammerBroJumpLData:
      .byte $20, $37

HammerBroJumpCode:
       lda Enemy_State,x           ;get hammer bro's enemy state
       and #%00000111              ;mask out all but 3 LSB
       cmp #$01                    ;check for d0 set (for jumping)
       beq MoveHammerBroXDir       ;if set, branch ahead to moving code
       lda #$00                    ;load default value here
       sta $00                     ;save into temp variable for now
       ldy #$fa                    ;set default vertical speed
       lda Enemy_Y_Position,x      ;check hammer bro's vertical coordinate
       bmi SetHJ                   ;if on the bottom half of the screen, use current speed
       ldy #$fd                    ;otherwise set alternate vertical speed
       cmp #$70                    ;check to see if hammer bro is above the middle of screen
       inc $00                     ;increment preset value to $01
       bcc SetHJ                   ;if above the middle of the screen, use current speed and $01
       dec $00                     ;otherwise return value to $00
       lda PseudoRandomBitReg+1,x  ;get part of LSFR, mask out all but LSB
       and #$01
       bne SetHJ                   ;if d0 of LSFR set, branch and use current speed and $00
       ldy #$fa                    ;otherwise reset to default vertical speed
SetHJ: sty Enemy_Y_Speed,x         ;set vertical speed for jumping
       lda Enemy_State,x           ;set d0 in enemy state for jumping
       ora #$01
       sta Enemy_State,x
       lda $00                     ;load preset value here to use as bitmask
       and PseudoRandomBitReg+2,x  ;and do bit-wise comparison with part of LSFR
       tay                         ;then use as offset
       lda SecondaryHardMode       ;check secondary hard mode flag
       bne HJump
       tay                         ;if secondary hard mode flag clear, set offset to 0
HJump: lda HammerBroJumpLData,y    ;get jump length timer data using offset from before
       sta EnemyFrameTimer,x       ;save in enemy timer
       lda PseudoRandomBitReg+1,x
       ora #%11000000              ;get contents of part of LSFR, set d7 and d6, then
       sta HammerBroJumpTimer,x    ;store in jump timer

MoveHammerBroXDir:
         ldy #$fc                  ;move hammer bro a little to the left
         lda FrameCounter
         and #%01000000            ;change hammer bro's direction every 64 frames
         bne Shimmy
         ldy #$04                  ;if d6 set in counter, move him a little to the right
Shimmy:  sty Enemy_X_Speed,x       ;store horizontal speed
         ldy #$01                  ;set to face right by default
         jsr PlayerEnemyDiff       ;get horizontal difference between player and hammer bro
         bmi SetShim               ;if enemy to the left of player, skip this part
         iny                       ;set to face left
         lda EnemyIntervalTimer,x  ;check walking timer
         bne SetShim               ;if not yet expired, skip to set moving direction
         lda #$f8
         sta Enemy_X_Speed,x       ;otherwise, make the hammer bro walk left towards player
SetShim: sty Enemy_MovingDir,x     ;set moving direction

MoveNormalEnemy:
       ldy #$00                   ;init Y to leave horizontal movement as-is
       lda Enemy_State,x
       and #%01000000             ;check enemy state for d6 set, if set skip
       bne FallE                  ;to move enemy vertically, then horizontally if necessary
       lda Enemy_State,x
       asl                        ;check enemy state for d7 set
       bcs SteadM                 ;if set, branch to move enemy horizontally
       lda Enemy_State,x
       and #%00100000             ;check enemy state for d5 set
       bne MoveDefeatedEnemy      ;if set, branch to move defeated enemy object
       lda Enemy_State,x
       and #%00000111             ;check d2-d0 of enemy state for any set bits
       beq SteadM                 ;if enemy in normal state, branch to move enemy horizontally
       cmp #$05
       beq FallE                  ;if enemy in state used by spiny's egg, go ahead here
       cmp #$03
       bcs ReviveStunned          ;if enemy in states $03 or $04, skip ahead to yet another part
FallE: jsr MoveD_EnemyVertically  ;do a sub here to move enemy downwards
       ldy #$00
       lda Enemy_State,x          ;check for enemy state $02
       cmp #$02
       beq MEHor                  ;if found, branch to move enemy horizontally
       and #%01000000             ;check for d6 set
       beq SteadM                 ;if not set, branch to something else
       lda Enemy_ID,x
       cmp #PowerUpObject         ;check for power-up object
       beq SteadM
       bne SlowM                  ;if any other object where d6 set, jump to set Y
MEHor: jmp MoveEnemyHorizontally  ;jump here to move enemy horizontally for <> $2e and d6 set

SlowM:  ldy #$01                  ;if branched here, increment Y to slow horizontal movement
SteadM: lda Enemy_X_Speed,x       ;get current horizontal speed
        pha                       ;save to stack
        bpl AddHS                 ;if not moving or moving right, skip, leave Y alone
        iny
        iny                       ;otherwise increment Y to next data
AddHS:  clc
        adc XSpeedAdderData,y     ;add value here to slow enemy down if necessary
        sta Enemy_X_Speed,x       ;save as horizontal speed temporarily
        jsr MoveEnemyHorizontally ;then do a sub to move horizontally
        pla
        sta Enemy_X_Speed,x       ;get old horizontal speed from stack and return to
        rts                       ;original memory location, then leave

ReviveStunned:
         lda EnemyIntervalTimer,x  ;if enemy timer not expired yet,
         bne ChkKillGoomba         ;skip ahead to something else
         sta Enemy_State,x         ;otherwise initialize enemy state to normal
         lda FrameCounter
         and #$01                  ;get d0 of frame counter
         tay                       ;use as Y and increment for movement direction
         iny
         sty Enemy_MovingDir,x     ;store as pseudorandom movement direction
         dey                       ;decrement for use as pointer
         lda PrimaryHardMode       ;check primary hard mode flag
         beq SetRSpd               ;if not set, use pointer as-is
         iny
         iny                       ;otherwise increment 2 bytes to next data
SetRSpd: lda RevivedXSpeed,y       ;load and store new horizontal speed
         sta Enemy_X_Speed,x       ;and leave
         rts

MoveDefeatedEnemy:
      jsr MoveD_EnemyVertically      ;execute sub to move defeated enemy downwards
      jmp MoveEnemyHorizontally      ;now move defeated enemy horizontally

ChkKillGoomba:
        cmp #$0e              ;check to see if enemy timer has reached
        bne NKGmba            ;a certain point, and branch to leave if not
        lda Enemy_ID,x
        cmp #Goomba           ;check for goomba object
        bne NKGmba            ;branch if not found
        jsr EraseEnemyObject  ;otherwise, kill this goomba object
NKGmba: rts                   ;leave!

;--------------------------------

MoveJumpingEnemy:
      jsr MoveJ_EnemyVertically  ;do a sub to impose gravity on green paratroopa
      jmp MoveEnemyHorizontally  ;jump to move enemy horizontally

;--------------------------------

ProcMoveRedPTroopa:
          lda Enemy_Y_Speed,x
          ora Enemy_Y_MoveForce,x     ;check for any vertical force or speed
          bne MoveRedPTUpOrDown       ;branch if any found
          sta Enemy_YMF_Dummy,x       ;initialize something here
          lda Enemy_Y_Position,x      ;check current vs. original vertical coordinate
          cmp RedPTroopaOrigXPos,x
          bcs MoveRedPTUpOrDown       ;if current => original, skip ahead to more code
          lda FrameCounter            ;get frame counter
          and #%00000111              ;mask out all but 3 LSB
          bne NoIncPT                 ;if any bits set, branch to leave
          inc Enemy_Y_Position,x      ;otherwise increment red paratroopa's vertical position
NoIncPT:  rts                         ;leave

MoveRedPTUpOrDown:
          lda Enemy_Y_Position,x      ;check current vs. central vertical coordinate
          cmp RedPTroopaCenterYPos,x
          bcc MovPTDwn                ;if current < central, jump to move downwards
          jmp MoveRedPTroopaUp        ;otherwise jump to move upwards
MovPTDwn: jmp MoveRedPTroopaDown      ;move downwards

;--------------------------------
;$00 - used to store adder for movement, also used as adder for platform
;$01 - used to store maximum value for secondary counter

MoveFlyGreenPTroopa:
        jsr XMoveCntr_GreenPTroopa ;do sub to increment primary and secondary counters
        jsr MoveWithXMCntrs        ;do sub to move green paratroopa accordingly, and horizontally
        ldy #$01                   ;set Y to move green paratroopa down
        lda FrameCounter
        and #%00000011             ;check frame counter 2 LSB for any bits set
        bne NoMGPT                 ;branch to leave if set to move up/down every fourth frame
        lda FrameCounter
        and #%01000000             ;check frame counter for d6 set
        bne YSway                  ;branch to move green paratroopa down if set
        ldy #$ff                   ;otherwise set Y to move green paratroopa up
YSway:  sty $00                    ;store adder here
        lda Enemy_Y_Position,x
        clc                        ;add or subtract from vertical position
        adc $00                    ;to give green paratroopa a wavy flight
        sta Enemy_Y_Position,x
NoMGPT: rts                        ;leave!

XMoveCntr_GreenPTroopa:
         lda #$13                    ;load preset maximum value for secondary counter

XMoveCntr_Platform:
         sta $01                     ;store value here
         lda FrameCounter
         and #%00000011              ;branch to leave if not on
         bne NoIncXM                 ;every fourth frame
         ldy XMoveSecondaryCounter,x ;get secondary counter
         lda XMovePrimaryCounter,x   ;get primary counter
         lsr
         bcs DecSeXM                 ;if d0 of primary counter set, branch elsewhere
         cpy $01                     ;compare secondary counter to preset maximum value
         beq IncPXM                  ;if equal, branch ahead of this part
         inc XMoveSecondaryCounter,x ;increment secondary counter and leave
NoIncXM: rts
IncPXM:  inc XMovePrimaryCounter,x   ;increment primary counter and leave
         rts
DecSeXM: tya                         ;put secondary counter in A
         beq IncPXM                  ;if secondary counter at zero, branch back
         dec XMoveSecondaryCounter,x ;otherwise decrement secondary counter and leave
         rts

MoveWithXMCntrs:
         lda XMoveSecondaryCounter,x  ;save secondary counter to stack
         pha
         ldy #$01                     ;set value here by default
         lda XMovePrimaryCounter,x
         and #%00000010               ;if d1 of primary counter is
         bne XMRight                  ;set, branch ahead of this part here
         lda XMoveSecondaryCounter,x
         eor #$ff                     ;otherwise change secondary
         clc                          ;counter to two's compliment
         adc #$01
         sta XMoveSecondaryCounter,x
         ldy #$02                     ;load alternate value here
XMRight: sty Enemy_MovingDir,x        ;store as moving direction
         jsr MoveEnemyHorizontally
         sta $00                      ;save value obtained from sub here
         pla                          ;get secondary counter from stack
         sta XMoveSecondaryCounter,x  ;and return to original place
         rts

;--------------------------------

BlooberBitmasks:
      .byte %00111111, %00000011

MoveBloober:
        lda Enemy_State,x
        and #%00100000             ;check enemy state for d5 set
        bne MoveDefeatedBloober    ;branch if set to move defeated bloober
        ldy SecondaryHardMode      ;use secondary hard mode flag as offset
        lda PseudoRandomBitReg+1,x ;get LSFR
        and BlooberBitmasks,y      ;mask out bits in LSFR using bitmask loaded with offset
        bne BlooberSwim            ;if any bits set, skip ahead to make swim
        txa
        lsr                        ;check to see if on second or fourth slot (1 or 3)
        bcc FBLeft                 ;if not, branch to figure out moving direction
        ldy Player_MovingDir       ;otherwise, load player's moving direction and
        bcs SBMDir                 ;do an unconditional branch to set
FBLeft: ldy #$02                   ;set left moving direction by default
        jsr PlayerEnemyDiff        ;get horizontal difference between player and bloober
        bpl SBMDir                 ;if enemy to the right of player, keep left
        dey                        ;otherwise decrement to set right moving direction
SBMDir: sty Enemy_MovingDir,x      ;set moving direction of bloober, then continue on here

BlooberSwim:
       jsr ProcSwimmingB        ;execute sub to make bloober swim characteristically
       lda Enemy_Y_Position,x   ;get vertical coordinate
       sec
       sbc Enemy_Y_MoveForce,x  ;subtract movement force
       cmp #$20                 ;check to see if position is above edge of status bar
       bcc SwimX                ;if so, don't do it
       sta Enemy_Y_Position,x   ;otherwise, set new vertical position, make bloober swim
SwimX: ldy Enemy_MovingDir,x    ;check moving direction
       dey
       bne LeftSwim             ;if moving to the left, branch to second part
       lda Enemy_X_Position,x
       clc                      ;add movement speed to horizontal coordinate
       adc BlooperMoveSpeed,x
       sta Enemy_X_Position,x   ;store result as new horizontal coordinate
       lda Enemy_PageLoc,x
       adc #$00                 ;add carry to page location
       sta Enemy_PageLoc,x      ;store as new page location and leave
       rts

LeftSwim:
      lda Enemy_X_Position,x
      sec                      ;subtract movement speed from horizontal coordinate
      sbc BlooperMoveSpeed,x
      sta Enemy_X_Position,x   ;store result as new horizontal coordinate
      lda Enemy_PageLoc,x
      sbc #$00                 ;subtract borrow from page location
      sta Enemy_PageLoc,x      ;store as new page location and leave
      rts

MoveDefeatedBloober:
      jmp MoveEnemySlowVert    ;jump to move defeated bloober downwards

ProcSwimmingB:
        lda BlooperMoveCounter,x  ;get enemy's movement counter
        and #%00000010            ;check for d1 set
        bne ChkForFloatdown       ;branch if set
        lda FrameCounter
        and #%00000111            ;get 3 LSB of frame counter
        pha                       ;and save it to the stack
        lda BlooperMoveCounter,x  ;get enemy's movement counter
        lsr                       ;check for d0 set
        bcs SlowSwim              ;branch if set
        pla                       ;pull 3 LSB of frame counter from the stack
        bne BSwimE                ;branch to leave, execute code only every eighth frame
        lda Enemy_Y_MoveForce,x
        clc                       ;add to movement force to speed up swim
        adc #$01
        sta Enemy_Y_MoveForce,x   ;set movement force
        sta BlooperMoveSpeed,x    ;set as movement speed
        cmp #$02
        bne BSwimE                ;if certain horizontal speed, branch to leave
        inc BlooperMoveCounter,x  ;otherwise increment movement counter
BSwimE: rts

SlowSwim:
       pla                      ;pull 3 LSB of frame counter from the stack
       bne NoSSw                ;branch to leave, execute code only every eighth frame
       lda Enemy_Y_MoveForce,x
       sec                      ;subtract from movement force to slow swim
       sbc #$01
       sta Enemy_Y_MoveForce,x  ;set movement force
       sta BlooperMoveSpeed,x   ;set as movement speed
       bne NoSSw                ;if any speed, branch to leave
       inc BlooperMoveCounter,x ;otherwise increment movement counter
       lda #$02
       sta EnemyIntervalTimer,x ;set enemy's timer
NoSSw: rts                      ;leave

ChkForFloatdown:
      lda EnemyIntervalTimer,x ;get enemy timer
      beq ChkNearPlayer        ;branch if expired

Floatdown:
      lda FrameCounter        ;get frame counter
      lsr                     ;check for d0 set
      bcs NoFD                ;branch to leave on every other frame
      inc Enemy_Y_Position,x  ;otherwise increment vertical coordinate
NoFD: rts                     ;leave

ChkNearPlayer:
      lda Enemy_Y_Position,x    ;get vertical coordinate
      adc #$10                  ;add sixteen pixels
      cmp Player_Y_Position     ;compare result with player's vertical coordinate
      bcc Floatdown             ;if modified vertical less than player's, branch
      lda #$00
      sta BlooperMoveCounter,x  ;otherwise nullify movement counter
      rts

;--------------------------------

MoveBulletBill:
         lda Enemy_State,x          ;check bullet bill's enemy object state for d5 set
         and #%00100000
         beq NotDefB                ;if not set, continue with movement code
         jmp MoveJ_EnemyVertically  ;otherwise jump to move defeated bullet bill downwards
NotDefB: lda #$e8                   ;set bullet bill's horizontal speed
         sta Enemy_X_Speed,x        ;and move it accordingly (note: this bullet bill
         jmp MoveEnemyHorizontally  ;object occurs in frenzy object $17, not from cannons)

;--------------------------------
;$02 - used to hold preset values
;$03 - used to hold enemy state

SwimCCXMoveData:
      .byte $40, $80
      .byte $04, $04 ;residual data, not used

MoveSwimmingCheepCheep:
        lda Enemy_State,x         ;check cheep-cheep's enemy object state
        and #%00100000            ;for d5 set
        beq CCSwim                ;if not set, continue with movement code
        jmp MoveEnemySlowVert     ;otherwise jump to move defeated cheep-cheep downwards
CCSwim: sta $03                   ;save enemy state in $03
        lda Enemy_ID,x            ;get enemy identifier
        sec
        sbc #$0a                  ;subtract ten for cheep-cheep identifiers
        tay                       ;use as offset
        lda SwimCCXMoveData,y     ;load value here
        sta $02
        lda Enemy_X_MoveForce,x   ;load horizontal force
        sec
        sbc $02                   ;subtract preset value from horizontal force
        sta Enemy_X_MoveForce,x   ;store as new horizontal force
        lda Enemy_X_Position,x    ;get horizontal coordinate
        sbc #$00                  ;subtract borrow (thus moving it slowly)
        sta Enemy_X_Position,x    ;and save as new horizontal coordinate
        lda Enemy_PageLoc,x
        sbc #$00                  ;subtract borrow again, this time from the
        sta Enemy_PageLoc,x       ;page location, then save
        lda #$20
        sta $02                   ;save new value here
        cpx #$02                  ;check enemy object offset
        bcc ExSwCC                ;if in first or second slot, branch to leave
        lda CheepCheepMoveMFlag,x ;check movement flag
        cmp #$10                  ;if movement speed set to $00,
        bcc CCSwimUpwards         ;branch to move upwards
        lda Enemy_YMF_Dummy,x
        clc
        adc $02                   ;add preset value to dummy variable to get carry
        sta Enemy_YMF_Dummy,x     ;and save dummy
        lda Enemy_Y_Position,x    ;get vertical coordinate
        adc $03                   ;add carry to it plus enemy state to slowly move it downwards
        sta Enemy_Y_Position,x    ;save as new vertical coordinate
        lda Enemy_Y_HighPos,x
        adc #$00                  ;add carry to page location and
        jmp ChkSwimYPos           ;jump to end of movement code

CCSwimUpwards:
        lda Enemy_YMF_Dummy,x
        sec
        sbc $02                   ;subtract preset value to dummy variable to get borrow
        sta Enemy_YMF_Dummy,x     ;and save dummy
        lda Enemy_Y_Position,x    ;get vertical coordinate
        sbc $03                   ;subtract borrow to it plus enemy state to slowly move it upwards
        sta Enemy_Y_Position,x    ;save as new vertical coordinate
        lda Enemy_Y_HighPos,x
        sbc #$00                  ;subtract borrow from page location

ChkSwimYPos:
        sta Enemy_Y_HighPos,x     ;save new page location here
        ldy #$00                  ;load movement speed to upwards by default
        lda Enemy_Y_Position,x    ;get vertical coordinate
        sec
        sbc CheepCheepOrigYPos,x  ;subtract original coordinate from current
        bpl YPDiff                ;if result positive, skip to next part
        ldy #$10                  ;otherwise load movement speed to downwards
        eor #$ff
        clc                       ;get two's compliment of result
        adc #$01                  ;to obtain total difference of original vs. current
YPDiff: cmp #$0f                  ;if difference between original vs. current vertical
        bcc ExSwCC                ;coordinates < 15 pixels, leave movement speed alone
        tya
        sta CheepCheepMoveMFlag,x ;otherwise change movement speed
ExSwCC: rts                       ;leave

;--------------------------------
;$00 - used as counter for firebar parts
;$01 - used for oscillated high byte of spin state or to hold horizontal adder
;$02 - used for oscillated high byte of spin state or to hold vertical adder
;$03 - used for mirror data
;$04 - used to store player's sprite 1 X coordinate
;$05 - used to evaluate mirror data
;$06 - used to store either screen X coordinate or sprite data offset
;$07 - used to store screen Y coordinate
;Local_ed - used to hold maximum length of firebar
;Local_ef - used to hold high byte of spinstate

;horizontal adder is at first byte + high byte of spinstate,
;vertical adder is same + 8 bytes, two's compliment
;if greater than $08 for proper oscillation
FirebarPosLookupTbl:
      .byte $00, $01, $03, $04, $05, $06, $07, $07, $08
      .byte $00, $03, $06, $09, $0b, $0d, $0e, $0f, $10
      .byte $00, $04, $09, $0d, $10, $13, $16, $17, $18
      .byte $00, $06, $0c, $12, $16, $1a, $1d, $1f, $20
      .byte $00, $07, $0f, $16, $1c, $21, $25, $27, $28
      .byte $00, $09, $12, $1b, $21, $27, $2c, $2f, $30
      .byte $00, $0b, $15, $1f, $27, $2e, $33, $37, $38
      .byte $00, $0c, $18, $24, $2d, $35, $3b, $3e, $40
      .byte $00, $0e, $1b, $28, $32, $3b, $42, $46, $48
      .byte $00, $0f, $1f, $2d, $38, $42, $4a, $4e, $50
      .byte $00, $11, $22, $31, $3e, $49, $51, $56, $58

FirebarMirrorData:
      .byte $01, $03, $02, $00

FirebarTblOffsets:
      .byte $00, $09, $12, $1b, $24, $2d
      .byte $36, $3f, $48, $51, $5a, $63

FirebarYPos:
      .byte $0c, $18

ProcFirebar:
          jsr GetEnemyOffscreenBits   ;get offscreen information
          lda Enemy_OffscreenBits     ;check for d3 set
          and #%00001000              ;if so, branch to leave
          bne SkipFBar
          lda TimerControl            ;if master timer control set, branch
          bne SusFbar                 ;ahead of this part
          lda FirebarSpinSpeed,x      ;load spinning speed of firebar
          jsr FirebarSpin             ;modify current spinstate
          and #%00011111              ;mask out all but 5 LSB
          sta FirebarSpinState_High,x ;and store as new high byte of spinstate
SusFbar:  lda FirebarSpinState_High,x ;get high byte of spinstate
          ldy Enemy_ID,x              ;check enemy identifier
          cpy #$1f
          bcc SetupGFB                ;if < $1f (long firebar), branch
          cmp #$08                    ;check high byte of spinstate
          beq SkpFSte                 ;if eight, branch to change
          cmp #$18
          bne SetupGFB                ;if not at twenty-four branch to not change
SkpFSte:  clc
          adc #$01                    ;add one to spinning thing to avoid horizontal state
          sta FirebarSpinState_High,x
SetupGFB: sta Local_ef                     ;save high byte of spinning thing, modified or otherwise
          jsr RelativeEnemyPosition   ;get relative coordinates to screen
          jsr GetFirebarPosition      ;do a sub here (residual, too early to be used now)
          ldy Enemy_SprDataOffset,x   ;get OAM data offset
          lda Enemy_Rel_YPos          ;get relative vertical coordinate
          sta Sprite_Y_Position,y     ;store as Y in OAM data
          sta $07                     ;also save here
          lda Enemy_Rel_XPos          ;get relative horizontal coordinate
          sta Sprite_X_Position,y     ;store as X in OAM data
          sta $06                     ;also save here
          lda #$01
          sta $00                     ;set $01 value here (not necessary)
          jsr FirebarCollision        ;draw fireball part and do collision detection
          ldy #$05                    ;load value for short firebars by default
          lda Enemy_ID,x
          cmp #$1f                    ;are we doing a long firebar?
          bcc SetMFbar                ;no, branch then
          ldy #$0b                    ;otherwise load value for long firebars
SetMFbar: sty Local_ed                     ;store maximum value for length of firebars
          lda #$00
          sta $00                     ;initialize counter here
DrawFbar: lda Local_ef                     ;load high byte of spinstate
          jsr GetFirebarPosition      ;get fireball position data depending on firebar part
          jsr DrawFirebar_Collision   ;position it properly, draw it and do collision detection
          lda $00                     ;check which firebar part
          cmp #$04
          bne NextFbar
          ldy DuplicateObj_Offset     ;if we arrive at fifth firebar part,
          lda Enemy_SprDataOffset,y   ;get offset from long firebar and load OAM data offset
          sta $06                     ;using long firebar offset, then store as new one here
NextFbar: inc $00                     ;move onto the next firebar part
          lda $00
          cmp Local_ed                     ;if we end up at the maximum part, go on and leave
          bcc DrawFbar                ;otherwise go back and do another
SkipFBar: rts

DrawFirebar_Collision:
         lda $03                  ;store mirror data elsewhere
         sta $05
         ldy $06                  ;load OAM data offset for firebar
         lda $01                  ;load horizontal adder we got from position loader
         lsr $05                  ;shift LSB of mirror data
         bcs AddHA                ;if carry was set, skip this part
         eor #$ff
         adc #$01                 ;otherwise get two's compliment of horizontal adder
AddHA:   clc                      ;add horizontal coordinate relative to screen to
         adc Enemy_Rel_XPos       ;horizontal adder, modified or otherwise
         sta Sprite_X_Position,y  ;store as X coordinate here
         sta $06                  ;store here for now, note offset is saved in Y still
         cmp Enemy_Rel_XPos       ;compare X coordinate of sprite to original X of firebar
         bcs SubtR1               ;if sprite coordinate => original coordinate, branch
         lda Enemy_Rel_XPos
         sec                      ;otherwise subtract sprite X from the
         sbc $06                  ;original one and skip this part
         jmp ChkFOfs
SubtR1:  sec                      ;subtract original X from the
         sbc Enemy_Rel_XPos       ;current sprite X
ChkFOfs: cmp #$59                 ;if difference of coordinates within a certain range,
         bcc VAHandl              ;continue by handling vertical adder
         lda #$f8                 ;otherwise, load offscreen Y coordinate
         bne SetVFbr              ;and unconditionally branch to move sprite offscreen
VAHandl: lda Enemy_Rel_YPos       ;if vertical relative coordinate offscreen,
         cmp #$f8                 ;skip ahead of this part and write into sprite Y coordinate
         beq SetVFbr
         lda $02                  ;load vertical adder we got from position loader
         lsr $05                  ;shift LSB of mirror data one more time
         bcs AddVA                ;if carry was set, skip this part
         eor #$ff
         adc #$01                 ;otherwise get two's compliment of second part
AddVA:   clc                      ;add vertical coordinate relative to screen to
         adc Enemy_Rel_YPos       ;the second data, modified or otherwise
SetVFbr: sta Sprite_Y_Position,y  ;store as Y coordinate here
         sta $07                  ;also store here for now

FirebarCollision:
         jsr DrawFirebar          ;run sub here to draw current tile of firebar
         tya                      ;return OAM data offset and save
         pha                      ;to the stack for now
         lda StarInvincibleTimer  ;if star mario invincibility timer
         ora TimerControl         ;or master timer controls set
         bne NoColFB              ;then skip all of this
         sta $05                  ;otherwise initialize counter
         ldy Player_Y_HighPos
         dey                      ;if player's vertical high byte offscreen,
         bne NoColFB              ;skip all of this
         ldy Player_Y_Position    ;get player's vertical position
         lda PlayerSize           ;get player's size
         bne AdjSm                ;if player small, branch to alter variables
         lda CrouchingFlag
         beq BigJp                ;if player big and not crouching, jump ahead
AdjSm:   inc $05                  ;if small or big but crouching, execute this part
         inc $05                  ;first increment our counter twice (setting $02 as flag)
         tya
         clc                      ;then add 24 pixels to the player's
         adc #$18                 ;vertical coordinate
         tay
BigJp:   tya                      ;get vertical coordinate, altered or otherwise, from Y
FBCLoop: sec                      ;subtract vertical position of firebar
         sbc $07                  ;from the vertical coordinate of the player
         bpl ChkVFBD              ;if player lower on the screen than firebar,
         eor #$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adc #$01
ChkVFBD: cmp #$08                 ;if difference => 8 pixels, skip ahead of this part
         bcs Chk2Ofs
         lda $06                  ;if firebar on far right on the screen, skip this,
         cmp #$f0                 ;because, really, what's the point?
         bcs Chk2Ofs
         lda Sprite_X_Position+4  ;get OAM X coordinate for sprite #1
         clc
         adc #$04                 ;add four pixels
         sta $04                  ;store here
         sec                      ;subtract horizontal coordinate of firebar
         sbc $06                  ;from the X coordinate of player's sprite 1
         bpl ChkFBCl              ;if modded X coordinate to the right of firebar
         eor #$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adc #$01
ChkFBCl: cmp #$08                 ;if difference < 8 pixels, collision, thus branch
         bcc ChgSDir              ;to process
Chk2Ofs: lda $05                  ;if value of $02 was set earlier for whatever reason,
         cmp #$02                 ;branch to increment OAM offset and leave, no collision
         beq NoColFB
         ldy $05                  ;otherwise get temp here and use as offset
         lda Player_Y_Position
         clc
         adc FirebarYPos,y        ;add value loaded with offset to player's vertical coordinate
         inc $05                  ;then increment temp and jump back
         jmp FBCLoop
ChgSDir: ldx #$01                 ;set movement direction by default
         lda $04                  ;if OAM X coordinate of player's sprite 1
         cmp $06                  ;is greater than horizontal coordinate of firebar
         bcs SetSDir              ;then do not alter movement direction
         inx                      ;otherwise increment it
SetSDir: stx Enemy_MovingDir      ;store movement direction here
         ldx #$00
         lda $00                  ;save value written to $00 to stack
         pha
         jsr InjurePlayer         ;perform sub to hurt or kill player
         pla
         sta $00                  ;get value of $00 from stack
NoColFB: pla                      ;get OAM data offset
         clc                      ;add four to it and save
         adc #$04
         sta $06
         ldx ObjectOffset         ;get enemy object buffer offset and leave
         rts

GetFirebarPosition:
           pha                        ;save high byte of spinstate to the stack
           and #%00001111             ;mask out low nybble
           cmp #$09
           bcc GetHAdder              ;if lower than $09, branch ahead
           eor #%00001111             ;otherwise get two's compliment to oscillate
           clc
           adc #$01
GetHAdder: sta $01                    ;store result, modified or not, here
           ldy $00                    ;load number of firebar ball where we're at
           lda FirebarTblOffsets,y    ;load offset to firebar position data
           clc
           adc $01                    ;add oscillated high byte of spinstate
           tay                        ;to offset here and use as new offset
           lda FirebarPosLookupTbl,y  ;get data here and store as horizontal adder
           sta $01
           pla                        ;pull whatever was in A from the stack
           pha                        ;save it again because we still need it
           clc
           adc #$08                   ;add eight this time, to get vertical adder
           and #%00001111             ;mask out high nybble
           cmp #$09                   ;if lower than $09, branch ahead
           bcc GetVAdder
           eor #%00001111             ;otherwise get two's compliment
           clc
           adc #$01
GetVAdder: sta $02                    ;store result here
           ldy $00
           lda FirebarTblOffsets,y    ;load offset to firebar position data again
           clc
           adc $02                    ;this time add value in $02 to offset here and use as offset
           tay
           lda FirebarPosLookupTbl,y  ;get data here and store as vertica adder
           sta $02
           pla                        ;pull out whatever was in A one last time
           lsr                        ;divide by eight or shift three to the right
           lsr
           lsr
           tay                        ;use as offset
           lda FirebarMirrorData,y    ;load mirroring data here
           sta $03                    ;store
           rts

;--------------------------------

PRandomSubtracter:
      .byte $f8, $a0, $70, $bd, $00

FlyCCBPriority:
      .byte $20, $20, $20, $00, $00

MoveFlyingCheepCheep:
        lda Enemy_State,x          ;check cheep-cheep's enemy state
        and #%00100000             ;for d5 set
        beq FlyCC                  ;branch to continue code if not set
        lda #$00
        sta Enemy_SprAttrib,x      ;otherwise clear sprite attributes
        jmp MoveJ_EnemyVertically  ;and jump to move defeated cheep-cheep downwards
FlyCC:  jsr MoveEnemyHorizontally  ;move cheep-cheep horizontally based on speed and force
        ldy #$0d                   ;set vertical movement amount
        lda #$05                   ;set maximum speed
        jsr SetXMoveAmt            ;branch to impose gravity on flying cheep-cheep
        lda Enemy_Y_MoveForce,x
        lsr                        ;get vertical movement force and
        lsr                        ;move high nybble to low
        lsr
        lsr
        tay                        ;save as offset (note this tends to go into reach of code)
        lda Enemy_Y_Position,x     ;get vertical position
        sec                        ;subtract pseudorandom value based on offset from position
        sbc PRandomSubtracter,y
        bpl AddCCF                  ;if result within top half of screen, skip this part
        eor #$ff
        clc                        ;otherwise get two's compliment
        adc #$01
AddCCF: cmp #$08                   ;if result or two's compliment greater than eight,
        bcs BPGet                  ;skip to the end without changing movement force
        lda Enemy_Y_MoveForce,x
        clc
        adc #$10                   ;otherwise add to it
        sta Enemy_Y_MoveForce,x
        lsr                        ;move high nybble to low again
        lsr
        lsr
        lsr
        tay
BPGet:  lda FlyCCBPriority,y       ;load bg priority data and store (this is very likely
        sta Enemy_SprAttrib,x      ;broken or residual code, value is overwritten before
        rts                        ;drawing it next frame), then leave

;--------------------------------
;$00 - used to hold horizontal difference
;$01-$03 - used to hold difference adjusters

LakituDiffAdj:
      .byte $15, $30, $40

MoveLakitu:
         lda Enemy_State,x          ;check lakitu's enemy state
         and #%00100000             ;for d5 set
         beq ChkLS                  ;if not set, continue with code
         jmp MoveD_EnemyVertically  ;otherwise jump to move defeated lakitu downwards
ChkLS:   lda Enemy_State,x          ;if lakitu's enemy state not set at all,
         beq Fr12S                  ;go ahead and continue with code
         lda #$00
         sta LakituMoveDirection,x  ;otherwise initialize moving direction to move to left
         sta EnemyFrenzyBuffer      ;initialize frenzy buffer
         lda #$10
         bne SetLSpd                ;load horizontal speed and do unconditional branch
Fr12S:   lda #Spiny
         sta EnemyFrenzyBuffer      ;set spiny identifier in frenzy buffer
         ldy #$02
LdLDa:   lda LakituDiffAdj,y        ;load values
         sta $0001,y                ;store in zero page
         dey
         bpl LdLDa                  ;do this until all values are stired
         jsr PlayerLakituDiff       ;execute sub to set speed and create spinys
SetLSpd: sta LakituMoveSpeed,x      ;set movement speed returned from sub
         ldy #$01                   ;set moving direction to right by default
         lda LakituMoveDirection,x
         and #$01                   ;get LSB of moving direction
         bne SetLMov                ;if set, branch to the end to use moving direction
         lda LakituMoveSpeed,x
         eor #$ff                   ;get two's compliment of moving speed
         clc
         adc #$01
         sta LakituMoveSpeed,x      ;store as new moving speed
         iny                        ;increment moving direction to left
SetLMov: sty Enemy_MovingDir,x      ;store moving direction
         jmp MoveEnemyHorizontally  ;move lakitu horizontally

PlayerLakituDiff:
           ldy #$00                   ;set Y for default value
           jsr PlayerEnemyDiff        ;get horizontal difference between enemy and player
           bpl ChkLakDif              ;branch if enemy is to the right of the player
           iny                        ;increment Y for left of player
           lda $00
           eor #$ff                   ;get two's compliment of low byte of horizontal difference
           clc
           adc #$01                   ;store two's compliment as horizontal difference
           sta $00
ChkLakDif: lda $00                    ;get low byte of horizontal difference
           cmp #$3c                   ;if within a certain distance of player, branch
           bcc ChkPSpeed
           lda #$3c                   ;otherwise set maximum distance
           sta $00
           lda Enemy_ID,x             ;check if lakitu is in our current enemy slot
           cmp #Lakitu
           bne ChkPSpeed              ;if not, branch elsewhere
           tya                        ;compare contents of Y, now in A
           cmp LakituMoveDirection,x  ;to what is being used as horizontal movement direction
           beq ChkPSpeed              ;if moving toward the player, branch, do not alter
           lda LakituMoveDirection,x  ;if moving to the left beyond maximum distance,
           beq SetLMovD               ;branch and alter without delay
           dec LakituMoveSpeed,x      ;decrement horizontal speed
           lda LakituMoveSpeed,x      ;if horizontal speed not yet at zero, branch to leave
           bne ExMoveLak
SetLMovD:  tya                        ;set horizontal direction depending on horizontal
           sta LakituMoveDirection,x  ;difference between enemy and player if necessary
ChkPSpeed: lda $00
           and #%00111100             ;mask out all but four bits in the middle
           lsr                        ;divide masked difference by four
           lsr
           sta $00                    ;store as new value
           ldy #$00                   ;init offset
           lda Player_X_Speed
           beq SubDifAdj              ;if player not moving horizontally, branch
           lda ScrollAmount
           beq SubDifAdj              ;if scroll speed not set, branch to same place
           iny                        ;otherwise increment offset
           lda Player_X_Speed
           cmp #$19                   ;if player not running, branch
           bcc ChkSpinyO
           lda ScrollAmount
           cmp #$02                   ;if scroll speed below a certain amount, branch
           bcc ChkSpinyO              ;to same place
           iny                        ;otherwise increment once more
ChkSpinyO: lda Enemy_ID,x             ;check for spiny object
           cmp #Spiny
           bne ChkEmySpd              ;branch if not found
           lda Player_X_Speed         ;if player not moving, skip this part
           bne SubDifAdj
ChkEmySpd: lda Enemy_Y_Speed,x        ;check vertical speed
           bne SubDifAdj              ;branch if nonzero
           ldy #$00                   ;otherwise reinit offset
SubDifAdj: lda $0001,y                ;get one of three saved values from earlier
           ldy $00                    ;get saved horizontal difference
SPixelLak: sec                        ;subtract one for each pixel of horizontal difference
           sbc #$01                   ;from one of three saved values
           dey
           bpl SPixelLak              ;branch until all pixels are subtracted, to adjust difference
ExMoveLak: rts                        ;leave!!!

;-------------------------------------------------------------------------------------
;$04-$05 - used to store name table address in little endian order

BridgeCollapseData:
      .byte $1a ;axe
      .byte $58 ;chain
      .byte $98, $96, $94, $92, $90, $8e, $8c ;bridge
      .byte $8a, $88, $86, $84, $82, $80

BridgeCollapse:
       ldx BowserFront_Offset    ;get enemy offset for bowser
       lda Enemy_ID,x            ;check enemy object identifier for bowser
       cmp #Bowser               ;if not found, branch ahead,
       bne SetM2                 ;metatile removal not necessary
       stx ObjectOffset          ;store as enemy offset here
       lda Enemy_State,x         ;if bowser in normal state, skip all of this
       beq RemoveBridge
       and #%01000000            ;if bowser's state has d6 clear, skip to silence music
       beq SetM2
       lda Enemy_Y_Position,x    ;check bowser's vertical coordinate
       cmp #$e0                  ;if bowser not yet low enough, skip this part ahead
       bcc MoveD_Bowser
SetM2: lda #Silence              ;silence music
       sta EventMusicQueue
       inc OperMode_Task         ;move onto next secondary mode in autoctrl mode
       jmp KillAllEnemies        ;jump to empty all enemy slots and then leave

MoveD_Bowser:
       jsr MoveEnemySlowVert     ;do a sub to move bowser downwards
       jmp BowserGfxHandler      ;jump to draw bowser's front and rear, then leave

RemoveBridge:
         dec BowserFeetCounter     ;decrement timer to control bowser's feet
         bne NoBFall               ;if not expired, skip all of this
         lda #$04
         sta BowserFeetCounter     ;otherwise, set timer now
         lda BowserBodyControls
         eor #$01                  ;invert bit to control bowser's feet
         sta BowserBodyControls
         lda #$22                  ;put high byte of name table address here for now
         sta $05
         ldy BridgeCollapseOffset  ;get bridge collapse offset here
         lda BridgeCollapseData,y  ;load low byte of name table address and store here
         sta $04
         ldy VRAM_Buffer1_Offset   ;increment vram buffer offset
         iny
         ldx #$0c                  ;set offset for tile data for sub to draw blank metatile
         jsr RemBridge             ;do sub here to remove bowser's bridge metatiles
         ldx ObjectOffset          ;get enemy offset
         jsr MoveVOffset           ;set new vram buffer offset
         lda #Sfx_Blast            ;load the fireworks/gunfire sound into the square 2 sfx
         sta Square2SoundQueue     ;queue while at the same time loading the brick
         lda #Sfx_BrickShatter     ;shatter sound into the noise sfx queue thus
         sta NoiseSoundQueue       ;producing the unique sound of the bridge collapsing
         inc BridgeCollapseOffset  ;increment bridge collapse offset
         lda BridgeCollapseOffset
         cmp #$0f                  ;if bridge collapse offset has not yet reached
         bne NoBFall               ;the end, go ahead and skip this part
         jsr InitVStf              ;initialize whatever vertical speed bowser has
         lda #%01000000
         sta Enemy_State,x         ;set bowser's state to one of defeated states (d6 set)
         lda #Sfx_BowserFall
         sta Square2SoundQueue     ;play bowser defeat sound
NoBFall: jmp BowserGfxHandler      ;jump to code that draws bowser

;--------------------------------

PRandomRange:
      .byte $21, $41, $11, $31

RunBowser:
      lda Enemy_State,x       ;if d5 in enemy state is not set
      and #%00100000          ;then branch elsewhere to run bowser
      beq BowserControl
      lda Enemy_Y_Position,x  ;otherwise check vertical position
      cmp #$e0                ;if above a certain point, branch to move defeated bowser
      bcc MoveD_Bowser        ;otherwise proceed to KillAllEnemies

KillAllEnemies:
          ldx #$04              ;start with last enemy slot
KillLoop: jsr EraseEnemyObject  ;branch to kill enemy objects
          dex                   ;move onto next enemy slot
          bpl KillLoop          ;do this until all slots are emptied
          sta EnemyFrenzyBuffer ;empty frenzy buffer
          ldx ObjectOffset      ;get enemy object offset and leave
          rts

BowserControl:
           lda #$00
           sta EnemyFrenzyBuffer      ;empty frenzy buffer
           lda TimerControl           ;if master timer control not set,
           beq ChkMouth               ;skip jump and execute code here
           jmp SkipToFB               ;otherwise, jump over a bunch of code
ChkMouth:  lda BowserBodyControls     ;check bowser's mouth
           bpl FeetTmr                ;if bit clear, go ahead with code here
           jmp HammerChk              ;otherwise skip a whole section starting here
FeetTmr:   dec BowserFeetCounter      ;decrement timer to control bowser's feet
           bne ResetMDr               ;if not expired, skip this part
           lda #$20                   ;otherwise, reset timer
           sta BowserFeetCounter
           lda BowserBodyControls     ;and invert bit used
           eor #%00000001             ;to control bowser's feet
           sta BowserBodyControls
ResetMDr:  lda FrameCounter           ;check frame counter
           and #%00001111             ;if not on every sixteenth frame, skip
           bne B_FaceP                ;ahead to continue code
           lda #$02                   ;otherwise reset moving/facing direction every
           sta Enemy_MovingDir,x      ;sixteen frames
B_FaceP:   lda EnemyFrameTimer,x      ;if timer set here expired,
           beq GetPRCmp               ;branch to next section
           jsr PlayerEnemyDiff        ;get horizontal difference between player and bowser,
           bpl GetPRCmp               ;and branch if bowser to the right of the player
           lda #$01
           sta Enemy_MovingDir,x      ;set bowser to move and face to the right
           lda #$02
           sta BowserMovementSpeed    ;set movement speed
           lda #$20
           sta EnemyFrameTimer,x      ;set timer here
           sta BowserFireBreathTimer  ;set timer used for bowser's flame
           lda Enemy_X_Position,x
           cmp #$c8                   ;if bowser to the right past a certain point,
           bcs HammerChk              ;skip ahead to some other section
GetPRCmp:  lda FrameCounter           ;get frame counter
           and #%00000011
           bne HammerChk              ;execute this code every fourth frame, otherwise branch
           lda Enemy_X_Position,x
           cmp BowserOrigXPos         ;if bowser not at original horizontal position,
           bne GetDToO                ;branch to skip this part
           lda PseudoRandomBitReg,x
           and #%00000011             ;get pseudorandom offset
           tay
           lda PRandomRange,y         ;load value using pseudorandom offset
           sta MaxRangeFromOrigin     ;and store here
GetDToO:   lda Enemy_X_Position,x
           clc                        ;add movement speed to bowser's horizontal
           adc BowserMovementSpeed    ;coordinate and save as new horizontal position
           sta Enemy_X_Position,x
           ldy Enemy_MovingDir,x
           cpy #$01                   ;if bowser moving and facing to the right, skip ahead
           beq HammerChk
           ldy #$ff                   ;set default movement speed here (move left)
           sec                        ;get difference of current vs. original
           sbc BowserOrigXPos         ;horizontal position
           bpl CompDToO               ;if current position to the right of original, skip ahead
           eor #$ff
           clc                        ;get two's compliment
           adc #$01
           ldy #$01                   ;set alternate movement speed here (move right)
CompDToO:  cmp MaxRangeFromOrigin     ;compare difference with pseudorandom value
           bcc HammerChk              ;if difference < pseudorandom value, leave speed alone
           sty BowserMovementSpeed    ;otherwise change bowser's movement speed
HammerChk: lda EnemyFrameTimer,x      ;if timer set here not expired yet, skip ahead to
           bne MakeBJump              ;some other section of code
           jsr MoveEnemySlowVert      ;otherwise start by moving bowser downwards
           lda WorldNumber            ;check world number
           cmp #World6
           bcc SetHmrTmr              ;if world 1-5, skip this part (not time to throw hammers yet)
           lda FrameCounter
           and #%00000011             ;check to see if it's time to execute sub
           bne SetHmrTmr              ;if not, skip sub, otherwise
           jsr SpawnHammerObj         ;execute sub on every fourth frame to spawn misc object (hammer)
SetHmrTmr: lda Enemy_Y_Position,x     ;get current vertical position
           cmp #$80                   ;if still above a certain point
           bcc ChkFireB               ;then skip to world number check for flames
           lda PseudoRandomBitReg,x
           and #%00000011             ;get pseudorandom offset
           tay
           lda PRandomRange,y         ;get value using pseudorandom offset
           sta EnemyFrameTimer,x      ;set for timer here
SkipToFB:  jmp ChkFireB               ;jump to execute flames code
MakeBJump: cmp #$01                   ;if timer not yet about to expire,
           bne ChkFireB               ;skip ahead to next part
           dec Enemy_Y_Position,x     ;otherwise decrement vertical coordinate
           jsr InitVStf               ;initialize movement amount
           lda #$fe
           sta Enemy_Y_Speed,x        ;set vertical speed to move bowser upwards
ChkFireB:  lda WorldNumber            ;check world number here
           cmp #World8                ;world 8?
           beq SpawnFBr               ;if so, execute this part here
           cmp #World6                ;world 6-7?
           bcs BowserGfxHandler       ;if so, skip this part here
SpawnFBr:  lda BowserFireBreathTimer  ;check timer here
           bne BowserGfxHandler       ;if not expired yet, skip all of this
           lda #$20
           sta BowserFireBreathTimer  ;set timer here
           lda BowserBodyControls
           eor #%10000000             ;invert bowser's mouth bit to open
           sta BowserBodyControls     ;and close bowser's mouth
           bmi ChkFireB               ;if bowser's mouth open, loop back
           jsr SetFlameTimer          ;get timing for bowser's flame
           ldy SecondaryHardMode
           beq SetFBTmr               ;if secondary hard mode flag not set, skip this
           sec
           sbc #$10                   ;otherwise subtract from value in A
SetFBTmr:  sta BowserFireBreathTimer  ;set value as timer here
           lda #BowserFlame           ;put bowser's flame identifier
           sta EnemyFrenzyBuffer      ;in enemy frenzy buffer

;--------------------------------

BowserGfxHandler:
          jsr ProcessBowserHalf    ;do a sub here to process bowser's front
          ldy #$10                 ;load default value here to position bowser's rear
          lda Enemy_MovingDir,x    ;check moving direction
          lsr
          bcc CopyFToR             ;if moving left, use default
          ldy #$f0                 ;otherwise load alternate positioning value here
CopyFToR: tya                      ;move bowser's rear object position value to A
          clc
          adc Enemy_X_Position,x   ;add to bowser's front object horizontal coordinate
          ldy DuplicateObj_Offset  ;get bowser's rear object offset
          sta Enemy_X_Position,y   ;store A as bowser's rear horizontal coordinate
          lda Enemy_Y_Position,x
          clc                      ;add eight pixels to bowser's front object
          adc #$08                 ;vertical coordinate and store as vertical coordinate
          sta Enemy_Y_Position,y   ;for bowser's rear
          lda Enemy_State,x
          sta Enemy_State,y        ;copy enemy state directly from front to rear
          lda Enemy_MovingDir,x
          sta Enemy_MovingDir,y    ;copy moving direction also
          lda ObjectOffset         ;save enemy object offset of front to stack
          pha
          ldx DuplicateObj_Offset  ;put enemy object offset of rear as current
          stx ObjectOffset
          lda #Bowser              ;set bowser's enemy identifier
          sta Enemy_ID,x           ;store in bowser's rear object
          jsr ProcessBowserHalf    ;do a sub here to process bowser's rear
          pla
          sta ObjectOffset         ;get original enemy object offset
          tax
          lda #$00                 ;nullify bowser's front/rear graphics flag
          sta BowserGfxFlag
ExBGfxH:  rts                      ;leave!

ProcessBowserHalf:
      inc BowserGfxFlag         ;increment bowser's graphics flag, then run subroutines
      jsr RunRetainerObj        ;to get offscreen bits, relative position and draw bowser (finally!)
      lda Enemy_State,x
      bne ExBGfxH               ;if either enemy object not in normal state, branch to leave
      lda #$0a
      sta Enemy_BoundBoxCtrl,x  ;set bounding box size control
      jsr GetEnemyBoundBox      ;get bounding box coordinates
      jmp PlayerEnemyCollision  ;do player-to-enemy collision detection

;-------------------------------------------------------------------------------------
;$00 - used to hold movement force and tile number
;$01 - used to hold sprite attribute data

FlameTimerData:
      .byte $bf, $40, $bf, $bf, $bf, $40, $40, $bf

SetFlameTimer:
      ldy BowserFlameTimerCtrl  ;load counter as offset
      inc BowserFlameTimerCtrl  ;increment
      lda BowserFlameTimerCtrl  ;mask out all but 3 LSB
      and #%00000111            ;to keep in range of 0-7
      sta BowserFlameTimerCtrl
      lda FlameTimerData,y      ;load value to be used then leave
ExFl: rts

ProcBowserFlame:
         lda TimerControl            ;if master timer control flag set,
         bne SetGfxF                 ;skip all of this
         lda #$40                    ;load default movement force
         ldy SecondaryHardMode
         beq SFlmX                   ;if secondary hard mode flag not set, use default
         lda #$60                    ;otherwise load alternate movement force to go faster
SFlmX:   sta $00                     ;store value here
         lda Enemy_X_MoveForce,x
         sec                         ;subtract value from movement force
         sbc $00
         sta Enemy_X_MoveForce,x     ;save new value
         lda Enemy_X_Position,x
         sbc #$01                    ;subtract one from horizontal position to move
         sta Enemy_X_Position,x      ;to the left
         lda Enemy_PageLoc,x
         sbc #$00                    ;subtract borrow from page location
         sta Enemy_PageLoc,x
         ldy BowserFlamePRandomOfs,x ;get some value here and use as offset
         lda Enemy_Y_Position,x      ;load vertical coordinate
         cmp FlameYPosData,y         ;compare against coordinate data using $0417,x as offset
         beq SetGfxF                 ;if equal, branch and do not modify coordinate
         clc
         adc Enemy_Y_MoveForce,x     ;otherwise add value here to coordinate and store
         sta Enemy_Y_Position,x      ;as new vertical coordinate
SetGfxF: jsr RelativeEnemyPosition   ;get new relative coordinates
         lda Enemy_State,x           ;if bowser's flame not in normal state,
         bne ExFl                    ;branch to leave
         lda #$f3                    ;otherwise, continue
         sta $00                     ;write first tile number
         ldy #$02                    ;load attributes without vertical flip by default
         lda FrameCounter
         and #%00000010              ;invert vertical flip bit every 2 frames
         beq FlmeAt                  ;if d1 not set, write default value
         ldy #$82                    ;otherwise write value with vertical flip bit set
FlmeAt:  sty $01                     ;set bowser's flame sprite attributes here
         ldy Enemy_SprDataOffset,x   ;get OAM data offset
         ldx #$00

DrawFlameLoop:
         lda Enemy_Rel_YPos         ;get Y relative coordinate of current enemy object
         sta Sprite_Y_Position,y    ;write into Y coordinate of OAM data
         lda $00
         sta Sprite_Tilenumber,y    ;write current tile number into OAM data
         inc $00                    ;increment tile number to draw more bowser's flame
         lda $01
         sta Sprite_Attributes,y    ;write saved attributes into OAM data
         lda Enemy_Rel_XPos
         sta Sprite_X_Position,y    ;write X relative coordinate of current enemy object
         clc
         adc #$08
         sta Enemy_Rel_XPos         ;then add eight to it and store
         iny
         iny
         iny
         iny                        ;increment Y four times to move onto the next OAM
         inx                        ;move onto the next OAM, and branch if three
         cpx #$03                   ;have not yet been done
         bcc DrawFlameLoop
         ldx ObjectOffset           ;reload original enemy offset
         jsr GetEnemyOffscreenBits  ;get offscreen information
         ldy Enemy_SprDataOffset,x  ;get OAM data offset
         lda Enemy_OffscreenBits    ;get enemy object offscreen bits
         lsr                        ;move d0 to carry and result to stack
         pha
         bcc M3FOfs                 ;branch if carry not set
         lda #$f8                   ;otherwise move sprite offscreen, this part likely
         sta Sprite_Y_Position+12,y ;residual since flame is only made of three sprites
M3FOfs:  pla                        ;get bits from stack
         lsr                        ;move d1 to carry and move bits back to stack
         pha
         bcc M2FOfs                 ;branch if carry not set again
         lda #$f8                   ;otherwise move third sprite offscreen
         sta Sprite_Y_Position+8,y
M2FOfs:  pla                        ;get bits from stack again
         lsr                        ;move d2 to carry and move bits back to stack again
         pha
         bcc M1FOfs                 ;branch if carry not set yet again
         lda #$f8                   ;otherwise move second sprite offscreen
         sta Sprite_Y_Position+4,y
M1FOfs:  pla                        ;get bits from stack one last time
         lsr                        ;move d3 to carry
         bcc ExFlmeD                ;branch if carry not set one last time
         lda #$f8
         sta Sprite_Y_Position,y    ;otherwise move first sprite offscreen
ExFlmeD: rts                        ;leave

;--------------------------------

RunFireworks:
           dec ExplosionTimerCounter,x ;decrement explosion timing counter here
           bne SetupExpl               ;if not expired, skip this part
           lda #$08
           sta ExplosionTimerCounter,x ;reset counter
           inc ExplosionGfxCounter,x   ;increment explosion graphics counter
           lda ExplosionGfxCounter,x
           cmp #$03                    ;check explosion graphics counter
           bcs FireworksSoundScore     ;if at a certain point, branch to kill this object
SetupExpl: jsr RelativeEnemyPosition   ;get relative coordinates of explosion
           lda Enemy_Rel_YPos          ;copy relative coordinates
           sta Fireball_Rel_YPos       ;from the enemy object to the fireball object
           lda Enemy_Rel_XPos          ;first vertical, then horizontal
           sta Fireball_Rel_XPos
           ldy Enemy_SprDataOffset,x   ;get OAM data offset
           lda ExplosionGfxCounter,x   ;get explosion graphics counter
           jsr DrawExplosion_Fireworks ;do a sub to draw the explosion then leave
           rts

FireworksSoundScore:
      lda #$00               ;disable enemy buffer flag
      sta Enemy_Flag,x
      lda #Sfx_Blast         ;play fireworks/gunfire sound
      sta Square2SoundQueue
      lda #$05               ;set part of score modifier for 500 points
      sta DigitModifier+4
      jmp EndAreaPoints     ;jump to award points accordingly then leave

;--------------------------------

StarFlagYPosAdder:
      .byte $00, $00, $08, $08

StarFlagXPosAdder:
      .byte $00, $08, $00, $08

StarFlagTileData:
      .byte $e8, $e9, $f8, $f9

RunStarFlagObj:
      lda #$00                 ;initialize enemy frenzy buffer
      sta EnemyFrenzyBuffer
      lda StarFlagTaskControl  ;check star flag object task number here
      cmp #$05                 ;if greater than 5, branch to exit
      bcs StarFlagExit
      jsr JumpEngine           ;otherwise jump to appropriate sub

      .word StarFlagExit
      .word GameTimerFireworks
      .word AwardGameTimerPoints
      .word RaiseFlagSetoffFWorks
      .word DelayToAreaEnd

GameTimerFireworks:
        ldy #$05               ;set default state for star flag object
        lda GameTimerDisplay+2 ;get game timer's last digit
        cmp #$01
        beq SetFWC             ;if last digit of game timer set to 1, skip ahead
        ldy #$03               ;otherwise load new value for state
        cmp #$03
        beq SetFWC             ;if last digit of game timer set to 3, skip ahead
        ldy #$00               ;otherwise load one more potential value for state
        cmp #$06
        beq SetFWC             ;if last digit of game timer set to 6, skip ahead
        lda #$ff               ;otherwise set value for no fireworks
SetFWC: sta FireworksCounter   ;set fireworks counter here
        sty Enemy_State,x      ;set whatever state we have in star flag object

IncrementSFTask1:
      inc StarFlagTaskControl  ;increment star flag object task number

StarFlagExit:
      rts                      ;leave

AwardGameTimerPoints:
         lda GameTimerDisplay   ;check all game timer digits for any intervals left
         ora GameTimerDisplay+1
         ora GameTimerDisplay+2
         beq IncrementSFTask1   ;if no time left on game timer at all, branch to next task
         lda FrameCounter
         and #%00000100         ;check frame counter for d2 set (skip ahead
         beq NoTTick            ;for four frames every four frames) branch if not set
         lda #Sfx_TimerTick
         sta Square2SoundQueue  ;load timer tick sound
NoTTick: ldy #$23               ;set offset here to subtract from game timer's last digit
         lda #$ff               ;set adder here to $ff, or -1, to subtract one
         sta DigitModifier+5    ;from the last digit of the game timer
         jsr DigitsMathRoutine  ;subtract digit
         lda #$05               ;set now to add 50 points
         sta DigitModifier+5    ;per game timer interval subtracted

EndAreaPoints:
         ldy #$0b               ;load offset for mario's score by default
         lda CurrentPlayer      ;check player on the screen
         beq ELPGive            ;if mario, do not change
         ldy #$11               ;otherwise load offset for luigi's score
ELPGive: jsr DigitsMathRoutine  ;award 50 points per game timer interval
         lda CurrentPlayer      ;get player on the screen (or 500 points per
         asl                    ;fireworks explosion if branched here from there)
         asl                    ;shift to high nybble
         asl
         asl
         ora #%00000100         ;add four to set nybble for game timer
         jmp UpdateNumber       ;jump to print the new score and game timer

RaiseFlagSetoffFWorks:
         lda Enemy_Y_Position,x  ;check star flag's vertical position
         cmp #$72                ;against preset value
         bcc SetoffF             ;if star flag higher vertically, branch to other code
         dec Enemy_Y_Position,x  ;otherwise, raise star flag by one pixel
         jmp DrawStarFlag        ;and skip this part here
SetoffF: lda FireworksCounter    ;check fireworks counter
         beq DrawFlagSetTimer    ;if no fireworks left to go off, skip this part
         bmi DrawFlagSetTimer    ;if no fireworks set to go off, skip this part
         lda #Fireworks
         sta EnemyFrenzyBuffer   ;otherwise set fireworks object in frenzy queue

DrawStarFlag:
         jsr RelativeEnemyPosition  ;get relative coordinates of star flag
         ldy Enemy_SprDataOffset,x  ;get OAM data offset
         ldx #$03                   ;do four sprites
DSFLoop: lda Enemy_Rel_YPos         ;get relative vertical coordinate
         clc
         adc StarFlagYPosAdder,x    ;add Y coordinate adder data
         sta Sprite_Y_Position,y    ;store as Y coordinate
         lda StarFlagTileData,x     ;get tile number
         sta Sprite_Tilenumber,y    ;store as tile number
         lda #$22                   ;set palette and background priority bits
         sta Sprite_Attributes,y    ;store as attributes
         lda Enemy_Rel_XPos         ;get relative horizontal coordinate
         clc
         adc StarFlagXPosAdder,x    ;add X coordinate adder data
         sta Sprite_X_Position,y    ;store as X coordinate
         iny
         iny                        ;increment OAM data offset four bytes
         iny                        ;for next sprite
         iny
         dex                        ;move onto next sprite
         bpl DSFLoop                ;do this until all sprites are done
         ldx ObjectOffset           ;get enemy object offset and leave
         rts

DrawFlagSetTimer:
      jsr DrawStarFlag          ;do sub to draw star flag
      lda #$06
      sta EnemyIntervalTimer,x  ;set interval timer here

IncrementSFTask2:
      inc StarFlagTaskControl   ;move onto next task
      rts

DelayToAreaEnd:
      jsr DrawStarFlag          ;do sub to draw star flag
      lda EnemyIntervalTimer,x  ;if interval timer set in previous task
      bne StarFlagExit2         ;not yet expired, branch to leave
      lda songPlaying           ;if event music buffer empty,
      beq IncrementSFTask2      ;branch to increment task

StarFlagExit2:
      rts                       ;otherwise leave

;--------------------------------
;$00 - used to store horizontal difference between player and piranha plant

MovePiranhaPlant:
      lda Enemy_State,x           ;check enemy state
      bne PutinPipe               ;if set at all, branch to leave
      lda EnemyFrameTimer,x       ;check enemy's timer here
      bne PutinPipe               ;branch to end if not yet expired
      lda PiranhaPlant_MoveFlag,x ;check movement flag
      bne SetupToMovePPlant       ;if moving, skip to part ahead
      lda PiranhaPlant_Y_Speed,x  ;if currently rising, branch
      bmi ReversePlantSpeed       ;to move enemy upwards out of pipe
      jsr PlayerEnemyDiff         ;get horizontal difference between player and
      bpl ChkPlayerNearPipe       ;piranha plant, and branch if enemy to right of player
      lda $00                     ;otherwise get saved horizontal difference
      eor #$ff
      clc                         ;and change to two's compliment
      adc #$01
      sta $00                     ;save as new horizontal difference

ChkPlayerNearPipe:
      lda $00                     ;get saved horizontal difference
      cmp #$21
      bcc PutinPipe               ;if player within a certain distance, branch to leave

ReversePlantSpeed:
      lda PiranhaPlant_Y_Speed,x  ;get vertical speed
      eor #$ff
      clc                         ;change to two's compliment
      adc #$01
      sta PiranhaPlant_Y_Speed,x  ;save as new vertical speed
      inc PiranhaPlant_MoveFlag,x ;increment to set movement flag

SetupToMovePPlant:
      lda PiranhaPlantDownYPos,x  ;get original vertical coordinate (lowest point)
      ldy PiranhaPlant_Y_Speed,x  ;get vertical speed
      bpl RiseFallPiranhaPlant    ;branch if moving downwards
      lda PiranhaPlantUpYPos,x    ;otherwise get other vertical coordinate (highest point)

RiseFallPiranhaPlant:
      sta $00                     ;save vertical coordinate here
      lda FrameCounter            ;get frame counter
      lsr
      bcc PutinPipe               ;branch to leave if d0 set (execute code every other frame)
      lda TimerControl            ;get master timer control
      bne PutinPipe               ;branch to leave if set (likely not necessary)
      lda Enemy_Y_Position,x      ;get current vertical coordinate
      clc
      adc PiranhaPlant_Y_Speed,x  ;add vertical speed to move up or down
      sta Enemy_Y_Position,x      ;save as new vertical coordinate
      cmp $00                     ;compare against low or high coordinate
      bne PutinPipe               ;branch to leave if not yet reached
      lda #$00
      sta PiranhaPlant_MoveFlag,x ;otherwise clear movement flag
      lda #$40
      sta EnemyFrameTimer,x       ;set timer to delay piranha plant movement

PutinPipe:
      lda #%00100000              ;set background priority bit in sprite
      sta Enemy_SprAttrib,x       ;attributes to give illusion of being inside pipe
      rts                         ;then leave

;-------------------------------------------------------------------------------------
;$07 - spinning speed

FirebarSpin:
      sta $07                     ;save spinning speed here
      lda FirebarSpinDirection,x  ;check spinning direction
      bne SpinCounterClockwise    ;if moving counter-clockwise, branch to other part
      ldy #$18                    ;possibly residual ldy
      lda FirebarSpinState_Low,x
      clc                         ;add spinning speed to what would normally be
      adc $07                     ;the horizontal speed
      sta FirebarSpinState_Low,x
      lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
      adc #$00
      rts

SpinCounterClockwise:
      ldy #$08                    ;possibly residual ldy
      lda FirebarSpinState_Low,x
      sec                         ;subtract spinning speed to what would normally be
      sbc $07                     ;the horizontal speed
      sta FirebarSpinState_Low,x
      lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
      sbc #$00
      rts

;-------------------------------------------------------------------------------------
;$00 - used to hold collision flag, Y movement force + 5 or low byte of name table for rope
;$01 - used to hold high byte of name table for rope
;$02 - used to hold page location of rope

BalancePlatform:
       lda Enemy_Y_HighPos,x       ;check high byte of vertical position
       cmp #$03
       bne DoBPl
       jmp EraseEnemyObject        ;if far below screen, kill the object
DoBPl: lda Enemy_State,x           ;get object's state (set to $ff or other platform offset)
       bpl CheckBalPlatform        ;if doing other balance platform, branch to leave
       rts

CheckBalPlatform:
       tay                         ;save offset from state as Y
       lda PlatformCollisionFlag,x ;get collision flag of platform
       sta $00                     ;store here
       lda Enemy_MovingDir,x       ;get moving direction
       beq ChkForFall
       jmp PlatformFall            ;if set, jump here

ChkForFall:
       lda #$2d                    ;check if platform is above a certain point
       cmp Enemy_Y_Position,x
       bcc ChkOtherForFall         ;if not, branch elsewhere
       cpy $00                     ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adc #$02                    ;otherwise add 2 pixels to vertical position
       sta Enemy_Y_Position,x      ;of current platform and branch elsewhere
       jmp StopPlatforms           ;to make platforms stop

MakePlatformFall:
       jmp InitPlatformFall        ;make platforms fall

ChkOtherForFall:
       cmp Enemy_Y_Position,y      ;check if other platform is above a certain point
       bcc ChkToMoveBalPlat        ;if not, branch elsewhere
       cpx $00                     ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adc #$02                    ;otherwise add 2 pixels to vertical position
       sta Enemy_Y_Position,y      ;of other platform and branch elsewhere
       jmp StopPlatforms           ;jump to stop movement and do not return

ChkToMoveBalPlat:
        lda Enemy_Y_Position,x      ;save vertical position to stack
        pha
        lda PlatformCollisionFlag,x ;get collision flag
        bpl ColFlg                  ;branch if collision
        lda Enemy_Y_MoveForce,x
        clc                         ;add $05 to contents of moveforce, whatever they be
        adc #$05
        sta $00                     ;store here
        lda Enemy_Y_Speed,x
        adc #$00                    ;add carry to vertical speed
        bmi PlatDn                  ;branch if moving downwards
        bne PlatUp                  ;branch elsewhere if moving upwards
        lda $00
        cmp #$0b                    ;check if there's still a little force left
        bcc PlatSt                  ;if not enough, branch to stop movement
        bcs PlatUp                  ;otherwise keep branch to move upwards
ColFlg: cmp ObjectOffset            ;if collision flag matches
        beq PlatDn                  ;current enemy object offset, branch
PlatUp: jsr MovePlatformUp          ;do a sub to move upwards
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatSt: jsr StopPlatforms           ;do a sub to stop movement
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatDn: jsr MovePlatformDown        ;do a sub to move downwards

DoOtherPlatform:
       ldy Enemy_State,x           ;get offset of other platform
       pla                         ;get old vertical coordinate from stack
       sec
       sbc Enemy_Y_Position,x      ;get difference of old vs. new coordinate
       clc
       adc Enemy_Y_Position,y      ;add difference to vertical coordinate of other
       sta Enemy_Y_Position,y      ;platform to move it in the opposite direction
       lda PlatformCollisionFlag,x ;if no collision, skip this part here
       bmi DrawEraseRope
       tax                         ;put offset which collision occurred here
       jsr PositionPlayerOnVPlat   ;and use it to position player accordingly

DrawEraseRope:
         ldy ObjectOffset            ;get enemy object offset
         lda Enemy_Y_Speed,y         ;check to see if current platform is
         ora Enemy_Y_MoveForce,y     ;moving at all
         beq ExitRp                  ;if not, skip all of this and branch to leave
         ldx VRAM_Buffer1_Offset     ;get vram buffer offset
         cpx #$20                    ;if offset beyond a certain point, go ahead
         bcs ExitRp                  ;and skip this, branch to leave
         lda Enemy_Y_Speed,y
         pha                         ;save two copies of vertical speed to stack
         pha
         jsr SetupPlatformRope       ;do a sub to figure out where to put new bg tiles
         lda $01                     ;write name table address to vram buffer
         sta VRAM_Buffer1,x          ;first the high byte, then the low
         lda $00
         sta VRAM_Buffer1+1,x
         lda #$02                    ;set length for 2 bytes
         sta VRAM_Buffer1+2,x
         lda Enemy_Y_Speed,y         ;if platform moving upwards, branch
         bmi EraseR1                 ;to do something else
         lda #$7d
         sta VRAM_Buffer1+3,x        ;otherwise put tile numbers for left
         lda #$7e                    ;and right sides of rope in vram buffer
         sta VRAM_Buffer1+4,x
         jmp OtherRope               ;jump to skip this part
EraseR1: lda #$24                    ;put blank tiles in vram buffer
         sta VRAM_Buffer1+3,x        ;to erase rope
         sta VRAM_Buffer1+4,x

OtherRope:
         lda Enemy_State,y           ;get offset of other platform from state
         tay                         ;use as Y here
         pla                         ;pull second copy of vertical speed from stack
         eor #$ff                    ;invert bits to reverse speed
         jsr SetupPlatformRope       ;do sub again to figure out where to put bg tiles
         lda $01                     ;write name table address to vram buffer
         sta VRAM_Buffer1+5,x        ;this time we're doing putting tiles for
         lda $00                     ;the other platform
         sta VRAM_Buffer1+6,x
         lda #$02
         sta VRAM_Buffer1+7,x        ;set length again for 2 bytes
         pla                         ;pull first copy of vertical speed from stack
         bpl EraseR2                 ;if moving upwards (note inversion earlier), skip this
         lda #$7d
         sta VRAM_Buffer1+8,x        ;otherwise put tile numbers for left
         lda #$7e                    ;and right sides of rope in vram
         sta VRAM_Buffer1+9,x        ;transfer buffer
         jmp EndRp                   ;jump to skip this part
EraseR2: lda #$24                    ;put blank tiles in vram buffer
         sta VRAM_Buffer1+8,x        ;to erase rope
         sta VRAM_Buffer1+9,x
EndRp:   lda #$00                    ;put null terminator at the end
         sta VRAM_Buffer1+10,x
         lda VRAM_Buffer1_Offset     ;add ten bytes to the vram buffer offset
         clc                         ;and store
         adc #10
         sta VRAM_Buffer1_Offset
ExitRp:  ldx ObjectOffset            ;get enemy object buffer offset and leave
         rts

SetupPlatformRope:
        pha                     ;save second/third copy to stack
        lda Enemy_X_Position,y  ;get horizontal coordinate
        clc
        adc #$08                ;add eight pixels
        ldx SecondaryHardMode   ;if secondary hard mode flag set,
        bne GetLRp              ;use coordinate as-is
        clc
        adc #$10                ;otherwise add sixteen more pixels
GetLRp: pha                     ;save modified horizontal coordinate to stack
        lda Enemy_PageLoc,y
        adc #$00                ;add carry to page location
        sta $02                 ;and save here
        pla                     ;pull modified horizontal coordinate
        and #%11110000          ;from the stack, mask out low nybble
        lsr                     ;and shift three bits to the right
        lsr
        lsr
        sta $00                 ;store result here as part of name table low byte
        ldx Enemy_Y_Position,y  ;get vertical coordinate
        pla                     ;get second/third copy of vertical speed from stack
        bpl GetHRp              ;skip this part if moving downwards or not at all
        txa
        clc
        adc #$08                ;add eight to vertical coordinate and
        tax                     ;save as X
GetHRp: txa                     ;move vertical coordinate to A
        ldx VRAM_Buffer1_Offset ;get vram buffer offset
        asl
        rol                     ;rotate d7 to d0 and d6 into carry
        pha                     ;save modified vertical coordinate to stack
        rol                     ;rotate carry to d0, thus d7 and d6 are at 2 LSB
        and #%00000011          ;mask out all bits but d7 and d6, then set
        ora #%00100000          ;d5 to get appropriate high byte of name table
        sta $01                 ;address, then store
        lda $02                 ;get saved page location from earlier
        and #$01                ;mask out all but LSB
        asl
        asl                     ;shift twice to the left and save with the
        ora $01                 ;rest of the bits of the high byte, to get
        sta $01                 ;the proper name table and the right place on it
        pla                     ;get modified vertical coordinate from stack
        and #%11100000          ;mask out low nybble and LSB of high nybble
        clc
        adc $00                 ;add to horizontal part saved here
        sta $00                 ;save as name table low byte
        lda Enemy_Y_Position,y
        cmp #$e8                ;if vertical position not below the
        bcc ExPRp               ;bottom of the screen, we're done, branch to leave
        lda $00
        and #%10111111          ;mask out d6 of low byte of name table address
        sta $00
ExPRp:  rts                     ;leave!

InitPlatformFall:
      tya                        ;move offset of other platform from Y to X
      tax
      jsr GetEnemyOffscreenBits  ;get offscreen bits
      lda #$06
      jsr SetupFloateyNumber     ;award 1000 points to player
      lda Player_Rel_XPos
      sta FloateyNum_X_Pos,x     ;put floatey number coordinates where player is
      lda Player_Y_Position
      sta FloateyNum_Y_Pos,x
      lda #$01                   ;set moving direction as flag for
      sta Enemy_MovingDir,x      ;falling platforms

StopPlatforms:
      jsr InitVStf             ;initialize vertical speed and low byte
      sta Enemy_Y_Speed,y      ;for both platforms and leave
      sta Enemy_Y_MoveForce,y
      rts

PlatformFall:
      tya                         ;save offset for other platform to stack
      pha
      jsr MoveFallingPlatform     ;make current platform fall
      pla
      tax                         ;pull offset from stack and save to X
      jsr MoveFallingPlatform     ;make other platform fall
      ldx ObjectOffset
      lda PlatformCollisionFlag,x ;if player not standing on either platform,
      bmi ExPF                    ;skip this part
      tax                         ;transfer collision flag offset as offset to X
      jsr PositionPlayerOnVPlat   ;and position player appropriately
ExPF: ldx ObjectOffset            ;get enemy object buffer offset and leave
      rts

;--------------------------------

YMovingPlatform:
        lda Enemy_Y_Speed,x          ;if platform moving up or down, skip ahead to
        ora Enemy_Y_MoveForce,x      ;check on other position
        bne ChkYCenterPos
        sta Enemy_YMF_Dummy,x        ;initialize dummy variable
        lda Enemy_Y_Position,x
        cmp YPlatformTopYPos,x       ;if current vertical position => top position, branch
        bcs ChkYCenterPos            ;ahead of all this
        lda FrameCounter
        and #%00000111               ;check for every eighth frame
        bne SkipIY
        inc Enemy_Y_Position,x       ;increase vertical position every eighth frame
SkipIY: jmp ChkYPCollision           ;skip ahead to last part

ChkYCenterPos:
        lda Enemy_Y_Position,x       ;if current vertical position < central position, branch
        cmp YPlatformCenterYPos,x    ;to slow ascent/move downwards
        bcc YMDown
        jsr MovePlatformUp           ;otherwise start slowing descent/moving upwards
        jmp ChkYPCollision
YMDown: jsr MovePlatformDown         ;start slowing ascent/moving downwards

ChkYPCollision:
       lda PlatformCollisionFlag,x  ;if collision flag not set here, branch
       bmi ExYPl                    ;to leave
       jsr PositionPlayerOnVPlat    ;otherwise position player appropriately
ExYPl: rts                          ;leave

;--------------------------------
;$00 - used as adder to position player hotizontally

XMovingPlatform:
      lda #$0e                     ;load preset maximum value for secondary counter
      jsr XMoveCntr_Platform       ;do a sub to increment counters for movement
      jsr MoveWithXMCntrs          ;do a sub to move platform accordingly, and return value
      lda PlatformCollisionFlag,x  ;if no collision with player,
      bmi ExXMP                    ;branch ahead to leave

PositionPlayerOnHPlat:
         lda Player_X_Position
         clc                       ;add saved value from second subroutine to
         adc $00                   ;current player's position to position
         sta Player_X_Position     ;player accordingly in horizontal position
         lda Player_PageLoc        ;get player's page location
         ldy $00                   ;check to see if saved value here is positive or negative
         bmi PPHSubt               ;if negative, branch to subtract
         adc #$00                  ;otherwise add carry to page location
         jmp SetPVar               ;jump to skip subtraction
PPHSubt: sbc #$00                  ;subtract borrow from page location
SetPVar: sta Player_PageLoc        ;save result to player's page location
         sty Platform_X_Scroll     ;put saved value from second sub here to be used later
         jsr PositionPlayerOnVPlat ;position player vertically and appropriately
ExXMP:   rts                       ;and we are done here

;--------------------------------

DropPlatform:
       lda PlatformCollisionFlag,x  ;if no collision between platform and player
       bmi ExDPl                    ;occurred, just leave without moving anything
       jsr MoveDropPlatform         ;otherwise do a sub to move platform down very quickly
       jsr PositionPlayerOnVPlat    ;do a sub to position player appropriately
ExDPl: rts                          ;leave

;--------------------------------
;$00 - residual value from sub

RightPlatform:
       jsr MoveEnemyHorizontally     ;move platform with current horizontal speed, if any
       sta $00                       ;store saved value here (residual code)
       lda PlatformCollisionFlag,x   ;check collision flag, if no collision between player
       bmi ExRPl                     ;and platform, branch ahead, leave speed unaltered
       lda #riding_speed
       sta Enemy_X_Speed,x           ;otherwise set new speed (gets moving if motionless)
       jsr PositionPlayerOnHPlat     ;use saved value from earlier sub to position player
ExRPl: rts                           ;then leave

;--------------------------------

MoveLargeLiftPlat:
      jsr MoveLiftPlatforms  ;execute common to all large and small lift platforms
      jmp ChkYPCollision     ;branch to position player correctly

MoveSmallPlatform:
      jsr MoveLiftPlatforms      ;execute common to all large and small lift platforms
      jmp ChkSmallPlatCollision  ;branch to position player correctly

MoveLiftPlatforms:
      lda TimerControl         ;if master timer control set, skip all of this
      bne ExLiftP              ;and branch to leave
      lda Enemy_YMF_Dummy,x
      clc                      ;add contents of movement amount to whatever's here
      adc Enemy_Y_MoveForce,x
      sta Enemy_YMF_Dummy,x
      lda Enemy_Y_Position,x   ;add whatever vertical speed is set to current
      adc Enemy_Y_Speed,x      ;vertical position plus carry to move up or down
      sta Enemy_Y_Position,x   ;and then leave
      rts

ChkSmallPlatCollision:
         lda PlatformCollisionFlag,x ;get bounding box counter saved in collision flag
         beq ExLiftP                 ;if none found, leave player position alone
         jsr PositionPlayerOnS_Plat  ;use to position player correctly
ExLiftP: rts                         ;then leave

;-------------------------------------------------------------------------------------
;$00 - page location of extended left boundary
;$01 - extended left boundary position
;$02 - page location of extended right boundary
;$03 - extended right boundary position

OffscreenBoundsCheck:
          lda Enemy_ID,x          ;check for cheep-cheep object
          cmp #FlyingCheepCheep   ;branch to leave if found
          beq ExScrnBd
          lda ScreenLeft_X_Pos    ;get horizontal coordinate for left side of screen
          ldy Enemy_ID,x
          cpy #HammerBro          ;check for hammer bro object
          beq LimitB
          cpy #PiranhaPlant       ;check for piranha plant object
          bne ExtendLB            ;these two will be erased sooner than others if too far left
LimitB:   adc #$38                ;add 56 pixels to coordinate if hammer bro or piranha plant
ExtendLB: sbc #$48                ;subtract 72 pixels regardless of enemy object
          sta $01                 ;store result here
          lda ScreenLeft_PageLoc
          sbc #$00                ;subtract borrow from page location of left side
          sta $00                 ;store result here
          lda ScreenRight_X_Pos   ;add 72 pixels to the right side horizontal coordinate
          adc #$48
          sta $03                 ;store result here
          lda ScreenRight_PageLoc
          adc #$00                ;then add the carry to the page location
          sta $02                 ;and store result here
          lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmp $01                 ;to modified horizontal left edge coordinate to get carry
          lda Enemy_PageLoc,x
          sbc $00                 ;then subtract it from the page coordinate of the enemy object
          bmi TooFar              ;if enemy object is too far left, branch to erase it
          lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmp $03                 ;to modified horizontal right edge coordinate to get carry
          lda Enemy_PageLoc,x
          sbc $02                 ;then subtract it from the page coordinate of the enemy object
          bmi ExScrnBd            ;if enemy object is on the screen, leave, do not erase enemy
          lda Enemy_State,x       ;if at this point, enemy is offscreen to the right, so check
          cmp #HammerBro          ;if in state used by spiny's egg, do not erase
          beq ExScrnBd
          cpy #PiranhaPlant       ;if piranha plant, do not erase
          beq ExScrnBd
          cpy #FlagpoleFlagObject ;if flagpole flag, do not erase
          beq ExScrnBd
          cpy #StarFlagObject     ;if star flag, do not erase
          beq ExScrnBd
          cpy #JumpspringObject   ;if jumpspring, do not erase
          beq ExScrnBd            ;erase all others too far to the right
TooFar:   jsr EraseEnemyObject    ;erase object if necessary
ExScrnBd: rts                     ;leave

;-------------------------------------------------------------------------------------

;some unused space
      .byte $ff, $ff, $ff

;-------------------------------------------------------------------------------------
;$01 - enemy buffer offset

FireballEnemyCollision:
      lda Fireball_State,x  ;check to see if fireball state is set at all
      beq ExitFBallEnemy    ;branch to leave if not
      asl
      bcs ExitFBallEnemy    ;branch to leave also if d7 in state is set
      lda FrameCounter
      lsr                   ;get LSB of frame counter
      bcs ExitFBallEnemy    ;branch to leave if set (do routine every other frame)
      txa
      asl                   ;multiply fireball offset by four
      asl
      clc
      adc #$1c              ;then add $1c or 28 bytes to it
      tay                   ;to use fireball's bounding box coordinates
      ldx #$04

FireballEnemyCDLoop:
           stx $01                     ;store enemy object offset here
           tya
           pha                         ;push fireball offset to the stack
           lda Enemy_State,x
           and #%00100000              ;check to see if d5 is set in enemy state
           bne NoFToECol               ;if so, skip to next enemy slot
           lda Enemy_Flag,x            ;check to see if buffer flag is set
           beq NoFToECol               ;if not, skip to next enemy slot
           lda Enemy_ID,x              ;check enemy identifier
           cmp #$24
           bcc GoombaDie               ;if < $24, branch to check further
           cmp #$2b
           bcc NoFToECol               ;if in range $24-$2a, skip to next enemy slot
GoombaDie: cmp #Goomba                 ;check for goomba identifier
           bne NotGoomba               ;if not found, continue with code
           lda Enemy_State,x           ;otherwise check for defeated state
           cmp #$02                    ;if stomped or otherwise defeated,
           bcs NoFToECol               ;skip to next enemy slot
NotGoomba: lda EnemyOffscrBitsMasked,x ;if any masked offscreen bits set,
           bne NoFToECol               ;skip to next enemy slot
           txa
           asl                         ;otherwise multiply enemy offset by four
           asl
           clc
           adc #$04                    ;add 4 bytes to it
           tax                         ;to use enemy's bounding box coordinates
           jsr SprObjectCollisionCore  ;do fireball-to-enemy collision detection
           ldx ObjectOffset            ;return fireball's original offset
           bcc NoFToECol               ;if carry clear, no collision, thus do next enemy slot
           lda #%10000000
           sta Fireball_State,x        ;set d7 in enemy state
           ldx $01                     ;get enemy offset
           jsr HandleEnemyFBallCol     ;jump to handle fireball to enemy collision
NoFToECol: pla                         ;pull fireball offset from stack
           tay                         ;put it in Y
           ldx $01                     ;get enemy object offset
           dex                         ;decrement it
           bpl FireballEnemyCDLoop     ;loop back until collision detection done on all enemies

ExitFBallEnemy:
      ldx ObjectOffset                 ;get original fireball offset and leave
      rts

BowserIdentities:
      .byte Goomba, GreenKoopa, BuzzyBeetle, Spiny, Lakitu, Bloober, HammerBro, Bowser

HandleEnemyFBallCol:
      jsr RelativeEnemyPosition  ;get relative coordinate of enemy
      ldx $01                    ;get current enemy object offset
      lda Enemy_Flag,x           ;check buffer flag for d7 set
      bpl ChkBuzzyBeetle         ;branch if not set to continue
      and #%00001111             ;otherwise mask out high nybble and
      tax                        ;use low nybble as enemy offset
      lda Enemy_ID,x
      cmp #Bowser                ;check enemy identifier for bowser
      beq HurtBowser             ;branch if found
      ldx $01                    ;otherwise retrieve current enemy offset

ChkBuzzyBeetle:
      lda Enemy_ID,x
      cmp #BuzzyBeetle           ;check for buzzy beetle
      beq ExHCF                  ;branch if found to leave (buzzy beetles fireproof)
      cmp #Bowser                ;check for bowser one more time (necessary if d7 of flag was clear)
      bne ChkOtherEnemies        ;if not found, branch to check other enemies

HurtBowser:
          dec BowserHitPoints        ;decrement bowser's hit points
          bne ExHCF                  ;if bowser still has hit points, branch to leave
          jsr InitVStf               ;otherwise do sub to init vertical speed and movement force
          sta Enemy_X_Speed,x        ;initialize horizontal speed
          sta EnemyFrenzyBuffer      ;init enemy frenzy buffer
          lda #$fe
          sta Enemy_Y_Speed,x        ;set vertical speed to make defeated bowser jump a little
          ldy WorldNumber            ;use world number as offset
          lda BowserIdentities,y     ;get enemy identifier to replace bowser with
          sta Enemy_ID,x             ;set as new enemy identifier
          lda #$20                   ;set A to use starting value for state
          cpy #$03                   ;check to see if using offset of 3 or more
          bcs SetDBSte               ;branch if so
          ora #$03                   ;otherwise add 3 to enemy state
SetDBSte: sta Enemy_State,x          ;set defeated enemy state
          lda #Sfx_BowserFall
          sta Square2SoundQueue      ;load bowser defeat sound
          ldx $01                    ;get enemy offset
          lda #$09                   ;award 5000 points to player for defeating bowser
          bne EnemySmackScore        ;unconditional branch to award points

ChkOtherEnemies:
      cmp #BulletBill_FrenzyVar
      beq ExHCF                 ;branch to leave if bullet bill (frenzy variant)
      cmp #Podoboo
      beq ExHCF                 ;branch to leave if podoboo
      cmp #$15
      bcs ExHCF                 ;branch to leave if identifier => $15

ShellOrBlockDefeat:
      lda Enemy_ID,x            ;check for piranha plant
      cmp #PiranhaPlant
      bne StnE                  ;branch if not found
      lda Enemy_Y_Position,x
      adc #$18                  ;add 24 pixels to enemy object's vertical position
      sta Enemy_Y_Position,x
StnE: jsr ChkToStunEnemies      ;do yet another sub
      lda Enemy_State,x
      and #%00011111            ;mask out 2 MSB of enemy object's state
      ora #%00100000            ;set d5 to defeat enemy and save as new state
      sta Enemy_State,x
      lda #$02                  ;award 200 points by default
      ldy Enemy_ID,x            ;check for hammer bro
      cpy #HammerBro
      bne GoombaPoints          ;branch if not found
      lda #$06                  ;award 1000 points for hammer bro

GoombaPoints:
      cpy #Goomba               ;check for goomba
      bne EnemySmackScore       ;branch if not found
      lda #$01                  ;award 100 points for goomba

EnemySmackScore:
       jsr SetupFloateyNumber   ;update necessary score variables
       lda #Sfx_EnemySmack      ;play smack enemy sound
       sta Square1SoundQueue
ExHCF: rts                      ;and now let's leave

;-------------------------------------------------------------------------------------

PlayerHammerCollision:
        lda FrameCounter          ;get frame counter
        lsr                       ;shift d0 into carry
        bcc ExPHC                 ;branch to leave if d0 not set to execute every other frame
        lda TimerControl          ;if either master timer control
        ora Misc_OffscreenBits    ;or any offscreen bits for hammer are set,
        bne ExPHC                 ;branch to leave
        txa
        asl                       ;multiply misc object offset by four
        asl
        clc
        adc #$24                  ;add 36 or $24 bytes to get proper offset
        tay                       ;for misc object bounding box coordinates
        jsr PlayerCollisionCore   ;do player-to-hammer collision detection
        ldx ObjectOffset          ;get misc object offset
        bcc ClHCol                ;if no collision, then branch
        lda Misc_Collision_Flag,x ;otherwise read collision flag
        bne ExPHC                 ;if collision flag already set, branch to leave
        lda #$01
        sta Misc_Collision_Flag,x ;otherwise set collision flag now
        lda Misc_X_Speed,x
        eor #$ff                  ;get two's compliment of
        clc                       ;hammer's horizontal speed
        adc #$01
        sta Misc_X_Speed,x        ;set to send hammer flying the opposite direction
        lda StarInvincibleTimer   ;if star mario invincibility timer set,
        bne ExPHC                 ;branch to leave
        jmp InjurePlayer          ;otherwise jump to hurt player, do not return
ClHCol: lda #$00                  ;clear collision flag
        sta Misc_Collision_Flag,x
ExPHC:  rts

;-------------------------------------------------------------------------------------

HandlePowerUpCollision:
      jsr EraseEnemyObject    ;erase the power-up object
      lda #$06
      jsr SetupFloateyNumber  ;award 1000 points to player by default
      lda #Sfx_PowerUpGrab
      sta Square2SoundQueue   ;play the power-up sound
      lda PowerUpType         ;check power-up type
      cmp #$02
      bcc Shroom_Flower_PUp   ;if mushroom or fire flower, branch
      cmp #$03
      beq SetFor1Up           ;if 1-up mushroom, branch
      lda #starman_time       ;otherwise set star mario invincibility
      sta StarInvincibleTimer ;timer, and load the star mario music
      lda #StarPowerMusic     ;into the area music queue, then leave
      sta AreaMusicQueue
      rts

Shroom_Flower_PUp:
      lda PlayerStatus    ;if player status = small, branch
      beq UpToSuper
      cmp #$01            ;if player status not super, leave
      bne NoPUp
      ldx ObjectOffset    ;get enemy offset, not necessary
      lda #$02            ;set player status to fiery
      sta PlayerStatus
      jsr GetPlayerColors ;run sub to change colors of player
      ldx ObjectOffset    ;get enemy offset again, and again not necessary
      lda #$0c            ;set value to be used by subroutine tree (fiery)
      jmp UpToFiery       ;jump to set values accordingly

SetFor1Up:
      lda #$0b                 ;change 1000 points into 1-up instead
      sta FloateyNum_Control,x ;and then leave
      rts

UpToSuper:
       lda #$01         ;set player status to super
       sta PlayerStatus
       lda #$09         ;set value to be used by subroutine tree (super)

UpToFiery:
       ldy #$00         ;set value to be used as new player state
       jsr SetPRout     ;set values to stop certain things in motion
NoPUp: rts

;--------------------------------

ResidualXSpdData:
      .byte $18, $e8

KickedShellXSpdData:
      .byte $30, $d0

DemotedKoopaXSpdData:
      .byte $08, $f8

PlayerEnemyCollision:
         lda FrameCounter            ;check counter for d0 set
         lsr
         bcs NoPUp                   ;if set, branch to leave
         jsr CheckPlayerVertical     ;if player object is completely offscreen or
         bcs NoPECol                 ;if down past 224th pixel row, branch to leave
         lda EnemyOffscrBitsMasked,x ;if current enemy is offscreen by any amount,
         bne NoPECol                 ;go ahead and branch to leave
         lda GameEngineSubroutine
         cmp #$08                    ;if not set to run player control routine
         bne NoPECol                 ;on next frame, branch to leave
         lda Enemy_State,x
         and #%00100000              ;if enemy state has d5 set, branch to leave
         bne NoPECol
         jsr GetEnemyBoundBoxOfs     ;get bounding box offset for current enemy object
         jsr PlayerCollisionCore     ;do collision detection on player vs. enemy
         ldx ObjectOffset            ;get enemy object buffer offset
         bcs CheckForPUpCollision    ;if collision, branch past this part here
         lda Enemy_CollisionBits,x
         and #%11111110              ;otherwise, clear d0 of current enemy object's
         sta Enemy_CollisionBits,x   ;collision bit
NoPECol: rts

CheckForPUpCollision:
       ldy Enemy_ID,x
       cpy #PowerUpObject            ;check for power-up object
       bne EColl                     ;if not found, branch to next part
       jmp HandlePowerUpCollision    ;otherwise, unconditional jump backwards
EColl: lda StarInvincibleTimer       ;if star mario invincibility timer expired,
       beq HandlePECollisions        ;perform task here, otherwise kill enemy like
       jmp ShellOrBlockDefeat        ;hit with a shell, or from beneath

KickedShellPtsData:
      .byte $0a, $06, $04

HandlePECollisions:
       lda Enemy_CollisionBits,x    ;check enemy collision bits for d0 set
       and #%00000001               ;or for being offscreen at all
       ora EnemyOffscrBitsMasked,x
       bne ExPEC                    ;branch to leave if either is true
       lda #$01
       ora Enemy_CollisionBits,x    ;otherwise set d0 now
       sta Enemy_CollisionBits,x
       cpy #Spiny                   ;branch if spiny
       beq ChkForPlayerInjury
       cpy #PiranhaPlant            ;branch if piranha plant
       beq InjurePlayer
       cpy #Podoboo                 ;branch if podoboo
       beq InjurePlayer
       cpy #BulletBill_CannonVar    ;branch if bullet bill
       beq ChkForPlayerInjury
       cpy #$15                     ;branch if object => $15
       bcs InjurePlayer
       lda AreaType                 ;branch if water type level
       beq InjurePlayer
       lda Enemy_State,x            ;branch if d7 of enemy state was set
       asl
       bcs ChkForPlayerInjury
       lda Enemy_State,x            ;mask out all but 3 LSB of enemy state
       and #%00000111
       cmp #$02                     ;branch if enemy is in normal or falling state
       bcc ChkForPlayerInjury
       lda Enemy_ID,x               ;branch to leave if goomba in defeated state
       cmp #Goomba
       beq ExPEC
       lda #Sfx_EnemySmack          ;play smack enemy sound
       sta Square1SoundQueue
       lda Enemy_State,x            ;set d7 in enemy state, thus become moving shell
       ora #%10000000
       sta Enemy_State,x
       jsr EnemyFacePlayer          ;set moving direction and get offset
       lda KickedShellXSpdData,y    ;load and set horizontal speed data with offset
       sta Enemy_X_Speed,x
       lda #$03                     ;add three to whatever the stomp counter contains
       clc                          ;to give points for kicking the shell
       adc StompChainCounter
       ldy EnemyIntervalTimer,x     ;check shell enemy's timer
       cpy #$03                     ;if above a certain point, branch using the points
       bcs KSPts                    ;data obtained from the stomp counter + 3
       lda KickedShellPtsData,y     ;otherwise, set points based on proximity to timer expiration
KSPts: jsr SetupFloateyNumber       ;set values for floatey number now
ExPEC: rts                          ;leave!!!

ChkForPlayerInjury:
          lda Player_Y_Speed     ;check player's vertical speed
          bmi ChkInj             ;perform procedure below if player moving upwards
          bne EnemyStomped       ;or not at all, and branch elsewhere if moving downwards
ChkInj:   lda Enemy_ID,x         ;branch if enemy object < $07
          cmp #Bloober
          bcc ChkETmrs
          lda Player_Y_Position  ;add 12 pixels to player's vertical position
          clc
          adc #$0c
          cmp Enemy_Y_Position,x ;compare modified player's position to enemy's position
          bcc EnemyStomped       ;branch if this player's position above (less than) enemy's
ChkETmrs: lda StompTimer         ;check stomp timer
          bne EnemyStomped       ;branch if set
          lda InjuryTimer        ;check to see if injured invincibility timer still
          bne ExInjColRoutines   ;counting down, and branch elsewhere to leave if so
          lda Player_Rel_XPos
          cmp Enemy_Rel_XPos     ;if player's relative position to the left of enemy's
          bcc TInjE              ;relative position, branch here
          jmp ChkEnemyFaceRight  ;otherwise do a jump here
TInjE:    lda Enemy_MovingDir,x  ;if enemy moving towards the left,
          cmp #$01               ;branch, otherwise do a jump here
          bne InjurePlayer       ;to turn the enemy around
          jmp LInj

InjurePlayer:
      lda InjuryTimer          ;check again to see if injured invincibility timer is
      bne ExInjColRoutines     ;at zero, and branch to leave if so

ForceInjury:
          ldx PlayerStatus          ;check player's status
          beq KillPlayer            ;branch if small
          sta PlayerStatus          ;otherwise set player's status to small
          lda #invincibility_time
          sta InjuryTimer           ;set injured invincibility timer
          asl
          sta Square1SoundQueue     ;play pipedown/injury sound
          jsr GetPlayerColors       ;change player's palette if necessary
          lda #$0a                  ;set subroutine to run on next frame
SetKRout: ldy #$01                  ;set new player state
SetPRout: sta GameEngineSubroutine  ;load new value to run subroutine on next frame
          sty Player_State          ;store new player state
          ldy #$ff
          sty TimerControl          ;set master timer control flag to halt timers
          iny
          sty ScrollAmount          ;initialize scroll speed

ExInjColRoutines:
      ldx ObjectOffset              ;get enemy offset and leave
      rts

KillPlayer:
      stx Player_X_Speed   ;halt player's horizontal movement by initializing speed
      inx
      stx EventMusicQueue  ;set event music queue to death music
      lda #-speed_at_death
      sta Player_Y_Speed   ;set new vertical speed
      lda #$0b             ;set subroutine to run on next frame
      bne SetKRout         ;branch to set player's state and other things

StompedEnemyPtsData:
      .byte $02, $06, $05, $06

EnemyStomped:
      lda Enemy_ID,x             ;check for spiny, branch to hurt player
      cmp #Spiny                 ;if found
      beq InjurePlayer
      lda #Sfx_EnemyStomp        ;otherwise play stomp/swim sound
      sta Square1SoundQueue
      lda Enemy_ID,x
      ldy #$00                   ;initialize points data offset for stomped enemies
      cmp #FlyingCheepCheep      ;branch for cheep-cheep
      beq EnemyStompedPts
      cmp #BulletBill_FrenzyVar  ;branch for either bullet bill object
      beq EnemyStompedPts
      cmp #BulletBill_CannonVar
      beq EnemyStompedPts
      cmp #Podoboo               ;branch for podoboo (this branch is logically impossible
      beq EnemyStompedPts        ;for cpu to take due to earlier checking of podoboo)
      iny                        ;increment points data offset
      cmp #HammerBro             ;branch for hammer bro
      beq EnemyStompedPts
      iny                        ;increment points data offset
      cmp #Lakitu                ;branch for lakitu
      beq EnemyStompedPts
      iny                        ;increment points data offset
      cmp #Bloober               ;branch if NOT bloober
      bne ChkForDemoteKoopa

EnemyStompedPts:
      lda StompedEnemyPtsData,y  ;load points data using offset in Y
      jsr SetupFloateyNumber     ;run sub to set floatey number controls
      lda Enemy_MovingDir,x
      pha                        ;save enemy movement direction to stack
      jsr SetStun                ;run sub to kill enemy
      pla
      sta Enemy_MovingDir,x      ;return enemy movement direction from stack
      lda #%00100000
      sta Enemy_State,x          ;set d5 in enemy state
      jsr InitVStf               ;nullify vertical speed, physics-related thing,
      sta Enemy_X_Speed,x        ;and horizontal speed
      lda #y_stomp               ;set player's vertical speed, to give bounce
      sta Player_Y_Speed
      rts

ChkForDemoteKoopa:
      cmp #$09                   ;branch elsewhere if enemy object < $09
      bcc HandleStompedShellE
      and #%00000001             ;demote koopa paratroopas to ordinary troopas
      sta Enemy_ID,x
      ldy #$00                   ;return enemy to normal state
      sty Enemy_State,x
      lda #$03                   ;award 400 points to the player
      jsr SetupFloateyNumber
      jsr InitVStf               ;nullify physics-related thing and vertical speed
      jsr EnemyFacePlayer        ;turn enemy around if necessary
      lda DemotedKoopaXSpdData,y
      sta Enemy_X_Speed,x        ;set appropriate moving speed based on direction
      jmp SBnce                  ;then move onto something else

RevivalRateData:
      .byte $10, $0b

HandleStompedShellE:
       lda #$04                   ;set defeated state for enemy
       sta Enemy_State,x
       inc StompChainCounter      ;increment the stomp counter
       lda StompChainCounter      ;add whatever is in the stomp counter
       clc                        ;to whatever is in the stomp timer
       adc StompTimer
       jsr SetupFloateyNumber     ;award points accordingly
       inc StompTimer             ;increment stomp timer of some sort
       ldy PrimaryHardMode        ;check primary hard mode flag
       lda RevivalRateData,y      ;load timer setting according to flag
       sta EnemyIntervalTimer,x   ;set as enemy timer to revive stomped enemy
SBnce: lda #y_bounce              ;set player's vertical speed for bounce
       sta Player_Y_Speed         ;and then leave!!!
       rts

ChkEnemyFaceRight:
       lda Enemy_MovingDir,x ;check to see if enemy is moving to the right
       cmp #$01
       bne LInj              ;if not, branch
       jmp InjurePlayer      ;otherwise go back to hurt player
LInj:  jsr EnemyTurnAround   ;turn the enemy around, if necessary
       jmp InjurePlayer      ;go back to hurt player


EnemyFacePlayer:
       ldy #$01               ;set to move right by default
       jsr PlayerEnemyDiff    ;get horizontal difference between player and enemy
       bpl SFcRt              ;if enemy is to the right of player, do not increment
       iny                    ;otherwise, increment to set to move to the left
SFcRt: sty Enemy_MovingDir,x  ;set moving direction here
       dey                    ;then decrement to use as a proper offset
       rts

SetupFloateyNumber:
       sta FloateyNum_Control,x ;set number of points control for floatey numbers
       lda #$30
       sta FloateyNum_Timer,x   ;set timer for floatey numbers
       lda Enemy_Y_Position,x
       sta FloateyNum_Y_Pos,x   ;set vertical coordinate
       lda Enemy_Rel_XPos
       sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
ExSFN: rts

;-------------------------------------------------------------------------------------
;$01 - used to hold enemy offset for second enemy

SetBitsMask:
      .byte %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010

ClearBitsMask:
      .byte %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101

EnemiesCollision:
        lda FrameCounter            ;check counter for d0 set
        lsr
        bcc ExSFN                   ;if d0 not set, leave
        lda AreaType
        beq ExSFN                   ;if water area type, leave
        lda Enemy_ID,x
        cmp #$15                    ;if enemy object => $15, branch to leave
        bcs ExitECRoutine
        cmp #Lakitu                 ;if lakitu, branch to leave
        beq ExitECRoutine
        cmp #PiranhaPlant           ;if piranha plant, branch to leave
        beq ExitECRoutine
        lda EnemyOffscrBitsMasked,x ;if masked offscreen bits nonzero, branch to leave
        bne ExitECRoutine
        jsr GetEnemyBoundBoxOfs     ;otherwise, do sub, get appropriate bounding box offset for
        dex                         ;first enemy we're going to compare, then decrement for second
        bmi ExitECRoutine           ;branch to leave if there are no other enemies
ECLoop: stx $01                     ;save enemy object buffer offset for second enemy here
        tya                         ;save first enemy's bounding box offset to stack
        pha
        lda Enemy_Flag,x            ;check enemy object enable flag
        beq ReadyNextEnemy          ;branch if flag not set
        lda Enemy_ID,x
        cmp #$15                    ;check for enemy object => $15
        bcs ReadyNextEnemy          ;branch if true
        cmp #Lakitu
        beq ReadyNextEnemy          ;branch if enemy object is lakitu
        cmp #PiranhaPlant
        beq ReadyNextEnemy          ;branch if enemy object is piranha plant
        lda EnemyOffscrBitsMasked,x
        bne ReadyNextEnemy          ;branch if masked offscreen bits set
        txa                         ;get second enemy object's bounding box offset
        asl                         ;multiply by four, then add four
        asl
        clc
        adc #$04
        tax                         ;use as new contents of X
        jsr SprObjectCollisionCore  ;do collision detection using the two enemies here
        ldx ObjectOffset            ;use first enemy offset for X
        ldy $01                     ;use second enemy offset for Y
        bcc NoEnemyCollision        ;if carry clear, no collision, branch ahead of this
        lda Enemy_State,x
        ora Enemy_State,y           ;check both enemy states for d7 set
        and #%10000000
        bne YesEC                   ;branch if at least one of them is set
        lda Enemy_CollisionBits,y   ;load first enemy's collision-related bits
        and SetBitsMask,x           ;check to see if bit connected to second enemy is
        bne ReadyNextEnemy          ;already set, and move onto next enemy slot if set
        lda Enemy_CollisionBits,y
        ora SetBitsMask,x           ;if the bit is not set, set it now
        sta Enemy_CollisionBits,y
YesEC:  jsr ProcEnemyCollisions     ;react according to the nature of collision
        jmp ReadyNextEnemy          ;move onto next enemy slot

NoEnemyCollision:
      lda Enemy_CollisionBits,y     ;load first enemy's collision-related bits
      and ClearBitsMask,x           ;clear bit connected to second enemy
      sta Enemy_CollisionBits,y     ;then move onto next enemy slot

ReadyNextEnemy:
      pla              ;get first enemy's bounding box offset from the stack
      tay              ;use as Y again
      ldx $01          ;get and decrement second enemy's object buffer offset
      dex
      bpl ECLoop       ;loop until all enemy slots have been checked

ExitECRoutine:
      ldx ObjectOffset ;get enemy object buffer offset
      rts              ;leave

ProcEnemyCollisions:
      lda Enemy_State,y        ;check both enemy states for d5 set
      ora Enemy_State,x
      and #%00100000           ;if d5 is set in either state, or both, branch
      bne ExitProcessEColl     ;to leave and do nothing else at this point
      lda Enemy_State,x
      cmp #$06                 ;if second enemy state < $06, branch elsewhere
      bcc ProcSecondEnemyColl
      lda Enemy_ID,x           ;check second enemy identifier for hammer bro
      cmp #HammerBro           ;if hammer bro found in alt state, branch to leave
      beq ExitProcessEColl
      lda Enemy_State,y        ;check first enemy state for d7 set
      asl
      bcc ShellCollisions      ;branch if d7 is clear
      lda #$06
      jsr SetupFloateyNumber   ;award 1000 points for killing enemy
      jsr ShellOrBlockDefeat   ;then kill enemy, then load
      ldy $01                  ;original offset of second enemy

ShellCollisions:
      tya                      ;move Y to X
      tax
      jsr ShellOrBlockDefeat   ;kill second enemy
      ldx ObjectOffset
      lda ShellChainCounter,x  ;get chain counter for shell
      clc
      adc #$04                 ;add four to get appropriate point offset
      ldx $01
      jsr SetupFloateyNumber   ;award appropriate number of points for second enemy
      ldx ObjectOffset         ;load original offset of first enemy
      inc ShellChainCounter,x  ;increment chain counter for additional enemies

ExitProcessEColl:
      rts                      ;leave!!!

ProcSecondEnemyColl:
      lda Enemy_State,y        ;if first enemy state < $06, branch elsewhere
      cmp #$06
      bcc MoveEOfs
      lda Enemy_ID,y           ;check first enemy identifier for hammer bro
      cmp #HammerBro           ;if hammer bro found in alt state, branch to leave
      beq ExitProcessEColl
      jsr ShellOrBlockDefeat   ;otherwise, kill first enemy
      ldy $01
      lda ShellChainCounter,y  ;get chain counter for shell
      clc
      adc #$04                 ;add four to get appropriate point offset
      ldx ObjectOffset
      jsr SetupFloateyNumber   ;award appropriate number of points for first enemy
      ldx $01                  ;load original offset of second enemy
      inc ShellChainCounter,x  ;increment chain counter for additional enemies
      rts                      ;leave!!!

MoveEOfs:
      tya                      ;move Y ($01) to X
      tax
      jsr EnemyTurnAround      ;do the sub here using value from $01
      ldx ObjectOffset         ;then do it again using value from $08

EnemyTurnAround:
       lda Enemy_ID,x           ;check for specific enemies
       cmp #PiranhaPlant
       beq ExTA                 ;if piranha plant, leave
       cmp #Lakitu
       beq ExTA                 ;if lakitu, leave
       cmp #HammerBro
       beq ExTA                 ;if hammer bro, leave
       cmp #Spiny
       beq RXSpd                ;if spiny, turn it around
       cmp #GreenParatroopaJump
       beq RXSpd                ;if green paratroopa, turn it around
       cmp #$07
       bcs ExTA                 ;if any OTHER enemy object => $07, leave
RXSpd: lda Enemy_X_Speed,x      ;load horizontal speed
       eor #$ff                 ;get two's compliment for horizontal speed
       tay
       iny
       sty Enemy_X_Speed,x      ;store as new horizontal speed
       lda Enemy_MovingDir,x
       eor #%00000011           ;invert moving direction and store, then leave
       sta Enemy_MovingDir,x    ;thus effectively turning the enemy around
ExTA:  rts                      ;leave!!!

;-------------------------------------------------------------------------------------
;$00 - vertical position of platform

LargePlatformCollision:
       lda #$ff                     ;save value here
       sta PlatformCollisionFlag,x
       lda TimerControl             ;check master timer control
       bne ExLPC                    ;if set, branch to leave
       lda Enemy_State,x            ;if d7 set in object state,
       bmi ExLPC                    ;branch to leave
       lda Enemy_ID,x
       cmp #$24                     ;check enemy object identifier for
       bne ChkForPlayerC_LargeP     ;balance platform, branch if not found
       lda Enemy_State,x
       tax                          ;set state as enemy offset here
       jsr ChkForPlayerC_LargeP     ;perform code with state offset, then original offset, in X

ChkForPlayerC_LargeP:
       jsr CheckPlayerVertical      ;figure out if player is below a certain point
       bcs ExLPC                    ;or offscreen, branch to leave if true
       txa
       jsr GetEnemyBoundBoxOfsArg   ;get bounding box offset in Y
       lda Enemy_Y_Position,x       ;store vertical coordinate in
       sta $00                      ;temp variable for now
       txa                          ;send offset we're on to the stack
       pha
       jsr PlayerCollisionCore      ;do player-to-platform collision detection
       pla                          ;retrieve offset from the stack
       tax
       bcc ExLPC                    ;if no collision, branch to leave
       jsr ProcLPlatCollisions      ;otherwise collision, perform sub
ExLPC: ldx ObjectOffset             ;get enemy object buffer offset and leave
       rts

;--------------------------------
;$00 - counter for bounding boxes

SmallPlatformCollision:
      lda TimerControl             ;if master timer control set,
      bne ExSPC                    ;branch to leave
      sta PlatformCollisionFlag,x  ;otherwise initialize collision flag
      jsr CheckPlayerVertical      ;do a sub to see if player is below a certain point
      bcs ExSPC                    ;or entirely offscreen, and branch to leave if true
      lda #$02
      sta $00                      ;load counter here for 2 bounding boxes

ChkSmallPlatLoop:
      ldx ObjectOffset           ;get enemy object offset
      jsr GetEnemyBoundBoxOfs    ;get bounding box offset in Y
      and #%00000010             ;if d1 of offscreen lower nybble bits was set
      bne ExSPC                  ;then branch to leave
      lda BoundingBox_UL_YPos,y  ;check top of platform's bounding box for being
      cmp #$20                   ;above a specific point
      bcc MoveBoundBox           ;if so, branch, don't do collision detection
      jsr PlayerCollisionCore    ;otherwise, perform player-to-platform collision detection
      bcs ProcSPlatCollisions    ;skip ahead if collision

MoveBoundBox:
       lda BoundingBox_UL_YPos,y  ;move bounding box vertical coordinates
       clc                        ;128 pixels downwards
       adc #$80
       sta BoundingBox_UL_YPos,y
       lda BoundingBox_DR_YPos,y
       clc
       adc #$80
       sta BoundingBox_DR_YPos,y
       dec $00                    ;decrement counter we set earlier
       bne ChkSmallPlatLoop       ;loop back until both bounding boxes are checked
ExSPC: ldx ObjectOffset           ;get enemy object buffer offset, then leave
       rts

;--------------------------------

ProcSPlatCollisions:
      ldx ObjectOffset             ;return enemy object buffer offset to X, then continue

ProcLPlatCollisions:
      lda BoundingBox_DR_YPos,y    ;get difference by subtracting the top
      sec                          ;of the player's bounding box from the bottom
      sbc BoundingBox_UL_YPos      ;of the platform's bounding box
      cmp #$04                     ;if difference too large or negative,
      bcs ChkForTopCollision       ;branch, do not alter vertical speed of player
      lda Player_Y_Speed           ;check to see if player's vertical speed is moving down
      bpl ChkForTopCollision       ;if so, don't mess with it
      lda #$01                     ;otherwise, set vertical
      sta Player_Y_Speed           ;speed of player to kill jump

ChkForTopCollision:
      lda BoundingBox_DR_YPos      ;get difference by subtracting the top
      sec                          ;of the platform's bounding box from the bottom
      sbc BoundingBox_UL_YPos,y    ;of the player's bounding box
      cmp #$06
      bcs PlatformSideCollisions   ;if difference not close enough, skip all of this
      lda Player_Y_Speed
      bmi PlatformSideCollisions   ;if player's vertical speed moving upwards, skip this
      lda $00                      ;get saved bounding box counter from earlier
      ldy Enemy_ID,x
      cpy #$2b                     ;if either of the two small platform objects are found,
      beq SetCollisionFlag         ;regardless of which one, branch to use bounding box counter
      cpy #$2c                     ;as contents of collision flag
      beq SetCollisionFlag
      txa                          ;otherwise use enemy object buffer offset

SetCollisionFlag:
      ldx ObjectOffset             ;get enemy object buffer offset
      sta PlatformCollisionFlag,x  ;save either bounding box counter or enemy offset here
      lda #$00
      sta Player_State             ;set player state to normal then leave
      rts

PlatformSideCollisions:
         lda #$01                   ;set value here to indicate possible horizontal
         sta $00                    ;collision on left side of platform
         lda BoundingBox_DR_XPos    ;get difference by subtracting platform's left edge
         sec                        ;from player's right edge
         sbc BoundingBox_UL_XPos,y
         cmp #$08                   ;if difference close enough, skip all of this
         bcc SideC
         inc $00                    ;otherwise increment value set here for right side collision
         lda BoundingBox_DR_XPos,y  ;get difference by subtracting player's left edge
         clc                        ;from platform's right edge
         sbc BoundingBox_UL_XPos
         cmp #$09                   ;if difference not close enough, skip subroutine
         bcs NoSideC                ;and instead branch to leave (no collision)
SideC:   jsr ImpedePlayerMove       ;deal with horizontal collision
NoSideC: ldx ObjectOffset           ;return with enemy object buffer offset
         rts

;-------------------------------------------------------------------------------------

PlayerPosSPlatData:
      .byte $80, $00

PositionPlayerOnS_Plat:
      tay                        ;use bounding box counter saved in collision flag
      lda Enemy_Y_Position,x     ;for offset
      clc                        ;add positioning data using offset to the vertical
      adc PlayerPosSPlatData-1,y ;coordinate
      .byte $2c                    ;BIT instruction opcode

PositionPlayerOnVPlat:
         lda Enemy_Y_Position,x    ;get vertical coordinate
         ldy GameEngineSubroutine
         cpy #$0b                  ;if certain routine being executed on this frame,
         beq ExPlPos               ;skip all of this
         ldy Enemy_Y_HighPos,x
         cpy #$01                  ;if vertical high byte offscreen, skip this
         bne ExPlPos
         sec                       ;subtract 32 pixels from vertical coordinate
         sbc #$20                  ;for the player object's height
         sta Player_Y_Position     ;save as player's new vertical coordinate
         tya
         sbc #$00                  ;subtract borrow and store as player's
         sta Player_Y_HighPos      ;new vertical high byte
         lda #$00
         sta Player_Y_Speed        ;initialize vertical speed and low byte of force
         sta Player_Y_MoveForce    ;and then leave
ExPlPos: rts

;-------------------------------------------------------------------------------------

CheckPlayerVertical:
       lda Player_OffscreenBits  ;if player object is completely offscreen
       cmp #$f0                  ;vertically, leave this routine
       bcs ExCPV
       ldy Player_Y_HighPos      ;if player high vertical byte is not
       dey                       ;within the screen, leave this routine
       bne ExCPV
       lda Player_Y_Position     ;if on the screen, check to see how far down
       cmp #$d0                  ;the player is vertically
ExCPV: rts

;-------------------------------------------------------------------------------------

GetEnemyBoundBoxOfs:
      lda ObjectOffset         ;get enemy object buffer offset

GetEnemyBoundBoxOfsArg:
      asl                      ;multiply A by four, then add four
      asl                      ;to skip player's bounding box
      clc
      adc #$04
      tay                      ;send to Y
      lda Enemy_OffscreenBits  ;get offscreen bits for enemy object
      and #%00001111           ;save low nybble
      cmp #%00001111           ;check for all bits set
      rts

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold many values, essentially temp variables
;$04 - holds lower nybble of vertical coordinate from block buffer routine
;Local_eb - used to hold block buffer adder

PlayerBGUpperExtent:
      .byte $20, $10

PlayerBGCollision:
          lda DisableCollisionDet   ;if collision detection disabled flag set,
          bne ExPBGCol              ;branch to leave
          lda GameEngineSubroutine
          cmp #$0b                  ;if running routine #11 or $0b
          beq ExPBGCol              ;branch to leave
          cmp #$04
          bcc ExPBGCol              ;if running routines $00-$03 branch to leave
          lda #$01                  ;load default player state for swimming
          ldy SwimmingFlag          ;if swimming flag set,
          bne SetPSte               ;branch ahead to set default state
          lda Player_State          ;if player in normal state,
          beq SetFallS              ;branch to set default state for falling
          cmp #$03
          bne ChkOnScr              ;if in any other state besides climbing, skip to next part
SetFallS: lda #$02                  ;load default player state for falling
SetPSte:  sta Player_State          ;set whatever player state is appropriate
ChkOnScr: lda Player_Y_HighPos
          cmp #$01                  ;check player's vertical high byte for still on the screen
          bne ExPBGCol              ;branch to leave if not
          lda #$ff
          sta Player_CollisionBits  ;initialize player's collision flag
          lda Player_Y_Position
          cmp #$cf                  ;check player's vertical coordinate
          bcc ChkCollSize           ;if not too close to the bottom of screen, continue
ExPBGCol: rts                       ;otherwise leave

ChkCollSize:
         ldy #$02                    ;load default offset
         lda CrouchingFlag
         bne GBBAdr                  ;if player crouching, skip ahead
         lda PlayerSize
         bne GBBAdr                  ;if player small, skip ahead
         dey                         ;otherwise decrement offset for big player not crouching
         lda SwimmingFlag
         bne GBBAdr                  ;if swimming flag set, skip ahead
         dey                         ;otherwise decrement offset
GBBAdr:  lda BlockBufferAdderData,y  ;get value using offset
         sta Local_eb                     ;store value here
         tay                         ;put value into Y, as offset for block buffer routine
         ldx PlayerSize              ;get player's size as offset
         lda CrouchingFlag
         beq HeadChk                 ;if player not crouching, branch ahead
         inx                         ;otherwise increment size as offset
HeadChk: lda Player_Y_Position       ;get player's vertical coordinate
         cmp PlayerBGUpperExtent,x   ;compare with upper extent value based on offset
         bcc DoFootCheck             ;if player is too high, skip this part
         jsr BlockBufferColli_Head   ;do player-to-bg collision detection on top of
         beq DoFootCheck             ;player, and branch if nothing above player's head
         jsr CheckForCoinMTiles      ;check to see if player touched coin with their head
         bcs AwardTouchedCoin        ;if so, branch to some other part of code
         ldy Player_Y_Speed          ;check player's vertical speed
         bpl DoFootCheck             ;if player not moving upwards, branch elsewhere
         ldy $04                     ;check lower nybble of vertical coordinate returned
         cpy #$04                    ;from collision detection routine
         bcc DoFootCheck             ;if low nybble < 4, branch
         jsr CheckForSolidMTiles     ;check to see what player's head bumped on
         bcs SolidOrClimb            ;if player collided with solid metatile, branch
         ldy AreaType                ;otherwise check area type
         beq NYSpd                   ;if water level, branch ahead
         ldy BlockBounceTimer        ;if block bounce timer not expired,
         bne NYSpd                   ;branch ahead, do not process collision
         jsr PlayerHeadCollision     ;otherwise do a sub to process collision
         jmp DoFootCheck             ;jump ahead to skip these other parts here

SolidOrClimb:
       cmp #$26               ;if climbing metatile,
       beq NYSpd              ;branch ahead and do not play sound
       lda #Sfx_Bump
       sta Square1SoundQueue  ;otherwise load bump sound
NYSpd: lda #$01               ;set player's vertical speed to nullify
       sta Player_Y_Speed     ;jump or swim

DoFootCheck:
      ldy Local_eb                    ;get block buffer adder offset
      lda Player_Y_Position
      cmp #$cf                   ;check to see how low player is
      bcs DoPlayerSideCheck      ;if player is too far down on screen, skip all of this
      jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom left of player
      jsr CheckForCoinMTiles     ;check to see if player touched coin with their left foot
      bcs AwardTouchedCoin       ;if so, branch to some other part of code
      pha                        ;save bottom left metatile to stack
      jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom right of player
      sta $00                    ;save bottom right metatile here
      pla
      sta $01                    ;pull bottom left metatile and save here
      bne ChkFootMTile           ;if anything here, skip this part
      lda $00                    ;otherwise check for anything in bottom right metatile
      beq DoPlayerSideCheck      ;and skip ahead if not
      jsr CheckForCoinMTiles     ;check to see if player touched coin with their right foot
      bcc ChkFootMTile           ;if not, skip unconditional jump and continue code

AwardTouchedCoin:
      jmp HandleCoinMetatile     ;follow the code to erase coin and award to player 1 coin

ChkFootMTile:
          jsr CheckForClimbMTiles    ;check to see if player landed on climbable metatiles
          bcs DoPlayerSideCheck      ;if so, branch
          ldy Player_Y_Speed         ;check player's vertical speed
          bmi DoPlayerSideCheck      ;if player moving upwards, branch
          cmp #$c5
          bne ContChk                ;if player did not touch axe, skip ahead
          jmp HandleAxeMetatile      ;otherwise jump to set modes of operation
ContChk:  jsr ChkInvisibleMTiles     ;do sub to check for hidden coin or 1-up blocks
          beq DoPlayerSideCheck      ;if either found, branch
          ldy JumpspringAnimCtrl     ;if jumpspring animating right now,
          bne InitSteP               ;branch ahead
          ldy $04                    ;check lower nybble of vertical coordinate returned
          cpy #$05                   ;from collision detection routine
          bcc LandPlyr               ;if lower nybble < 5, branch
          lda Player_MovingDir
          sta $00                    ;use player's moving direction as temp variable
          jmp ImpedePlayerMove       ;jump to impede player's movement in that direction
LandPlyr: jsr ChkForLandJumpSpring   ;do sub to check for jumpspring metatiles and deal with it
          lda #$f0
          and Player_Y_Position      ;mask out lower nybble of player's vertical position
          sta Player_Y_Position      ;and store as new vertical position to land player properly
          jsr HandlePipeEntry        ;do sub to process potential pipe entry
          lda #$00
          sta Player_Y_Speed         ;initialize vertical speed and fractional
          sta Player_Y_MoveForce     ;movement force to stop player's vertical movement
          sta StompChainCounter      ;initialize enemy stomp counter
InitSteP: lda #$00
          sta Player_State           ;set player's state to normal

DoPlayerSideCheck:
      ldy Local_eb       ;get block buffer adder offset
      iny
      iny           ;increment offset 2 bytes to use adders for side collisions
      lda #$02      ;set value here to be used as counter
      sta $00

SideCheckLoop:
       iny                       ;move onto the next one
       sty Local_eb                   ;store it
       lda Player_Y_Position
       cmp #$20                  ;check player's vertical position
       bcc BHalf                 ;if player is in status bar area, branch ahead to skip this part
       cmp #$e4
       bcs ExSCH                 ;branch to leave if player is too far down
       jsr BlockBufferColli_Side ;do player-to-bg collision detection on one half of player
       beq BHalf                 ;branch ahead if nothing found
       cmp #$1c                  ;otherwise check for pipe metatiles
       beq BHalf                 ;if collided with sideways pipe (top), branch ahead
       cmp #$6b
       beq BHalf                 ;if collided with water pipe (top), branch ahead
       jsr CheckForClimbMTiles   ;do sub to see if player bumped into anything climbable
       bcc CheckSideMTiles       ;if not, branch to alternate section of code
BHalf: ldy Local_eb                   ;load block adder offset
       iny                       ;increment it
       lda Player_Y_Position     ;get player's vertical position
       cmp #$08
       bcc ExSCH                 ;if too high, branch to leave
       cmp #$d0
       bcs ExSCH                 ;if too low, branch to leave
       jsr BlockBufferColli_Side ;do player-to-bg collision detection on other half of player
       bne CheckSideMTiles       ;if something found, branch
       dec $00                   ;otherwise decrement counter
       bne SideCheckLoop         ;run code until both sides of player are checked
ExSCH: rts                       ;leave

CheckSideMTiles:
          jsr ChkInvisibleMTiles     ;check for hidden or coin 1-up blocks
          beq ExCSM                  ;branch to leave if either found
          jsr CheckForClimbMTiles    ;check for climbable metatiles
          bcc ContSChk               ;if not found, skip and continue with code
          jmp HandleClimbing         ;otherwise jump to handle climbing
ContSChk: jsr CheckForCoinMTiles     ;check to see if player touched coin
          bcs HandleCoinMetatile     ;if so, execute code to erase coin and award to player 1 coin
          jsr ChkJumpspringMetatiles ;check for jumpspring metatiles
          bcc ChkPBtm                ;if not found, branch ahead to continue cude
          lda JumpspringAnimCtrl     ;otherwise check jumpspring animation control
          bne ExCSM                  ;branch to leave if set
          jmp StopPlayerMove         ;otherwise jump to impede player's movement
ChkPBtm:  ldy Player_State           ;get player's state
          cpy #$00                   ;check for player's state set to normal
          bne StopPlayerMove         ;if not, branch to impede player's movement
          ldy PlayerFacingDir        ;get player's facing direction
          dey
          bne StopPlayerMove         ;if facing left, branch to impede movement
          cmp #$6c                   ;otherwise check for pipe metatiles
          beq PipeDwnS               ;if collided with sideways pipe (bottom), branch
          cmp #$1f                   ;if collided with water pipe (bottom), continue
          bne StopPlayerMove         ;otherwise branch to impede player's movement
PipeDwnS: lda Player_SprAttrib       ;check player's attributes
          bne PlyrPipe               ;if already set, branch, do not play sound again
          ldy #Sfx_PipeDown_Injury
          sty Square1SoundQueue      ;otherwise load pipedown/injury sound
PlyrPipe: ora #%00100000
          sta Player_SprAttrib       ;set background priority bit in player attributes
          lda Player_X_Position
          and #%00001111             ;get lower nybble of player's horizontal coordinate
          beq ChkGERtn               ;if at zero, branch ahead to skip this part
          ldy #$00                   ;set default offset for timer setting data
          lda ScreenLeft_PageLoc     ;load page location for left side of screen
          beq SetCATmr               ;if at page zero, use default offset
          iny                        ;otherwise increment offset
SetCATmr: lda AreaChangeTimerData,y  ;set timer for change of area as appropriate
          sta ChangeAreaTimer
ChkGERtn: lda GameEngineSubroutine   ;get number of game engine routine running
          cmp #$07
          beq ExCSM                  ;if running player entrance routine or
          cmp #$08                   ;player control routine, go ahead and branch to leave
          bne ExCSM
          lda #$02
          sta GameEngineSubroutine   ;otherwise set sideways pipe entry routine to run
          rts                        ;and leave

;--------------------------------
;$02 - high nybble of vertical coordinate from block buffer
;$04 - low nybble of horizontal coordinate from block buffer
;$06-$07 - block buffer address

StopPlayerMove:
       jsr ImpedePlayerMove      ;stop player's movement
ExCSM: rts                       ;leave

AreaChangeTimerData:
      .byte $a0, $34

HandleCoinMetatile:
      jsr ErACM             ;do sub to erase coin metatile from block buffer
      inc CoinTallyFor1Ups  ;increment coin tally used for 1-up blocks
      jmp GiveOneCoin       ;update coin amount and tally on the screen

HandleAxeMetatile:
       lda #$00
       sta OperMode_Task   ;reset secondary mode
       lda #$02
       sta OperMode        ;set primary mode to autoctrl mode
       lda #$18
       sta Player_X_Speed  ;set horizontal speed and continue to erase axe metatile
ErACM: ldy $02             ;load vertical high nybble offset for block buffer
       lda #$00            ;load blank metatile
       sta ($06),y         ;store to remove old contents from block buffer
       jmp RemoveCoin_Axe  ;update the screen accordingly

;--------------------------------
;$02 - high nybble of vertical coordinate from block buffer
;$04 - low nybble of horizontal coordinate from block buffer
;$06-$07 - block buffer address

ClimbXPosAdder:
      .byte $f9, $07

ClimbPLocAdder:
      .byte $ff, $00

FlagpoleYPosData:
      .byte $18, $22, $50, $68, $90

HandleClimbing:
      ldy $04            ;check low nybble of horizontal coordinate returned from
      cpy #$06           ;collision detection routine against certain values, this
      bcc ExHC           ;makes actual physical part of vine or flagpole thinner
      cpy #$0a           ;than 16 pixels
      bcc ChkForFlagpole
ExHC: rts                ;leave if too far left or too far right

ChkForFlagpole:
      cmp #$24               ;check climbing metatiles
      beq FlagpoleCollision  ;branch if flagpole ball found
      cmp #$25
      bne VineCollision      ;branch to alternate code if flagpole shaft not found

FlagpoleCollision:
      lda GameEngineSubroutine
      cmp #$05                  ;check for end-of-level routine running
      beq PutPlayerOnVine       ;if running, branch to end of climbing code
      lda #$01
      sta PlayerFacingDir       ;set player's facing direction to right
      inc ScrollLock            ;set scroll lock flag
      lda GameEngineSubroutine
      cmp #$04                  ;check for flagpole slide routine running
      beq RunFR                 ;if running, branch to end of flagpole code here
      lda #BulletBill_CannonVar ;load identifier for bullet bills (cannon variant)
      jsr KillEnemies           ;get rid of them
      lda #Silence
      sta EventMusicQueue       ;silence music
      lsr
      sta FlagpoleSoundQueue    ;load flagpole sound into flagpole sound queue
      ldx #$04                  ;start at end of vertical coordinate data
      lda Player_Y_Position
      sta FlagpoleCollisionYPos ;store player's vertical coordinate here to be used later

ChkFlagpoleYPosLoop:
       cmp FlagpoleYPosData,x    ;compare with current vertical coordinate data
       bcs MtchF                 ;if player's => current, branch to use current offset
       dex                       ;otherwise decrement offset to use
       bne ChkFlagpoleYPosLoop   ;do this until all data is checked (use last one if all checked)
MtchF: stx FlagpoleScore         ;store offset here to be used later
RunFR: lda #$04
       sta GameEngineSubroutine  ;set value to run flagpole slide routine
       jmp PutPlayerOnVine       ;jump to end of climbing code

VineCollision:
      cmp #$26                  ;check for climbing metatile used on vines
      bne PutPlayerOnVine
      lda Player_Y_Position     ;check player's vertical coordinate
      cmp #$20                  ;for being in status bar area
      bcs PutPlayerOnVine       ;branch if not that far up
      lda #$01
      sta GameEngineSubroutine  ;otherwise set to run autoclimb routine next frame

PutPlayerOnVine:
         lda #$03                ;set player state to climbing
         sta Player_State
         lda #$00                ;nullify player's horizontal speed
         sta Player_X_Speed      ;and fractional horizontal movement force
         sta Player_X_MoveForce
         lda Player_X_Position   ;get player's horizontal coordinate
         sec
         sbc ScreenLeft_X_Pos    ;subtract from left side horizontal coordinate
         cmp #$10
         bcs SetVXPl             ;if 16 or more pixels difference, do not alter facing direction
         lda #$02
         sta PlayerFacingDir     ;otherwise force player to face left
SetVXPl: ldy PlayerFacingDir     ;get current facing direction, use as offset
         lda $06                 ;get low byte of block buffer address
         asl
         asl                     ;move low nybble to high
         asl
         asl
         clc
         adc ClimbXPosAdder-1,y  ;add pixels depending on facing direction
         sta Player_X_Position   ;store as player's horizontal coordinate
         lda $06                 ;get low byte of block buffer address again
         bne ExPVne              ;if not zero, branch
         lda ScreenRight_PageLoc ;load page location of right side of screen
         clc
         adc ClimbPLocAdder-1,y  ;add depending on facing location
         sta Player_PageLoc      ;store as player's page location
ExPVne:  rts                     ;finally, we're done!

;--------------------------------

ChkInvisibleMTiles:
         cmp #$5f       ;check for hidden coin block
         beq ExCInvT    ;branch to leave if found
         cmp #$60       ;check for hidden 1-up block
ExCInvT: rts            ;leave with zero flag set if either found

;--------------------------------
;$00-$01 - used to hold bottom right and bottom left metatiles (in that order)
;$00 - used as flag by ImpedePlayerMove to restrict specific movement

ChkForLandJumpSpring:
        jsr ChkJumpspringMetatiles  ;do sub to check if player landed on jumpspring
        bcc ExCJSp                  ;if carry not set, jumpspring not found, therefore leave
        lda #$70
        sta VerticalForce           ;otherwise set vertical movement force for player
        lda #springboard_riding
        sta JumpspringForce         ;set default jumpspring force
        lda #$03
        sta JumpspringTimer         ;set jumpspring timer to be used later
        lsr
        sta JumpspringAnimCtrl      ;set jumpspring animation control to start animating
ExCJSp: rts                         ;and leave

ChkJumpspringMetatiles:
         cmp #$67      ;check for top jumpspring metatile
         beq JSFnd     ;branch to set carry if found
         cmp #$68      ;check for bottom jumpspring metatile
         clc           ;clear carry flag
         bne NoJSFnd   ;branch to use cleared carry if not found
JSFnd:   sec           ;set carry if found
NoJSFnd: rts           ;leave

ImpedePlayerMove:
       lda #$00                  ;initialize value here
       ldy Player_X_Speed        ;get player's horizontal speed
       ldx $00                   ;check value set earlier for
       dex                       ;left side collision
       bne RImpd                 ;if right side collision, skip this part
       inx                       ;return value to X
       cpy #$00                  ;if player moving to the left,
       bmi ExIPM                 ;branch to invert bit and leave
       lda #$ff                  ;otherwise load A with value to be used later
       jmp NXSpd                 ;and jump to affect movement
RImpd: ldx #$02                  ;return $02 to X
       cpy #$01                  ;if player moving to the right,
       bpl ExIPM                 ;branch to invert bit and leave
       lda #$01                  ;otherwise load A with value to be used here
NXSpd: ldy #$10
       sty SideCollisionTimer    ;set timer of some sort
       ldy #$00
       sty Player_X_Speed        ;nullify player's horizontal speed
       cmp #$00                  ;if value set in A not set to $ff,
       bpl PlatF                 ;branch ahead, do not decrement Y
       dey                       ;otherwise decrement Y now
PlatF: sty $00                   ;store Y as high bits of horizontal adder
       clc
       adc Player_X_Position     ;add contents of A to player's horizontal
       sta Player_X_Position     ;position to move player left or right
       lda Player_PageLoc
       adc $00                   ;add high bits and carry to
       sta Player_PageLoc        ;page location if necessary
ExIPM: txa                       ;invert contents of X
       eor #$ff
       and Player_CollisionBits  ;mask out bit that was set here
       sta Player_CollisionBits  ;store to clear bit
       rts

;--------------------------------

SolidMTileUpperExt:
      .byte $10, $61, $88, $c4

CheckForSolidMTiles:
      jsr GetMTileAttrib        ;find appropriate offset based on metatile's 2 MSB
      cmp SolidMTileUpperExt,x  ;compare current metatile with solid metatiles
      rts

ClimbMTileUpperExt:
      .byte $24, $6d, $8a, $c6

CheckForClimbMTiles:
      jsr GetMTileAttrib        ;find appropriate offset based on metatile's 2 MSB
      cmp ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
      rts

CheckForCoinMTiles:
         cmp #$c2              ;check for regular coin
         beq CoinSd            ;branch if found
         cmp #$c3              ;check for underwater coin
         beq CoinSd            ;branch if found
         clc                   ;otherwise clear carry and leave
         rts
CoinSd:  lda #Sfx_CoinGrab
         sta Square2SoundQueue ;load coin grab sound and leave
         rts

GetMTileAttrib:
       tay            ;save metatile value into Y
       and #%11000000 ;mask out all but 2 MSB
       asl
       rol            ;shift and rotate d7-d6 to d1-d0
       rol
       tax            ;use as offset for metatile data
       tya            ;get original metatile value back
ExEBG: rts            ;leave

;-------------------------------------------------------------------------------------
;$06-$07 - address from block buffer routine

EnemyBGCStateData:
      .byte $01, $01, $02, $02, $02, $05

EnemyBGCXSpdData:
      .byte $10, $f0

EnemyToBGCollisionDet:
      lda Enemy_State,x        ;check enemy state for d6 set
      and #%00100000
      bne ExEBG                ;if set, branch to leave
      jsr SubtEnemyYPos        ;otherwise, do a subroutine here
      bcc ExEBG                ;if enemy vertical coord + 62 < 68, branch to leave
      ldy Enemy_ID,x
      cpy #Spiny               ;if enemy object is not spiny, branch elsewhere
      bne DoIDCheckBGColl
      lda Enemy_Y_Position,x
      cmp #$25                 ;if enemy vertical coordinate < 36 branch to leave
      bcc ExEBG

DoIDCheckBGColl:
       cpy #GreenParatroopaJump ;check for some other enemy object
       bne HBChk                ;branch if not found
       jmp EnemyJump            ;otherwise jump elsewhere
HBChk: cpy #HammerBro           ;check for hammer bro
       bne CInvu                ;branch if not found
       jmp HammerBroBGColl      ;otherwise jump elsewhere
CInvu: cpy #Spiny               ;if enemy object is spiny, branch
       beq YesIn
       cpy #PowerUpObject       ;if special power-up object, branch
       beq YesIn
       cpy #$07                 ;if enemy object =>$07, branch to leave
       bcs ExEBGChk
YesIn: jsr ChkUnderEnemy        ;if enemy object < $07, or = $12 or $2e, do this sub
       bne HandleEToBGCollision ;if block underneath enemy, branch

NoEToBGCollision:
       jmp ChkForRedKoopa       ;otherwise skip and do something else

;--------------------------------
;$02 - vertical coordinate from block buffer routine

HandleEToBGCollision:
      jsr ChkForNonSolids       ;if something is underneath enemy, find out what
      beq NoEToBGCollision      ;if blank $26, coins, or hidden blocks, jump, enemy falls through
      cmp #$23
      bne LandEnemyProperly     ;check for blank metatile $23 and branch if not found
      ldy $02                   ;get vertical coordinate used to find block
      lda #$00                  ;store default blank metatile in that spot so we won't
      sta ($06),y               ;trigger this routine accidentally again
      lda Enemy_ID,x
      cmp #$15                  ;if enemy object => $15, branch ahead
      bcs ChkToStunEnemies
      cmp #Goomba               ;if enemy object not goomba, branch ahead of this routine
      bne GiveOEPoints
      jsr KillEnemyAboveBlock   ;if enemy object IS goomba, do this sub

GiveOEPoints:
      lda #$01                  ;award 100 points for hitting block beneath enemy
      jsr SetupFloateyNumber

ChkToStunEnemies:
          cmp #$09                   ;perform many comparisons on enemy object identifier
          bcc SetStun
          cmp #$11                   ;if the enemy object identifier is equal to the values
          bcs SetStun                ;$09, $0e, $0f or $10, it will be modified, and not
          cmp #$0a                   ;modified if not any of those values, note that piranha plant will
          bcc Demote                 ;always fail this test because A will still have vertical
          cmp #PiranhaPlant          ;coordinate from previous addition, also these comparisons
          bcc SetStun                ;are only necessary if branching from $d7a1
Demote:   and #%00000001             ;erase all but LSB, essentially turning enemy object
          sta Enemy_ID,x             ;into green or red koopa troopa to demote them
SetStun:  lda Enemy_State,x          ;load enemy state
          and #%11110000             ;save high nybble
          ora #%00000010
          sta Enemy_State,x          ;set d1 of enemy state
          dec Enemy_Y_Position,x
          dec Enemy_Y_Position,x     ;subtract two pixels from enemy's vertical position
          lda Enemy_ID,x
          cmp #Bloober               ;check for bloober object
          beq SetWYSpd
          lda #$fd                   ;set default vertical speed
          ldy AreaType
          bne SetNotW                ;if area type not water, set as speed, otherwise
SetWYSpd: lda #$ff                   ;change the vertical speed
SetNotW:  sta Enemy_Y_Speed,x        ;set vertical speed now
          ldy #$01
          jsr PlayerEnemyDiff        ;get horizontal difference between player and enemy object
          bpl ChkBBill               ;branch if enemy is to the right of player
          iny                        ;increment Y if not
ChkBBill: lda Enemy_ID,x
          cmp #BulletBill_CannonVar  ;check for bullet bill (cannon variant)
          beq NoCDirF
          cmp #BulletBill_FrenzyVar  ;check for bullet bill (frenzy variant)
          beq NoCDirF                ;branch if either found, direction does not change
          sty Enemy_MovingDir,x      ;store as moving direction
NoCDirF:  dey                        ;decrement and use as offset
          lda EnemyBGCXSpdData,y     ;get proper horizontal speed
          sta Enemy_X_Speed,x        ;and store, then leave
ExEBGChk: rts

;--------------------------------
;$04 - low nybble of vertical coordinate from block buffer routine

LandEnemyProperly:
       lda $04                 ;check lower nybble of vertical coordinate saved earlier
       sec
       sbc #$08                ;subtract eight pixels
       cmp #$05                ;used to determine whether enemy landed from falling
       bcs ChkForRedKoopa      ;branch if lower nybble in range of $0d-$0f before subtract
       lda Enemy_State,x
       and #%01000000          ;branch if d6 in enemy state is set
       bne LandEnemyInitState
       lda Enemy_State,x
       asl                     ;branch if d7 in enemy state is not set
       bcc ChkLandedEnemyState
SChkA: jmp DoEnemySideCheck    ;if lower nybble < $0d, d7 set but d6 not set, jump here

ChkLandedEnemyState:
           lda Enemy_State,x         ;if enemy in normal state, branch back to jump here
           beq SChkA
           cmp #$05                  ;if in state used by spiny's egg
           beq ProcEnemyDirection    ;then branch elsewhere
           cmp #$03                  ;if already in state used by koopas and buzzy beetles
           bcs ExSteChk              ;or in higher numbered state, branch to leave
           lda Enemy_State,x         ;load enemy state again (why?)
           cmp #$02                  ;if not in $02 state (used by koopas and buzzy beetles)
           bne ProcEnemyDirection    ;then branch elsewhere
           lda #$10                  ;load default timer here
           ldy Enemy_ID,x            ;check enemy identifier for spiny
           cpy #Spiny
           bne SetForStn             ;branch if not found
           lda #$00                  ;set timer for $00 if spiny
SetForStn: sta EnemyIntervalTimer,x  ;set timer here
           lda #$03                  ;set state here, apparently used to render
           sta Enemy_State,x         ;upside-down koopas and buzzy beetles
           jsr EnemyLanding          ;then land it properly
ExSteChk:  rts                       ;then leave

ProcEnemyDirection:
         lda Enemy_ID,x            ;check enemy identifier for goomba
         cmp #Goomba               ;branch if found
         beq LandEnemyInitState
         cmp #Spiny                ;check for spiny
         bne InvtD                 ;branch if not found
         lda #$01
         sta Enemy_MovingDir,x     ;send enemy moving to the right by default
         lda #$08
         sta Enemy_X_Speed,x       ;set horizontal speed accordingly
         lda FrameCounter
         and #%00000111            ;if timed appropriately, spiny will skip over
         beq LandEnemyInitState    ;trying to face the player
InvtD:   ldy #$01                  ;load 1 for enemy to face the left (inverted here)
         jsr PlayerEnemyDiff       ;get horizontal difference between player and enemy
         bpl CNwCDir               ;if enemy to the right of player, branch
         iny                       ;if to the left, increment by one for enemy to face right (inverted)
CNwCDir: tya
         cmp Enemy_MovingDir,x     ;compare direction in A with current direction in memory
         bne LandEnemyInitState
         jsr ChkForBump_HammerBroJ ;if equal, not facing in correct dir, do sub to turn around

LandEnemyInitState:
      jsr EnemyLanding       ;land enemy properly
      lda Enemy_State,x
      and #%10000000         ;if d7 of enemy state is set, branch
      bne NMovShellFallBit
      lda #$00               ;otherwise initialize enemy state and leave
      sta Enemy_State,x      ;note this will also turn spiny's egg into spiny
      rts

NMovShellFallBit:
      lda Enemy_State,x   ;nullify d6 of enemy state, save other bits
      and #%10111111      ;and store, then leave
      sta Enemy_State,x
      rts

;--------------------------------

ChkForRedKoopa:
             lda Enemy_ID,x            ;check for red koopa troopa $03
             cmp #RedKoopa
             bne Chk2MSBSt             ;branch if not found
             lda Enemy_State,x
             beq ChkForBump_HammerBroJ ;if enemy found and in normal state, branch
Chk2MSBSt:   lda Enemy_State,x         ;save enemy state into Y
             tay
             asl                       ;check for d7 set
             bcc GetSteFromD           ;branch if not set
             lda Enemy_State,x
             ora #%01000000            ;set d6
             jmp SetD6Ste              ;jump ahead of this part
GetSteFromD: lda EnemyBGCStateData,y   ;load new enemy state with old as offset
SetD6Ste:    sta Enemy_State,x         ;set as new state

;--------------------------------
;$00 - used to store bitmask (not used but initialized here)
;Local_eb - used in DoEnemySideCheck as counter and to compare moving directions

DoEnemySideCheck:
          lda Enemy_Y_Position,x     ;if enemy within status bar, branch to leave
          cmp #$20                   ;because there's nothing there that impedes movement
          bcc ExESdeC
          ldy #$16                   ;start by finding block to the left of enemy ($00,$14)
          lda #$02                   ;set value here in what is also used as
          sta Local_eb                    ;OAM data offset
SdeCLoop: lda Local_eb                    ;check value
          cmp Enemy_MovingDir,x      ;compare value against moving direction
          bne NextSdeC               ;branch if different and do not seek block there
          lda #$01                   ;set flag in A for save horizontal coordinate
          jsr BlockBufferChk_Enemy   ;find block to left or right of enemy object
          beq NextSdeC               ;if nothing found, branch
          jsr ChkForNonSolids        ;check for non-solid blocks
          bne ChkForBump_HammerBroJ  ;branch if not found
NextSdeC: dec Local_eb                    ;move to the next direction
          iny
          cpy #$18                   ;increment Y, loop only if Y < $18, thus we check
          bcc SdeCLoop               ;enemy ($00, $14) and ($10, $14) pixel coordinates
ExESdeC:  rts

ChkForBump_HammerBroJ:
        cpx #$05               ;check if we're on the special use slot
        beq NoBump             ;and if so, branch ahead and do not play sound
        lda Enemy_State,x      ;if enemy state d7 not set, branch
        asl                    ;ahead and do not play sound
        bcc NoBump
        lda #Sfx_Bump          ;otherwise, play bump sound
        sta Square1SoundQueue  ;sound will never be played if branching from ChkForRedKoopa
NoBump: lda Enemy_ID,x         ;check for hammer bro
        cmp #$05
        bne InvEnemyDir        ;branch if not found
        lda #$00
        sta $00                ;initialize value here for bitmask
        ldy #$fa               ;load default vertical speed for jumping
        jmp SetHJ              ;jump to code that makes hammer bro jump

InvEnemyDir:
      jmp RXSpd     ;jump to turn the enemy around

;--------------------------------
;$00 - used to hold horizontal difference between player and enemy

PlayerEnemyDiff:
      lda Enemy_X_Position,x  ;get distance between enemy object's
      sec                     ;horizontal coordinate and the player's
      sbc Player_X_Position   ;horizontal coordinate
      sta $00                 ;and store here
      lda Enemy_PageLoc,x
      sbc Player_PageLoc      ;subtract borrow, then leave
      rts

;--------------------------------

EnemyLanding:
      jsr InitVStf            ;do something here to vertical speed and something else
      lda Enemy_Y_Position,x
      and #%11110000          ;save high nybble of vertical coordinate, and
      ora #%00001000          ;set d3, then store, probably used to set enemy object
      sta Enemy_Y_Position,x  ;neatly on whatever it's landing on
      rts

SubtEnemyYPos:
      lda Enemy_Y_Position,x  ;add 62 pixels to enemy object's
      clc                     ;vertical coordinate
      adc #$3e
      cmp #$44                ;compare against a certain range
      rts                     ;and leave with flags set for conditional branch

EnemyJump:
        jsr SubtEnemyYPos     ;do a sub here
        bcc DoSide            ;if enemy vertical coord + 62 < 68, branch to leave
        lda Enemy_Y_Speed,x
        clc                   ;add two to vertical speed
        adc #$02
        cmp #$03              ;if green paratroopa not falling, branch ahead
        bcc DoSide
        jsr ChkUnderEnemy     ;otherwise, check to see if green paratroopa is
        beq DoSide            ;standing on anything, then branch to same place if not
        jsr ChkForNonSolids   ;check for non-solid blocks
        beq DoSide            ;branch if found
        jsr EnemyLanding      ;change vertical coordinate and speed
        lda #$fd
        sta Enemy_Y_Speed,x   ;make the paratroopa jump again
DoSide: jmp DoEnemySideCheck  ;check for horizontal blockage, then leave

;--------------------------------

HammerBroBGColl:
      jsr ChkUnderEnemy    ;check to see if hammer bro is standing on anything
      beq NoUnderHammerBro
      cmp #$23             ;check for blank metatile $23 and branch if not found
      bne UnderHammerBro

KillEnemyAboveBlock:
      jsr ShellOrBlockDefeat  ;do this sub to kill enemy
      lda #$fc                ;alter vertical speed of enemy and leave
      sta Enemy_Y_Speed,x
      rts

UnderHammerBro:
      lda EnemyFrameTimer,x ;check timer used by hammer bro
      bne NoUnderHammerBro  ;branch if not expired
      lda Enemy_State,x
      and #%10001000        ;save d7 and d3 from enemy state, nullify other bits
      sta Enemy_State,x     ;and store
      jsr EnemyLanding      ;modify vertical coordinate, speed and something else
      jmp DoEnemySideCheck  ;then check for horizontal blockage and leave

NoUnderHammerBro:
      lda Enemy_State,x  ;if hammer bro is not standing on anything, set d0
      ora #$01           ;in the enemy state to indicate jumping or falling, then leave
      sta Enemy_State,x
      rts

ChkUnderEnemy:
      lda #$00                  ;set flag in A for save vertical coordinate
      ldy #$15                  ;set Y to check the bottom middle (8,18) of enemy object
      jmp BlockBufferChk_Enemy  ;hop to it!

ChkForNonSolids:
       cmp #$26       ;blank metatile used for vines?
       beq NSFnd
       cmp #$c2       ;regular coin?
       beq NSFnd
       cmp #$c3       ;underwater coin?
       beq NSFnd
       cmp #$5f       ;hidden coin block?
       beq NSFnd
       cmp #$60       ;hidden 1-up block?
NSFnd: rts

;-------------------------------------------------------------------------------------

FireballBGCollision:
      lda Fireball_Y_Position,x   ;check fireball's vertical coordinate
      cmp #$18
      bcc ClearBounceFlag         ;if within the status bar area of the screen, branch ahead
      jsr BlockBufferChk_FBall    ;do fireball to background collision detection on bottom of it
      beq ClearBounceFlag         ;if nothing underneath fireball, branch
      jsr ChkForNonSolids         ;check for non-solid metatiles
      beq ClearBounceFlag         ;branch if any found
      lda Fireball_Y_Speed,x      ;if fireball's vertical speed set to move upwards,
      bmi InitFireballExplode     ;branch to set exploding bit in fireball's state
      lda FireballBouncingFlag,x  ;if bouncing flag already set,
      bne InitFireballExplode     ;branch to set exploding bit in fireball's state
      lda #fb_bounce
      sta Fireball_Y_Speed,x      ;otherwise set vertical speed to move upwards (give it bounce)
      lda #$01
      sta FireballBouncingFlag,x  ;set bouncing flag
      lda Fireball_Y_Position,x
      and #$f8                    ;modify vertical coordinate to land it properly
      sta Fireball_Y_Position,x   ;store as new vertical coordinate
      rts                         ;leave

ClearBounceFlag:
      lda #$00
      sta FireballBouncingFlag,x  ;clear bouncing flag by default
      rts                         ;leave

InitFireballExplode:
      lda #$80
      sta Fireball_State,x        ;set exploding flag in fireball's state
      lda #Sfx_Bump
      sta Square1SoundQueue       ;load bump sound
      rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used to hold one of bitmasks, or offset
;$01 - used for relative X coordinate, also used to store middle screen page location
;$02 - used for relative Y coordinate, also used to store middle screen coordinate

;this data added to relative coordinates of sprite objects
;stored in order: left edge, top edge, right edge, bottom edge
BoundBoxCtrlData:
      .byte $02, $08, $0e, $20
      .byte $03, $14, $0d, $20
      .byte $02, $14, $0e, $20
      .byte $02, $09, $0e, $15
      .byte $00, $00, $18, $06
      .byte $00, $00, $20, $0d
      .byte $00, $00, $30, $0d
      .byte $00, $00, $08, $08
      .byte $06, $04, $0a, $08
      .byte $03, $0e, $0d, $14
      .byte $00, $02, $10, $15
      .byte $04, $04, $0c, $1c

GetFireballBoundBox:
      txa         ;add seven bytes to offset
      clc         ;to use in routines as offset for fireball
      adc #$07
      tax
      ldy #$02    ;set offset for relative coordinates
      bne FBallB  ;unconditional branch

GetMiscBoundBox:
        txa                       ;add nine bytes to offset
        clc                       ;to use in routines as offset for misc object
        adc #$09
        tax
        ldy #$06                  ;set offset for relative coordinates
FBallB: jsr BoundingBoxCore       ;get bounding box coordinates
        jmp CheckRightScreenBBox  ;jump to handle any offscreen coordinates

GetEnemyBoundBox:
      ldy #$48                 ;store bitmask here for now
      sty $00
      ldy #$44                 ;store another bitmask here for now and jump
      jmp GetMaskedOffScrBits

SmallPlatformBoundBox:
      ldy #$08                 ;store bitmask here for now
      sty $00
      ldy #$04                 ;store another bitmask here for now

GetMaskedOffScrBits:
        lda Enemy_X_Position,x      ;get enemy object position relative
        sec                         ;to the left side of the screen
        sbc ScreenLeft_X_Pos
        sta $01                     ;store here
        lda Enemy_PageLoc,x         ;subtract borrow from current page location
        sbc ScreenLeft_PageLoc      ;of left side
        bmi CMBits                  ;if enemy object is beyond left edge, branch
        ora $01
        beq CMBits                  ;if precisely at the left edge, branch
        ldy $00                     ;if to the right of left edge, use value in $00 for A
CMBits: tya                         ;otherwise use contents of Y
        and Enemy_OffscreenBits     ;preserve bitwise whatever's in here
        sta EnemyOffscrBitsMasked,x ;save masked offscreen bits here
        bne MoveBoundBoxOffscreen   ;if anything set here, branch
        jmp SetupEOffsetFBBox       ;otherwise, do something else

LargePlatformBoundBox:
      inx                        ;increment X to get the proper offset
      jsr GetXOffscreenBits      ;then jump directly to the sub for horizontal offscreen bits
      dex                        ;decrement to return to original offset
      cmp #$fe                   ;if completely offscreen, branch to put entire bounding
      bcs MoveBoundBoxOffscreen  ;box offscreen, otherwise start getting coordinates

SetupEOffsetFBBox:
      txa                        ;add 1 to offset to properly address
      clc                        ;the enemy object memory locations
      adc #$01
      tax
      ldy #$01                   ;load 1 as offset here, same reason
      jsr BoundingBoxCore        ;do a sub to get the coordinates of the bounding box
      jmp CheckRightScreenBBox   ;jump to handle offscreen coordinates of bounding box

MoveBoundBoxOffscreen:
      txa                            ;multiply offset by 4
      asl
      asl
      tay                            ;use as offset here
      lda #$ff
      sta EnemyBoundingBoxCoord,y    ;load value into four locations here and leave
      sta EnemyBoundingBoxCoord+1,y
      sta EnemyBoundingBoxCoord+2,y
      sta EnemyBoundingBoxCoord+3,y
      rts

BoundingBoxCore:
      stx $00                     ;save offset here
      lda SprObject_Rel_YPos,y    ;store object coordinates relative to screen
      sta $02                     ;vertically and horizontally, respectively
      lda SprObject_Rel_XPos,y
      sta $01
      txa                         ;multiply offset by four and save to stack
      asl
      asl
      pha
      tay                         ;use as offset for Y, X is left alone
      lda SprObj_BoundBoxCtrl,x   ;load value here to be used as offset for X
      asl                         ;multiply that by four and use as X
      asl
      tax
      lda $01                     ;add the first number in the bounding box data to the
      clc                         ;relative horizontal coordinate using enemy object offset
      adc BoundBoxCtrlData,x      ;and store somewhere using same offset * 4
      sta BoundingBox_UL_Corner,y ;store here
      lda $01
      clc
      adc BoundBoxCtrlData+2,x    ;add the third number in the bounding box data to the
      sta BoundingBox_LR_Corner,y ;relative horizontal coordinate and store
      inx                         ;increment both offsets
      iny
      lda $02                     ;add the second number to the relative vertical coordinate
      clc                         ;using incremented offset and store using the other
      adc BoundBoxCtrlData,x      ;incremented offset
      sta BoundingBox_UL_Corner,y
      lda $02
      clc
      adc BoundBoxCtrlData+2,x    ;add the fourth number to the relative vertical coordinate
      sta BoundingBox_LR_Corner,y ;and store
      pla                         ;get original offset loaded into $00 * y from stack
      tay                         ;use as Y
      ldx $00                     ;get original offset and use as X again
      rts

CheckRightScreenBBox:
       lda ScreenLeft_X_Pos       ;add 128 pixels to left side of screen
       clc                        ;and store as horizontal coordinate of middle
       adc #$80
       sta $02
       lda ScreenLeft_PageLoc     ;add carry to page location of left side of screen
       adc #$00                   ;and store as page location of middle
       sta $01
       lda SprObject_X_Position,x ;get horizontal coordinate
       cmp $02                    ;compare against middle horizontal coordinate
       lda SprObject_PageLoc,x    ;get page location
       sbc $01                    ;subtract from middle page location
       bcc CheckLeftScreenBBox    ;if object is on the left side of the screen, branch
       lda BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
       bmi NoOfs                  ;coordinates, branch if still on the screen
       lda #$ff                   ;load offscreen value here to use on one or both horizontal sides
       ldx BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
       bmi SORte                  ;coordinates, and branch if still on the screen
       sta BoundingBox_UL_XPos,y  ;store offscreen value for left side
SORte: sta BoundingBox_DR_XPos,y  ;store offscreen value for right side
NoOfs: ldx ObjectOffset           ;get object offset and leave
       rts

CheckLeftScreenBBox:
        lda BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
        bpl NoOfs2                 ;coordinates, and branch if still on the screen
        cmp #$a0                   ;check to see if left-side edge is in the middle of the
        bcc NoOfs2                 ;screen or really offscreen, and branch if still on
        lda #$00
        ldx BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
        bpl SOLft                  ;coordinates, branch if still onscreen
        sta BoundingBox_DR_XPos,y  ;store offscreen value for right side
SOLft:  sta BoundingBox_UL_XPos,y  ;store offscreen value for left side
NoOfs2: ldx ObjectOffset           ;get object offset and leave
        rts

;-------------------------------------------------------------------------------------
;$06 - second object's offset
;$07 - counter

PlayerCollisionCore:
      ldx #$00     ;initialize X to use player's bounding box for comparison

SprObjectCollisionCore:
      sty $06      ;save contents of Y here
      lda #$01
      sta $07      ;save value 1 here as counter, compare horizontal coordinates first

CollisionCoreLoop:
      lda BoundingBox_UL_Corner,y  ;compare left/top coordinates
      cmp BoundingBox_UL_Corner,x  ;of first and second objects' bounding boxes
      bcs FirstBoxGreater          ;if first left/top => second, branch
      cmp BoundingBox_LR_Corner,x  ;otherwise compare to right/bottom of second
      bcc SecondBoxVerticalChk     ;if first left/top < second right/bottom, branch elsewhere
      beq CollisionFound           ;if somehow equal, collision, thus branch
      lda BoundingBox_LR_Corner,y  ;if somehow greater, check to see if bottom of
      cmp BoundingBox_UL_Corner,y  ;first object's bounding box is greater than its top
      bcc CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      cmp BoundingBox_UL_Corner,x  ;otherwise compare bottom of first bounding box to the top
      bcs CollisionFound           ;of second box, and if equal or greater, collision, thus branch
      ldy $06                      ;otherwise return with carry clear and Y = $0006
      rts                          ;note horizontal wrapping never occurs

SecondBoxVerticalChk:
      lda BoundingBox_LR_Corner,x  ;check to see if the vertical bottom of the box
      cmp BoundingBox_UL_Corner,x  ;is greater than the vertical top
      bcc CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      lda BoundingBox_LR_Corner,y  ;otherwise compare horizontal right or vertical bottom
      cmp BoundingBox_UL_Corner,x  ;of first box with horizontal left or vertical top of second box
      bcs CollisionFound           ;if equal or greater, collision, thus branch
      ldy $06                      ;otherwise return with carry clear and Y = $0006
      rts

FirstBoxGreater:
      cmp BoundingBox_UL_Corner,x  ;compare first and second box horizontal left/vertical top again
      beq CollisionFound           ;if first coordinate = second, collision, thus branch
      cmp BoundingBox_LR_Corner,x  ;if not, compare with second object right or bottom edge
      bcc CollisionFound           ;if left/top of first less than or equal to right/bottom of second
      beq CollisionFound           ;then collision, thus branch
      cmp BoundingBox_LR_Corner,y  ;otherwise check to see if top of first box is greater than bottom
      bcc NoCollisionFound         ;if less than or equal, no collision, branch to end
      beq NoCollisionFound
      lda BoundingBox_LR_Corner,y  ;otherwise compare bottom of first to top of second
      cmp BoundingBox_UL_Corner,x  ;if bottom of first is greater than top of second, vertical wrap
      bcs CollisionFound           ;collision, and branch, otherwise, proceed onwards here

NoCollisionFound:
      clc          ;clear carry, then load value set earlier, then leave
      ldy $06      ;like previous ones, if horizontal coordinates do not collide, we do
      rts          ;not bother checking vertical ones, because what's the point?

CollisionFound:
      inx                    ;increment offsets on both objects to check
      iny                    ;the vertical coordinates
      dec $07                ;decrement counter to reflect this
      bpl CollisionCoreLoop  ;if counter not expired, branch to loop
      sec                    ;otherwise we already did both sets, therefore collision, so set carry
      ldy $06                ;load original value set here earlier, then leave
      rts

;-------------------------------------------------------------------------------------
;$02 - modified y coordinate
;$03 - stores metatile involved in block buffer collisions
;$04 - comes in with offset to block buffer adder data, goes out with low nybble x/y coordinate
;$05 - modified x coordinate
;$06-$07 - block buffer address

BlockBufferChk_Enemy:
      pha        ;save contents of A to stack
      txa
      clc        ;add 1 to X to run sub with enemy offset in mind
      adc #$01
      tax
      pla        ;pull A from stack and jump elsewhere
      jmp BBChk_E

ResidualMiscObjectCode:
      txa
      clc           ;supposedly used once to set offset for
      adc #$0d      ;miscellaneous objects
      tax
      ldy #$1b      ;supposedly used once to set offset for block buffer data
      jmp ResJmpM   ;probably used in early stages to do misc to bg collision detection

BlockBufferChk_FBall:
         ldy #$1a                  ;set offset for block buffer adder data
         txa
         clc
         adc #$07                  ;add seven bytes to use
         tax
ResJmpM: lda #$00                  ;set A to return vertical coordinate
BBChk_E: jsr BlockBufferCollision  ;do collision detection subroutine for sprite object
         ldx ObjectOffset          ;get object offset
         cmp #$00                  ;check to see if object bumped into anything
         rts

BlockBufferAdderData:
      .byte $00, $07, $0e

BlockBuffer_X_Adder:
      .byte $08, $03, $0c, $02, $02, $0d, $0d, $08
      .byte $03, $0c, $02, $02, $0d, $0d, $08, $03
      .byte $0c, $02, $02, $0d, $0d, $08, $00, $10
      .byte $04, $14, $04, $04

BlockBuffer_Y_Adder:
      .byte $04, $20, $20, $08, $18, $08, $18, $02
      .byte $20, $20, $08, $18, $08, $18, $12, $20
      .byte $20, $18, $18, $18, $18, $18, $14, $14
      .byte $06, $06, $08, $10

BlockBufferColli_Feet:
       iny            ;if branched here, increment to next set of adders

BlockBufferColli_Head:
       lda #$00       ;set flag to return vertical coordinate
       .byte $2c        ;BIT instruction opcode

BlockBufferColli_Side:
       lda #$01       ;set flag to return horizontal coordinate
       ldx #$00       ;set offset for player object

BlockBufferCollision:
       pha                         ;save contents of A to stack
       sty $04                     ;save contents of Y here
       lda BlockBuffer_X_Adder,y   ;add horizontal coordinate
       clc                         ;of object to value obtained using Y as offset
       adc SprObject_X_Position,x
       sta $05                     ;store here
       lda SprObject_PageLoc,x
       adc #$00                    ;add carry to page location
       and #$01                    ;get LSB, mask out all other bits
       lsr                         ;move to carry
       ora $05                     ;get stored value
       ror                         ;rotate carry to MSB of A
       lsr                         ;and effectively move high nybble to
       lsr                         ;lower, LSB which became MSB will be
       lsr                         ;d4 at this point
       jsr GetBlockBufferAddr      ;get address of block buffer into $06, $07
       ldy $04                     ;get old contents of Y
       lda SprObject_Y_Position,x  ;get vertical coordinate of object
       clc
       adc BlockBuffer_Y_Adder,y   ;add it to value obtained using Y as offset
       and #%11110000              ;mask out low nybble
       sec
       sbc #$20                    ;subtract 32 pixels for the status bar
       sta $02                     ;store result here
       tay                         ;use as offset for block buffer
       lda ($06),y                 ;check current content of block buffer
       sta $03                     ;and store here
       ldy $04                     ;get old contents of Y again
       pla                         ;pull A from stack
       bne RetXC                   ;if A = 1, branch
       lda SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
       jmp RetYC                   ;and jump
RetXC: lda SprObject_X_Position,x  ;otherwise load horizontal coordinate
RetYC: and #%00001111              ;and mask out high nybble
       sta $04                     ;store masked out result here
       lda $03                     ;get saved content of block buffer
       rts                         ;and leave

;-------------------------------------------------------------------------------------

;unused byte
      .byte $ff

;-------------------------------------------------------------------------------------
;$00 - offset to vine Y coordinate adder
;$02 - offset to sprite data

VineYPosAdder:
      .byte $00, $30

DrawVine:
         sty $00                    ;save offset here
         lda Enemy_Rel_YPos         ;get relative vertical coordinate
         clc
         adc VineYPosAdder,y        ;add value using offset in Y to get value
         ldx VineObjOffset,y        ;get offset to vine
         ldy Enemy_SprDataOffset,x  ;get sprite data offset
         sty $02                    ;store sprite data offset here
         jsr SixSpriteStacker       ;stack six sprites on top of each other vertically
         lda Enemy_Rel_XPos         ;get relative horizontal coordinate
         sta Sprite_X_Position,y    ;store in first, third and fifth sprites
         sta Sprite_X_Position+8,y
         sta Sprite_X_Position+16,y
         clc
         adc #$06                   ;add six pixels to second, fourth and sixth sprites
         sta Sprite_X_Position+4,y  ;to give characteristic staggered vine shape to
         sta Sprite_X_Position+12,y ;our vertical stack of sprites
         sta Sprite_X_Position+20,y
         lda #%00100001             ;set bg priority and palette attribute bits
         sta Sprite_Attributes,y    ;set in first, third and fifth sprites
         sta Sprite_Attributes+8,y
         sta Sprite_Attributes+16,y
         ora #%01000000             ;additionally, set horizontal flip bit
         sta Sprite_Attributes+4,y  ;for second, fourth and sixth sprites
         sta Sprite_Attributes+12,y
         sta Sprite_Attributes+20,y
         ldx #$05                   ;set tiles for six sprites
VineTL:  lda #$7b                   ;set tile number for sprite
         sta Sprite_Tilenumber,y
         iny                        ;move offset to next sprite data
         iny
         iny
         iny
         dex                        ;move onto next sprite
         bpl VineTL                 ;loop until all sprites are done
         ldy $02                    ;get original offset
         lda $00                    ;get offset to vine adding data
         bne SkpVTop                ;if offset not zero, skip this part
         lda #$7a
         sta Sprite_Tilenumber,y    ;set other tile number for top of vine
SkpVTop: ldx #$00                   ;start with the first sprite again
ChkFTop: lda VineStart_Y_Position   ;get original starting vertical coordinate
         sec
         sbc Sprite_Y_Position,y    ;subtract top-most sprite's Y coordinate
         cmp #$64                   ;if two coordinates are less than 100/$64 pixels
         bcc NextVSp                ;apart, skip this to leave sprite alone
         lda #$f8
         sta Sprite_Y_Position,y    ;otherwise move sprite offscreen
NextVSp: iny                        ;move offset to next OAM data
         iny
         iny
         iny
         inx                        ;move onto next sprite
         cpx #$06                   ;do this until all sprites are checked
         bne ChkFTop
         ldy $00                    ;return offset set earlier
         rts

SixSpriteStacker:
       ldx #$06           ;do six sprites
StkLp: sta Sprite_Data,y  ;store X or Y coordinate into OAM data
       clc
       adc #$08           ;add eight pixels
       iny
       iny                ;move offset four bytes forward
       iny
       iny
       dex                ;do another sprite
       bne StkLp          ;do this until all sprites are done
       ldy $02            ;get saved OAM data offset and leave
       rts

;-------------------------------------------------------------------------------------

FirstSprXPos:
      .byte $04, $00, $04, $00

FirstSprYPos:
      .byte $00, $04, $00, $04

SecondSprXPos:
      .byte $00, $08, $00, $08

SecondSprYPos:
      .byte $08, $00, $08, $00

FirstSprTilenum:
      .byte $c8, $ca, $c9, $cb

SecondSprTilenum:
      .byte $c9, $cb, $c8, $ca

HammerSprAttrib:
      .byte $03, $03, $c3, $c3

DrawHammer:
            ldy Misc_SprDataOffset,x    ;get misc object OAM data offset
            lda TimerControl
            bne ForceHPose              ;if master timer control set, skip this part
            lda Misc_State,x            ;otherwise get hammer's state
            and #%01111111              ;mask out d7
            cmp #$01                    ;check to see if set to 1 yet
            beq GetHPose                ;if so, branch
ForceHPose: ldx #$00                    ;reset offset here
            beq RenderH                 ;do unconditional branch to rendering part
GetHPose:   lda FrameCounter            ;get frame counter
            lsr                         ;move d3-d2 to d1-d0
            lsr
            and #%00000011              ;mask out all but d1-d0 (changes every four frames)
            tax                         ;use as timing offset
RenderH:    lda Misc_Rel_YPos           ;get relative vertical coordinate
            clc
            adc FirstSprYPos,x          ;add first sprite vertical adder based on offset
            sta Sprite_Y_Position,y     ;store as sprite Y coordinate for first sprite
            clc
            adc SecondSprYPos,x         ;add second sprite vertical adder based on offset
            sta Sprite_Y_Position+4,y   ;store as sprite Y coordinate for second sprite
            lda Misc_Rel_XPos           ;get relative horizontal coordinate
            clc
            adc FirstSprXPos,x          ;add first sprite horizontal adder based on offset
            sta Sprite_X_Position,y     ;store as sprite X coordinate for first sprite
            clc
            adc SecondSprXPos,x         ;add second sprite horizontal adder based on offset
            sta Sprite_X_Position+4,y   ;store as sprite X coordinate for second sprite
            lda FirstSprTilenum,x
            sta Sprite_Tilenumber,y     ;get and store tile number of first sprite
            lda SecondSprTilenum,x
            sta Sprite_Tilenumber+4,y   ;get and store tile number of second sprite
            lda HammerSprAttrib,x
            sta Sprite_Attributes,y     ;get and store attribute bytes for both
            sta Sprite_Attributes+4,y   ;note in this case they use the same data
            ldx ObjectOffset            ;get misc object offset
            lda Misc_OffscreenBits
            and #%11111100              ;check offscreen bits
            beq NoHOffscr               ;if all bits clear, leave object alone
            lda #$00
            sta Misc_State,x            ;otherwise nullify misc object state
            lda #$f8
            jsr DumpTwoSpr              ;do sub to move hammer sprites offscreen
NoHOffscr:  rts                         ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tile numbers ($01 addressed in draw floatey number part)
;$02 - used to hold Y coordinate for floatey number
;$03 - residual byte used for flip (but value set here affects nothing)
;$04 - attribute byte for floatey number
;$05 - used as X coordinate for floatey number
FlagpoleScoreNumTiles:
      .byte $74, $70
      .byte $72, $70
      .byte $75, $76
      .byte $73, $76
      .byte $71, $76

FlagpoleGfxHandler:
      ldy Enemy_SprDataOffset,x      ;get sprite data offset for flagpole flag
      lda Enemy_Rel_XPos             ;get relative horizontal coordinate
      sta Sprite_X_Position,y        ;store as X coordinate for first sprite
      clc
      adc #$08                       ;add eight pixels and store
      sta Sprite_X_Position+4,y      ;as X coordinate for second and third sprites
      sta Sprite_X_Position+8,y
      clc
      adc #$0c                       ;add twelve more pixels and
      sta $05                        ;store here to be used later by floatey number
      lda Enemy_Y_Position,x         ;get vertical coordinate
      jsr DumpTwoSpr                 ;and do sub to dump into first and second sprites
      adc #$08                       ;add eight pixels
      sta Sprite_Y_Position+8,y      ;and store into third sprite
      lda FlagpoleFNum_Y_Pos         ;get vertical coordinate for floatey number
      sta $02                        ;store it here
      lda #$01
      sta $03                        ;set value for flip which will not be used, and
      sta $04                        ;attribute byte for floatey number
      sta Sprite_Attributes,y        ;set attribute bytes for all three sprites
      sta Sprite_Attributes+4,y
      sta Sprite_Attributes+8,y
      lda #$d8
      sta Sprite_Tilenumber,y        ;put triangle shaped tile
      sta Sprite_Tilenumber+8,y      ;into first and third sprites
      lda #$d9
      sta Sprite_Tilenumber+4,y      ;put skull tile into second sprite
      lda FlagpoleCollisionYPos      ;get vertical coordinate at time of collision
      beq ChkFlagOffscreen           ;if zero, branch ahead
      tya
      clc                            ;add 12 bytes to sprite data offset
      adc #$0c
      tay                            ;put back in Y
      lda FlagpoleScore              ;get offset used to award points for touching flagpole
      asl                            ;multiply by 2 to get proper offset here
      tax
      lda FlagpoleScoreNumTiles,x    ;get appropriate tile data
      sta $00
      lda FlagpoleScoreNumTiles+1,x
      jsr DrawOneSpriteRow           ;use it to render floatey number

ChkFlagOffscreen:
      ldx ObjectOffset               ;get object offset for flag
      ldy Enemy_SprDataOffset,x      ;get OAM data offset
      lda Enemy_OffscreenBits        ;get offscreen bits
      and #%00001110                 ;mask out all but d3-d1
      beq ExitDumpSpr                ;if none of these bits set, branch to leave

;-------------------------------------------------------------------------------------

MoveSixSpritesOffscreen:
      lda #$f8                  ;set offscreen coordinate if jumping here

DumpSixSpr:
      sta Sprite_Data+20,y      ;dump A contents
      sta Sprite_Data+16,y      ;into third row sprites

DumpFourSpr:
      sta Sprite_Data+12,y      ;into second row sprites

DumpThreeSpr:
      sta Sprite_Data+8,y

DumpTwoSpr:
      sta Sprite_Data+4,y       ;and into first row sprites
      sta Sprite_Data,y

ExitDumpSpr:
      rts

;-------------------------------------------------------------------------------------

DrawLargePlatform:
      ldy Enemy_SprDataOffset,x   ;get OAM data offset
      sty $02                     ;store here
      iny                         ;add 3 to it for offset
      iny                         ;to X coordinate
      iny
      lda Enemy_Rel_XPos          ;get horizontal relative coordinate
      jsr SixSpriteStacker        ;store X coordinates using A as base, stack horizontally
      ldx ObjectOffset
      lda Enemy_Y_Position,x      ;get vertical coordinate
      jsr DumpFourSpr             ;dump into first four sprites as Y coordinate
      ldy AreaType
      cpy #$03                    ;check for castle-type level
      beq ShrinkPlatform
      ldy SecondaryHardMode       ;check for secondary hard mode flag set
      beq SetLast2Platform        ;branch if not set elsewhere

ShrinkPlatform:
      lda #$f8                    ;load offscreen coordinate if flag set or castle-type level

SetLast2Platform:
      ldy Enemy_SprDataOffset,x   ;get OAM data offset
      sta Sprite_Y_Position+16,y  ;store vertical coordinate or offscreen
      sta Sprite_Y_Position+20,y  ;coordinate into last two sprites as Y coordinate
      lda #$bc                    ;load default tile for platform (girder)
      ldx CloudTypeOverride
      beq SetPlatformTilenum      ;if cloud level override flag not set, use
      lda #$fe                    ;otherwise load other tile for platform (puff)

SetPlatformTilenum:
        ldx ObjectOffset            ;get enemy object buffer offset
        iny                         ;increment Y for tile offset
        jsr DumpSixSpr              ;dump tile number into all six sprites
        lda #$02                    ;set palette controls
        iny                         ;increment Y for sprite attributes
        jsr DumpSixSpr              ;dump attributes into all six sprites
        inx                         ;increment X for enemy objects
        jsr GetXOffscreenBits       ;get offscreen bits again
        dex
        ldy Enemy_SprDataOffset,x   ;get OAM data offset
        asl                         ;rotate d7 into carry, save remaining
        pha                         ;bits to the stack
        bcc SChk2
        lda #$f8                    ;if d7 was set, move first sprite offscreen
        sta Sprite_Y_Position,y
SChk2:  pla                         ;get bits from stack
        asl                         ;rotate d6 into carry
        pha                         ;save to stack
        bcc SChk3
        lda #$f8                    ;if d6 was set, move second sprite offscreen
        sta Sprite_Y_Position+4,y
SChk3:  pla                         ;get bits from stack
        asl                         ;rotate d5 into carry
        pha                         ;save to stack
        bcc SChk4
        lda #$f8                    ;if d5 was set, move third sprite offscreen
        sta Sprite_Y_Position+8,y
SChk4:  pla                         ;get bits from stack
        asl                         ;rotate d4 into carry
        pha                         ;save to stack
        bcc SChk5
        lda #$f8                    ;if d4 was set, move fourth sprite offscreen
        sta Sprite_Y_Position+12,y
SChk5:  pla                         ;get bits from stack
        asl                         ;rotate d3 into carry
        pha                         ;save to stack
        bcc SChk6
        lda #$f8                    ;if d3 was set, move fifth sprite offscreen
        sta Sprite_Y_Position+16,y
SChk6:  pla                         ;get bits from stack
        asl                         ;rotate d2 into carry
        bcc SLChk                   ;save to stack
        lda #$f8
        sta Sprite_Y_Position+20,y  ;if d2 was set, move sixth sprite offscreen
SLChk:  lda Enemy_OffscreenBits     ;check d7 of offscreen bits
        asl                         ;and if d7 is not set, skip sub
        bcc ExDLPl
        jsr MoveSixSpritesOffscreen ;otherwise branch to move all sprites offscreen
ExDLPl: rts

;-------------------------------------------------------------------------------------

DrawFloateyNumber_Coin:
          lda FrameCounter          ;get frame counter
          lsr                       ;divide by 2
          bcs NotRsNum              ;branch if d0 not set to raise number every other frame
          dec Misc_Y_Position,x     ;otherwise, decrement vertical coordinate
NotRsNum: lda Misc_Y_Position,x     ;get vertical coordinate
          jsr DumpTwoSpr            ;dump into both sprites
          lda Misc_Rel_XPos         ;get relative horizontal coordinate
          sta Sprite_X_Position,y   ;store as X coordinate for first sprite
          clc
          adc #$08                  ;add eight pixels
          sta Sprite_X_Position+4,y ;store as X coordinate for second sprite
          lda #$02
          sta Sprite_Attributes,y   ;store attribute byte in both sprites
          sta Sprite_Attributes+4,y
          lda #$72
          sta Sprite_Tilenumber,y   ;put tile numbers into both sprites
          lda #$76                  ;that resemble "200"
          sta Sprite_Tilenumber+4,y
          jmp ExJCGfx               ;then jump to leave (why not an rts here instead?)

JumpingCoinTiles:
      .byte $60, $61, $62, $63

JCoinGfxHandler:
         ldy Misc_SprDataOffset,x    ;get coin/floatey number's OAM data offset
         lda Misc_State,x            ;get state of misc object
         cmp #$02                    ;if 2 or greater,
         bcs DrawFloateyNumber_Coin  ;branch to draw floatey number
         lda Misc_Y_Position,x       ;store vertical coordinate as
         sta Sprite_Y_Position,y     ;Y coordinate for first sprite
         clc
         adc #$08                    ;add eight pixels
         sta Sprite_Y_Position+4,y   ;store as Y coordinate for second sprite
         lda Misc_Rel_XPos           ;get relative horizontal coordinate
         sta Sprite_X_Position,y
         sta Sprite_X_Position+4,y   ;store as X coordinate for first and second sprites
         lda FrameCounter            ;get frame counter
         lsr                         ;divide by 2 to alter every other frame
         and #%00000011              ;mask out d2-d1
         tax                         ;use as graphical offset
         lda JumpingCoinTiles,x      ;load tile number
         iny                         ;increment OAM data offset to write tile numbers
         jsr DumpTwoSpr              ;do sub to dump tile number into both sprites
         dey                         ;decrement to get old offset
         lda #$02
         sta Sprite_Attributes,y     ;set attribute byte in first sprite
         lda #$82
         sta Sprite_Attributes+4,y   ;set attribute byte with vertical flip in second sprite
         ldx ObjectOffset            ;get misc object offset
ExJCGfx: rts                         ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tiles for drawing the power-up, $00 also used to hold power-up type
;$02 - used to hold bottom row Y position
;$03 - used to hold flip control (not used here)
;$04 - used to hold sprite attributes
;$05 - used to hold X position
;$07 - counter

;tiles arranged in top left, right, bottom left, right order
PowerUpGfxTable:
      .byte $6e, $6f, $7e, $7f ;regular mushroom
      .byte $6d, $6d, $7d, $7d ;fire flower
      .byte $6c, $6c, $7c, $7c ;star
      .byte $6e, $6f, $7e, $7f ;1-up mushroom

PowerUpAttributes:
      .byte $02, $01, $02, $01

DrawPowerUp:
      ldy Enemy_SprDataOffset+5  ;get power-up's sprite data offset
      lda Enemy_Rel_YPos         ;get relative vertical coordinate
      clc
      adc #$08                   ;add eight pixels
      sta $02                    ;store result here
      lda Enemy_Rel_XPos         ;get relative horizontal coordinate
      sta $05                    ;store here
      ldx PowerUpType            ;get power-up type
      lda PowerUpAttributes,x    ;get attribute data for power-up type
      ora Enemy_SprAttrib+5      ;add background priority bit if set
      sta $04                    ;store attributes here
      txa
      pha                        ;save power-up type to the stack
      asl
      asl                        ;multiply by four to get proper offset
      tax                        ;use as X
      lda #$01
      sta $07                    ;set counter here to draw two rows of sprite object
      sta $03                    ;init d1 of flip control

PUpDrawLoop:
        lda PowerUpGfxTable,x      ;load left tile of power-up object
        sta $00
        lda PowerUpGfxTable+1,x    ;load right tile
        jsr DrawOneSpriteRow       ;branch to draw one row of our power-up object
        dec $07                    ;decrement counter
        bpl PUpDrawLoop            ;branch until two rows are drawn
        ldy Enemy_SprDataOffset+5  ;get sprite data offset again
        pla                        ;pull saved power-up type from the stack
        beq PUpOfs                 ;if regular mushroom, branch, do not change colors or flip
        cmp #$03
        beq PUpOfs                 ;if 1-up mushroom, branch, do not change colors or flip
        sta $00                    ;store power-up type here now
        lda FrameCounter           ;get frame counter
        lsr                        ;divide by 2 to change colors every two frames
        and #%00000011             ;mask out all but d1 and d0 (previously d2 and d1)
        ora Enemy_SprAttrib+5      ;add background priority bit if any set
        sta Sprite_Attributes,y    ;set as new palette bits for top left and
        sta Sprite_Attributes+4,y  ;top right sprites for fire flower and star
        ldx $00
        dex                        ;check power-up type for fire flower
        beq FlipPUpRightSide       ;if found, skip this part
        sta Sprite_Attributes+8,y  ;otherwise set new palette bits  for bottom left
        sta Sprite_Attributes+12,y ;and bottom right sprites as well for star only

FlipPUpRightSide:
        lda Sprite_Attributes+4,y
        ora #%01000000             ;set horizontal flip bit for top right sprite
        sta Sprite_Attributes+4,y
        lda Sprite_Attributes+12,y
        ora #%01000000             ;set horizontal flip bit for bottom right sprite
        sta Sprite_Attributes+12,y ;note these are only done for fire flower and star power-ups
PUpOfs: jmp SprObjectOffscrChk     ;jump to check to see if power-up is offscreen at all, then leave

;-------------------------------------------------------------------------------------
;$00-$01 - used in DrawEnemyObjRow to hold sprite tile numbers
;$02 - used to store Y position
;$03 - used to store moving direction, used to flip enemies horizontally
;$04 - used to store enemy's sprite attributes
;$05 - used to store X position
;Local_eb - used to hold sprite data offset
;Local_ec - used to hold either altered enemy state or special value used in gfx handler as condition
;Local_ed - used to hold enemy state from buffer
;Local_ef - used to hold enemy code used in gfx handler (may or may not resemble Enemy_ID values)

;tiles arranged in top left, right, middle left, right, bottom left, right order
EnemyGraphicsTable:
      .byte $ff, $ff, $82, $83, $92, $93  ;buzzy beetle frame 1
      .byte $ff, $ff, $84, $85, $94, $95  ;             frame 2
      .byte $ff, $8b, $9a, $9b, $aa, $ab  ;koopa troopa frame 1
      .byte $ff, $8d, $9c, $9d, $ac, $ad  ;             frame 2
      .byte $8a, $8b, $ba, $9b, $aa, $ab  ;koopa paratroopa frame 1
      .byte $8c, $8d, $bb, $9d, $ac, $ad  ;                 frame 2
      .byte $ff, $ff, $86, $87, $96, $97  ;spiny frame 1
      .byte $ff, $ff, $88, $89, $98, $99  ;      frame 2
      .byte $ff, $ff, $b3, $a3, $a3, $b3  ;spiny's egg frame 1
      .byte $ff, $ff, $b4, $a4, $a4, $b4  ;            frame 2
      .byte $ff, $ff, $cd, $cd, $fd, $fd  ;bloober frame 1
      .byte $cd, $cd, $dd, $dd, $ed, $ed  ;        frame 2
      .byte $ff, $ff, $a6, $a7, $b6, $b7  ;cheep-cheep frame 1
      .byte $ff, $ff, $a5, $a7, $b5, $b7  ;            frame 2
      .byte $ff, $ff, $80, $81, $90, $91  ;goomba
      .byte $ff, $ff, $a1, $a1, $b1, $b1  ;koopa shell frame 1 (upside-down)
      .byte $ff, $ff, $a2, $a2, $b1, $b1  ;            frame 2
      .byte $ff, $ff, $b1, $b1, $a1, $a1  ;koopa shell frame 1 (rightsideup)
      .byte $ff, $ff, $b1, $b1, $a2, $a2  ;            frame 2
      .byte $ff, $ff, $b0, $b0, $a0, $a0  ;buzzy beetle shell frame 1 (rightsideup)
      .byte $ff, $ff, $b0, $b0, $a0, $a0  ;                   frame 2
      .byte $ff, $ff, $a0, $a0, $b0, $b0  ;buzzy beetle shell frame 1 (upside-down)
      .byte $ff, $ff, $a0, $a0, $b0, $b0  ;                   frame 2
      .byte $ff, $ff, $ff, $ff, $b2, $b2  ;defeated goomba
      .byte $8e, $8f, $9e, $9f, $ae, $ae  ;lakitu frame 1
      .byte $ff, $ff, $af, $af, $ae, $ae  ;       frame 2
      .byte $ea, $eb, $fa, $fb, $fc, $fc  ;princess
      .byte $cc, $cc, $dc, $dc, $ec, $ec  ;mushroom retainer
      .byte $c4, $c5, $f6, $f7, $e6, $e7  ;hammer bro frame 1
      .byte $c4, $c5, $d4, $d5, $e4, $e5  ;           frame 2
      .byte $c6, $c7, $d6, $d7, $e6, $e7  ;           frame 3
      .byte $c6, $c7, $d6, $d7, $e4, $e5  ;           frame 4
      .byte $ce, $ce, $de, $de, $ee, $ee  ;piranha plant frame 1
      .byte $cf, $cf, $df, $df, $ef, $ef  ;              frame 2
      .byte $ff, $ff, $da, $da, $db, $db  ;podoboo
      .byte $c2, $c3, $d2, $d3, $e2, $ff  ;bowser front frame 1
      .byte $d0, $d1, $e0, $e1, $f0, $f1  ;bowser rear frame 1
      .byte $c2, $c3, $f2, $e3, $e2, $ff  ;       front frame 2
      .byte $d0, $d1, $e0, $e1, $c0, $c1  ;       rear frame 2
      .byte $ff, $ff, $a8, $a9, $b8, $b9  ;bullet bill
      .byte $6a, $6a, $6b, $6b, $6a, $6a  ;jumpspring frame 1
      .byte $69, $69, $69, $69, $ff, $ff  ;           frame 2
      .byte $68, $68, $ff, $ff, $ff, $ff  ;           frame 3

EnemyGfxTableOffsets:
      .byte $0c, $0c, $00, $0c, $0c, $a8, $54, $3c
      .byte $ea, $18, $48, $48, $cc, $c0, $18, $18
      .byte $18, $90, $24, $ff, $48, $9c, $d2, $d8
      .byte $f0, $f6, $fc

EnemyAttributeData:
      .byte $01, $02, $03, $02, $01, $01, $03, $03
      .byte $03, $01, $01, $02, $02, $21, $01, $02
      .byte $01, $01, $02, $ff, $02, $02, $01, $01
      .byte $02, $02, $02

EnemyAnimTimingBMask:
      .byte $08, $18

JumpspringFrameOffsets:
      .byte $18, $19, $1a, $19, $18

EnemyGfxHandler:
      lda Enemy_Y_Position,x      ;get enemy object vertical position
      sta $02
      lda Enemy_Rel_XPos          ;get enemy object horizontal position
      sta $05                     ;relative to screen
      ldy Enemy_SprDataOffset,x
      sty Local_eb                     ;get sprite data offset
      lda #$00
      sta VerticalFlipFlag        ;initialize vertical flip flag by default
      lda Enemy_MovingDir,x
      sta $03                     ;get enemy object moving direction
      lda Enemy_SprAttrib,x
      sta $04                     ;get enemy object sprite attributes
      lda Enemy_ID,x
      cmp #PiranhaPlant           ;is enemy object piranha plant?
      bne CheckForRetainerObj     ;if not, branch
      ldy PiranhaPlant_Y_Speed,x
      bmi CheckForRetainerObj     ;if piranha plant moving upwards, branch
      ldy EnemyFrameTimer,x
      beq CheckForRetainerObj     ;if timer for movement expired, branch
      rts                         ;if all conditions fail, leave

CheckForRetainerObj:
      lda Enemy_State,x           ;store enemy state
      sta Local_ed
      and #%00011111              ;nullify all but 5 LSB and use as Y
      tay
      lda Enemy_ID,x              ;check for mushroom retainer/princess object
      cmp #RetainerObject
      bne CheckForBulletBillCV    ;if not found, branch
      ldy #$00                    ;if found, nullify saved state in Y
      lda #$01                    ;set value that will not be used
      sta $03
      lda #$15                    ;set value $15 as code for mushroom retainer/princess object

CheckForBulletBillCV:
       cmp #BulletBill_CannonVar   ;otherwise check for bullet bill object
       bne CheckForJumpspring      ;if not found, branch again
       dec $02                     ;decrement saved vertical position
       lda #$03
       ldy EnemyFrameTimer,x       ;get timer for enemy object
       beq SBBAt                   ;if expired, do not set priority bit
       ora #%00100000              ;otherwise do so
SBBAt: sta $04                     ;set new sprite attributes
       ldy #$00                    ;nullify saved enemy state both in Y and in
       sty Local_ed                     ;memory location here
       lda #$08                    ;set specific value to unconditionally branch once

CheckForJumpspring:
      cmp #JumpspringObject        ;check for jumpspring object
      bne CheckForPodoboo
      ldy #$03                     ;set enemy state -2 MSB here for jumpspring object
      ldx JumpspringAnimCtrl       ;get current frame number for jumpspring object
      lda JumpspringFrameOffsets,x ;load data using frame number as offset

CheckForPodoboo:
      sta Local_ef                 ;store saved enemy object value here
      sty Local_ec                 ;and Y here (enemy state -2 MSB if not changed)
      ldx ObjectOffset        ;get enemy object offset
      cmp #$0c                ;check for podoboo object
      bne CheckBowserGfxFlag  ;branch if not found
      lda Enemy_Y_Speed,x     ;if moving upwards, branch
      bmi CheckBowserGfxFlag
      inc VerticalFlipFlag    ;otherwise, set flag for vertical flip

CheckBowserGfxFlag:
             lda BowserGfxFlag   ;if not drawing bowser at all, skip to something else
             beq CheckForGoomba
             ldy #$16            ;if set to 1, draw bowser's front
             cmp #$01
             beq SBwsrGfxOfs
             iny                 ;otherwise draw bowser's rear
SBwsrGfxOfs: sty Local_ef

CheckForGoomba:
          ldy Local_ef               ;check value for goomba object
          cpy #Goomba
          bne CheckBowserFront  ;branch if not found
          lda Enemy_State,x
          cmp #$02              ;check for defeated state
          bcc GmbaAnim          ;if not defeated, go ahead and animate
          ldx #$04              ;if defeated, write new value here
          stx Local_ec
GmbaAnim: and #%00100000        ;check for d5 set in enemy object state
          ora TimerControl      ;or timer disable flag set
          bne CheckBowserFront  ;if either condition true, do not animate goomba
          lda FrameCounter
          and #%00001000        ;check for every eighth frame
          bne CheckBowserFront
          lda $03
          eor #%00000011        ;invert bits to flip horizontally every eight frames
          sta $03               ;leave alone otherwise

CheckBowserFront:
             lda EnemyAttributeData,y    ;load sprite attribute using enemy object
             ora $04                     ;as offset, and add to bits already loaded
             sta $04
             lda EnemyGfxTableOffsets,y  ;load value based on enemy object as offset
             tax                         ;save as X
             ldy Local_ec                     ;get previously saved value
             lda BowserGfxFlag
             beq CheckForSpiny           ;if not drawing bowser object at all, skip all of this
             cmp #$01
             bne CheckBowserRear         ;if not drawing front part, branch to draw the rear part
             lda BowserBodyControls      ;check bowser's body control bits
             bpl ChkFrontSte             ;branch if d7 not set (control's bowser's mouth)
             ldx #$de                    ;otherwise load offset for second frame
ChkFrontSte: lda Local_ed                     ;check saved enemy state
             and #%00100000              ;if bowser not defeated, do not set flag
             beq DrawBowser

FlipBowserOver:
      stx VerticalFlipFlag  ;set vertical flip flag to nonzero

DrawBowser:
      jmp DrawEnemyObject   ;draw bowser's graphics now

CheckBowserRear:
            lda BowserBodyControls  ;check bowser's body control bits
            and #$01
            beq ChkRearSte          ;branch if d0 not set (control's bowser's feet)
            ldx #$e4                ;otherwise load offset for second frame
ChkRearSte: lda Local_ed                 ;check saved enemy state
            and #%00100000          ;if bowser not defeated, do not set flag
            beq DrawBowser
            lda $02                 ;subtract 16 pixels from
            sec                     ;saved vertical coordinate
            sbc #$10
            sta $02
            jmp FlipBowserOver      ;jump to set vertical flip flag

CheckForSpiny:
        cpx #$24               ;check if value loaded is for spiny
        bne CheckForLakitu     ;if not found, branch
        cpy #$05               ;if enemy state set to $05, do this,
        bne NotEgg             ;otherwise branch
        ldx #$30               ;set to spiny egg offset
        lda #$02
        sta $03                ;set enemy direction to reverse sprites horizontally
        lda #$05
        sta Local_ec                ;set enemy state
NotEgg: jmp CheckForHammerBro  ;skip a big chunk of this if we found spiny but not in egg

CheckForLakitu:
        cpx #$90                  ;check value for lakitu's offset loaded
        bne CheckUpsideDownShell  ;branch if not loaded
        lda Local_ed
        and #%00100000            ;check for d5 set in enemy state
        bne NoLAFr                ;branch if set
        lda FrenzyEnemyTimer
        cmp #$10                  ;check timer to see if we've reached a certain range
        bcs NoLAFr                ;branch if not
        ldx #$96                  ;if d6 not set and timer in range, load alt frame for lakitu
NoLAFr: jmp CheckDefeatedState    ;skip this next part if we found lakitu but alt frame not needed

CheckUpsideDownShell:
      lda Local_ef                    ;check for enemy object => $04
      cmp #$04
      bcs CheckRightSideUpShell  ;branch if true
      cpy #$02
      bcc CheckRightSideUpShell  ;branch if enemy state < $02
      ldx #$5a                   ;set for upside-down koopa shell by default
      ldy Local_ef
      cpy #BuzzyBeetle           ;check for buzzy beetle object
      bne CheckRightSideUpShell
      ldx #$7e                   ;set for upside-down buzzy beetle shell if found
      inc $02                    ;increment vertical position by one pixel

CheckRightSideUpShell:
      lda Local_ec                ;check for value set here
      cmp #$04               ;if enemy state < $02, do not change to shell, if
      bne CheckForHammerBro  ;enemy state => $02 but not = $04, leave shell upside-down
      ldx #$72               ;set right-side up buzzy beetle shell by default
      inc $02                ;increment saved vertical position by one pixel
      ldy Local_ef
      cpy #BuzzyBeetle       ;check for buzzy beetle object
      beq CheckForDefdGoomba ;branch if found
      ldx #$66               ;change to right-side up koopa shell if not found
      inc $02                ;and increment saved vertical position again

CheckForDefdGoomba:
      cpy #Goomba            ;check for goomba object (necessary if previously
      bne CheckForHammerBro  ;failed buzzy beetle object test)
      ldx #$54               ;load for regular goomba
      lda Local_ed                ;note that this only gets performed if enemy state => $02
      and #%00100000         ;check saved enemy state for d5 set
      bne CheckForHammerBro  ;branch if set
      ldx #$8a               ;load offset for defeated goomba
      dec $02                ;set different value and decrement saved vertical position

CheckForHammerBro:
      ldy ObjectOffset
      lda Local_ef                  ;check for hammer bro object
      cmp #HammerBro
      bne CheckForBloober      ;branch if not found
      lda Local_ed
      beq CheckToAnimateEnemy  ;branch if not in normal enemy state
      and #%00001000
      beq CheckDefeatedState   ;if d3 not set, branch further away
      ldx #$b4                 ;otherwise load offset for different frame
      bne CheckToAnimateEnemy  ;unconditional branch

CheckForBloober:
      cpx #$48                 ;check for cheep-cheep offset loaded
      beq CheckToAnimateEnemy  ;branch if found
      lda EnemyIntervalTimer,y
      cmp #$05
      bcs CheckDefeatedState   ;branch if some timer is above a certain point
      cpx #$3c                 ;check for bloober offset loaded
      bne CheckToAnimateEnemy  ;branch if not found this time
      cmp #$01
      beq CheckDefeatedState   ;branch if timer is set to certain point
      inc $02                  ;increment saved vertical coordinate three pixels
      inc $02
      inc $02
      jmp CheckAnimationStop   ;and do something else

CheckToAnimateEnemy:
      lda Local_ef                  ;check for specific enemy objects
      cmp #Goomba
      beq CheckDefeatedState   ;branch if goomba
      cmp #$08
      beq CheckDefeatedState   ;branch if bullet bill (note both variants use $08 here)
      cmp #Podoboo
      beq CheckDefeatedState   ;branch if podoboo
      cmp #$18                 ;branch if => $18
      bcs CheckDefeatedState
      ldy #$00
      cmp #$15                 ;check for mushroom retainer/princess object
      bne CheckForSecondFrame  ;which uses different code here, branch if not found
      iny                      ;residual instruction
      lda WorldNumber          ;are we on world 8?
      cmp #World8
      bcs CheckDefeatedState   ;if so, leave the offset alone (use princess)
      ldx #$a2                 ;otherwise, set for mushroom retainer object instead
      lda #$03                 ;set alternate state here
      sta Local_ec
      bne CheckDefeatedState   ;unconditional branch

CheckForSecondFrame:
      lda FrameCounter            ;load frame counter
      and EnemyAnimTimingBMask,y  ;mask it (partly residual, one byte not ever used)
      bne CheckDefeatedState      ;branch if timing is off

CheckAnimationStop:
      lda Local_ed                 ;check saved enemy state
      and #%10100000          ;for d7 or d5, or check for timers stopped
      ora TimerControl
      bne CheckDefeatedState  ;if either condition true, branch
      txa
      clc
      adc #$06                ;add $06 to current enemy offset
      tax                     ;to animate various enemy objects

CheckDefeatedState:
      lda Local_ed               ;check saved enemy state
      and #%00100000        ;for d5 set
      beq DrawEnemyObject   ;branch if not set
      lda Local_ef
      cmp #$04              ;check for saved enemy object => $04
      bcc DrawEnemyObject   ;branch if less
      ldy #$01
      sty VerticalFlipFlag  ;set vertical flip flag
      dey
      sty Local_ec               ;init saved value here

DrawEnemyObject:
      ldy Local_eb                    ;load sprite data offset
      jsr DrawEnemyObjRow        ;draw six tiles of data
      jsr DrawEnemyObjRow        ;into sprite data
      jsr DrawEnemyObjRow
      ldx ObjectOffset           ;get enemy object offset
      ldy Enemy_SprDataOffset,x  ;get sprite data offset
      lda Local_ef
      cmp #$08                   ;get saved enemy object and check
      bne CheckForVerticalFlip   ;for bullet bill, branch if not found

SkipToOffScrChk:
      jmp SprObjectOffscrChk     ;jump if found

CheckForVerticalFlip:
      lda VerticalFlipFlag       ;check if vertical flip flag is set here
      beq CheckForESymmetry      ;branch if not
      lda Sprite_Attributes,y    ;get attributes of first sprite we dealt with
      ora #%10000000             ;set bit for vertical flip
      iny
      iny                        ;increment two bytes so that we store the vertical flip
      jsr DumpSixSpr             ;in attribute bytes of enemy obj sprite data
      dey
      dey                        ;now go back to the Y coordinate offset
      tya
      tax                        ;give offset to X
      lda Local_ef
      cmp #HammerBro             ;check saved enemy object for hammer bro
      beq FlipEnemyVertically
      cmp #Lakitu                ;check saved enemy object for lakitu
      beq FlipEnemyVertically    ;branch for hammer bro or lakitu
      cmp #$15
      bcs FlipEnemyVertically    ;also branch if enemy object => $15
      txa
      clc
      adc #$08                   ;if not selected objects or => $15, set
      tax                        ;offset in X for next row

FlipEnemyVertically:
      lda Sprite_Tilenumber,x     ;load first or second row tiles
      pha                         ;and save tiles to the stack
      lda Sprite_Tilenumber+4,x
      pha
      lda Sprite_Tilenumber+16,y  ;exchange third row tiles
      sta Sprite_Tilenumber,x     ;with first or second row tiles
      lda Sprite_Tilenumber+20,y
      sta Sprite_Tilenumber+4,x
      pla                         ;pull first or second row tiles from stack
      sta Sprite_Tilenumber+20,y  ;and save in third row
      pla
      sta Sprite_Tilenumber+16,y

CheckForESymmetry:
        lda BowserGfxFlag           ;are we drawing bowser at all?
        bne SkipToOffScrChk         ;branch if so
        lda Local_ef
        ldx Local_ec                     ;get alternate enemy state
        cmp #$05                    ;check for hammer bro object
        bne ContES
        jmp SprObjectOffscrChk      ;jump if found
ContES: cmp #Bloober                ;check for bloober object
        beq MirrorEnemyGfx
        cmp #PiranhaPlant           ;check for piranha plant object
        beq MirrorEnemyGfx
        cmp #Podoboo                ;check for podoboo object
        beq MirrorEnemyGfx          ;branch if either of three are found
        cmp #Spiny                  ;check for spiny object
        bne ESRtnr                  ;branch closer if not found
        cpx #$05                    ;check spiny's state
        bne CheckToMirrorLakitu     ;branch if not an egg, otherwise
ESRtnr: cmp #$15                    ;check for princess/mushroom retainer object
        bne SpnySC
        lda #$42                    ;set horizontal flip on bottom right sprite
        sta Sprite_Attributes+20,y  ;note that palette bits were already set earlier
SpnySC: cpx #$02                    ;if alternate enemy state set to 1 or 0, branch
        bcc CheckToMirrorLakitu

MirrorEnemyGfx:
        lda BowserGfxFlag           ;if enemy object is bowser, skip all of this
        bne CheckToMirrorLakitu
        lda Sprite_Attributes,y     ;load attribute bits of first sprite
        and #%10100011
        sta Sprite_Attributes,y     ;save vertical flip, priority, and palette bits
        sta Sprite_Attributes+8,y   ;in left sprite column of enemy object OAM data
        sta Sprite_Attributes+16,y
        ora #%01000000              ;set horizontal flip
        cpx #$05                    ;check for state used by spiny's egg
        bne EggExc                  ;if alternate state not set to $05, branch
        ora #%10000000              ;otherwise set vertical flip
EggExc: sta Sprite_Attributes+4,y   ;set bits of right sprite column
        sta Sprite_Attributes+12,y  ;of enemy object sprite data
        sta Sprite_Attributes+20,y
        cpx #$04                    ;check alternate enemy state
        bne CheckToMirrorLakitu     ;branch if not $04
        lda Sprite_Attributes+8,y   ;get second row left sprite attributes
        ora #%10000000
        sta Sprite_Attributes+8,y   ;store bits with vertical flip in
        sta Sprite_Attributes+16,y  ;second and third row left sprites
        ora #%01000000
        sta Sprite_Attributes+12,y  ;store with horizontal and vertical flip in
        sta Sprite_Attributes+20,y  ;second and third row right sprites

CheckToMirrorLakitu:
        lda Local_ef                     ;check for lakitu enemy object
        cmp #Lakitu
        bne CheckToMirrorJSpring    ;branch if not found
        lda VerticalFlipFlag
        bne NVFLak                  ;branch if vertical flip flag not set
        lda Sprite_Attributes+16,y  ;save vertical flip and palette bits
        and #%10000001              ;in third row left sprite
        sta Sprite_Attributes+16,y
        lda Sprite_Attributes+20,y  ;set horizontal flip and palette bits
        ora #%01000001              ;in third row right sprite
        sta Sprite_Attributes+20,y
        ldx FrenzyEnemyTimer        ;check timer
        cpx #$10
        bcs SprObjectOffscrChk      ;branch if timer has not reached a certain range
        sta Sprite_Attributes+12,y  ;otherwise set same for second row right sprite
        and #%10000001
        sta Sprite_Attributes+8,y   ;preserve vertical flip and palette bits for left sprite
        bcc SprObjectOffscrChk      ;unconditional branch
NVFLak: lda Sprite_Attributes,y     ;get first row left sprite attributes
        and #%10000001
        sta Sprite_Attributes,y     ;save vertical flip and palette bits
        lda Sprite_Attributes+4,y   ;get first row right sprite attributes
        ora #%01000001              ;set horizontal flip and palette bits
        sta Sprite_Attributes+4,y   ;note that vertical flip is left as-is

CheckToMirrorJSpring:
      lda Local_ef                     ;check for jumpspring object (any frame)
      cmp #$18
      bcc SprObjectOffscrChk      ;branch if not jumpspring object at all
      lda #$82
      sta Sprite_Attributes+8,y   ;set vertical flip and palette bits of
      sta Sprite_Attributes+16,y  ;second and third row left sprites
      ora #%01000000
      sta Sprite_Attributes+12,y  ;set, in addition to those, horizontal flip
      sta Sprite_Attributes+20,y  ;for second and third row right sprites

SprObjectOffscrChk:
         ldx ObjectOffset          ;get enemy buffer offset
         lda Enemy_OffscreenBits   ;check offscreen information
         lsr
         lsr                       ;shift three times to the right
         lsr                       ;which puts d2 into carry
         pha                       ;save to stack
         bcc LcChk                 ;branch if not set
         lda #$04                  ;set for right column sprites
         jsr MoveESprColOffscreen  ;and move them offscreen
LcChk:   pla                       ;get from stack
         lsr                       ;move d3 to carry
         pha                       ;save to stack
         bcc Row3C                 ;branch if not set
         lda #$00                  ;set for left column sprites,
         jsr MoveESprColOffscreen  ;move them offscreen
Row3C:   pla                       ;get from stack again
         lsr                       ;move d5 to carry this time
         lsr
         pha                       ;save to stack again
         bcc Row23C                ;branch if carry not set
         lda #$10                  ;set for third row of sprites
         jsr MoveESprRowOffscreen  ;and move them offscreen
Row23C:  pla                       ;get from stack
         lsr                       ;move d6 into carry
         pha                       ;save to stack
         bcc AllRowC
         lda #$08                  ;set for second and third rows
         jsr MoveESprRowOffscreen  ;move them offscreen
AllRowC: pla                       ;get from stack once more
         lsr                       ;move d7 into carry
         bcc ExEGHandler
         jsr MoveESprRowOffscreen  ;move all sprites offscreen (A should be 0 by now)
         lda Enemy_ID,x
         cmp #Podoboo              ;check enemy identifier for podoboo
         beq ExEGHandler           ;skip this part if found, we do not want to erase podoboo!
         lda Enemy_Y_HighPos,x     ;check high byte of vertical position
         cmp #$02                  ;if not yet past the bottom of the screen, branch
         bne ExEGHandler
         jsr EraseEnemyObject      ;what it says

ExEGHandler:
      rts

DrawEnemyObjRow:
      lda EnemyGraphicsTable,x    ;load two tiles of enemy graphics
      sta $00
      lda EnemyGraphicsTable+1,x

DrawOneSpriteRow:
      sta $01
      jmp DrawSpriteObject        ;draw them

MoveESprRowOffscreen:
      clc                         ;add A to enemy object OAM data offset
      adc Enemy_SprDataOffset,x
      tay                         ;use as offset
      lda #$f8
      jmp DumpTwoSpr              ;move first row of sprites offscreen

MoveESprColOffscreen:
      clc                         ;add A to enemy object OAM data offset
      adc Enemy_SprDataOffset,x
      tay                         ;use as offset
      jsr MoveColOffscreen        ;move first and second row sprites in column offscreen
      sta Sprite_Data+16,y        ;move third row sprite in column offscreen
      rts

;-------------------------------------------------------------------------------------
;$00-$01 - tile numbers
;$02 - relative Y position
;$03 - horizontal flip flag (not used here)
;$04 - attributes
;$05 - relative X position

DefaultBlockObjTiles:
      .byte $bd, $bd, $be, $be             ;brick w/ line (these are sprite tiles, not BG!)

DrawBlock:
           lda Block_Rel_YPos            ;get relative vertical coordinate of block object
           sta $02                       ;store here
           lda Block_Rel_XPos            ;get relative horizontal coordinate of block object
           sta $05                       ;store here
           lda #$03
           sta $04                       ;set attribute byte here
           lsr
           sta $03                       ;set horizontal flip bit here (will not be used)
           ldy Block_SprDataOffset,x     ;get sprite data offset
           ldx #$00                      ;reset X for use as offset to tile data
DBlkLoop:  lda DefaultBlockObjTiles,x    ;get left tile number
           sta $00                       ;set here
           lda DefaultBlockObjTiles+1,x  ;get right tile number
           jsr DrawOneSpriteRow          ;do sub to write tile numbers to first row of sprites
           cpx #$04                      ;check incremented offset
           bne DBlkLoop                  ;and loop back until all four sprites are done
           ldx ObjectOffset              ;get block object offset
           ldy Block_SprDataOffset,x     ;get sprite data offset
           lda AreaType
           cmp #$01                      ;check for ground level type area
           beq ChkRep                    ;if found, branch to next part
           lda #$be
           sta Sprite_Tilenumber,y       ;otherwise remove brick tiles with lines
           sta Sprite_Tilenumber+4,y     ;and replace then with lineless brick tiles
ChkRep:    lda Block_Metatile,x          ;check replacement metatile
           cmp #$c4                      ;if not used block metatile, then
           bne BlkOffscr                 ;branch ahead to use current graphics
           lda #$bf                      ;set A for used block tile
           iny                           ;increment Y to write to tile bytes
           jsr DumpFourSpr               ;do sub to dump into all four sprites
           dey                           ;return Y to original offset
           lda #$03                      ;set palette bits
           ldx AreaType
           dex                           ;check for ground level type area again
           beq SetBFlip                  ;if found, use current palette bits
           lsr                           ;otherwise set to $01
SetBFlip:  ldx ObjectOffset              ;put block object offset back in X
           sta Sprite_Attributes,y       ;store attribute byte as-is in first sprite
           ora #%01000000
           sta Sprite_Attributes+4,y     ;set horizontal flip bit for second sprite
           ora #%10000000
           sta Sprite_Attributes+12,y    ;set both flip bits for fourth sprite
           and #%10000011
           sta Sprite_Attributes+8,y     ;set vertical flip bit for third sprite
BlkOffscr: lda Block_OffscreenBits       ;get offscreen bits for block object
           pha                           ;save to stack
           and #%00000100                ;check to see if d2 in offscreen bits are set
           beq PullOfsB                  ;if not set, branch, otherwise move sprites offscreen
           lda #$f8                      ;move offscreen two OAMs
           sta Sprite_Y_Position+4,y     ;on the right side
           sta Sprite_Y_Position+12,y
PullOfsB:  pla                           ;pull offscreen bits from stack
ChkLeftCo: and #%00001000                ;check to see if d3 in offscreen bits are set
           beq ExDBlk                    ;if not set, branch, otherwise move sprites offscreen

MoveColOffscreen:
        lda #$f8                   ;move offscreen two OAMs
        sta Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
        sta Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
ExDBlk: rts

;-------------------------------------------------------------------------------------
;$00 - used to hold palette bits for attribute byte or relative X position

DrawBrickChunks:
         lda #$02                   ;set palette bits here
         sta $00
         lda #$fe                   ;set tile number for ball (something residual, likely)
         ldy GameEngineSubroutine
         cpy #$05                   ;if end-of-level routine running,
         beq DChunks                ;use palette and tile number assigned
         lda #$03                   ;otherwise set different palette bits
         sta $00
         lda #$67                   ;and set tile number for brick chunks
DChunks: ldy Block_SprDataOffset,x  ;get OAM data offset
         iny                        ;increment to start with tile bytes in OAM
         jsr DumpFourSpr            ;do sub to dump tile number into all four sprites
         lda FrameCounter           ;get frame counter
         asl
         asl
         asl                        ;move low nybble to high
         asl
         and #$c0                   ;get what was originally d3-d2 of low nybble
         ora $00                    ;add palette bits
         iny                        ;increment offset for attribute bytes
         jsr DumpFourSpr            ;do sub to dump attribute data into all four sprites
         dey
         dey                        ;decrement offset to Y coordinate
         lda Block_Rel_YPos         ;get first block object's relative vertical coordinate
         jsr DumpTwoSpr             ;do sub to dump current Y coordinate into two sprites
         lda Block_Rel_XPos         ;get first block object's relative horizontal coordinate
         sta Sprite_X_Position,y    ;save into X coordinate of first sprite
         lda Block_Orig_XPos,x      ;get original horizontal coordinate
         sec
         sbc ScreenLeft_X_Pos       ;subtract coordinate of left side from original coordinate
         sta $00                    ;store result as relative horizontal coordinate of original
         sec
         sbc Block_Rel_XPos         ;get difference of relative positions of original - current
         adc $00                    ;add original relative position to result
         adc #$06                   ;plus 6 pixels to position second brick chunk correctly
         sta Sprite_X_Position+4,y  ;save into X coordinate of second sprite
         lda Block_Rel_YPos+1       ;get second block object's relative vertical coordinate
         sta Sprite_Y_Position+8,y
         sta Sprite_Y_Position+12,y ;dump into Y coordinates of third and fourth sprites
         lda Block_Rel_XPos+1       ;get second block object's relative horizontal coordinate
         sta Sprite_X_Position+8,y  ;save into X coordinate of third sprite
         lda $00                    ;use original relative horizontal position
         sec
         sbc Block_Rel_XPos+1       ;get difference of relative positions of original - current
         adc $00                    ;add original relative position to result
         adc #$06                   ;plus 6 pixels to position fourth brick chunk correctly
         sta Sprite_X_Position+12,y ;save into X coordinate of fourth sprite
         lda Block_OffscreenBits    ;get offscreen bits for block object
         jsr ChkLeftCo              ;do sub to move left half of sprites offscreen if necessary
         lda Block_OffscreenBits    ;get offscreen bits again
         asl                        ;shift d7 into carry
         bcc ChnkOfs                ;if d7 not set, branch to last part
         lda #$f8
         jsr DumpTwoSpr             ;otherwise move top sprites offscreen
ChnkOfs: lda $00                    ;if relative position on left side of screen,
         bpl ExBCDr                 ;go ahead and leave
         lda Sprite_X_Position,y    ;otherwise compare left-side X coordinate
         cmp Sprite_X_Position+4,y  ;to right-side X coordinate
         bcc ExBCDr                 ;branch to leave if less
         lda #$f8                   ;otherwise move right half of sprites offscreen
         sta Sprite_Y_Position+4,y
         sta Sprite_Y_Position+12,y
ExBCDr:  rts                        ;leave

;-------------------------------------------------------------------------------------

DrawFireball:
      ldy FBall_SprDataOffset,x  ;get fireball's sprite data offset
      lda Fireball_Rel_YPos      ;get relative vertical coordinate
      sta Sprite_Y_Position,y    ;store as sprite Y coordinate
      lda Fireball_Rel_XPos      ;get relative horizontal coordinate
      sta Sprite_X_Position,y    ;store as sprite X coordinate, then do shared code

DrawFirebar:
       lda FrameCounter         ;get frame counter
       lsr                      ;divide by four
       lsr
       pha                      ;save result to stack
       and #$01                 ;mask out all but last bit
       eor #$50                 ;set either tile $64 or $65 as fireball tile
       sta Sprite_Tilenumber,y  ;thus tile changes every four frames
       pla                      ;get from stack
       lsr                      ;divide by four again
       lsr
       lda #$02                 ;load value $02 to set palette in attrib byte
       bcc FireA                ;if last bit shifted out was not set, skip this
       ora #%11000000           ;otherwise flip both ways every eight frames
FireA: sta Sprite_Attributes,y  ;store attribute byte and leave
       rts

;-------------------------------------------------------------------------------------

ExplosionTiles:
      .byte $64, $65, $66

DrawExplosion_Fireball:
      ldy Alt_SprDataOffset,x  ;get OAM data offset of alternate sort for fireball's explosion
      lda Fireball_State,x     ;load fireball state
      inc Fireball_State,x     ;increment state for next frame
      lsr                      ;divide by 2
      and #%00000111           ;mask out all but d3-d1
      cmp #$03                 ;check to see if time to kill fireball
      bcs KillFireBall         ;branch if so, otherwise continue to draw explosion

DrawExplosion_Fireworks:
      tax                         ;use whatever's in A for offset
      lda ExplosionTiles,x        ;get tile number using offset
      iny                         ;increment Y (contains sprite data offset)
      jsr DumpFourSpr             ;and dump into tile number part of sprite data
      dey                         ;decrement Y so we have the proper offset again
      ldx ObjectOffset            ;return enemy object buffer offset to X
      lda Fireball_Rel_YPos       ;get relative vertical coordinate
      sec                         ;subtract four pixels vertically
      sbc #$04                    ;for first and third sprites
      sta Sprite_Y_Position,y
      sta Sprite_Y_Position+8,y
      clc                         ;add eight pixels vertically
      adc #$08                    ;for second and fourth sprites
      sta Sprite_Y_Position+4,y
      sta Sprite_Y_Position+12,y
      lda Fireball_Rel_XPos       ;get relative horizontal coordinate
      sec                         ;subtract four pixels horizontally
      sbc #$04                    ;for first and second sprites
      sta Sprite_X_Position,y
      sta Sprite_X_Position+4,y
      clc                         ;add eight pixels horizontally
      adc #$08                    ;for third and fourth sprites
      sta Sprite_X_Position+8,y
      sta Sprite_X_Position+12,y
      lda #$02                    ;set palette attributes for all sprites, but
      sta Sprite_Attributes,y     ;set no flip at all for first sprite
      lda #$82
      sta Sprite_Attributes+4,y   ;set vertical flip for second sprite
      lda #$42
      sta Sprite_Attributes+8,y   ;set horizontal flip for third sprite
      lda #$c2
      sta Sprite_Attributes+12,y  ;set both flips for fourth sprite
      rts                         ;we are done

KillFireBall:
      lda #$00                    ;clear fireball state to kill it
      sta Fireball_State,x
      rts

;-------------------------------------------------------------------------------------

DrawSmallPlatform:
       ldy Enemy_SprDataOffset,x   ;get OAM data offset
       lda #$bc                    ;load tile number for small platforms
       iny                         ;increment offset for tile numbers
       jsr DumpSixSpr              ;dump tile number into all six sprites
       iny                         ;increment offset for attributes
       lda #$02                    ;load palette controls
       jsr DumpSixSpr              ;dump attributes into all six sprites
       dey                         ;decrement for original offset
       dey
       lda Enemy_Rel_XPos          ;get relative horizontal coordinate
       sta Sprite_X_Position,y
       sta Sprite_X_Position+12,y  ;dump as X coordinate into first and fourth sprites
       clc
       adc #$08                    ;add eight pixels
       sta Sprite_X_Position+4,y   ;dump into second and fifth sprites
       sta Sprite_X_Position+16,y
       clc
       adc #$08                    ;add eight more pixels
       sta Sprite_X_Position+8,y   ;dump into third and sixth sprites
       sta Sprite_X_Position+20,y
       lda Enemy_Y_Position,x      ;get vertical coordinate
       tax
       pha                         ;save to stack
       cpx #$20                    ;if vertical coordinate below status bar,
       bcs TopSP                   ;do not mess with it
       lda #$f8                    ;otherwise move first three sprites offscreen
TopSP: jsr DumpThreeSpr            ;dump vertical coordinate into Y coordinates
       pla                         ;pull from stack
       clc
       adc #$80                    ;add 128 pixels
       tax
       cpx #$20                    ;if below status bar (taking wrap into account)
       bcs BotSP                   ;then do not change altered coordinate
       lda #$f8                    ;otherwise move last three sprites offscreen
BotSP: sta Sprite_Y_Position+12,y  ;dump vertical coordinate + 128 pixels
       sta Sprite_Y_Position+16,y  ;into Y coordinates
       sta Sprite_Y_Position+20,y
       lda Enemy_OffscreenBits     ;get offscreen bits
       pha                         ;save to stack
       and #%00001000              ;check d3
       beq SOfs
       lda #$f8                    ;if d3 was set, move first and
       sta Sprite_Y_Position,y     ;fourth sprites offscreen
       sta Sprite_Y_Position+12,y
SOfs:  pla                         ;move out and back into stack
       pha
       and #%00000100              ;check d2
       beq SOfs2
       lda #$f8                    ;if d2 was set, move second and
       sta Sprite_Y_Position+4,y   ;fifth sprites offscreen
       sta Sprite_Y_Position+16,y
SOfs2: pla                         ;get from stack
       and #%00000010              ;check d1
       beq ExSPl
       lda #$f8                    ;if d1 was set, move third and
       sta Sprite_Y_Position+8,y   ;sixth sprites offscreen
       sta Sprite_Y_Position+20,y
ExSPl: ldx ObjectOffset            ;get enemy object offset and leave
       rts

;-------------------------------------------------------------------------------------

DrawBubble:
        ldy Player_Y_HighPos        ;if player's vertical high position
        dey                         ;not within screen, skip all of this
        bne ExDBub
        lda Bubble_OffscreenBits    ;check air bubble's offscreen bits
        and #%00001000
        bne ExDBub                  ;if bit set, branch to leave
        ldy Bubble_SprDataOffset,x  ;get air bubble's OAM data offset
        lda Bubble_Rel_XPos         ;get relative horizontal coordinate
        sta Sprite_X_Position,y     ;store as X coordinate here
        lda Bubble_Rel_YPos         ;get relative vertical coordinate
        sta Sprite_Y_Position,y     ;store as Y coordinate here
        lda #$52
        sta Sprite_Tilenumber,y     ;put air bubble tile into OAM data
        lda #$02
        sta Sprite_Attributes,y     ;set attribute byte
ExDBub: rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used to store player's vertical offscreen bits

PlayerGfxTblOffsets:
      .byte $20, $28, $c8, $18, $00, $40, $50, $58
      .byte $80, $88, $b8, $78, $60, $a0, $b0, $b8

;tiles arranged in order, 2 tiles per row, top to bottom

PlayerGraphicsTable:
;big player table
      .byte $00, $01, $10, $11, $20, $21, $30, $31 ;walking frame 1
      .byte $02, $03, $12, $13, $22, $23, $32, $33 ;        frame 2
      .byte $04, $05, $14, $15, $24, $25, $34, $35 ;        frame 3
      .byte $06, $07, $16, $17, $26, $27, $36, $37 ;skidding
      .byte $08, $09, $18, $19, $28, $29, $38, $39 ;jumping
      .byte $02, $03, $0a, $0b, $1a, $1b, $2a, $2b ;swimming frame 1
      .byte $02, $03, $12, $13, $22, $1d, $2a, $2b ;         frame 2
      .byte $02, $03, $12, $13, $0c, $0d, $2a, $2b ;         frame 3
      .byte $02, $03, $0a, $0b, $1a, $1b, $5c, $5d ;climbing frame 1
      .byte $02, $03, $12, $13, $22, $23, $5e, $5f ;         frame 2
      .byte $ff, $ff, $02, $03, $54, $55, $53, $53 ;crouching
      .byte $02, $03, $0a, $0b, $1a, $1b, $32, $33 ;fireball throwing

;small player table
      .byte $ff, $ff, $ff, $ff, $0e, $0f, $1e, $1f ;walking frame 1
      .byte $ff, $ff, $ff, $ff, $2e, $2f, $3e, $3f ;        frame 2
      .byte $ff, $ff, $ff, $ff, $41, $2f, $44, $45 ;        frame 3
      .byte $ff, $ff, $ff, $ff, $3c, $3d, $4c, $4d ;skidding
      .byte $ff, $ff, $ff, $ff, $0e, $40, $42, $43 ;jumping
      .byte $ff, $ff, $ff, $ff, $0e, $0f, $3a, $3b ;swimming frame 1
      .byte $ff, $ff, $ff, $ff, $0e, $0f, $3a, $4b ;         frame 2
      .byte $ff, $ff, $ff, $ff, $0e, $0f, $2c, $2d ;         frame 3
      .byte $ff, $ff, $ff, $ff, $0e, $0f, $58, $59 ;climbing frame 1
      .byte $ff, $ff, $ff, $ff, $41, $2f, $5a, $5b ;         frame 2
      .byte $ff, $ff, $ff, $ff, $4e, $4e, $4f, $4f ;killed

;used by both player sizes
      .byte $ff, $ff, $ff, $ff, $41, $2f, $49, $49 ;small player standing
      .byte $ff, $ff, $00, $01, $46, $47, $48, $48 ;intermediate grow frame
      .byte $00, $01, $46, $47, $56, $56, $57, $57 ;big player standing

SwimKickTileNum:
      .byte $1c, $4a

PlayerGfxHandler:
        lda InjuryTimer             ;if player's injured invincibility timer
        beq CntPl                   ;not set, skip checkpoint and continue code
        lda FrameCounter
        lsr                         ;otherwise check frame counter and branch
        bcs ExPGH                   ;to leave on every other frame (when d0 is set)
CntPl:  lda GameEngineSubroutine    ;if executing specific game engine routine,
        cmp #$0b                    ;branch ahead to some other part
        beq PlayerKilled
        lda PlayerChangeSizeFlag    ;if grow/shrink flag set
        bne DoChangeSize            ;then branch to some other code
        ldy SwimmingFlag            ;if swimming flag set, branch to
        beq FindPlayerAction        ;different part, do not return
        lda Player_State
        cmp #$00                    ;if player status normal,
        beq FindPlayerAction        ;branch and do not return
        jsr FindPlayerAction        ;otherwise jump and return
        lda FrameCounter
        and #%00000100              ;check frame counter for d2 set (8 frames every
        bne ExPGH                   ;eighth frame), and branch if set to leave
        tax                         ;initialize X to zero
        ldy Player_SprDataOffset    ;get player sprite data offset
        lda PlayerFacingDir         ;get player's facing direction
        lsr
        bcs SwimKT                  ;if player facing to the right, use current offset
        iny
        iny                         ;otherwise move to next OAM data
        iny
        iny
SwimKT: lda PlayerSize              ;check player's size
        beq BigKTS                  ;if big, use first tile
        lda Sprite_Tilenumber+24,y  ;check tile number of seventh/eighth sprite
        cmp SwimTileRepOffset       ;against tile number in player graphics table
        beq ExPGH                   ;if spr7/spr8 tile number = value, branch to leave
        inx                         ;otherwise increment X for second tile
BigKTS: lda SwimKickTileNum,x       ;overwrite tile number in sprite 7/8
        sta Sprite_Tilenumber+24,y  ;to animate player's feet when swimming
ExPGH:  rts                         ;then leave

FindPlayerAction:
      jsr ProcessPlayerAction       ;find proper offset to graphics table by player's actions
      jmp PlayerGfxProcessing       ;draw player, then process for fireball throwing

DoChangeSize:
      jsr HandleChangeSize          ;find proper offset to graphics table for grow/shrink
      jmp PlayerGfxProcessing       ;draw player, then process for fireball throwing

PlayerKilled:
      ldy #$0e                      ;load offset for player killed
      lda PlayerGfxTblOffsets,y     ;get offset to graphics table

PlayerGfxProcessing:
       sta PlayerGfxOffset           ;store offset to graphics table here
       lda #$04
       jsr RenderPlayerSub           ;draw player based on offset loaded
       jsr ChkForPlayerAttrib        ;set horizontal flip bits as necessary
       lda FireballThrowingTimer
       beq PlayerOffscreenChk        ;if fireball throw timer not set, skip to the end
       ldy #$00                      ;set value to initialize by default
       lda PlayerAnimTimer           ;get animation frame timer
       cmp FireballThrowingTimer     ;compare to fireball throw timer
       sty FireballThrowingTimer     ;initialize fireball throw timer
       bcs PlayerOffscreenChk        ;if animation frame timer => fireball throw timer skip to end
       sta FireballThrowingTimer     ;otherwise store animation timer into fireball throw timer
       ldy #$07                      ;load offset for throwing
       lda PlayerGfxTblOffsets,y     ;get offset to graphics table
       sta PlayerGfxOffset           ;store it for use later
       ldy #$04                      ;set to update four sprite rows by default
       lda Player_X_Speed
       ora Left_Right_Buttons        ;check for horizontal speed or left/right button press
       beq SUpdR                     ;if no speed or button press, branch using set value in Y
       dey                           ;otherwise set to update only three sprite rows
SUpdR: tya                           ;save in A for use
       jsr RenderPlayerSub           ;in sub, draw player object again

PlayerOffscreenChk:
           lda Player_OffscreenBits      ;get player's offscreen bits
           lsr
           lsr                           ;move vertical bits to low nybble
           lsr
           lsr
           sta $00                       ;store here
           ldx #$03                      ;check all four rows of player sprites
           lda Player_SprDataOffset      ;get player's sprite data offset
           clc
           adc #$18                      ;add 24 bytes to start at bottom row
           tay                           ;set as offset here
PROfsLoop: lda #$f8                      ;load offscreen Y coordinate just in case
           lsr $00                       ;shift bit into carry
           bcc NPROffscr                 ;if bit not set, skip, do not move sprites
           jsr DumpTwoSpr                ;otherwise dump offscreen Y coordinate into sprite data
NPROffscr: tya
           sec                           ;subtract eight bytes to do
           sbc #$08                      ;next row up
           tay
           dex                           ;decrement row counter
           bpl PROfsLoop                 ;do this until all sprite rows are checked
           rts                           ;then we are done!

;-------------------------------------------------------------------------------------

IntermediatePlayerData:
        .byte $58, $01, $00, $60, $ff, $04

DrawPlayer_Intermediate:
          ldx #$05                       ;store data into zero page memory
PIntLoop: lda IntermediatePlayerData,x   ;load data to display player as he always
          sta $02,x                      ;appears on world/lives display
          dex
          bpl PIntLoop                   ;do this until all data is loaded
          ldx #$b8                       ;load offset for small standing
          ldy #$04                       ;load sprite data offset
          jsr DrawPlayerLoop             ;draw player accordingly
          lda Sprite_Attributes+36       ;get empty sprite attributes
          ora #%01000000                 ;set horizontal flip bit for bottom-right sprite
          sta Sprite_Attributes+32       ;store and leave
          rts

;-------------------------------------------------------------------------------------
switchBNK:
		stx temp
		tax
		lda #%00000110
		sta MMC3_BANK_SELECT
		stx MMC3_BANK_DATA
		lda #%00000111
		sta MMC3_BANK_SELECT
		inx
		stx MMC3_BANK_DATA
		ldx temp
		rts