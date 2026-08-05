;to be implemented
GetAreaPointerFromWorld:
    rts

SwitchToEnemyLvlBank:
    lda entityBnk
    jmp switchBNK_save

LoadAreaPointer:
    lda AreaNumber
    sta AreaPointer
    rts

.proc AreaParserCore
;deal with backloading flag (skipping to entrance page)
    lda BackloadingFlag
    beq ParseOneColumn
    sta $05
ParseOnePage:
    lda #16
    sta $04
ParseLoop:
    jsr ParseOneColumn
    dec $04
    bne ParseLoop    
    dec $05
    bne ParseOnePage
    lda #0
    sta BackloadingFlag
;parse next column
ParseOneColumn:
	lda	BlockBufferColumnPos
    jsr GetBlockBufferAddr

    ;Handle background data
    lda bgBnk
    jsr switchBNK_save_fast
    lda #13
    sta $00
    ldy #BACKGROUND_HM_WRAM_OFFS
    jsr LoadHuffmunchState
    ldx #0 ;start at top row
BgLoop:
    stx $01 ;unclobber 
    jsr huffmunch_read
    ldx $01 ;unclobber 
    sta MetatileBuffer,x ;ONLY draw it
    inx
    dec $00 ;do 13 times
    bne BgLoop
    ldy #BACKGROUND_HM_WRAM_OFFS
    jsr SaveHuffmunchState

    ;Handle foreground data
    lda fgBnk
    jsr switchBNK_save_fast
    lda #13
    sta $00
    ldy #FOREGROUND_HM_WRAM_OFFS
    jsr LoadHuffmunchState
    ldy #0 ;start at top row
    ldx #0 ;for MetatileBuffer
FgLoop:
    sty $01 ;unclobber 
    stx $02
    jsr huffmunch_read
    ldy $01 ;unclobber 
    ldx $02
    cmp #0  ;if no foreground tile, then draw bg
    beq SetInBBuf
    sta MetatileBuffer,x
SetInBBuf:
    sta ($06),y
    tya
    clc
    adc #$10 ;next row
    tay
    inx
    dec $00 ;do 13 times
    bne FgLoop
    ldy #FOREGROUND_HM_WRAM_OFFS
    jsr SaveHuffmunchState

    lda #0
    jmp switchBNK_save_fast
.endproc

.proc GetAreaDataAddrs
    lda #0
    sta EnemyDataOffset
    ;Load foreground huffmunch state
    ldy AreaPointer
    ;ldy #0
    lda LevelFgPtrsLo,y
    sta hm_node
    lda LevelFgPtrsHi,y
    sta hm_node+1
    lda LevelAreaTypes,y
    sta AreaType
    lda AltEntranceControl
    beq LoadPosFromLut
LoadPosFromPipePointer:
    lda entranceX
    sta Player_X_Position
    lda entranceY
    sta Player_Y_Position
    jmp PlayerPositionLoaded
LoadPosFromLut:
    lda LevelPlayerXs,y
    sta Player_X_Position
    lda LevelPlayerYs,y
    sta Player_Y_Position
PlayerPositionLoaded:
    lda LevelEntityBanks,y
    sta entityBnk
    lda LevelEntityPtrsLo,y
    sta EnemyDataLow
    lda LevelEntityPtrsHi,y
    sta EnemyDataHigh
    lda LevelFgBanks,y
    sta fgBnk
    jsr switchBNK_save_fast
    lda LevelTimersLo,y
    sta bcdNum
    lda LevelTimersHi,y
    sta bcdNum+1
    jsr bcdConvert
    lda bcdResult+2
    sta GameTimerDisplay+0
    lda bcdResult+1
    sta GameTimerDisplay+1
    lda bcdResult+0
    sta GameTimerDisplay+2
    ldy #0
    ldx #0
    stx Player_SprAttrib
    jsr huffmunch_load
    stx foreground_bytesLeft
    sty foreground_bytesLeft+1
    ldy #FOREGROUND_HM_WRAM_OFFS
    jsr SaveHuffmunchState
    ;Load background huffmunch state
    ldy AreaPointer
    ;ldy #0
    lda LevelBgPtrsLo,y
    sta hm_node
    lda LevelBgPtrsHi,y
    sta hm_node+1
    lda LevelBgBanks,y
    sta bgBnk
    jsr switchBNK_save_fast
    ldy #0
    ldx #0
    jsr huffmunch_load
    stx background_bytesLeft
    sty background_bytesLeft+1   
    ldy #BACKGROUND_HM_WRAM_OFFS
    jsr SaveHuffmunchState
Done:
    lda #0
    jmp switchBNK_save_fast
.endproc

.proc SaveHuffmunchState
    ldx #0
Loop:
    lda hm_values_zp,x
    sta hm_values_wram,y
    iny
    inx
    cpx #9
    bcc Loop
    rts
.endproc

.proc LoadHuffmunchState
    ldx #0
Loop:
    lda hm_values_wram,y
    sta hm_values_zp,x
    iny
    inx
    cpx #9
    bcc Loop
    rts
