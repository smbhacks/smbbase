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
;What you need to input: .byte 5, space, "TIMES", space, 5, space, "EQUALS", space, 2, 5

;--END OF CASTLE--
MarioThanksMessage:
;"THANK YOU MARIO!"
    .byte $25, $48, @e-@s
@s:
    .byte "THANK", space, "YOU", space, "MARIO", exclamation
@e:
    .byte $00 ;eod

LuigiThanksMessage:
;"THANK YOU LUIGI!"
    .byte $25, $48, @e-@s
@s:
    .byte "THANK", space, "YOU", space, "LUIGI", exclamation
@e:
    .byte $00 ;eod

MushroomRetainerSaved:
;"BUT OUR PRINCESS IS IN"
    .byte $25, $c5, @e-@s
@s:
    .byte "BUT", space, "OUR", space, "PRINCESS", space, "IS", space, "IN"
@e:

;"ANOTHER CASTLE!"
    .byte $26, $05, @e2-@s2
@s2:
    .byte "ANOTHER", space, "CASTLE", exclamation
@e2:
    .byte $00 ;eod

PrincessSaved1:
;"YOUR QUEST IS OVER."
    .byte $25, $a7, @e-@s
@s:
    .byte "YOUR", space, "QUEST", space, "IS", space, "OVER", period
@e:
    .byte $00 ;eod
    
PrincessSaved2:
;"WE PRESENT YOU A NEW QUEST."
    .byte $25, $e3, @e-@s
@s:
    .byte "WE", space, "PRESENT", space, "YOU", space, "A", space, "NEW", space, "QUEST", period
@e:
    .byte $00 ;eod

WorldSelectMessage1:
;"PUSH BUTTON B"
    .byte $26, $4a, @e-@s
@s:
    .byte "PUSH", space, "BUTTON", space, "B"
@e:
    .byte $00 ;eod
    
WorldSelectMessage2:
;"TO SELECT A WORLD"
    .byte $26, $88, @e-@s
@s:
    .byte "TO", space, "SELECT", space, "A", space, "WORLD"
@e:
    .byte $00 ;eod

;--STATUSBAR--
TopStatusBarLine:
;Mario
    .byte $20, $43, @e-@s
@s:
    .byte "MARIO"
@e:

;World & Time
    .byte $20, $52, @e2-@s2
@s2:
    .byte "WORLD", space, space, "TIME"
@e2:

;Score trail (0) and coin indicator (coin icon and the x)
    .byte $20, $68, @e3-@s3
@s3:
    .byte 0, space, space, coin, cross
@e3:
    
;Misc. attributes
    .byte $23, $c0, $7f, $aa ;attribute table data, clears name table 0 to palette 2
    .byte $23, $c2, $01, $ea ;attribute table data, used for coin icon in status bar
    .byte $ff ;eod

;-RANSITION SCREEN--
WorldLivesDisplay:
;Cross, clear lives display
    .byte $21, $cd, @e-@s
@s:
    .byte space, space, cross, space, space, space, space
@e:

;World and the dash
    .byte $21, $4b, @e2-@s2
@s2:
    .byte "WORLD", space, space, dash, space
@e2:

;Misc. attributes
    .byte $22, $0c, $47, $24 ;possibly used to clear time up
    .byte $23, $dc, $01, $ba ;attribute table data for crown if more than 9 lives
    .byte $ff ;eod

LuigiName:
;<!!!>
  .byte "LUIGI"

;-IME UP--
TwoPlayerTimeUp:
;<!!!>
;2 players, Mario event 
    .byte $21, $cd, @e-@s
@s:
    .byte "MARIO"
@e:
    
OnePlayerTimeUp:
;Time up display
    .byte $22, $0c, txt_timeup_end - txt_timeup_start
txt_timeup_start:
    .byte "TIME", space, "UP"
txt_timeup_end:
    .byte $ff ;eod

;--GAME OVER--
TwoPlayerGameOver:
;<!!!>
;2 players, Mario event 
    .byte $21, $cd, @e-@s
@s:
    .byte "MARIO"
@e:

OnePlayerGameOver:
;Game Over display
    .byte $22, $0b, @e-@s
@s:
    .byte "GAME", space, "OVER"
@e:
    .byte $ff ;eod

;--WARP ZONE--
WarpZoneWelcome:
;Welcome to Warp Zone!
    .byte $25, $84, @e-@s
@s:
    .byte "WELCOME", space, "TO", space, "WARP", space, "ZONE", exclamation
@e:
;Misc.
    .byte $26, $25, $01, $24 ;placeholder for left pipe
    .byte $26, $2d, $01, $24 ;placeholder for middle pipe
    .byte $26, $35, $01, $24 ;placeholder for right pipe
    .byte $27, $d9, $46, $aa ;attribute data
    .byte $27, $e1, $45, $aa
    .byte $ff ;eod

GameTextOffsets:
  .byte TopStatusBarLine-TopStatusBarLine, TopStatusBarLine-TopStatusBarLine
  .byte WorldLivesDisplay-TopStatusBarLine, WorldLivesDisplay-TopStatusBarLine
  .byte TwoPlayerTimeUp-TopStatusBarLine, OnePlayerTimeUp-TopStatusBarLine
  .byte TwoPlayerGameOver-TopStatusBarLine, OnePlayerGameOver-TopStatusBarLine
  .byte WarpZoneWelcome-TopStatusBarLine, WarpZoneWelcome-TopStatusBarLine