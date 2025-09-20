BSceneDataOffsets:
    .byte $00, $30, $60

BackSceneryData:
    .byte $93, $00, $00, $11, $12, $12, $13, $00 ;clouds
    .byte $00, $51, $52, $53, $00, $00, $00, $00
    .byte $00, $00, $01, $02, $02, $03, $00, $00
    .byte $00, $00, $00, $00, $91, $92, $93, $00
    .byte $00, $00, $00, $51, $52, $53, $41, $42
    .byte $43, $00, $00, $00, $00, $00, $91, $92

    .byte $97, $87, $88, $89, $99, $00, $00, $00 ;mountains and bushes
    .byte $11, $12, $13, $a4, $a5, $a5, $a5, $a6
    .byte $97, $98, $99, $01, $02, $03, $00, $a4
    .byte $a5, $a6, $00, $11, $12, $12, $12, $13
    .byte $00, $00, $00, $00, $01, $02, $02, $03
    .byte $00, $a4, $a5, $a5, $a6, $00, $00, $00

    .byte $11, $12, $12, $13, $00, $00, $00, $00 ;trees and fences
    .byte $00, $00, $00, $9c, $00, $8b, $aa, $aa
    .byte $aa, $aa, $11, $12, $13, $8b, $00, $9c
    .byte $9c, $00, $00, $01, $02, $03, $11, $12
    .byte $12, $13, $00, $00, $00, $00, $aa, $aa
    .byte $9c, $aa, $00, $8b, $00, $01, $02, $03

BackSceneryMetatiles:
    .byte MT_CLOUD_LEFT, MT_CLOUD_BOTTOM_LEFT, $00 ;cloud left
    .byte MT_CLOUD_MIDDLE, MT_CLOUD_BOTTOM_MIDDLE, $00 ;cloud middle
    .byte MT_CLOUD_RIGHT, MT_CLOUD_BOTTOM_RIGHT, $00 ;cloud right
    .byte MT_BUSH_LEFT, $00, $00 ;bush left
    .byte MT_BUSH_MIDDLE, $00, $00 ;bush middle
    .byte MT_BUSH_RIGHT, $00, $00 ;bush right
    .byte $00, MT_MOUNTAIN_LEFT, MT_MOUNTAIN_LEFT_BOTTOM_MIDDLE_CENTER ;mountain left
    .byte MT_MOUNTAIN_MIDDLE_TOP, MT_MOUNTAIN_LEFT_BOTTOM_MIDDLE_CENTER, MT_MOUNTAIN_MIDDLE_BOTTOM ;mountain middle
    .byte $00, MT_MOUNTAIN_RIGHT, MT_MOUNTAIN_RIGHT_BOTTOM ;mountain right
    .byte MT_FENCE, $00, $00 ;fence
    .byte MT_TALL_TREE_TOP_AND_TOP_HALF, MT_TALL_TREE_TOP_AND_BOTTOM_HALF, MT_TREE_TRUNK ;tall tree
    .byte MT_SHORT_TREE_TOP, MT_TREE_TRUNK, MT_TREE_TRUNK ;short tree

FSceneDataOffsets:
    .byte $00, $0d, $1a

ForeSceneryData:
;in water
    .byte MT_WATER_OR_LAVA_TOP
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA   
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_WATER_OR_LAVA
    .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK
    .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK

;wall
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte MT_CASTLE_TOP
    .byte MT_CASTLE_BRICK_WALL   
    .byte MT_CASTLE_BRICK_WALL
    .byte MT_CASTLE_BRICK_WALL
    .byte MT_CASTLE_BRICK_WALL
    .byte MT_CASTLE_BRICK_WALL
    .byte $00
    .byte $00

;over water
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00   
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte MT_WATER_OR_LAVA_TOP
    .byte MT_WATER_OR_LAVA

TerrainMetatiles:
    .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK
    .byte MT_CRACKED_ROCK_TERRAIN
    .byte MT_BREAKABLE_BRICK
    .byte MT_SOLID_BLOCK_WHITE_WALL

TerrainRenderBits:
    .byte %00000000, %00000000 ;no ceiling or floor
    .byte %00000000, %00011000 ;no ceiling, floor 2
    .byte %00000001, %00011000 ;ceiling 1, floor 2
    .byte %00000111, %00011000 ;ceiling 3, floor 2
    .byte %00001111, %00011000 ;ceiling 4, floor 2
    .byte %11111111, %00011000 ;ceiling 8, floor 2
    .byte %00000001, %00011111 ;ceiling 1, floor 5
    .byte %00000111, %00011111 ;ceiling 3, floor 5
    .byte %00001111, %00011111 ;ceiling 4, floor 5
    .byte %10000001, %00011111 ;ceiling 1, floor 6
    .byte %00000001, %00000000 ;ceiling 1, no floor
    .byte %10001111, %00011111 ;ceiling 4, floor 6
    .byte %11110001, %00011111 ;ceiling 1, floor 9
    .byte %11111001, %00011000 ;ceiling 1, middle 5, floor 2
    .byte %11110001, %00011000 ;ceiling 1, middle 4, floor 2
    .byte %11111111, %00011111 ;completely solid top to bottom

AreaParserCore:
    lda BackloadingFlag       ;check to see if we are starting right of start
    beq RenderSceneryTerrain  ;if not, go ahead and render background, foreground and terrain
    jsr ProcessAreaData_      ;otherwise skip ahead and load level data

RenderSceneryTerrain:
    ldx #$0c
    lda #$00
ClrMTBuf: 
    sta MetatileBuffer,x       ;clear out metatile buffer
    dex
    bpl ClrMTBuf
    ldy BackgroundScenery      ;do we need to render the background scenery?
    beq RendFore               ;if not, skip to check the foreground
    lda CurrentPageLoc         ;otherwise check for every third page
