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