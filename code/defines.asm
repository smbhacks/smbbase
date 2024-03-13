;----------------------------------------------------------------
.segment "ZEROPAGE"

ObjectOffset:           .res 1
FrameCounter:           .res 1
A_B_Buttons:            .res 1
Up_Down_Buttons:        .res 1
Left_Right_Buttons:     .res 1
PreviousA_B_Buttons:    .res 1
GameEngineSubroutine:   .res 1
Enemy_Flag:             .res 7
Enemy_ID:               .res 7
Player_State:           .res 1
Enemy_State:            .res 6
Fireball_State:         .res 2
Block_State:            .res 4
Misc_State:             .res 9
PlayerFacingDir:        .res 1
FirebarSpinDirection  = DestinationPageLoc
DestinationPageLoc:     .res 1
VictoryWalkControl:     .res 4
PowerUpType:            .res 1
FireballBouncingFlag:   .res 2
HammerBroJumpTimer:     .res 9
Player_MovingDir:       .res 1
Enemy_MovingDir:        .res 17
Player_X_Speed        = SprObject_X_Speed
Enemy_X_Speed         = SprObject_X_Speed + 1
YPlatformCenterYPos   = Enemy_X_Speed  
Jumpspring_FixedYPos  = Enemy_X_Speed
RedPTroopaCenterYPos  = Enemy_X_Speed
XMoveSecondaryCounter = Enemy_X_Speed
CheepCheepMoveMFlag   = Enemy_X_Speed
LakituMoveSpeed       = Enemy_X_Speed
FirebarSpinState_Low  = Enemy_X_Speed
BlooperMoveSpeed      = Enemy_X_Speed
PiranhaPlant_Y_Speed  = Enemy_X_Speed
ExplosionGfxCounter   = Enemy_X_Speed
SprObject_X_Speed:      .res 7
Fireball_X_Speed:       .res 2
Block_X_Speed:          .res 4
Misc_X_Speed:           .res 9
Player_PageLoc         = SprObject_PageLoc
Enemy_PageLoc          = SprObject_PageLoc + 1
SprObject_PageLoc:      .res 7
Fireball_PageLoc:       .res 2
Block_PageLoc:          .res 4
Misc_PageLoc:           .res 9
Bubble_PageLoc:         .res 3
Player_X_Position      = SprObject_X_Position
Enemy_X_Position       = SprObject_X_Position + 1
SprObject_X_Position:   .res 7
Fireball_X_Position:    .res 2
Block_X_Position:       .res 4
Misc_X_Position:        .res 9
Bubble_X_Position:      .res 3
Player_Y_Speed         = SprObject_Y_Speed
Enemy_Y_Speed          = SprObject_Y_Speed + 1
SprObject_Y_Speed:      .res 7
XMovePrimaryCounter    = Enemy_Y_Speed
LakituMoveDirection    = Enemy_Y_Speed
FirebarSpinState_High  = Enemy_Y_Speed
BlooperMoveCounter     = Enemy_Y_Speed
PiranhaPlant_MoveFlag  = Enemy_Y_Speed
ExplosionTimerCounter  = Enemy_Y_Speed
Fireball_Y_Speed:       .res 2
Block_Y_Speed:          .res 4
Misc_Y_Speed:           .res 9
Player_Y_HighPos       = SprObject_Y_HighPos
Enemy_Y_HighPos        = SprObject_Y_HighPos + 1
SprObject_Y_HighPos:    .res 7
Fireball_Y_HighPos:     .res 2
Block_Y_HighPos:        .res 4
Misc_Y_HighPos:         .res 9
Bubble_Y_HighPos:       .res 3
Player_Y_Position      = SprObject_Y_Position
Enemy_Y_Position       = SprObject_Y_Position + 1
SprObject_Y_Position:   .res 7
Fireball_Y_Position:    .res 2
Block_Y_Position:       .res 4
Misc_Y_Position:        .res 9
Bubble_Y_Position:      .res 3
AreaDataLow            = AreaData
AreaDataHigh           = AreaData + 1
AreaData:               .res 2
EnemyDataLow           = EnemyData
EnemyDataHigh          = EnemyData + 1
EnemyData:              .res 2
Local_eb:               .res 1
Local_ec:               .res 1
Local_ed:               .res 1
Local_ef:               .res 1
Square1SoundBuffer:     .res 1
Square2SoundBuffer:     .res 1
NoiseSoundBuffer:       .res 1
AreaMusicBuffer:        .res 1
ShadowSelect:           .res 1
bnkTMP:                 .res 1 ;for holding the X reg
bnkSP:                  .res 1 ;stack pointer for banks

