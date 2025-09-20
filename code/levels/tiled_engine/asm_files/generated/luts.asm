LevelAreaTypes:
    .byte 1
LevelTimersLo:
    .lobytes 123
LevelTimersHi:
    .hibytes 123
LevelFgPtrsLo:
    .lobytes _1_1_foreground
LevelFgPtrsHi:
    .hibytes _1_1_foreground
LevelBgPtrsLo:
    .lobytes _1_1_background
LevelBgPtrsHi:
    .hibytes _1_1_background
LevelFgBanks:
    .byte <.bank(_1_1_foreground)
LevelBgBanks:
    .byte <.bank(_1_1_background)
