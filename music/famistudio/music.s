; This file is for the FamiStudio Sound Engine and was generated by FamiStudio

.if FAMISTUDIO_CFG_C_BINDINGS
.export _music_data_=music_data_
.endif

music_data_:
	.byte 13
	.word @instruments
	.word @samples-4
; 00 : Overworld
	.word @song0ch0
	.word @song0ch1
	.word @song0ch2
	.word @song0ch3
	.word @song0ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 01 : Waterworld
	.word @song1ch0
	.word @song1ch1
	.word @song1ch2
	.word @song1ch3
	.word @song1ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 02 : Underworld
	.word @song2ch0
	.word @song2ch1
	.word @song2ch2
	.word @song2ch3
	.word @song2ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 03 : Castleworld
	.word @song3ch0
	.word @song3ch1
	.word @song3ch2
	.word @song3ch3
	.word @song3ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 04 : Cloud
	.word @song4ch0
	.word @song4ch1
	.word @song4ch2
	.word @song4ch3
	.word @song4ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 05 : Enter in a pipe
	.word @song5ch0
	.word @song5ch1
	.word @song5ch2
	.word @song5ch3
	.word @song5ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 06 : Starman
	.word @song6ch0
	.word @song6ch1
	.word @song6ch2
	.word @song6ch3
	.word @song6ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 07 : Death
	.word @song7ch0
	.word @song7ch1
	.word @song7ch2
	.word @song7ch3
	.word @song7ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 08 : Game Over
	.word @song8ch0
	.word @song8ch1
	.word @song8ch2
	.word @song8ch3
	.word @song8ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 09 : You saved the princess
	.word @song9ch0
	.word @song9ch1
	.word @song9ch2
	.word @song9ch3
	.word @song9ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 0a : In an other castle
	.word @song10ch0
	.word @song10ch1
	.word @song10ch2
	.word @song10ch3
	.word @song10ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 0b : Victory
	.word @song11ch0
	.word @song11ch1
	.word @song11ch2
	.word @song11ch3
	.word @song11ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0
; 0c : Hurry up
	.word @song12ch0
	.word @song12ch1
	.word @song12ch2
	.word @song12ch3
	.word @song12ch4
	.byte .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), 0, 0

.export music_data_
.global FAMISTUDIO_DPCM_PTR

@instruments:
	.word @env7,@env6,@env10,@env0 ; 00 : Noise short
	.word @env2,@env6,@env10,@env0 ; 01 : Noise long
	.word @env1,@env6,@env11,@env0 ; 02 : Instrumental
	.word @env3,@env6,@env10,@env0 ; 03 : Triangle
	.word @env12,@env6,@env14,@env0 ; 04 : Long instrumental
	.word @env4,@env6,@env10,@env0 ; 05 : Blank
	.word @env13,@env5,@env11,@env0 ; 06 : Death effect
	.word @env8,@env6,@env11,@env0 ; 07 : Instrumental 2
	.word @env9,@env5,@env11,@env0 ; 08 : Death effect 2
	.word @env15,@env6,@env11,@env0 ; 09 : Death instrument

@env0:
	.byte $00,$c0,$7f,$00,$02
@env1:
	.byte $00,$c0,$c8,$c7,$c6,$c5,$c5,$c4,$c4,$c0,$00,$09
@env2:
	.byte $00,$cc,$04,$c0,$00,$03
@env3:
	.byte $00,$cf,$07,$c0,$00,$03
@env4:
	.byte $00,$cf,$7f,$00,$02
@env5:
	.byte $c0,$bf,$be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$00,$0a
@env6:
	.byte $c0,$7f,$00,$01
@env7:
	.byte $00,$cc,$c0,$00,$02
@env8:
	.byte $00,$c0,$cb,$ca,$c9,$c8,$00,$05
@env9:
	.byte $00,$c8,$c4,$c0,$00,$03
@env10:
	.byte $7f,$00,$00
@env11:
	.byte $c2,$7f,$00,$00
@env12:
	.byte $00,$c5,$c3,$c4,$c5,$c5,$c6,$10,$c5,$05,$c4,$05,$c3,$02,$c2,$c2,$c1,$c0,$00,$11
@env13:
	.byte $00,$ce,$cc,$cb,$ca,$c8,$c7,$c6,$c4,$c3,$c2,$c0,$00,$0b
@env14:
	.byte $c0,$c2,$00,$01
@env15:
	.byte $00,$ce,$cd,$cb,$ca,$c9,$c7,$c6,$c5,$c3,$c2,$c1,$c0,$00,$0c

@samples:

@tempo_env_1_mid:
	.byte $03,$05,$80

@song0ch0:
@song0ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $84
@song0ref6:
	.byte $1f, $8f, $1f, $a1, $1f, $a1, $1f, $8f, $1f, $a1, $24, $c5, $20, $c5
@song0ref20:
	.byte $48, $1d, $b3, $19, $b3, $14, $b3, $19, $a1, $1b, $a1, $1a, $8f, $19, $a1, $48, $19, $95, $20, $95, $24, $95, $25, $a1
	.byte $22, $8f, $24, $a1, $22, $a1, $1d, $8f, $1e, $8f, $1b, $b3
	.byte $41, $22
	.word @song0ref20