.endproc

;Enemy format is in convert_tiled_levels.py
ProcessEnemyData:
        ldy EnemyDataOffset      ;get offset of enemy object data
        lda (EnemyData),y        ;load first byte
        cmp #$ff                 ;check for EOD terminator
        bne CheckRightBounds
        jmp CheckFrenzyBuffer    ;if found, jump to check frenzy buffer, otherwise

;CheckEndofBuffer:
;        and #%00001111           ;check for special row $0e
;        cmp #$0e
;        beq CheckRightBounds     ;if found, branch, otherwise
;        cpx #$05                 ;check for end of buffer         !!!!!!!!!!!! 
;        bcc CheckRightBounds     ;if not at end of buffer, branch !!!!!!!!!!!!
;        rts                      ;the sixth slot

CheckRightBounds:
        lda ScreenRight_X_Pos    ;add 48 to pixel coordinate of right boundary
        clc
        adc #$30
        and #%11110000           ;store high nybble
        sta $07
        lda ScreenRight_PageLoc  ;add carry to page location of right boundary
        adc #$00
        sta $06                  ;store page location + carry
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
        iny
        lda (EnemyData),y
        and #%01110000
        lsr
        lsr
        lsr
        clc 
        adc Enemy_X_Position,x
        sta Enemy_X_Position,x
        dey
        cmp ScreenRight_X_Pos    ;check column position against right boundary
        lda Enemy_PageLoc,x      ;without subtracting, then subtract borrow
        sbc ScreenRight_PageLoc  ;from page location
        bcs CheckRightExtBounds  ;if enemy object beyond or at boundary, branch
        lda (EnemyData),y
        and #%00001111           ;check for special row $0e
        cmp #$0e                 ;if found, jump elsewhere
        beq ParseRow0e
        jmp Inc3B                ;if not found, unconditional jump

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
        and #%00001110
        clc
        adc Enemy_Y_Position,x
        sta Enemy_Y_Position,x
        iny
        lda (EnemyData),y
        sta Enemy_ID,x       ;store enemy object number into buffer
        lda #$01
        sta Enemy_Flag,x     ;set flag for enemy in buffer
        jsr InitEnemyObject
        jmp Inc3B

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

ParseRow0e:
        iny
        lda (EnemyData),y        ;otherwise, get second byte and use as offset
        and #$7f
        sta AreaPointer          ;to addresses for level and enemy object data
        iny
        lda (EnemyData),y        ;get third byte again, and this time mask out
        and #%00111111           ;the 3 MSB from before, save as page number to be
        sta EntrancePage         ;used upon entry to area, if area is entered
        iny
        lda (EnemyData),y        ;get fourth byte
        asl
        asl
        asl
        asl
        sta entranceY
        lda (EnemyData),y
        and #%11110000
        sta entranceX        
NotUse: jmp Inc4B

Inc4B:
        inc EnemyDataOffset      
Inc3B:  
        inc EnemyDataOffset      
        inc EnemyDataOffset      
        inc EnemyDataOffset
        jsr CheckEnemyDataOffset
        lda #$00                 ;init page select for enemy objects
        sta EnemyObjectPageSel
        ldx ObjectOffset         ;reload current offset in enemy buffers
        rts                      ;and leave

.proc CheckEnemyDataOffset
    lda EnemyDataOffset
    cmp #$40
    bcc Done
    clc
    adc EnemyDataLow
    sta EnemyDataLow
    lda #0
    sta EnemyDataOffset
    bcc Done
    inc EnemyDataHigh
Done:
    rts
.endproc

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
      .word FlagpoleInit
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

;for the time being, ill just copy
;the flagpole object into slot 5, and free up the original slot
;there's a better probably approach that can be implemented later
FlagpoleInit:
    lda #FlagpoleFlagObject
    sta Enemy_ID+5
    sta Enemy_Flag+5
    lda Enemy_X_Position,x
    sta Enemy_X_Position+5
    lda Enemy_Y_Position,x
    clc
    adc #8
    sta Enemy_Y_Position+5
    lda Enemy_PageLoc,x
    sta Enemy_PageLoc+5
    lda #0
    sta Enemy_Flag,x
    ;set initial vertical coordinate for flagpole's floatey number
    lda #$b0
    sta FlagpoleFNum_Y_Pos    
    ;initialize castle star flag entity
    txa
    tay
    jsr FindEmptyEnemySlot   ;find an empty place on the enemy object buffer
    lda Enemy_X_Position,y
    clc 
    adc #6*16+8
    sta Enemy_X_Position,x
    lda Enemy_PageLoc,y
    adc #0
    sta Enemy_PageLoc,x
    lda #$01
    sta Enemy_Y_HighPos,x    ;set vertical high byte
    sta Enemy_Flag,x         ;set flag for buffer
    lda #$90
    sta Enemy_Y_Position,x   ;set vertical coordinate
    lda #StarFlagObject      ;set star flag value in buffer itself
    sta Enemy_ID,x 
    rts