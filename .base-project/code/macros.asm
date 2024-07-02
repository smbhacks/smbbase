;Bankswitching .macros---------------------------------------------------------------------
.macro Switch_Bank arg1
    pha
    lda #arg1
    sta bank0
    jsr switchBNK
    pla
.endmacro

.macro Bank_NoSave arg1
    pha
    lda #arg1
    jsr switchBNK
    pla
.endmacro

.macro Original_Bank
    pha
    lda bank0
    jsr switchBNK
    pla
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