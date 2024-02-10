
CHRInitTable:
 .db $00,$02,$04,$05,$06,$07
Start:
             ;sei                          ;pretty standard 6502 type init here
             cld
             lda #%00010000               ;init PPU control register 1 
             sta PPU_CTRL_REG1
		   cli
             lda #$40
             sta $4017
		   ldx #$ff                     ;reset stack pointer
             txs
VBlank1:     lda PPU_STATUS               ;wait two frames
             bpl VBlank1
VBlank2:     lda PPU_STATUS
             bpl VBlank2
             ; make sure to initialize the 8000 and a000 banks before calling code in them!
             Bank_NoSave 0
             ; Setup the CHR rom banks to the default as well
             ldx #5
CHRBankInitLoop:
             stx $8000
             lda CHRInitTable,x
             sta $8001
             dex
             bpl CHRBankInitLoop
             ldy #ColdBootOffset          ;load default cold boot pointer
             ldx #$05                     ;this is where we check for a warm boot
WBootCheck:  lda TopScoreDisplay,x        ;check each score digit in the top score
             cmp #10                      ;to see if we have a valid digit
             bcs ColdBoot                 ;if not, give up and proceed with cold boot
             dex                      
             bpl WBootCheck
             lda WarmBootValidation       ;second checkpoint, check to see if 
             cmp #$a5                     ;another location has a specific value
             bne ColdBoot   
             ldy #WarmBootOffset          ;if passed both, load warm boot pointer
ColdBoot:    jsr InitializeMemory         ;clear memory using pointer in Y
             sta SND_DELTA_REG+1          ;reset delta counter load register
             sta OperMode                 ;reset primary mode of operation
             lda #$a5                     ;set warm boot flag
             sta WarmBootValidation     
             sta PseudoRandomBitReg       ;set seed for pseudorandom register
             lda #%00001111
             sta SND_MASTERCTRL_REG       ;enable all sound channels except dmc
             lda #%00000110
             sta PPU_CTRL_REG2            ;turn off clipping for OAM and background
             jsr MoveAllSpritesOffscreen
             jsr InitializeNameTables     ;initialize both name tables
             inc DisableScreenFlag        ;set flag to disable screen output
             ; Enable PRG ram with write protect disabled
             lda #$80
             sta $a001
             ; Clear the sleeping flag to allow NMI to start
             lda #0
             sta sleeping
		   sta $a000
             ldx #$1f
             lda #$60
             sta $01
             ldy #$00
             sty $00
             tya
@clear_wram:
             sta ($00),y
             dey
             bne @clear_wram
             inc $01
             dex
             bpl @clear_wram
             lda Mirror_PPU_CTRL_REG1
             ora #%10000000               ;enable NMIs
             jsr WritePPUReg1
EndlessLoop: jmp EndlessLoop              ;endless loop, need I say more?
