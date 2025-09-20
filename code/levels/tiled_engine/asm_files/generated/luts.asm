LevelAreaTypes:
    .byte 1
LevelTimersLo:
    .lobytes 300
LevelTimersHi:
    .hibytes 300
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