@song0ref59:
	.byte $48, $a3, $29, $8f, $28, $8f, $27, $8f, $24, $a1, $25, $a1, $1d, $8f, $1e, $8f, $20, $a1, $19, $8f, $1d, $8f, $1e, $8f
	.byte $48, $a3, $29, $8f, $28, $8f, $27, $8f, $24, $a1, $25, $a1, $2a, $a1, $2a, $8f, $2a, $c5
	.byte $41, $18
	.word @song0ref59
	.byte $21, $b3, $1e, $b3, $1d, $ff, $8d
	.byte $41, $28
	.word @song0ref59
	.byte $41, $18
	.word @song0ref59
	.byte $21, $b3, $1e, $b3, $1d, $ff, $8d
@song0ref124:
	.byte $48, $21, $8f, $21, $a1, $21, $a1, $21, $8f, $23, $a1, $20, $8f, $1d, $a1, $1d, $8f, $19, $c5, $48, $21, $8f, $21, $a1
	.byte $21, $a1, $21, $8f, $23, $8f, $20, $ff, $9f
	.byte $41, $12
	.word @song0ref124
	.byte $48
	.byte $41, $30
	.word @song0ref6
	.byte $41, $22
	.word @song0ref20
@song0ref167:
	.byte $48, $25, $8f, $22, $a1, $1d, $b3, $1d, $a1, $1e, $8f, $25, $a1, $25, $8f, $1e, $c5, $48, $20, $95, $2a, $95, $2a, $95
	.byte $2a, $95, $29, $95, $27, $95, $25, $95, $22, $95, $1e, $95, $1d, $c5
	.byte $41, $12
	.word @song0ref167
@song0ref208:
	.byte $27, $9b, $27, $8f, $27, $95, $25, $95, $24, $95, $20, $8f, $1d, $a1, $1d, $8f, $19, $c5
	.byte $41, $24
	.word @song0ref167
	.byte $41, $12
	.word @song0ref167
	.byte $41, $12
	.word @song0ref208
	.byte $41, $1f
	.word @song0ref124
	.byte $41, $12
	.word @song0ref124
	.byte $48
	.byte $41, $0e
	.word @song0ref6
	.byte $41, $24
	.word @song0ref167
	.byte $41, $12
	.word @song0ref167
	.byte $41, $12
	.word @song0ref208
	.byte $42
	.word @song0ch0loop
@song0ch1:
@song0ch1loop:
	.byte $84
@song0ref259:
	.byte $29, $8f, $29, $a1, $29, $a1, $25, $8f, $29, $a1, $2c, $ff, $8d
@song0ref272:
	.byte $25, $b3, $20, $b3, $1d, $b3, $22, $a1, $24, $a1, $23, $8f, $22, $a1, $20, $95, $29, $95, $2c, $95, $2e, $a1, $2a, $8f
	.byte $2c, $a1, $29, $a1, $25, $8f, $27, $8f, $24, $b3
	.byte $41, $22
	.word @song0ref272
@song0ref309:
	.byte $a3, $2c, $8f, $2b, $8f, $2a, $8f, $28, $a1, $29, $a1, $21, $8f, $22, $8f, $25, $a1, $22, $8f, $25, $8f, $27, $8f, $a3
	.byte $2c, $8f, $2b, $8f, $2a, $8f, $28, $a1, $29, $a1, $31, $a1, $31, $8f, $31, $c5
	.byte $41, $18
	.word @song0ref309
	.byte $28, $b3, $27, $b3, $25, $ff, $8d
	.byte $41, $28
	.word @song0ref309
	.byte $41, $18
	.word @song0ref309
	.byte $28, $b3, $27, $b3, $25, $ff, $8d
@song0ref372:
	.byte $25, $8f, $25, $a1, $25, $a1, $25, $8f, $27, $a1, $29, $8f, $25, $a1, $22, $8f, $20, $c5, $25, $8f, $25, $a1, $25, $a1
	.byte $25, $8f, $27, $8f, $29, $ff, $9f
	.byte $41, $12
	.word @song0ref372
	.byte $41, $2f
	.word @song0ref259
	.byte $41, $22
	.word @song0ref272
@song0ref412:
	.byte $29, $8f, $25, $a1, $20, $b3, $21, $a1, $22, $8f, $2a, $a1, $2a, $8f, $22, $c5, $24, $95, $2e, $95, $2e, $95, $2e, $95
	.byte $2c, $95, $2a, $95, $29, $95, $25, $95, $22, $95, $20, $c5
	.byte $41, $12
	.word @song0ref412
