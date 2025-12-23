SwitchToEnemyLvlBank:
SwitchToLvlBank:
    lda #<.bank(LevelData)
    jmp switchBNK

LoadAreaPointer:
    jsr FindAreaPointer  ;find it and store it here
    sta AreaPointer
GetAreaType: 
    and #%01100000       ;mask out all but d6 and d5
    asl
    rol
    rol
    rol                  ;make %0xx00000 into %000000xx
    sta AreaType         ;save 2 MSB as area type
    rts

FindAreaPointer:
    jsr SwitchToLvlBank
    ldy WorldNumber        ;load offset from world variable
    lda WorldAddrOffsets,y
    clc                    ;add area number used to find data
    adc AreaNumber
    tay
    lda AreaAddrOffsets,y  ;from there we have our area pointer
	Switch_Bank #0
    rts

GetAreaDataAddrs:
    jsr SwitchToLvlBank
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
StoreFore:  
    sta ForegroundScenery    ;if less, save value here as foreground scenery
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
StoreStyle: 
    sta AreaStyle
    lda AreaDataLow          ;increment area data address by 2 bytes
    clc
    adc #$02
    sta AreaDataLow
    lda AreaDataHigh
    adc #$00
    sta AreaDataHigh
    Switch_Bank #0
    rts

GetAreaPointerFromWorld:
    ldx WorldAddrOffsets,y    ;get offset to where this world's area offsets are
    lda AreaAddrOffsets,x     ;get area offset based on world offset
    sta AreaPointer           ;store area offset here to be used to change areas
    rts

GetHalfwayPageNumber:
    jsr SwitchToLvlBank
    ldy HalfwayPageNybbles,x
    Switch_Bank #0
    rts

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
Alter2:  
    pla
    and #%00000111            ;mask out all but 3 LSB
    cmp #$04                  ;if four or greater, set color control bits
    bcc SetFore               ;and nullify foreground scenery bits
    sta BackgroundColorCtrl
    lda #$00
SetFore: 
    sta ForegroundScenery     ;otherwise set new foreground scenery bits
    rts

ProcessAreaData_:
    jsr SwitchToLvlBank
    jsr ProcessAreaData
    Switch_Bank #0
    rts

ProcessAreaData:
    ldx #$02                 ;start at the end of area object buffer
ProcADLoop: 
    stx ObjectOffset
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
Chk1Row13:  
    dey
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
Chk1Row14:  
    cmp #$0e                 ;row 14?
    bne CheckRear
    lda BackloadingFlag      ;check flag for saved page number and branch if set
    bne RdyDecode            ;to render the object (otherwise bg might not look right)
CheckRear:  
    lda AreaObjectPageLoc    ;check to see if current page of level object is
    cmp CurrentPageLoc       ;behind current page of renderer
    bcc SetBehind            ;if so branch
RdyDecode:  
    jsr DecodeAreaData       ;do sub and do not turn on flag
    jmp ChkLength
SetBehind:  
    inc BehindAreaParserFlag ;turn on flag if object is behind renderer
NextAObj:   
    jsr IncAreaObjOffset     ;increment buffer offset and move on
ChkLength:  
    ldx ObjectOffset         ;get buffer offset
    lda AreaObjectLength,x   ;check object length for anything stored here
    bmi ProcLoopb            ;if not, branch to handle loopback
    dec AreaObjectLength,x   ;otherwise decrement length or get rid of it
ProcLoopb:  
    dex                      ;decrement buffer offset
    bpl ProcADLoop           ;and loopback unless exceeded buffer
    lda BehindAreaParserFlag ;check for flag set if objects were behind renderer
    bne ProcessAreaData      ;branch if true to load more level data, otherwise
    lda BackloadingFlag      ;check for flag set if starting right of page $00
    bne ProcessAreaData      ;branch if true to load more level data, otherwise leave
EndAParse:  
    rts

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
Chk1stB:  
    ldx #$10                   ;load offset of 16 for special row 15
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
ChkRow14: 
    stx $07                    ;store whatever value we just loaded here
    ldx ObjectOffset           ;get object offset again
    cmp #$0e                   ;row 14?
    bne ChkRow13
    lda #$00                   ;if so, load offset with $00
    sta $07
    lda #$2e                   ;and load A with another value
    bne NormObj                ;unconditional branch
