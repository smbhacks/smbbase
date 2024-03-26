;Bankswitching .macros---------------------------------------------------------------------
;These preserve X, but not the A register!
.macro NEW_BANK bankval
    num_of_bank_macros .set num_of_bank_macros + 1
    lda bankval
    jsr newBNK
.endmacro

.macro RESTORE_BANK
    num_of_bank_macros .set num_of_bank_macros + 1
    jsr restoreBNK
.endmacro

.macro SWITCH_BANK bankval
    num_of_bank_macros .set num_of_bank_macros + 1
    lda bankval
    jsr switchBNK
.endmacro

.macro LATEST_BANK
    num_of_bank_macros .set num_of_bank_macros + 1
    jsr latestBNK
.endmacro

;These macros dont preserve X!
.macro MMC3_PRIMARY_BANKSWITCH bankval
    num_of_bank_macros .set num_of_bank_macros + 1
    ldx bankval
    jsr mmc3_bankswitch_primary
.endmacro

.macro MMC3_SECONDARY_BANKSWITCH bankval
    num_of_bank_macros .set num_of_bank_macros + 1
    ldx bankval
    jsr mmc3_bankswitch_secondary
.endmacro

.macro far_call address
    .assert .bank(address) <> .bank(*), warning, "Make this a near_call!"
    .assert .bank(address) <> .bank(Start), warning, "Make this a fixed_call!"
    num_of_farcalls .set num_of_farcalls + 1
    jsr FarCallRoutine
    .byte .hibyte(address-1)
    .byte .lobyte(address-1)
    .byte .bank(address)
.endmacro

.macro near_call address
    .assert .bank(address) = .bank(Start) || .bank(address) = .bank(*), warning, "Make this a far_call!"
    .assert .bank(address) <> .bank(Start), warning, "Make this a fixed_call!"
    jsr address
.endmacro

.macro fixed_call address
    .assert .bank(address) <> .bank(*) || .bank(address) = .bank(Start), warning, "Make this a near_call!"
    .assert .bank(address) = .bank(*) || .bank(address) = .bank(Start), warning, "Make this a far_call!"
    jsr address
.endmacro

;Long branch .macros---------------------------------------------------------------------
.macro jcc address
    .byte $b0, 3
    jmp address
.endmacro
.macro jcs address
    .byte $90, 3
    jmp address
.endmacro
.macro jeq address
    .byte $d0, 3
    jmp address
.endmacro
.macro jne address
    .byte $f0, 3
    jmp address
.endmacro
.macro jmi address
    .byte $10, 3
    jmp address
.endmacro
.macro jvc address
    .byte $70, 3
    jmp address
.endmacro
.macro jvs address
    .byte $50, 3
    jmp address
.endmacro