@song0ref451:
	.byte $2a, $9b, $2a, $8f, $2a, $95, $29, $95, $27, $95, $25, $ff, $8d
	.byte $41, $24
	.word @song0ref412
	.byte $41, $12
	.word @song0ref412
	.byte $41, $0d
	.word @song0ref451
	.byte $41, $1f
	.word @song0ref372
	.byte $41, $12
	.word @song0ref372
	.byte $41, $0d
	.word @song0ref259
	.byte $41, $24
	.word @song0ref412
	.byte $41, $12
	.word @song0ref412
	.byte $41, $0d
	.word @song0ref451
	.byte $42
	.word @song0ch1loop
@song0ch2:
@song0ch2loop:
	.byte $86
@song0ref496:
	.byte $1b, $8f, $1b, $a1, $1b, $a1, $1b, $8f, $1b, $a1, $2c, $c5, $20, $c5
@song0ref510:
	.byte $20, $b3, $1d, $b3, $19, $b3, $1e, $a1, $20, $a1, $1f, $8f, $1e, $a1, $84, $1d, $95, $25, $95, $29, $95, $2a, $a1, $27
	.byte $8f, $29, $a1, $25, $a1, $22, $8f, $24, $8f, $20, $b3, $86
	.byte $41, $22
	.word @song0ref510
@song0ref549:
	.byte $19, $b3, $20, $b3, $25, $a1, $1e, $b3, $25, $8f, $25, $a1, $1e, $a1, $19, $b3, $1d, $b3, $20, $8f, $25, $a1, $38, $a1
	.byte $38, $8f, $38, $a1, $20, $a1
	.byte $41, $0e
	.word @song0ref549
@song0ref582:
	.byte $86, $19, $a1, $21, $b3, $23, $b3, $25, $b3, $20, $8f, $20, $a1, $19, $a1, $84
	.byte $41, $1e
	.word @song0ref549
	.byte $41, $0e
	.word @song0ref549
	.byte $41, $0e
	.word @song0ref582
@song0ref607:
	.byte $15, $b3, $1c, $b3, $21, $a1, $20, $b3, $19, $b3, $14, $a1, $15, $b3, $1c, $b3, $21, $a1, $20, $b3, $19, $b3, $14, $a1
	.byte $15, $b3, $1c, $b3, $21, $a1, $20, $b3, $19, $b3, $14, $a1
	.byte $41, $30
	.word @song0ref496
	.byte $86
	.byte $41, $22
	.word @song0ref510
@song0ref650:
	.byte $86
@song0ref651:
	.byte $19, $b3, $1f, $8f, $20, $a1, $25, $a1, $1e, $a1, $1e, $a1, $25, $8f, $25, $8f, $1e, $a1, $1b, $b3, $1e, $8f, $20, $a1
	.byte $24, $a1, $20, $a1, $20, $a1, $25, $8f, $25, $8f, $20, $a1
	.byte $41, $12
	.word @song0ref651
@song0ref690:
	.byte $84, $20, $b3, $20, $8f, $20, $95, $22, $95, $24, $95, $25, $a1, $20, $a1, $19, $c5
	.byte $41, $24
	.word @song0ref650
	.byte $41, $12
	.word @song0ref651
	.byte $41, $10
	.word @song0ref690
	.byte $86
	.byte $41, $24
	.word @song0ref607
	.byte $41, $0e
	.word @song0ref496
	.byte $41, $24
	.word @song0ref651
	.byte $41, $12
	.word @song0ref651
	.byte $41, $10
	.word @song0ref690
	.byte $42
	.word @song0ch2loop
@song0ch3:
@song0ch3loop:
@song0ref736:
	.byte $82, $20, $a1, $80, $20, $8f, $82, $20, $a1, $80, $20, $8f, $82, $20, $a1, $20, $b3, $20, $a1, $80, $20, $8f, $20, $8f
	.byte $20, $8f
@song0ref762:
	.byte $17, $a1, $20, $95, $20, $89, $82, $20, $a1, $80, $20, $95, $20, $89, $17, $a1, $20, $95, $20, $89, $82, $20, $a1, $80
	.byte $20, $95, $20, $89
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $14
	.word @song0ref736
	.byte $41, $14
	.word @song0ref736
	.byte $41, $14
	.word @song0ref736
	.byte $41, $2c
	.word @song0ref736
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
	.byte $41, $18
	.word @song0ref762
@song0ref844:
	.byte $20, $b3, $20, $8f, $82, $20, $a1, $80, $20, $a1, $20, $b3, $20, $8f, $82, $20, $a1, $80, $20, $a1
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $14
	.word @song0ref736
	.byte $41, $14
	.word @song0ref736
	.byte $41, $14
	.word @song0ref736
	.byte $41, $14
	.word @song0ref736
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $41, $10
	.word @song0ref844
	.byte $42
	.word @song0ch3loop
@song0ch4:
@song0ch4loop:
@song0ref913:
	.byte $ff, $ff, $9f, $ff, $ff, $9f, $ff, $ff, $9f, $ff, $ff, $9f, $ff, $ff, $9f
	.byte $41, $0f
	.word @song0ref913
	.byte $41, $0f
	.word @song0ref913
	.byte $41, $0f
	.word @song0ref913
	.byte $41, $0f
	.word @song0ref913
	.byte $41, $0f
	.word @song0ref913
	.byte $41, $0f
	.word @song0ref913
	.byte $ff, $ff, $9f, $ff, $ff, $9f, $42
	.word @song0ch4loop
