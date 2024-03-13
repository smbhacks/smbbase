
CHRInitTable:
 .byte default_chr, default_chr+2, default_chr+4, default_chr+5, default_chr+6, default_chr+7
Start:
             ;sei                          ;pretty standard 6502 type init here
             cld
             lda #%00010000               ;init PPU control register 1 
             sta PPU_CTRL_REG1
             cli
             lda #$40
             sta SND_FRAME_COUNTER
             ldx #$ff                     ;reset stack pointer
             txs
VBlank1:     lda PPU_STATUS               ;wait two frames
             bpl VBlank1
VBlank2:     lda PPU_STATUS
             bpl VBlank2
             ; make sure to initialize the 8000 and a000 banks before calling code in them!
             MMC3_SECONDARY_BANKSWITCH #0
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
             sta MMC3_RAM_PROTECT
             ; Clear the sleeping flag to allow NMI to start
             ldx #$1f
             lda #$60
             sta $01
             ldy #$00
             sty $00
             sty MMC3_MIRRORING
             tya
@clear_wram:
             sta ($00),y
             dey
             bne @clear_wram
             inc $01
             dex
             bpl @clear_wram
             ; Setup the CHR rom banks
             ldx #5
CHRBankInitLoop:
             stx MMC3_BANK_SELECT
             lda CHRInitTable,x
             sta CHR0,x
             sta MMC3_BANK_DATA
             dex
             bpl CHRBankInitLoop
             NEW_BANK #0
             lda Mirror_PPU_CTRL_REG1
             ora #%10000000               ;enable NMIs
             jsr WritePPUReg1
EndlessLoop: jmp EndlessLoop              ;endless loop, need I say more?