.if CustomMusicDriver = VanillaPlusMusic || CustomMusicDriver = OriginalSMBMusic
NoteLenLookupTblOfs:    .res 1
MusicDataLow           = MusicData
MusicDataHigh          = MusicData + 1
MusicData:              .res 2
.endif

.if CustomMusicDriver = VanillaPlusMusic
SQ2_PatternLow         = SQ2_Pattern
SQ2_PatternHigh        = SQ2_Pattern + 1
SQ2_Pattern:            .res 2
SQ1_PatternLow         = SQ1_Pattern
SQ1_PatternHigh        = SQ1_Pattern + 1
SQ1_Pattern:            .res 2
SQ2_Offset:             .res 1
.endif

.if CustomMusicDriver = OriginalSMBMusic
MusicOffset_Square2:    .res 1
MusicOffset_Square1:    .res 1
MusicOffset_Triangle:   .res 1
.endif

;----------------------------------------------------------------
.segment "SHORTRAM"

bankStack:             .res 8
temp:                  .res 1 ;$0100
songPlaying:           .res 1 ;$0101
ScrollH:               .res 1 ;$0102
ScrollBit:	           .res 1 ;$0103
bank0:		           .res 1 ;$0104
PauseSoundQueue:       .res 1 ;$0106
AreaMusicQueue:        .res 2 ;$0107
VerticalFlipFlag:      .res 4 ;$0109
FlagpoleFNum_Y_Pos:    .res 1 ;$010d
FlagpoleFNum_YMFDummy: .res 1 ;$010e
FlagpoleScore:         .res 1 ;$010f
FloateyNum_Control:    .res 7 ;$0110
FloateyNum_X_Pos:      .res 7 ;$0117
FloateyNum_Y_Pos:      .res 7 ;$011e
ShellChainCounter:     .res 7 ;$0125
FloateyNum_Timer:      .res 8 ;$012c
DigitModifier:         .res 6 ;$0134
EventMusicQueue:        .res 1
NoiseSoundQueue:        .res 1
Square2SoundQueue:      .res 1
Square1SoundQueue:      .res 1

.if CustomMusicDriver = VanillaPlusMusic
NOI_Offset:            .res 1
CurPattern:            .res 1    
Instrument_High:       .res 1
Instrument_Low:        .res 1
TriangleMode:          .res 1
Instrument_Length:     .res 1
TRI_PatternHigh:       .res 1
TRI_PatternLow:        .res 1      
NOI_PatternHigh:       .res 1         
NOI_PatternLow:        .res 1      
SQ1_Offset:            .res 1      
TRI_Offset:            .res 1
.endif

;----------------------------------------------------------------
.segment "STACK"

;declaring variables here is not safe

;----------------------------------------------------------------
.segment "OAM"

Sprite_Y_Position     = Sprite_Data 
Sprite_Tilenumber     = Sprite_Data + 1
Sprite_Attributes     = Sprite_Data + 2
Sprite_X_Position     = Sprite_Data + 3
Sprite_Data:           .res 4

;----------------------------------------------------------------
.segment "BSS"

