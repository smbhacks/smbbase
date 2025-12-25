LevelAreaTypes:
    .byte 1
    .byte 2
LevelTimersLo:
    .lobytes 300
    .lobytes 300
LevelTimersHi:
    .hibytes 300
    .hibytes 300
LevelPlayerXs:
    .byte 48
    .byte 48
LevelPlayerYs:
    .byte 176
    .byte 176
LevelFgPtrsLo:
    .lobytes _1_1_foreground
    .lobytes _1_1_bonus_foreground
LevelFgPtrsHi:
    .hibytes _1_1_foreground
    .hibytes _1_1_bonus_foreground
LevelBgPtrsLo:
    .lobytes _1_1_background
    .lobytes _1_1_bonus_background
LevelBgPtrsHi:
    .hibytes _1_1_background
    .hibytes _1_1_bonus_background
LevelEntityPtrsLo:
    .lobytes _1_1_entities
    .lobytes _1_1_bonus_entities
LevelEntityPtrsHi:
    .hibytes _1_1_entities
    .hibytes _1_1_bonus_entities
LevelFgBanks:
    .byte <.bank(_1_1_foreground)
    .byte <.bank(_1_1_bonus_foreground)
LevelBgBanks:
    .byte <.bank(_1_1_background)
    .byte <.bank(_1_1_bonus_background)
LevelEntityBanks:
    .byte <.bank(_1_1_entities)
    .byte <.bank(_1_1_bonus_entities)
_1_1_id = 0
_1_1_bonus_id = 1