@song1ch0:
@song1ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $88, $1b, $9d, $1a, $9d, $19, $9d, $18, $9d, $19, $9d, $1a
	.byte $9d, $1b, $8d, $1b, $8d, $1b, $8d, $00, $8d, $1d, $8d, $00, $8d, $1e, $cd, $00, $8d, $48, $20, $dd, $1f, $dd, $20, $ff
	.byte $bd, $48, $20, $dd, $1f, $bd, $22, $9d, $20, $ff, $bd, $48, $1e, $dd, $1d, $dd, $1e, $ff, $bd, $48, $1e, $dd, $18, $bd
	.byte $22, $9d, $20, $ff, $bd, $48, $29, $dd, $27, $dd, $26, $ff, $bd, $48, $27, $dd, $26, $dd, $25, $ff, $bd, $48, $19, $dd
	.byte $1e, $9d, $20, $9d, $24, $9d, $24, $8d, $24, $8d, $24, $ad, $1e, $8d, $1d, $dd, $42
	.word @song1ch0loop
@song1ch1:
@song1ch1loop:
	.byte $88, $1b, $9d, $1d, $9d, $1f, $9d, $20, $9d, $22, $9d, $23, $9d, $24, $8d, $24, $8d, $24, $8d, $00, $8d, $24, $8d, $00
	.byte $8d, $24, $bd, $20, $9d, $29, $dd, $28, $dd, $29, $ed, $20, $8d, $22, $8d, $24, $8d, $25, $8d, $27, $8d, $29, $dd, $28
	.byte $bd, $2a, $9d, $29, $ff, $ad, $20, $8d, $27, $dd, $26, $dd, $27, $ed, $20, $8d, $22, $8d, $24, $8d, $25, $8d, $26, $8d
	.byte $27, $dd, $20, $bd, $2a, $9d, $29, $ff, $ad, $20, $8d, $2c, $dd, $2c, $dd, $2c, $dd, $2c, $9d, $2e, $8d, $00, $9d, $2c
	.byte $8d, $2a, $dd, $2a, $dd, $2a, $dd, $2a, $9d, $2c, $8d, $00, $9d, $2a, $8d, $29, $dd, $22, $9d, $24, $9d, $2a, $9d, $29
	.byte $8d, $29, $8d, $29, $ad, $24, $8d, $25, $dd, $42
	.word @song1ch1loop
@song1ch2:
@song1ch2loop:
	.byte $00, $ff, $fd, $8a, $20, $8d, $00, $8d, $20, $dd
@song1ref252:
	.byte $19
@song1ref253:
	.byte $8d, $00, $8d, $20, $8d, $00, $8d, $25
@song1ref261:
	.byte $8d, $00, $8d
@song1ref264:
	.byte $18
@song1ref265:
	.byte $8d, $00, $8d, $20, $8d, $00, $8d, $24, $8d, $00, $8d
	.byte $41, $0c
	.word @song1ref252
	.byte $1d
	.byte $41, $0b
	.word @song1ref253
	.byte $41, $18
	.word @song1ref252
	.byte $41, $0c
	.word @song1ref252
	.byte $1d
	.byte $41, $0b
	.word @song1ref253
	.byte $1b
	.byte $41, $0b
	.word @song1ref265
	.byte $1a, $8d, $00, $8d, $1f, $8d, $00, $8d, $23, $8d, $00, $8d, $1b
	.byte $41, $0b
	.word @song1ref265
	.byte $41, $0c
	.word @song1ref264
	.byte $1b
	.byte $41, $0b
	.word @song1ref265
	.byte $41, $0c
	.word @song1ref264
	.byte $41, $0c
	.word @song1ref252
	.byte $14
	.byte $41, $0b
	.word @song1ref253
	.byte $19, $8d, $00, $8d, $20, $8d, $00, $8d, $29
	.byte $41, $0b
	.word @song1ref261
	.byte $27, $8d, $00, $8d, $17, $8d, $00, $8d, $20, $8d, $00, $8d, $26, $8d, $00, $8d, $1a
@song1ref359:
	.byte $8d, $00, $8d, $20, $8d, $00, $8d, $29, $8d, $00, $8d, $1b
@song1ref371:
	.byte $8d, $00, $8d, $22, $8d, $00, $8d, $2a, $8d, $00, $8d, $1a
	.byte $41, $0b
	.word @song1ref371
	.byte $19
	.byte $41, $0b
	.word @song1ref371
	.byte $18, $8d, $00, $8d, $20, $8d, $00, $8d, $2a, $8d, $00, $8d, $0d
	.byte $41, $0b
	.word @song1ref359
	.byte $14, $8d, $00, $8d, $20, $8d, $00, $8d, $20, $8d, $00, $8d, $1e, $cd, $18, $8d, $19, $dd, $42
	.word @song1ch2loop