VRAM_Buffer1          = VRAM_Buffer1_Offset + 1
VRAM_Buffer1_Offset:   .res 64 ;$0300
VRAM_Buffer2          = VRAM_Buffer2_Offset + 1
VRAM_Buffer2_Offset:   .res 35 ;$0340
BowserBodyControls:    .res 1 ;$0363
BowserFeetCounter:     .res 1 ;$0364
BowserMovementSpeed:   .res 1 ;$0365
BowserOrigXPos:        .res 1 ;$0366
BowserFlameTimerCtrl:  .res 1 ;$0367
BowserFront_Offset:    .res 1 ;$0368
BridgeCollapseOffset:  .res 1 ;$0369
BowserGfxFlag:         .res 30 ;$036a
FirebarSpinSpeed:      .res 16 ;$0388
VineFlagOffset:        .res 1 ;$0398
VineHeight:            .res 1 ;$0399
VineObjOffset:         .res 3 ;$039a
VineStart_Y_Position:  .res 3 ;$039d
BalPlatformAlignment:  .res 1 ;$03a0
Platform_X_Scroll:     .res 1 ;$03a1
HammerThrowingTimer:   .res 0 ;$03a2
PlatformCollisionFlag: .res 11 ;$03a2
Player_Rel_XPos       = SprObject_Rel_XPos ;$03ad
Enemy_Rel_XPos        = SprObject_Rel_XPos + 1 ;$03ae
Fireball_Rel_XPos     = SprObject_Rel_XPos + 2 ;$03af
Bubble_Rel_XPos       = SprObject_Rel_XPos + 3 ;$03b0
Block_Rel_XPos        = SprObject_Rel_XPos + 4 ;$03b1
Misc_Rel_XPos         = SprObject_Rel_XPos + 6 ;$03b3
SprObject_Rel_XPos:    .res 11 ;$03ad
Player_Rel_YPos       = SprObject_Rel_YPos ;$03b8
Enemy_Rel_YPos        = SprObject_Rel_YPos + 1 ;$03b9
Fireball_Rel_YPos     = SprObject_Rel_YPos + 2 ;$03ba
Bubble_Rel_YPos       = SprObject_Rel_YPos + 3 ;$03bb
Block_Rel_YPos        = SprObject_Rel_YPos + 4 ;$03bc
Misc_Rel_YPos         = SprObject_Rel_YPos + 6 ;$03be
SprObject_Rel_YPos:    .res 12 ;$03b8
Player_SprAttrib      = SprObject_SprAttrib
Enemy_SprAttrib       = SprObject_SprAttrib + 1
SprObject_SprAttrib:   .res 12 ;$03c4
Player_OffscreenBits  = SprObject_OffscrBits ;$03d0
Enemy_OffscreenBits   = SprObject_OffscrBits + 1 ;$03d1
FBall_OffscreenBits   = SprObject_OffscrBits + 2 ;$03d2
Bubble_OffscreenBits  = SprObject_OffscrBits + 3 ;$03d3
Block_OffscreenBits   = SprObject_OffscrBits + 4 ;$03d4
Misc_OffscreenBits    = SprObject_OffscrBits + 6 ;$03d6
SprObject_OffscrBits:  .res 8 ;$03d0
EnemyOffscrBitsMasked: .res 12 ;$03d8
Block_Orig_YPos:       .res 2 ;$03e4
Block_BBuf_Low:        .res 2 ;$03e6
Block_Metatile:        .res 2 ;$03e8
Block_PageLoc2:        .res 2 ;$03ea
Block_RepFlag:         .res 2 ;$03ec
SprDataOffset_Ctrl:    .res 2 ;$03ee
Block_ResidualCounter: .res 1 ;$03f0
Block_Orig_XPos:       .res 8 ;$03f1
AttributeBuffer:       .res 7 ;$03f9
SprObject_X_MoveForce: .res 1 ;$0400
RedPTroopaOrigXPos    = Enemy_X_MoveForce ;$0401
YPlatformTopYPos      = Enemy_X_MoveForce ;$0401
Enemy_X_MoveForce:     .res 21 ;$0401
Player_YMF_Dummy      = SprObject_YMF_Dummy ;$0416
Enemy_YMF_Dummy       = SprObject_YMF_Dummy + 1 ;$0417
PiranhaPlantUpYPos    = Enemy_YMF_Dummy
BowserFlamePRandomOfs  = Enemy_YMF_Dummy
SprObject_YMF_Dummy:   .res 22 ;$0416
Bubble_YMF_Dummy:      .res 7 ;$042c
Player_Y_MoveForce    = SprObject_Y_MoveForce
Enemy_Y_MoveForce     = SprObject_Y_MoveForce + 1
PiranhaPlantDownYPos  = Enemy_Y_MoveForce
CheepCheepOrigYPos    = Enemy_Y_MoveForce
SprObject_Y_MoveForce: .res 9
Block_Y_MoveForce:     .res 20 ;$043c
MaximumLeftSpeed:      .res 6 ;$0450
MaximumRightSpeed:     .res 20 ;$0456
Cannon_Offset         = Whirlpool_Offset ;$046a
Whirlpool_Offset:      .res 1 ;$046a
Cannon_PageLoc        = Whirlpool_PageLoc
Whirlpool_PageLoc:     .res 6 ;$046b
Cannon_X_Position     = Whirlpool_LeftExtent
Whirlpool_LeftExtent:  .res 6 ;$0471
Cannon_Y_Position     = Whirlpool_Length
Whirlpool_Length:      .res 6 ;$0477
Cannon_Timer          = Whirlpool_Flag
Whirlpool_Flag:        .res 6 ;$047d
BowserHitPoints:       .res 1 ;$0483
StompChainCounter:     .res 12 ;$0484
Player_CollisionBits  = SprObj_CollisionBits ;$0490
Enemy_CollisionBits   = SprObj_CollisionBits + 1 ;$0491
SprObj_CollisionBits:  .res 9
Player_BoundBoxCtrl   = SprObj_BoundBoxCtrl
Enemy_BoundBoxCtrl    = SprObj_BoundBoxCtrl + 1
SprObj_BoundBoxCtrl:   .res 7
Fireball_BoundBoxCtrl: .res 2 ;$04a0
Misc_BoundBoxCtrl:     .res 10 ;$04a2
BoundingBox_UL_Corner  = BoundingBox_UL_XPos
BoundingBox_UL_XPos:   .res 1 ;$04ac
BoundingBox_UL_YPos:   .res 1 ;$04ad
BoundingBox_LR_Corner  = BoundingBox_DR_XPos
BoundingBox_DR_XPos:   .res 1 ;$04ae
BoundingBox_DR_YPos:   .res 1 ;$04af
EnemyBoundingBoxCoord: .res 80 ;$04b0
Block_Buffer_1:        .res $d0 ;$0500
Block_Buffer_2:        .res $d0 ;$05d0
BlockBufferColumnPos:  .res 1 ;$06a0
MetatileBuffer:        .res 13 ;$06a1
HammerEnemyOffset:     .res 9 ;$06ae
JumpCoinMiscOffset:    .res 5 ;$06b7
BrickCoinTimerFlag:    .res 2 ;$06bc
Misc_Collision_Flag:   .res 13 ;$06be
EnemyFrenzyBuffer:     .res 1 ;$06cb
SecondaryHardMode:     .res 1 ;$06cc
EnemyFrenzyQueue:      .res 1 ;$06cd
FireballCounter:       .res 1 ;$06ce
DuplicateObj_Offset:   .res 2 ;$06cf
LakituReappearTimer:   .res 2 ;$06d1
NumberofGroupEnemies:  .res 1 ;$06d3
ColorRotateOffset:     .res 1 ;$06d4
PlayerGfxOffset:       .res 1 ;$06d5
WarpZoneControl:       .res 1 ;$06d6
FireworksCounter:      .res 2 ;$06d7
MultiLoopCorrectCntr:  .res 1 ;$06d9
MultiLoopPassCntr:     .res 1 ;$06da
JumpspringForce:       .res 1 ;$06db
MaxRangeFromOrigin:    .res 1 ;$06dc
BitMFilter:            .res 1 ;$06dd
ChangeAreaTimer:       .res 2 ;$06de
SprShuffleAmtOffset:   .res 1 ;$06e0
SprShuffleAmt:         .res 3 ;$06e1
Player_SprDataOffset  = SprDataOffset  ;$06e4
Enemy_SprDataOffset   = SprDataOffset + 1
SprDataOffset:         .res 8 ;$06e4
Block_SprDataOffset   = Alt_SprDataOffset ;$06ec
Bubble_SprDataOffset  = Alt_SprDataOffset + 2 ;$06ee
FBall_SprDataOffset   = Alt_SprDataOffset + 5 ;$06f1
Misc_SprDataOffset    = Alt_SprDataOffset + 7 ;$06f3
Alt_SprDataOffset:     .res 16 ;$06ec
SavedJoypad1Bits      = SavedJoypadBits ;$06fc
SavedJoypad2Bits      = SavedJoypadBits + 1 ;$06fd
SavedJoypadBits:       .res 3 ;$06fc
Player_X_Scroll:       .res 1 ;$06ff
;----------------------------------------------------------------
.segment "BSS_0700" ;Certain ram values might be immune to RAM initialisation in this segment
                    ;Because of this, declaration order matters here!