ChkRow13: 
    cmp #$0d                   ;row 13?
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
Mask2MSB: 
    and #%00111111             ;mask out d7 and d6
    jmp NormObj                ;and jump
ChkSRows: 
    cmp #$0c                   ;row 12-15?
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
LrgObj:   
    sta $00                    ;store value here (branch for large objects)
    cmp #$70                   ;check for vertical pipe object
    bne NotWPipe
    lda (AreaData),y           ;if not, reload second byte
    and #%00001000             ;mask out all but d3 (usage control bit)
    beq NotWPipe               ;if d3 clear, branch to get original value
    lda #$00                   ;otherwise, nullify value for warp pipe
    sta $00
NotWPipe: 
    lda $00                    ;get value and jump ahead
    jmp MoveAOId
SpecObj:  
    iny                        ;branch here for rows 12-15
    lda (AreaData),y
    and #%01110000             ;get next byte and mask out all but d6-d4
MoveAOId: 
    lsr                        ;move d6-d4 to lower nybble
    lsr
    lsr
    lsr
NormObj:  
    sta $00                    ;store value here (branch for small objects and rows 13 and 14)
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
LeavePar: 
    rts
InitRear: 
    lda BackloadingFlag        ;check backloading flag to see if it's been initialized
    beq BackColC               ;branch to column-wise check
    lda #$00                   ;if not, initialize both backloading and
    sta BackloadingFlag        ;behind-renderer flags and leave
    sta BehindAreaParserFlag
    sta ObjectOffset
LoopCmdE: 
    rts
BackColC: 
    ldy AreaDataOffset         ;get first byte again
    lda (AreaData),y
    and #%11110000             ;mask out low nybble and move high to low
    lsr
    lsr
    lsr
    lsr
    cmp CurrentColumnPos       ;is this where we're at?
    bne LeavePar               ;if not, branch to leave
StrAObj:  
    lda AreaDataOffset         ;if so, load area obj offset and store in buffer
    sta AreaObjOffsetBuffer,x
    jsr IncAreaObjOffset       ;do sub to increment to next object data
RunAObj:  
    lda $00                    ;get stored value and add offset to it
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

ScrollLockObject_Warp:
    ldx #$04            ;load value of 4 for game text routine as default
    lda WorldNumber     ;warp zone (4-3-2), then check world number
    beq WarpNum
    inx                 ;if world number > 1, increment for next warp zone (5)
    ldy AreaType        ;check area type
    dey
    bne WarpNum         ;if ground area type, increment for last warp zone
    inx                 ;(8-7-6) and move on
WarpNum: 
    txa
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
    lda #MT_TREE_LEDGE_LEFT_EDGE ;render start of tree ledge
    jmp NoUnder
MidTreeL: 
    ldx $07
    lda #MT_TREE_LEDGE_MIDDLE ;render middle of tree ledge
    sta MetatileBuffer,x    ;note that this is also used if ledge position is
    lda #MT_GREEN_LEDGE_STUMP ;at the start of level for continuous effect
    jmp AllUnder            ;now render the part underneath
EndTreeL: 
    lda #MT_TREE_LEDGE_RIGHT_EDGE ;render end of tree ledge
    jmp NoUnder

MushroomLedge:
    jsr ChkLrgObjLength        ;get shroom dimensions
    sty $06                    ;store length here for now
    bcc EndMushL
    lda AreaObjectLength,x     ;divide length by 2 and store elsewhere
    lsr
    sta MushroomLedgeHalfLen,x
    lda #MT_MUSHROOM_LEFT_EDGE ;render start of mushroom
    jmp NoUnder
EndMushL: 
    lda #MT_MUSHROOM_RIGHT_EDGE ;if at the end, render end of mushroom
    ldy AreaObjectLength,x
    beq NoUnder
    lda MushroomLedgeHalfLen,x ;get divided length and store where length
    sta $06                    ;was stored originally
    ldx $07
    lda #MT_MUSHROOM_MIDDLE
    sta MetatileBuffer,x       ;render middle of mushroom
    cpy $06                    ;are we smack dab in the center?
    bne MushLExit              ;if not, branch to leave
    inx
    lda #MT_MUSHROOM_STUMP_TOP
    sta MetatileBuffer,x       ;render stem top of mushroom underneath the middle
    lda #MT_MUSHROOM_STUMP_BOTTOM