@song1ch3:
@song1ch3loop:
@song1ref428:
	.byte $9f, $80, $20, $9d, $82, $20, $bd, $80, $20, $8d, $20, $8d, $82, $20, $bd, $80, $20, $9d, $82, $20, $bd, $80, $20, $8d
	.byte $20, $8d, $82, $20, $9d
	.byte $41, $15
	.word @song1ref428
	.byte $41, $15
	.word @song1ref428
	.byte $41, $15
	.word @song1ref428
	.byte $41, $15
	.word @song1ref428
	.byte $41, $15
	.word @song1ref428
	.byte $41, $15
	.word @song1ref428
	.byte $41, $15
	.word @song1ref428
	.byte $42
	.word @song1ch3loop
@song1ch4:
@song1ch4loop:
@song1ref482:
	.byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	.byte $41, $0b
	.word @song1ref482
	.byte $ff, $ff, $42
	.word @song1ch4loop
@song2ch0:
@song2ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $ff, $ff, $ff, $af, $48, $ff, $ff, $ff, $af, $48, $ff, $ff
	.byte $ff, $af, $48, $ff, $d7, $42
	.word @song2ch0loop
@song2ch1:
@song2ch1loop:
	.byte $84
@song2ref27:
	.byte $19, $8f, $25, $8f, $16, $8f, $22, $8f, $17, $8f, $23, $fb, $19, $8f, $25, $8f, $16, $8f, $22, $8f, $17, $8f, $23, $fb
	.byte $12, $8f, $1e, $8f, $0f, $8f, $1b, $8f, $10, $8f, $1c, $fb, $12, $8f, $1e, $8f, $0f, $8f, $1b, $8f, $10, $8f, $1c, $d7
	.byte $1c, $89, $1b, $89, $1a, $89, $19, $a1, $1c, $a1, $1b, $a1, $15, $a1, $14, $a1, $1a, $a1, $19, $89, $1f, $89, $1e, $89
	.byte $1d, $89, $23, $89, $22, $89, $21, $95, $1c, $95, $18, $95, $17, $95, $16, $95, $15, $95, $ff, $d7, $42
	.word @song2ch1loop
@song2ch2:
@song2ch2loop:
	.byte $86
	.byte $41, $5c
	.word @song2ref27
	.byte $42
	.word @song2ch2loop
@song2ch3:
@song2ch3loop:
@song2ref131:
	.byte $ff, $ff, $ff, $af, $ff, $ff, $ff, $af, $ff, $ff, $ff, $af, $ff, $d7, $42
	.word @song2ch3loop
@song2ch4:
@song2ch4loop:
	.byte $41, $0e
	.word @song2ref131
	.byte $42
	.word @song2ch4loop
@song3ch0:
@song3ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $89, $84
@song3ref7:
	.byte $27, $91, $26, $91, $25, $91, $26, $91, $27, $91, $28, $91, $27, $91, $26, $91
	.byte $41, $0f
	.word @song3ref7
	.byte $87, $48, $89
@song3ref29:
	.byte $26, $91, $25, $91, $26, $91, $27, $91, $26, $91, $27, $91, $26, $91, $25, $91
	.byte $41, $0f
	.word @song3ref29
	.byte $87, $48, $89
@song3ref51:
	.byte $2a, $91, $2b, $91, $2a, $91, $29, $91, $2a, $91, $29, $91, $28, $91, $29, $91
	.byte $41, $0f
	.word @song3ref51
	.byte $87, $42
	.word @song3ch0loop
@song3ch1:
@song3ch1loop:
	.byte $84
@song3ref76:
	.byte $20, $87, $23, $87, $20, $87, $22, $87, $20, $87, $21, $87, $20, $87, $22, $87, $20, $87, $23, $87, $20, $87, $24, $87
	.byte $20, $87, $23, $87, $20, $87, $22, $87
	.byte $41, $20
	.word @song3ref76
@song3ref111:
	.byte $1f, $87, $22, $87, $1f, $87, $21, $87, $1f, $87, $22, $87, $1f, $87, $23, $87, $1f, $87, $22, $87, $1f, $87, $23, $87
	.byte $1f, $87, $22, $87, $1f, $87, $21, $87
	.byte $41, $20
	.word @song3ref111
@song3ref146:
	.byte $23, $87, $27, $87, $23, $87, $28, $87, $23, $87, $27, $87, $23, $87, $26, $87, $23, $87, $27, $87, $23, $87, $26, $87
	.byte $23, $87, $25, $87, $23, $87, $26, $87
	.byte $41, $20
	.word @song3ref146
	.byte $42
	.word @song3ch1loop
@song3ch2:
@song3ch2loop:
	.byte $8a, $1c, $ff, $9d, $1b, $cd, $1f, $cd, $1e, $ff, $9d, $1d, $cd, $23, $cd, $22, $cd, $1d, $cd, $1c, $cd, $1d, $cd, $42
	.word @song3ch2loop