Player_XSpeedAbsolute: .res 1 ;$0700
FrictionAdderHigh:     .res 1 ;$0701
FrictionAdderLow:      .res 1 ;$0702
RunningSpeed:          .res 1 ;$0703
SwimmingFlag:          .res 1 ;$0704
Player_X_MoveForce:    .res 1 ;$0705
DiffToHaltJump:        .res 1 ;$0706
JumpOrigin_Y_HighPos:  .res 1 ;$0707
JumpOrigin_Y_Position: .res 1 ;$0708
VerticalForce:         .res 1 ;$0709
VerticalForceDown:     .res 1 ;$070a
PlayerChangeSizeFlag:  .res 1 ;$070b
PlayerAnimTimerSet:    .res 1 ;$070c
PlayerAnimCtrl:        .res 1 ;$070d
JumpspringAnimCtrl:    .res 1 ;$070e
FlagpoleCollisionYPos: .res 1 ;$070f
PlayerEntranceCtrl:    .res 1 ;$0710
FireballThrowingTimer: .res 1 ;$0711
DeathMusicLoaded:      .res 1 ;$0712
FlagpoleSoundQueue:    .res 1 ;$0713
CrouchingFlag:         .res 1 ;$0714
GameTimerSetting:      .res 1 ;$0715
DisableCollisionDet:   .res 1 ;$0716
DemoAction:            .res 1 ;$0717
DemoActionTimer:       .res 1 ;$0718
PrimaryMsgCounter:     .res 1 ;$0719
ScreenEdge_PageLoc    = ScreenLeft_PageLoc ;$071a
ScreenLeft_PageLoc:    .res 1 ;$071a
ScreenRight_PageLoc:   .res 1 ;$071b
ScreenEdge_X_Pos      = ScreenLeft_X_Pos
ScreenLeft_X_Pos:      .res 1 ;$071c
ScreenRight_X_Pos:     .res 1 ;$071d
ColumnSets:            .res 1 ;$071e
AreaParserTaskNum:     .res 1 ;$071f
CurrentNTAddr_High:    .res 1 ;$0720
CurrentNTAddr_Low:     .res 1 ;$0721
Sprite0HitDetectFlag:  .res 1 ;$0722
ScrollLock:            .res 2 ;$0723
CurrentPageLoc:        .res 1 ;$0725
CurrentColumnPos:      .res 1 ;$0726
TerrainControl:        .res 1 ;$0727
BackloadingFlag:       .res 1 ;$0728
BehindAreaParserFlag:  .res 1 ;$0729
AreaObjectPageLoc:     .res 1 ;$072a
AreaObjectPageSel:     .res 1 ;$072b
AreaDataOffset:        .res 1 ;$072c
AreaObjOffsetBuffer:   .res 3 ;$072d
AreaObjectLength:      .res 3 ;$0730
AreaStyle:             .res 1 ;$0733
StaircaseControl:      .res 1 ;$0734
AreaObjectHeight:      .res 1 ;$0735
MushroomLedgeHalfLen:  .res 3 ;$0736
EnemyDataOffset:       .res 1 ;$0739
EnemyObjectPageLoc:    .res 1 ;$073a
EnemyObjectPageSel:    .res 1 ;$073b
ScreenRoutineTask:     .res 1 ;$073c
ScrollThirtyTwo:       .res 2 ;$073d
HorizontalScroll:      .res 1 ;$073f
VerticalScroll:        .res 1 ;$0740
ForegroundScenery:     .res 1 ;$0741
BackgroundScenery:     .res 1 ;$0742
CloudTypeOverride:     .res 1 ;$0743
BackgroundColorCtrl:   .res 1 ;$0744
LoopCommand:           .res 1 ;$0745
StarFlagTaskControl:   .res 1 ;$0746
TimerControl:          .res 1 ;$0747
CoinTallyFor1Ups:      .res 1 ;$0748
SecondaryMsgCounter:   .res 1 ;$0749
JoypadBitMask:         .res 4 ;$074a
InitializeMemoryOffset = * - 1
AreaType:              .res 1 ;$074e
AreaAddrsLOffset:      .res 1 ;$074f
AreaPointer:           .res 1 ;$0750
EntrancePage:          .res 1 ;$0751
AltEntranceControl:    .res 1 ;$0752
CurrentPlayer:         .res 1 ;$0753
PlayerSize:            .res 1 ;$0754
Player_Pos_ForScroll:  .res 1 ;$0755
PlayerStatus:          .res 1 ;$0756
FetchNewGameTimerFlag: .res 1 ;$0757
JoypadOverride:        .res 1 ;$0758
GameTimerExpiredFlag:  .res 1 ;$0759
OnscreenPlayerInfo    = NumberofLives ;$075a
NumberofLives:         .res 1 ;$075a
HalfwayPage:           .res 1 ;$075b
LevelNumber:           .res 1 ;$075c
Hidden1UpFlag:         .res 1 ;$075d
CoinTally:             .res 1 ;$075e
WorldNumber:           .res 1 ;$075f
AreaNumber:            .res 1 ;$0760
OffscreenPlayerInfo   = OffScr_NumberofLives
OffScr_NumberofLives:  .res 1 ;$0761
OffScr_HalfwayPage:    .res 1 ;$0762
OffScr_LevelNumber:    .res 1 ;$0763
OffScr_Hidden1UpFlag:  .res 1 ;$0764
OffScr_CoinTally:      .res 1 ;$0765
OffScr_WorldNumber:    .res 1 ;$0766
OffScr_AreaNumber:     .res 1 ;$0767
ScrollFractional:      .res 1 ;$0768
DisableIntermediate:   .res 1 ;$0769
PrimaryHardMode:       .res 1 ;$076a
WorldSelectNumber:     .res 5 ;$076b
InitializeGameOffset = * - 1
OperMode:              .res 2 ;$0770
OperMode_Task:         .res 1 ;$0772
VRAM_Buffer_AddrCtrl:  .res 1 ;$0773
DisableScreenFlag:     .res 1 ;$0774
ScrollAmount:          .res 1 ;$0775
GamePauseStatus:       .res 1 ;$0776
GamePauseTimer:        .res 1 ;$0777
Mirror_PPU_CTRL_REG1:  .res 1 ;$0778
Mirror_PPU_CTRL_REG2:  .res 1 ;$0779
NumberOfPlayers:       .res 5 ;$077a
IntervalTimerControl:  .res 1 ;$077f
SelectTimer           = Timers + 0                ;.res 1
PlayerAnimTimer       = SelectTimer + 1           ;.res 1
JumpSwimTimer         = PlayerAnimTimer + 1       ;.res 1
RunningTimer          = JumpSwimTimer + 1         ;.res 1
BlockBounceTimer      = RunningTimer + 1          ;.res 1
SideCollisionTimer    = BlockBounceTimer + 1      ;.res 1
JumpspringTimer       = SideCollisionTimer + 1    ;.res 1
GameTimerCtrlTimer    = JumpspringTimer + 1       ;.res 2 ;only needs 1
ClimbSideTimer        = GameTimerCtrlTimer + 2    ;.res 1
EnemyFrameTimer       = ClimbSideTimer + 1        ;.res 5
FrenzyEnemyTimer      = EnemyFrameTimer + 5       ;.res 1
BowserFireBreathTimer = FrenzyEnemyTimer + 1      ;.res 1
StompTimer            = BowserFireBreathTimer + 1 ;.res 1
AirBubbleTimer        = StompTimer + 1            ;.res 3
ScrollIntervalTimer   = AirBubbleTimer + 3        ;.res 1
EnemyIntervalTimer    = ScrollIntervalTimer + 1   ;.res 7
BrickCoinTimer        = EnemyIntervalTimer + 7    ;.res 1
InjuryTimer           = BrickCoinTimer + 1        ;.res 1
StarInvincibleTimer   = InjuryTimer + 1           ;.res 1
ScreenTimer           = StarInvincibleTimer + 1   ;.res 1
WorldEndTimer         = ScreenTimer + 1           ;.res 1
DemoTimer             = WorldEndTimer + 1         ;.res 5 
Timers:                .res 39 ;$0780
PseudoRandomBitReg:    .res 9 ;$07a7
MusicOffset_Noise:     .res 1 ;$07b0
EventMusicBuffer:      .res 1 ;$07b1
PauseSoundBuffer:      .res 1 ;$07b2
Squ2_NoteLenBuffer:    .res 1 ;$07b3
Squ2_NoteLenCounter:   .res 1 ;$07b4
Squ2_EnvelopeDataCtrl: .res 1 ;$07b5
Squ1_NoteLenCounter:   .res 1 ;$07b6
Squ1_EnvelopeDataCtrl: .res 1 ;$07b7
Tri_NoteLenBuffer:     .res 1 ;$07b8
Tri_NoteLenCounter:    .res 1 ;$07b9
Noise_BeatLenCounter:  .res 1 ;$07ba
Squ1_SfxLenCounter:    .res 2 ;$07bb
Squ2_SfxLenCounter:    .res 1 ;$07bd
Sfx_SecondaryCounter:  .res 1 ;$07be
Noise_SfxLenCounter:   .res 1 ;$07bf
DAC_Counter:           .res 1 ;$07c0
NoiseDataLoopbackOfs:  .res 3 ;$07c1
NoteLengthTblAdder:    .res 1 ;$07c4
AreaMusicBuffer_Alt:   .res 1 ;$07c5
PauseModeFlag:         .res 1 ;$07c6
GroundMusicHeaderOfs:  .res 3 ;$07c7
AltRegContentFlag:     .res 13 ;$07ca
WarmBootOffset = * - 1 ;-------------------------------- WARM BOOT
DisplayDigits         = TopScoreDisplay ;$07d7
TopScoreDisplay:       .res 6 ;$07d7
ScoreAndCoinDisplay   = PlayerScoreDisplay ;$07dd
PlayerScoreDisplay:    .res 27 ;$07dd
GameTimerDisplay:      .res 4 ;$07f8
WorldSelectEnableFlag: .res 1 ;$07fc
ContinueWorld:         .res 2 ;$07fd
ColdBootOffset = * - 1 ;-------------------------------- COLD BOOT
WarmBootValidation:    .res 1 ;$07ff

;----------------------------------------------------------------
.segment "WRAM" ;$7f00+ could be occupied by Famitone/Famistudio if you have these enabled

CHRAnimWait:           .res 1 ;$7ff7
CHRAnimCounter:        .res 1 ;$7ff8
CHR0:                  .res 1 ;$7ff9
CHR2:                  .res 1 ;$7ffa
CHR4:                  .res 1 ;$7ffb
CHR5:                  .res 1 ;$7ffc
CHR6:                  .res 1 ;$7ffd
CHR7:                  .res 1 ;$7ffe
processinggame:        .res 1 ;$7fff
processingnmi:         .res 1