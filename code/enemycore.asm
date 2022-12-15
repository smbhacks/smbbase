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
      
      .dw RunNormalEnemies  ;for objects $00-$14

      .dw RunBowserFlame    ;for objects $15-$1f
      .dw RunFireworks
      .dw NoRunCode
      .dw NoRunCode
      .dw NoRunCode
      .dw NoRunCode
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj

      .dw RunFirebarObj     ;for objects $20-$2f
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw NoRunCode
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunSmallPlatform
      .dw RunSmallPlatform
      .dw RunBowser
      .dw PowerUpObjHandler
      .dw VineObjectHandler

      .dw NoRunCode         ;for objects $30-$35
      .dw RunStarFlagObj
      .dw JumpspringHandler
      .dw NoRunCode
      .dw WarpZoneObject
      .dw RunRetainerObj

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

      .dw MoveNormalEnemy      ;only objects $00-$14 use this table
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw ProcHammerBro
      .dw MoveNormalEnemy
      .dw MoveBloober
      .dw MoveBulletBill
      .dw NoMoveCode
      .dw MoveSwimmingCheepCheep
      .dw MoveSwimmingCheepCheep
      .dw MovePodoboo
      .dw MovePiranhaPlant
      .dw MoveJumpingEnemy
      .dw ProcMoveRedPTroopa
      .dw MoveFlyGreenPTroopa
      .dw MoveLakitu
      .dw MoveNormalEnemy
      .dw NoMoveCode   ;dummy
      .dw MoveFlyingCheepCheep

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

      .dw BalancePlatform   ;table used by objects $24-$2a
      .dw YMovingPlatform
      .dw MoveLargeLiftPlat
      .dw MoveLargeLiftPlat
      .dw XMovingPlatform
      .dw DropPlatform
      .dw RightPlatform

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
      .db $30, $1c

XSpeedAdderData:
      .db $00, $e8, $00, $18

RevivedXSpeed:
      .db $08, $f8, $0c, $f4

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
      .db $20, $37

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
      .db %00111111, %00000011

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
      .db $40, $80
      .db $04, $04 ;residual data, not used

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
;$ed - used to hold maximum length of firebar
;$ef - used to hold high byte of spinstate

;horizontal adder is at first byte + high byte of spinstate,
;vertical adder is same + 8 bytes, two's compliment
;if greater than $08 for proper oscillation
FirebarPosLookupTbl:
      .db $00, $01, $03, $04, $05, $06, $07, $07, $08
      .db $00, $03, $06, $09, $0b, $0d, $0e, $0f, $10
      .db $00, $04, $09, $0d, $10, $13, $16, $17, $18
      .db $00, $06, $0c, $12, $16, $1a, $1d, $1f, $20
      .db $00, $07, $0f, $16, $1c, $21, $25, $27, $28
      .db $00, $09, $12, $1b, $21, $27, $2c, $2f, $30
      .db $00, $0b, $15, $1f, $27, $2e, $33, $37, $38
      .db $00, $0c, $18, $24, $2d, $35, $3b, $3e, $40
      .db $00, $0e, $1b, $28, $32, $3b, $42, $46, $48
      .db $00, $0f, $1f, $2d, $38, $42, $4a, $4e, $50
      .db $00, $11, $22, $31, $3e, $49, $51, $56, $58

FirebarMirrorData:
      .db $01, $03, $02, $00

FirebarTblOffsets:
      .db $00, $09, $12, $1b, $24, $2d
      .db $36, $3f, $48, $51, $5a, $63

FirebarYPos:
      .db $0c, $18

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
SetupGFB: sta $ef                     ;save high byte of spinning thing, modified or otherwise
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
SetMFbar: sty $ed                     ;store maximum value for length of firebars
          lda #$00
          sta $00                     ;initialize counter here
DrawFbar: lda $ef                     ;load high byte of spinstate
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
          cmp $ed                     ;if we end up at the maximum part, go on and leave
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
      .db $f8, $a0, $70, $bd, $00

FlyCCBPriority:
      .db $20, $20, $20, $00, $00

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
      .db $15, $30, $40

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
      .db $1a ;axe
      .db $58 ;chain
      .db $98, $96, $94, $92, $90, $8e, $8c ;bridge
      .db $8a, $88, $86, $84, $82, $80

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
      .db $21, $41, $11, $31

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
      .db $bf, $40, $bf, $bf, $bf, $40, $40, $bf

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
         lda #$51                    ;otherwise, continue
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
      .db $00, $00, $08, $08

StarFlagXPosAdder:
      .db $00, $08, $00, $08

StarFlagTileData:
      .db $54, $55, $56, $57

RunStarFlagObj:
      lda #$00                 ;initialize enemy frenzy buffer
      sta EnemyFrenzyBuffer
      lda StarFlagTaskControl  ;check star flag object task number here
      cmp #$05                 ;if greater than 5, branch to exit
      bcs StarFlagExit
      jsr JumpEngine           ;otherwise jump to appropriate sub
      
      .dw StarFlagExit
      .dw GameTimerFireworks
      .dw AwardGameTimerPoints
      .dw RaiseFlagSetoffFWorks
      .dw DelayToAreaEnd

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
      lda songPlaying      ;if event music buffer empty,
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
         lda #$a2
         sta VRAM_Buffer1+3,x        ;otherwise put tile numbers for left
         lda #$a3                    ;and right sides of rope in vram buffer
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
         lda #$a2
         sta VRAM_Buffer1+8,x        ;otherwise put tile numbers for left
         lda #$a3                    ;and right sides of rope in vram
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
       lda #$10
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
      .db $ff, $ff, $ff

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
      .db Goomba, GreenKoopa, BuzzyBeetle, Spiny, Lakitu, Bloober, HammerBro, Bowser

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