@song3ch3:
@song3ch3loop:
	.byte $ff, $ff, $bf, $ff, $ff, $bf, $ff, $ff, $bf, $42
	.word @song3ch3loop
@song3ch4:
@song3ch4loop:
	.byte $ff, $ff, $bf, $ff, $ff, $bf, $ff, $ff, $bf, $42
	.word @song3ch4loop
@song4ch0:
@song4ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $84, $1e, $95, $1e, $95, $1e, $95, $1b, $89, $1e, $95, $1e
	.byte $95, $1b, $89, $1e, $89, $1b, $89, $1e, $95, $48, $1d, $95, $1d, $95, $1d, $95, $19, $89, $1d, $95, $1d, $95, $19, $89
	.byte $1d, $89, $19, $89, $1d, $95, $42
	.word @song4ch0loop
@song4ch1:
@song4ch1loop:
	.byte $84, $25, $95, $25, $95, $25, $a1, $25, $89, $00, $89, $25, $a1, $25, $95, $25, $95, $24, $95, $24, $95, $24, $a1, $24
	.byte $89, $00, $89, $24, $a1, $24, $95, $24, $95, $42
	.word @song4ch1loop
@song4ch2:
@song4ch2loop:
	.byte $86, $1b, $ad, $22, $a1, $27, $b9, $22, $95, $27, $95, $19, $ad, $20, $a1, $25, $b9, $20, $95, $25, $95, $42
	.word @song4ch2loop
@song4ch3:
@song4ch3loop:
	.byte $80
@song4ref114:
	.byte $17, $95, $20, $8d, $20, $85, $82, $20, $95, $80, $20, $8d, $20, $85
	.byte $41, $0c
	.word @song4ref114
	.byte $41, $0c
	.word @song4ref114
	.byte $41, $0c
	.word @song4ref114
	.byte $42
	.word @song4ch3loop
@song4ch4:
@song4ch4loop:
	.byte $ff, $bf, $ff, $bf, $42
	.word @song4ch4loop
@song5ch0:
	.byte $84, $1f, $8f, $1f, $a1, $1f, $a1, $1f, $8f, $1f, $a1, $24, $c5, $20, $c5
@song5ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $c7, $42
	.word @song5ch0loop
@song5ch1:
	.byte $84, $29, $8f, $29, $a1, $29, $a1, $25, $8f, $29, $a1, $2c, $ff, $8d
@song5ch1loop:
	.byte $c7, $42
	.word @song5ch1loop
@song5ch2:
	.byte $86, $1b, $8f, $1b, $a1, $1b, $a1, $1b, $8f, $1b, $a1, $2c, $c5, $20, $c5
@song5ch2loop:
	.byte $c7, $42
	.word @song5ch2loop
@song5ch3:
	.byte $82, $20, $a1, $80, $20, $8f, $82, $20, $a1, $80, $20, $8f, $82, $20, $a1, $20, $b3, $20, $a1, $80, $20, $8f, $20, $8f
	.byte $20, $8f
@song5ch3loop:
	.byte $c7, $42
	.word @song5ch3loop
@song5ch4:
	.byte $ff, $ff, $9f
@song5ch4loop:
	.byte $c7, $42
	.word @song5ch4loop
@song6ch0:
@song6ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $84, $1e, $95, $1e, $95, $1e, $95, $1b, $89, $1e, $95, $1e
	.byte $95, $1b, $89, $1e, $89, $1b, $89, $1e, $95, $48, $1d, $95, $1d, $95, $1d, $95, $19, $89, $1d, $95, $1d, $95, $19, $89
	.byte $1d, $89, $19, $89, $1d, $95, $42
	.word @song6ch0loop
@song6ch1:
@song6ch1loop:
	.byte $84, $25, $95, $25, $95, $25, $a1, $25, $89, $00, $89, $25, $a1, $25, $95, $25, $95, $24, $95, $24, $95, $24, $a1, $24
	.byte $89, $00, $89, $24, $a1, $24, $95, $24, $95, $42
	.word @song6ch1loop
@song6ch2:
@song6ch2loop:
	.byte $86, $1b, $ad, $22, $a1, $27, $b9, $22, $95, $27, $95, $19, $ad, $20, $a1, $25, $b9, $20, $95, $25, $95, $42
	.word @song6ch2loop
@song6ch3:
@song6ch3loop:
	.byte $80
@song6ref114:
	.byte $17, $95, $20, $8d, $20, $85, $82, $20, $95, $80, $20, $8d, $20, $85
	.byte $41, $0c
	.word @song6ref114
	.byte $41, $0c
	.word @song6ref114
	.byte $41, $0c
	.word @song6ref114
	.byte $42
	.word @song6ch3loop
@song6ch4:
@song6ch4loop:
	.byte $ff, $bf, $ff, $bf, $42
	.word @song6ch4loop
@song7ch0:
	.byte $8c, $22, $83, $23, $83, $24, $83, $90, $21, $b3, $48, $8c, $1f, $8f, $26, $a1, $26, $8f, $26, $95, $24, $95, $23, $95
	.byte $1f, $8f, $1c, $a1, $1c, $8f, $18, $b3
