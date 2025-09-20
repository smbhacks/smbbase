;to be implemented
GetAreaPointerFromWorld:
    rts

SwitchToEnemyLvlBank:
    lda entityBnk
    jmp switchBNK_save

LoadAreaPointer:
    rts

.proc AreaParserCore
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
    sta $03
    lda MetatileBuffer,x
    bne BgAlreadyThere
    lda $03
    sta MetatileBuffer,x
    sta ($06),y
BgAlreadyThere:
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
    ;ldy AreaPointer
    ldy #0
    lda LevelFgPtrsLo,y
    sta hm_node
    lda LevelFgPtrsHi,y
    sta hm_node+1
    lda LevelAreaTypes,y
    sta AreaType
    lda LevelPlayerXs,y
    sta Player_X_Position
    lda LevelPlayerYs,y
    sta Player_Y_Position
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
    ;ldy AreaPointer
    ldy #0
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

