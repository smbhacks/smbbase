newBNK:
    stx bnkTMP
    ldx bnkSP
    inc bnkSP
    sta bankStack,x
    tax 
    jsr mmc3_bankswitch_primary
    ldx bnkTMP
    rts

restoreBNK:
    stx bnkTMP
    dec bnkSP
    ldx bnkSP
    lda bankStack-1,x
    tax 
    jsr mmc3_bankswitch_primary
    ldx bnkTMP
    rts

latestBNK:
    stx bnkTMP
    ldx bnkSP
    lda bankStack-1,x
    tax 
    jsr mmc3_bankswitch_primary
    ldx bnkTMP
    rts

switchBNK:
    stx bnkTMP
    tax
    jsr mmc3_bankswitch_primary
    ldx bnkTMP
    rts

mmc3_bankswitch_primary:
    lda #%00000110
    sta ShadowSelect
    sta MMC3_BANK_SELECT
    stx MMC3_BANK_DATA
    lda #%00000111
    sta ShadowSelect
    sta MMC3_BANK_SELECT
    inx
    stx MMC3_BANK_DATA
    rts

mmc3_bankswitch_secondary:
    lda #%00000110
    sta MMC3_BANK_SELECT
    stx MMC3_BANK_DATA
    lda #%00000111
    sta MMC3_BANK_SELECT
    inx
    stx MMC3_BANK_DATA
    rts

;This can be optimized further probably
FarCallRoutine:
sta farcall_regs
stx farcall_regs+1
sty farcall_regs+2
    tsx
    ;add 3 to the return address (to skip the hi, lo and bank bytes)
    lda $0100+1,x
    sta call_ptr
    clc
    adc #3
    sta $0100+1,x
    lda $0100+2,x
    sta call_ptr+1
    adc #0
    sta $0100+2,x
    jsr @DoFarCall
    ldx bnkSP
    lda bankStack-1,x
    ldx #%00000110
    stx ShadowSelect
    stx MMC3_BANK_SELECT
    sta MMC3_BANK_DATA
    inx
    stx ShadowSelect
    stx MMC3_BANK_SELECT
    clc
    adc #1
    sta MMC3_BANK_DATA
lda farcall_regs
ldx farcall_regs+1
ldy farcall_regs+2
    rts

@DoFarCall:
    ldy #1
    lda (call_ptr),y
    pha
    iny
    lda (call_ptr),y
    pha
    iny
    lda (call_ptr),y
    ldx #%00000110
    stx ShadowSelect
    stx MMC3_BANK_SELECT
    sta MMC3_BANK_DATA
    inx
    stx ShadowSelect
    stx MMC3_BANK_SELECT
    clc
    adc #1
    sta MMC3_BANK_DATA
    rts