ThirdP:   
    cmp #$03
    bmi RendBack               ;if less than three we're there
    sec
    sbc #$03                   ;if 3 or more, subtract 3 and
    bpl ThirdP                 ;do an unconditional branch
RendBack: 
    asl                        ;move results to higher nybble
    asl
    asl
    asl
    adc BSceneDataOffsets-1,y  ;add to it offset loaded from here
    adc CurrentColumnPos       ;add to the result our current column position
    tax
    lda BackSceneryData,x      ;load data from sum of offsets
    beq RendFore               ;if zero, no scenery for that part
    pha
    and #$0f                   ;save to stack and clear high nybble
    sec
    sbc #$01                   ;subtract one (because low nybble is $01-$0c)
    sta $00                    ;save low nybble
    asl                        ;multiply by three (shift to left and add result to old one)
    adc $00                    ;note that since d7 was nulled, the carry flag is always clear
    tax                        ;save as offset for background scenery metatile data
    pla                        ;get high nybble from stack, move low
    lsr
    lsr
    lsr
    lsr
    tay                        ;use as second offset (used to determine height)
    lda #$03                   ;use previously saved memory location for counter
    sta $00
SceLoop1: 
    lda BackSceneryMetatiles,x ;load metatile data from offset of (lsb - 1) * 3
    sta MetatileBuffer,y       ;store into buffer from offset of (msb / 16)
    inx
    iny
    cpy #$0b                   ;if at this location, leave loop
    beq RendFore
    dec $00                    ;decrement until counter expires, barring exception
    bne SceLoop1
RendFore: 
    ldx ForegroundScenery      ;check for foreground data needed or not
    beq RendTerr               ;if not, skip this part
    ldy FSceneDataOffsets-1,x  ;load offset from location offset by header value, then
    ldx #$00                   ;reinit X
SceLoop2: 
    lda ForeSceneryData,y      ;load data until counter expires
    beq NoFore                 ;do not store if zero found
    sta MetatileBuffer,x
NoFore:   
    iny
    inx
    cpx #$0d                   ;store up to end of metatile buffer
    bne SceLoop2
RendTerr: 
    ldy AreaType               ;check world type for water level
    bne TerMTile               ;if not water level, skip this part
    lda WorldNumber            ;check world number, if not world number eight
    cmp #World8                ;then skip this part
    bne TerMTile
    lda #MT_SOLID_BLOCK_WHITE_WALL ;if set as water level and world number eight,
    jmp StoreMT                ;use castle wall metatile as terrain type
TerMTile: 
    lda TerrainMetatiles,y     ;otherwise get appropriate metatile for area type
    ldy CloudTypeOverride      ;check for cloud type override
    beq StoreMT                ;if not set, keep value otherwise
    lda #MT_CLOUD_LEVEL_TERRAIN ;use cloud block terrain
StoreMT:  
    sta $07                    ;store value here
    ldx #$00                   ;initialize X, use as metatile buffer offset
    lda TerrainControl         ;use yet another value from the header
    asl                        ;multiply by 2 and use as yet another offset
    tay
TerrLoop: 
    lda TerrainRenderBits,y    ;get one of the terrain rendering bit data
    sta $00
    iny                        ;increment Y and use as offset next time around
    sty $01
    lda CloudTypeOverride      ;skip if value here is zero
    beq NoCloud2
    cpx #$00                   ;otherwise, check if we're doing the ceiling byte
    beq NoCloud2
    lda $00                    ;if not, mask out all but d3
    and #%00001000
    sta $00
NoCloud2: 
    ldy #$00                   ;start at beginning of bitmasks
TerrBChk: 
    lda Bitmasks,y             ;load bitmask, then perform AND on contents of first byte
    bit $00
    beq NextTBit               ;if not set, skip this part (do not write terrain to buffer)
    lda $07
    sta MetatileBuffer,x       ;load terrain type metatile number and store into buffer here
NextTBit: 
    inx                        ;continue until end of buffer
    cpx #$0d
    beq RendBBuf               ;if we're at the end, break out of this loop
    lda AreaType               ;check world type for underground area
    cmp #$02
    bne EndUChk                ;if not underground, skip this part
    cpx #$0b
    bne EndUChk                ;if we're at the bottom of the screen, override
    lda #MT_CRACKED_ROCK_TERRAIN ;old terrain type with ground level terrain type
    sta $07
EndUChk:  
    iny                        ;increment bitmasks offset in Y
    cpy #$08
    bne TerrBChk               ;if not all bits checked, loop back
    ldy $01
    bne TerrLoop               ;unconditional branch, use Y to load next byte
RendBBuf: 
    jsr ProcessAreaData_       ;do the area data loading routine now
    lda BlockBufferColumnPos
    jsr GetBlockBufferAddr     ;get block buffer address from where we're at
    ldx #$00
    ldy #$00                   ;init index regs and start at beginning of smaller buffer
ChkMTLow: 
    sty $00
    lda MetatileBuffer,x       ;load stored metatile number
    tay
    lda Metatile_Attributes,y
    and #8                     ;check if interactable
    cmp #8
    tya
    bcs StrBlock               ;if equal or greater, branch
    lda #$00                   ;if less, init value before storing
StrBlock: 
    ldy $00                    ;get offset for block buffer
    sta ($06),y                ;store value into block buffer
    tya
    clc                        ;add 16 (move down one row) to offset
    adc #$10
    tay
    inx                        ;increment column value
    cpx #$0d
    bcc ChkMTLow               ;continue until we pass last row, then leave
    rts