@song7ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $c7, $42
	.word @song7ch0loop
@song7ch1:
	.byte $c7, $92, $24, $8f, $2a, $a1, $2a, $8f, $2a, $95, $29, $95, $27, $95, $25, $fb
@song7ch1loop:
	.byte $c7, $42
	.word @song7ch1loop
@song7ch2:
	.byte $c7, $86, $20, $b3, $20, $8f, $20, $95, $22, $95, $24, $95, $25, $a1, $20, $a1, $19, $b3
@song7ch2loop:
	.byte $c7, $42
	.word @song7ch2loop
@song7ch3:
	.byte $c7, $ff, $ff, $8d
@song7ch3loop:
	.byte $c7, $42
	.word @song7ch3loop
@song7ch4:
	.byte $c7, $ff, $ff, $8d
@song7ch4loop:
	.byte $c7, $42
	.word @song7ch4loop
@song8ch0:
	.byte $88, $1d, $8f, $00, $a1, $19, $8f, $00, $a1, $14, $a1, $1e, $c5, $1e, $e9, $1d, $8f, $1b, $8f, $1d, $c5, $00, $8f
@song8ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $c7, $42
	.word @song8ch0loop
@song8ch1:
	.byte $88, $25, $8f, $00, $a1, $20, $8f, $00, $a1, $1d, $a1, $22, $95, $24, $95, $22, $95, $21, $a1, $23, $a1, $21, $a1, $20
	.byte $fb
@song8ch1loop:
	.byte $c7, $42
	.word @song8ch1loop
@song8ch2:
	.byte $86, $20, $b3, $1d, $b3, $8a, $19, $a1, $1e, $c5, $1a, $e9, $19, $e9, $00, $8f
@song8ch2loop:
	.byte $c7, $42
	.word @song8ch2loop
@song8ch3:
	.byte $ff, $ff, $ff, $c1
@song8ch3loop:
	.byte $c7, $42
	.word @song8ch3loop
@song8ch4:
	.byte $ff, $ff, $ff, $c1
@song8ch4loop:
	.byte $c7, $42
	.word @song8ch4loop
@song9ch0:
	.byte $88, $20, $8d, $1f, $8d, $20, $8d
@song9ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $1d, $dd, $1e, $ad, $1f, $ad, $20, $dd, $25, $ad, $29, $a1
	.byte $29, $89, $48, $27, $ad, $29, $ad, $2a, $ad, $24, $ad, $27, $dd, $25, $ad, $20, $8d, $1f, $8d, $20, $8d, $42
	.word @song9ch0loop
@song9ch1:
	.byte $af
@song9ch1loop:
	.byte $88, $14, $dd, $16, $ad, $17, $ad, $18, $dd, $1d, $ad, $20, $ad, $1e, $ad, $20, $ad, $22, $ad, $1b, $ad, $1e, $ad, $00
	.byte $ad, $1d, $ad, $00, $ad, $42
	.word @song9ch1loop
@song9ch2:
	.byte $8a, $18, $ad
@song9ch2loop:
	.byte $19, $dd, $1b, $ad, $1c, $ad, $1d, $ad, $19, $ad, $22, $ad, $20, $ad, $1e, $ad, $1d, $ad, $1b, $ad, $1e, $ad, $20, $ad
	.byte $14, $ad, $19, $ad, $18, $ad, $42
	.word @song9ch2loop
@song9ch3:
	.byte $af
@song9ch3loop:
	.byte $ff, $ff, $ff, $ff, $ff, $ff, $42
	.word @song9ch3loop
@song9ch4:
	.byte $af
@song9ch4loop:
	.byte $ff, $ff, $ff, $ff, $ff, $ff, $42
	.word @song9ch4loop
@song10ch0:
	.byte $8e, $1d, $8d, $19, $8d, $14, $8d, $1d, $8d, $19, $8d, $14, $8d, $1d, $8d, $1d, $85, $1d, $85, $1d, $8d, $1d, $8d, $1d
	.byte $8d, $1d, $8d, $1e, $8d, $1a, $8d, $15, $8d, $1e, $8d, $1a, $8d, $15, $8d, $1e, $8d, $1e, $85, $1e, $85, $1e, $8d, $1e
	.byte $8d, $1e, $8d, $1e, $8d, $48, $20, $8d, $1c, $8d, $17, $8d, $20, $8d, $1c, $8d, $17, $8d, $20, $8d, $20, $85, $20, $85
	.byte $20, $8d, $22, $95, $22, $95, $22, $95, $24, $fd, $00, $a5
@song10ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $df, $42
	.word @song10ch0loop
@song10ch1:
	.byte $8e, $25, $8d, $20, $8d, $1d, $8d, $25, $8d, $20, $8d, $1d, $8d, $25, $dd, $26, $8d, $21, $8d, $1e, $8d, $26, $8d, $21
	.byte $8d, $1e, $8d, $26, $dd, $28, $8d, $23, $8d, $20, $8d, $28, $8d, $23, $8d, $20, $8d, $28, $ad, $2a, $95, $2a, $95, $2a
	.byte $95, $2c, $fd, $00, $a5