AllUnder: 
    inx
    ldy #$0f                   ;set $0f to render all way down
    jmp RenderUnderPart       ;now render the stem of mushroom
NoUnder:  
    ldx $07                    ;load row of ledge
    ldy #$00                   ;set 0 for no bottom on this part
    jmp RenderUnderPart

;--------------------------------

;tiles used by pulleys and rope object
PulleyRopeMetatiles:
    .byte MT_LEFT_PULLEY, MT_HORIZONTAL_ROPE, MT_RIGHT_PULLEY

PulleyRopeObject:
    jsr ChkLrgObjLength       ;get length of pulley/rope object
    ldy #$00                  ;initialize metatile offset
    bcs RenderPul             ;if starting, render left pulley
    iny
    lda AreaObjectLength,x    ;if not at the end, render rope
    bne RenderPul
    iny                       ;otherwise render right pulley
RenderPul: 
    lda PulleyRopeMetatiles,y
    sta MetatileBuffer        ;render at the top of the screen
MushLExit: 
    rts                       ;and leave

;--------------------------------
;$06 - used to store upper limit of rows for CastleObject

CastleMetatiles:
.byte MT_BLANK,                 MT_CASTLE_TOP,            MT_CASTLE_TOP,            MT_CASTLE_TOP,            MT_BLANK                  ; www
.byte MT_BLANK,                 MT_CASTLE_WINDOW_RIGHT,   MT_CASTLE_BRICK_WALL,     MT_CASTLE_WINDOW_LEFT,    MT_BLANK                  ; [#]
.byte MT_CASTLE_TOP,            MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP             ;wWWWw
.byte MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL      ;##^##
.byte MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL      ;##U##
.byte MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK  ;WWWWW
.byte MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL      ;#^#^#
.byte MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL      ;#U#U#
.byte MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL      ;#####
.byte MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP           ;^#^#^
.byte MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM        ;U#U#U

;mtile that is placed at the door (so that mario stops moving after clearing the level)
ReplacedCastleMTile = MT_BREAKABLE_BRICK

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
CRendLoop:  
    lda CastleMetatiles,y    ;load current byte using offset
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
ChkCFloor:  
    cpx #$0b                 ;have we reached the row just before floor?
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
NotTall:    
    cmp #$02                 ;if not tall castle, check to see if we're at the third column
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
PlayerStop: 
    ldy #ReplacedCastleMTile ;put brick at floor to stop player at end of level
    sty MetatileBuffer+10    ;this is only done if we're on the second column
ExitCastle: 
    rts

;--------------------------------

WaterPipe:
    jsr GetLrgObjAttrib     ;get row and lower nybble
    ldx $07                 ;get row
    lda #MT_WATER_PIPE_TOP
    sta MetatileBuffer,x    ;draw something here and below it
    lda #MT_WATER_PIPE_BOTTOM
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
VPipeSectLoop: 
    lda #$00                 ;all the way to the top of the screen
    sta MetatileBuffer,x     ;because otherwise it will look like exit pipe
    dex
    bpl VPipeSectLoop
    lda VerticalPipeData,y   ;draw the end of the vertical pipe part
    sta MetatileBuffer+7
NoBlankP:      
    rts

SidePipeShaftData:
    .byte MT_PIPE_SHAFT_RIGHT, MT_PIPE_SHAFT_LEFT  ;used to control whether or not vertical pipe shaft
    .byte MT_BLANK, MT_BLANK  ;is drawn, and if so, controls the metatile number
SidePipeTopPart:
    .byte MT_PIPE_SHAFT_RIGHT, MT_SIDEWAYS_PIPE_JOINT_TOP  ;top part of sideways part of pipe
    .byte MT_SIDEWAYS_PIPE_SHAFT_TOP, MT_SIDEWAYS_PIPE_END_TOP
SidePipeBottomPart: 
    .byte MT_PIPE_SHAFT_RIGHT, MT_SIDEWAYS_PIPE_JOINT_BOTTOM  ;bottom part of sideways part of pipe
    .byte MT_SIDEWAYS_PIPE_SHAFT_BOTTOM, MT_SIDEWAYS_PIPE_END_BOTTOM

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
DrawSidePart: 
    ldy $06                   ;render side pipe part at the bottom
    lda SidePipeTopPart,y
    sta MetatileBuffer,x      ;note that the pipe parts are stored
    lda SidePipeBottomPart,y  ;backwards horizontally
    sta MetatileBuffer+1,x
    rts

VerticalPipeData:
    .byte MT_WARP_PIPE_END_RIGHT_AND_POINTS_UP, MT_WARP_PIPE_END_LEFT_AND_POINTS_UP ;used by pipes that lead somewhere
    .byte MT_PIPE_SHAFT_RIGHT, MT_PIPE_SHAFT_LEFT
    .byte MT_DECORATION_PIPE_END_RIGHT_AND_POINTS_UP, MT_DECORATION_PIPE_END_LEFT_AND_POINTS_UP ;used by decoration pipes
    .byte MT_PIPE_SHAFT_RIGHT, MT_PIPE_SHAFT_LEFT

VerticalPipe:
    jsr GetPipeHeight
    lda $00                  ;check to see if value was nullified earlier
    beq WarpPipe             ;(if d3, the usage control bit of second byte, was set)
    iny
    iny
    iny
    iny                      ;add four if usage control bit was not set
WarpPipe: 
    tya                      ;save value in stack
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
DrawPipe: 
    pla                      ;get value saved earlier and use as Y
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

Hole_Water:
    jsr ChkLrgObjLength   ;get low nybble and save as length
    lda #MT_WATER_OR_LAVA_TOP ;render waves
    sta MetatileBuffer+10
    ldx #$0b
    ldy #$01              ;now render the water underneath
    lda #MT_WATER_OR_LAVA
    jmp RenderUnderPart

QuestionBlockRow_High:
    lda #$03    ;start on the fourth row
    .byte $2c   ;skip lda #$07 after this

QuestionBlockRow_Low:
    lda #$07             ;start on the eighth row
    pha                  ;save whatever row to the stack for now
    jsr ChkLrgObjLength  ;get low nybble and save as length
    pla
    tax                  ;render question boxes with coins
    lda #MT_QUESTION_BLOCK_COIN
    sta MetatileBuffer,x
    rts

Bridge_High:
    lda #$06  ;start on the seventh row from top of screen
    .byte $2c ;skip lda #$07 after this

Bridge_Middle:
    lda #$07  ;start on the eighth row
    .byte $2c   ;skip lda #$09 after this

Bridge_Low:
    lda #$09             ;start on the tenth row
    pha                  ;save whatever row to the stack for now
    jsr ChkLrgObjLength  ;get low nybble and save as length
    pla
    tax                  ;render bridge railing
    lda #MT_BRIDGE_GUARDRAIL
    sta MetatileBuffer,x
    inx
    ldy #$00             ;now render the bridge itself
    lda #MT_BRIDGE
    jmp RenderUnderPart

FlagBalls_Residual:
    jsr GetLrgObjAttrib  ;get low nybble from object byte
    ldx #$02             ;render flag balls on third row from top
    lda #$6d             ;of screen downwards based on low nybble
    jmp RenderUnderPart

FlagpoleObject:
    lda #MT_FLAGPOLE_BALL    ;render flagpole ball on top
    sta MetatileBuffer
    ldx #$01                 ;now render the flagpole shaft
    ldy #$08
    lda #MT_FLAGPOLE_SHAFT
    jsr RenderUnderPart
    lda #MT_SOLID_BLOCK_3D_BLOCK ;render solid block at the bottom
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

EndlessRope:
    ldx #$00       ;render rope from the top to the bottom of screen
    ldy #$0f
    jmp DrawRope

BalancePlatRope:
    txa                 ;save object buffer offset for now
    pha
    ldx #$01            ;blank out all from second row to the bottom
    ldy #$0f            ;with blank used for balance platform rope
    lda #MT_BLANK_USED_FOR_BALANCE_ROPE
    jsr RenderUnderPart
    pla                 ;get back object buffer offset
    tax
    jsr GetLrgObjAttrib ;get vertical length from lower nybble
    ldx #$01
DrawRope: 
    lda #MT_VERTICAL_ROPE ;render the actual rope
    jmp RenderUnderPart

CoinMetatileData:
    .byte MT_UNDERWATER_COIN ;water
    .byte MT_COIN ;ground
    .byte MT_COIN ;underground
    .byte MT_COIN ;castle

RowOfCoins:
    ldy AreaType            ;get area type
    lda CoinMetatileData,y  ;load appropriate coin metatile
    jmp GetRow

C_ObjectRow:
    .byte $06, $07, $08

C_ObjectMetatile:
    .byte MT_AXE, MT_CHAIN, MT_BOWSERS_BRIDGE

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
    lda #MT_EMPTY_BLOCK
ColObj: 
    ldy #$00             ;column length of 1
    jmp RenderUnderPart

SolidBlockMetatiles:
    .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK ;water
    .byte MT_SOLID_BLOCK_3D_BLOCK ;ground
    .byte MT_SOLID_BLOCK_3D_BLOCK ;underground
    .byte MT_SOLID_BLOCK_WHITE_WALL ;castle

BrickMetatiles:
    .byte MT_SEAPLANT ;water
    .byte MT_BREAKABLE_BRICK_WITH_LINE ;ground
    .byte MT_BREAKABLE_BRICK ;underground
    .byte MT_BREAKABLE_BRICK ;castle

BrickMetatileForRow = * - BrickMetatiles
    .byte MT_CLOUD_LEVEL_TERRAIN

RowOfBricks:
    ldy AreaType           ;load area type obtained from area offset pointer
    lda CloudTypeOverride  ;check for cloud type override
    beq DrawBricks
    ldy #BrickMetatileForRow ;if cloud type, override area type
DrawBricks: 
    lda BrickMetatiles,y   ;get appropriate metatile
    jmp GetRow             ;and go render it

RowOfSolidBlocks:
    ldy AreaType               ;load area type obtained from area offset pointer
    lda SolidBlockMetatiles,y  ;get metatile
GetRow:  
    pha                        ;store metatile here
    jsr ChkLrgObjLength        ;get row number, load length
DrawRow: 
    ldx $07
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
GetRow2: 
    pha                        ;save metatile to stack for now
    jsr GetLrgObjAttrib        ;get length and row
    pla                        ;restore metatile
    ldx $07                    ;get starting row
    jmp RenderUnderPart        ;now render the column

BulletBillCannon:
    jsr GetLrgObjAttrib      ;get row and length of bullet bill cannon
    ldx $07                  ;start at first row
    lda #MT_BULLET_BILL_CANNON_BARREL ;render bullet bill cannon
    sta MetatileBuffer,x
    inx
    dey                      ;done yet?
    bmi SetupCannon
    lda #MT_BULLET_BILL_CANNON_TOP ;if not, render middle part
    sta MetatileBuffer,x
    inx
    dey                      ;done yet?
    bmi SetupCannon
    lda #MT_BULLET_BILL_CANNON_BOTTOM ;if not, render bottom until length expires
    jsr RenderUnderPart
SetupCannon: 
    ldx Cannon_Offset        ;get offset for data used by cannons and whirlpools
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
StrCOffset:  
    stx Cannon_Offset        ;save new offset and leave
    rts

StaircaseHeightData:
    .byte $07, $07, $06, $05, $04, $03, $02, $01, $00

StaircaseRowData:
    .byte $03, $03, $04, $05, $06, $07, $08, $09, $0a

StaircaseObject:
    jsr ChkLrgObjLength       ;check and load length
    bcc NextStair             ;if length already loaded, skip init part
    lda #$09                  ;start past the end for the bottom
    sta StaircaseControl      ;of the staircase
NextStair: 
    dec StaircaseControl      ;move onto next step (or first if starting)
    ldy StaircaseControl
    ldx StaircaseRowData,y    ;get starting row and height to render
    lda StaircaseHeightData,y
    tay
    lda #MT_SOLID_BLOCK_3D_BLOCK ;now render solid block staircase
    jmp RenderUnderPart

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
    lda #MT_BLANK_USED_FOR_JUMPSPRING ;draw metatiles in two rows where jumpspring is
    sta MetatileBuffer,x
    lda #MT_HALF_BRICK_USED_FOR_JUMPSPRING
    sta MetatileBuffer+1,x
    rts

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
    lda #NumOfUniqBricks        ;otherwise use adder for bricks without lines
BWithL:   
    clc                         ;add object ID to adder
    adc $07
    tay                         ;use as offset for metatile
DrawQBlk: 
    lda BrickQBlockMetatiles,y  ;get appropriate metatile for brick (question block
    pha                         ;if branched to here from question block routine)
    jsr GetLrgObjAttrib         ;get row from location byte
    jmp DrawRow                 ;now render the object

GetAreaObjectID:
    lda $00    ;get value saved from area parser routine
    sec
    sbc #$00   ;possibly residual code
    tay        ;save to Y
ExitDecBlock: 
    rts

HoleMetatiles:
    .byte MT_WATER_OR_LAVA ;water
    .byte MT_BLANK ;ground
    .byte MT_BLANK ;underground
    .byte MT_BLANK ;castle

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
StrWOffset: 
    stx Whirlpool_Offset         ;save new offset here
NoWhirlP:   
    ldx AreaType                 ;get appropriate metatile, then
    lda HoleMetatiles,x          ;render the hole proper
    ldx #$08
    ldy #$0f                     ;start at ninth row and go to bottom, run RenderUnderPart
RenderUnderPart:
    sty AreaObjectHeight  ;store vertical length to render
    ldy MetatileBuffer,x  ;check current spot to see if there's something
    beq DrawThisRow       ;we need to keep, if nothing, go ahead
    cpy #MT_TREE_LEDGE_MIDDLE
    beq WaitOneRow        ;if middle part (tree ledge), wait until next row
    cpy #MT_MUSHROOM_MIDDLE
    beq WaitOneRow        ;if middle part (mushroom ledge), wait until next row
    cpy #MT_QUESTION_BLOCK_COIN
    beq DrawThisRow       ;if question block w/ coin, overwrite

    ;TODO: this needs to be optimized in the future
    ;(originally the code checked for palette 3 metatiles here)
    cpy #MT_QUESTION_BLOCK_POWER_UP
    beq WaitOneRow
    cpy #MT_COIN
    beq WaitOneRow
    cpy #MT_UNDERWATER_COIN
    beq WaitOneRow
    cpy #MT_EMPTY_BLOCK
    beq WaitOneRow
    cpy #MT_AXE
    beq WaitOneRow

    cpy #MT_CRACKED_ROCK_TERRAIN
    bne DrawThisRow       ;if cracked rock terrain, overwrite
    cmp #MT_MUSHROOM_STUMP_BOTTOM
    beq WaitOneRow        ;if stem bottom of mushroom, wait until next row
DrawThisRow: 
    sta MetatileBuffer,x  ;render contents of A from routine that called this
WaitOneRow:  
    inx
    cpx #$0d              ;stop rendering if we're at the bottom of the screen
    bcs ExitUPartR
    ldy AreaObjectHeight  ;decrement, and stop rendering if there is no more length
    dey
    bpl RenderUnderPart
ExitUPartR:  
    rts

ChkLrgObjLength:
    jsr GetLrgObjAttrib     ;get row location and size (length if branched to from here)

ChkLrgObjFixedLength:
    lda AreaObjectLength,x  ;check for set length counter
    clc                     ;clear carry flag for not just starting
    bpl LenSet              ;if counter not set, load it, otherwise leave alone
    tya                     ;save length into length counter
    sta AreaObjectLength,x
    sec                     ;set carry flag if just starting
LenSet: 
    rts

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

GetAreaObjXPosition:
    lda CurrentColumnPos    ;multiply current offset where we're at by 16
    asl                     ;to obtain horizontal pixel coordinate
    asl
    asl
    asl
    rts

GetAreaObjYPosition:
    lda $07  ;multiply value by 16
    asl
    asl      ;this will give us the proper vertical pixel coordinate
    asl
    asl
    clc
    adc #32  ;add 32 pixels for the status bar
    rts

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
