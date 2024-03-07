;ATTENTION!!!!!
;--------------
;If a text has a <!!!> mark, that means it should have 
;a shared length with other <!!!> text. Keep an eye out for that!
;Some characters don't translate to SMB1 well
;For numbers, you can just input the number
;For the rest, use labels for them:
space = $24
coin = $2e
cross = $29
dash = $28
exclamation = $2b
period = $2c
t = $37
;Example text: 5 TIMES 5 EQUALS 25
;What you need to input: .db 5, space, "TIMES"-t, space, 5, space, "EQUALS"-t, space, 2, 5

;--END OF CASTLE--
MarioThanksMessage:
;"THANK YOU MARIO!"
    .db $25, $48, @e-@s
@s
    .db "THANK"-t, space, "YOU"-t, space, "MARIO"-t, exclamation
@e
    .db $00 ;eod

LuigiThanksMessage:
;"THANK YOU LUIGI!"
    .db $25, $48, @e-@s
@s
    .db "THANK"-t, space, "YOU"-t, space, "LUIGI"-t, exclamation
@e
    .db $00 ;eod

MushroomRetainerSaved:
;"BUT OUR PRINCESS IS IN"
    .db $25, $c5, @e-@s
@s
    .db "BUT"-t, space, "OUR"-t, space, "PRINCESS"-t, space, "IS"-t, space, "IN"-t
@e

;"ANOTHER CASTLE!"
    .db $26, $05, @e2-@s2
@s2
    .db "ANOTHER"-t, space, "CASTLE"-t, exclamation
@e2
    .db $00 ;eod

PrincessSaved1:
;"YOUR QUEST IS OVER."
    .db $25, $a7, @e-@s
@s
    .db "YOUR"-t, space, "QUEST"-t, space, "IS"-t, space, "OVER"-t, period
@e
    .db $00 ;eod
    
PrincessSaved2:
;"WE PRESENT YOU A NEW QUEST."
    .db $25, $e3, @e-@s
@s
    .db "WE"-t, space, "PRESENT"-t, space, "YOU"-t, space, "A"-t, space, "NEW"-t, space, "QUEST"-t, period
@e
    .db $00 ;eod

WorldSelectMessage1:
;"PUSH BUTTON B"
    .db $26, $4a, @e-@s
@s
    .db "PUSH"-t, space, "BUTTON"-t, space, "B"-t
@e
    .db $00 ;eod
    
WorldSelectMessage2:
;"TO SELECT A WORLD"
    .db $26, $88, @e-@s
@s
    .db "TO"-t, space, "SELECT"-t, space, "A"-t, space, "WORLD"-t
@e
    .db $00 ;eod

;--STATUSBAR--
TopStatusBarLine:
;Mario
    .db $20, $43, @e-@s
@s
    .db "MARIO"-t
@e

;World & Time
    .db $20, $52, @e2-@s2
@s2
    .db "WORLD"-t, space, space, "TIME"-t
@e2

;Score trail (0) and coin indicator (coin icon and the x)
    .db $20, $68, @e3-@s3
@s3
    .db 0, space, space, coin, cross
@e3
    
;Misc. attributes
    .db $23, $c0, $7f, $aa ;attribute table data, clears name table 0 to palette 2
    .db $23, $c2, $01, $ea ;attribute table data, used for coin icon in status bar
    .db $ff ;eod

;--TRANSITION SCREEN--
WorldLivesDisplay:
;Cross, clear lives display
    .db $21, $cd, @e-@s
@s
    .db space, space, cross, space, space, space, space
@e

;World and the dash
    .db $21, $4b, @e2-@s2
@s2
    .db "WORLD"-t, space, space, dash, space
@e2

;Misc. attributes
    .db $22, $0c, $47, $24 ;possibly used to clear time up
    .db $23, $dc, $01, $ba ;attribute table data for crown if more than 9 lives
    .db $ff ;eod

LuigiName:
;<!!!>
  .db "LUIGI"-t

;--TIME UP--
TwoPlayerTimeUp:
;<!!!>
;2 players, Mario event 
    .db $21, $cd, @e-@s
@s
    .db "MARIO"-t
@e
    
OnePlayerTimeUp:
;Time up display
    .db $22, $0c, txt_timeup_end - txt_timeup_start
txt_timeup_start
    .db "TIME"-t, space, "UP"-t
txt_timeup_end
    .db $ff ;eod

;--GAME OVER--
TwoPlayerGameOver:
;<!!!>
;2 players, Mario event 
    .db $21, $cd, @e-@s
@s
    .db "MARIO"-t
@e

OnePlayerGameOver:
;Game Over display
    .db $22, $0b, @e-@s
@s
    .db "GAME"-t, space, "OVER"-t
@e
    .db $ff ;eod

;--WARP ZONE--
WarpZoneWelcome:
;Welcome to Warp Zone!
    .db $25, $84, @e-@s
@s
    .db "WELCOME"-t, space, "TO"-t, space, "WARP"-t, space, "ZONE"-t, exclamation
@e
;Misc.
    .db $26, $25, $01, $24 ;placeholder for left pipe
    .db $26, $2d, $01, $24 ;placeholder for middle pipe
    .db $26, $35, $01, $24 ;placeholder for right pipe
    .db $27, $d9, $46, $aa ;attribute data
    .db $27, $e1, $45, $aa
    .db $ff ;eod

GameTextOffsets:
  .db TopStatusBarLine-TopStatusBarLine, TopStatusBarLine-TopStatusBarLine
  .db WorldLivesDisplay-TopStatusBarLine, WorldLivesDisplay-TopStatusBarLine
  .db TwoPlayerTimeUp-TopStatusBarLine, OnePlayerTimeUp-TopStatusBarLine
  .db TwoPlayerGameOver-TopStatusBarLine, OnePlayerGameOver-TopStatusBarLine
  .db WarpZoneWelcome-TopStatusBarLine, WarpZoneWelcome-TopStatusBarLine