@song10ch1loop:
	.byte $df, $42
	.word @song10ch1loop
@song10ch2:
	.byte $8a, $19, $e5, $00, $85, $19, $95, $00, $85, $19, $85, $00, $85, $19, $85, $00, $85, $19, $85, $00, $85, $1a, $e5, $00
	.byte $85, $1a, $95, $00, $85, $1a, $85, $00, $85, $1a, $85, $00, $85, $1a
@song10ref189:
	.byte $85, $00, $85, $23, $85, $00, $85, $20, $85, $00, $85, $1c
	.byte $41, $0c
	.word @song10ref189
	.byte $85, $00, $85, $23, $85, $00, $85, $23, $95, $00, $85, $25, $85, $00, $8d, $25, $85, $00, $8d, $25, $85, $00, $8d, $27
	.byte $fd, $00, $a5
@song10ch2loop:
	.byte $df, $42
	.word @song10ch2loop
@song10ch3:
	.byte $ff, $ff, $ff, $ff, $ff, $ff
@song10ch3loop:
	.byte $df, $42
	.word @song10ch3loop
@song10ch4:
	.byte $ff, $ff, $ff, $ff, $ff, $ff
@song10ch4loop:
	.byte $df, $42
	.word @song10ch4loop
@song11ch0:
	.byte $8f, $88, $11, $8d
@song11ref5:
	.byte $14, $8d, $19, $8d, $1d, $8d, $20, $8d, $25, $ad, $20, $ad, $00, $8d, $10, $8d
@song11ref21:
	.byte $15, $8d, $19, $8d, $1c, $8d, $21, $8d, $25, $ad, $21, $ad, $48, $00, $8d, $12, $8d
@song11ref38:
	.byte $17, $8d, $1b, $8d, $1e, $8d, $23, $8d, $27, $ad, $27, $ad, $29, $c5, $00, $f5
@song11ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $ff, $bf, $42
	.word @song11ch0loop
@song11ch1:
	.byte $88
	.byte $41, $09
	.word @song11ref5
	.byte $8d, $29, $8d, $2c, $ad, $29, $ad
	.byte $41, $09
	.word @song11ref21
	.byte $8d, $28, $8d, $2d, $ad, $28, $ad
	.byte $41, $09
	.word @song11ref38
	.byte $8d, $2a, $8d, $2f, $ad, $2f, $8d, $2f, $8d, $2f, $8d, $31, $c5, $00, $f5
@song11ch1loop:
	.byte $ff, $bf, $42
	.word @song11ch1loop
@song11ch2:
	.byte $af, $8a, $19, $8d, $1d, $8d, $20, $8d, $29, $ad, $25, $8d, $00, $cd, $19, $8d, $1c, $8d, $21, $8d, $28, $ad, $25, $8d
	.byte $00, $9d, $af, $1b, $8d, $1e, $8d, $23, $8d, $2a, $ad, $27, $ad, $25, $c5, $00, $f5
@song11ch2loop:
	.byte $ff, $bf, $42
	.word @song11ch2loop
@song11ch3:
	.byte $ff, $ff, $ff, $ff, $ff, $ff
@song11ch3loop:
	.byte $ff, $bf, $42
	.word @song11ch3loop
@song11ch4:
	.byte $ff, $ff, $ff, $ff, $ff, $ff
@song11ch4loop:
	.byte $ff, $bf, $42
	.word @song11ch4loop
@song12ch0:
	.byte $88, $11, $89, $21, $95, $21, $89, $21, $95, $12, $89, $22, $95, $22, $89, $22, $95, $13, $89, $23, $95, $23, $89, $23
	.byte $95, $24, $95, $24, $dd
@song12ch0loop:
	.byte $47, .lobyte(@tempo_env_1_mid), .hibyte(@tempo_env_1_mid), $8b, $42
	.word @song12ch0loop
@song12ch1:
	.byte $88, $1d, $89, $27, $95, $27, $89, $27, $95, $1e, $89, $28, $95, $28, $89, $28, $95, $1f, $89, $29, $95, $29, $89, $29
	.byte $95, $2a, $95, $2a, $dd
@song12ch1loop:
	.byte $8b, $42
	.word @song12ch1loop
@song12ch2:
	.byte $86, $24, $89, $30, $95, $30, $89, $30, $95, $25, $89, $31, $95, $31, $89, $31, $95, $26, $89, $32, $95, $32, $89, $32
	.byte $95, $20, $95, $8a, $20, $ad, $00, $ad
@song12ch2loop:
	.byte $8b, $42
	.word @song12ch2loop
@song12ch3:
	.byte $ff, $ff, $cf
@song12ch3loop:
	.byte $8b, $42
	.word @song12ch3loop
@song12ch4:
	.byte $ff, $ff, $cf
@song12ch4loop:
	.byte $8b, $42
	.word @song12ch4loop
