macro Switch_Bank arg1
    pha
    lda #arg1
    sta bank0
    jsr switchBNK
    pla
endm

macro Bank_NoSave arg1
    pha
    lda #arg1
    jsr switchBNK
    pla
endm

macro Original_Bank
    pha
    lda bank0
    jsr switchBNK
    pla
endm

macro jcc address
    .db $b0, 3
    jmp address
endm
macro jcs address
    .db $90, 3
    jmp address
endm
macro jeq address
    .db $d0, 3
    jmp address
endm
macro jne address
    .db $f0, 3
    jmp address
endm
macro jmi address
    .db $10, 3
    jmp address
endm
macro jvc address
    .db $70, 3
    jmp address
endm
macro jvs address
    .db $50, 3
    jmp address
endm