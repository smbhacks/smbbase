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
period = $af
;Example text: 5 TIMES 5 EQUALS 25
;What you need to input: .db 5, space, "TIMES"-$37, space, 5, space, "EQUALS"-$37, space, 2, 5

;--END OF CASTLE--
MarioThanksMessage:
;"THANK YOU MARIO!"
	.db $25, $48, txt_mariothx_end-txt_mariothx_start
	txt_mariothx_start
	.db "THANK"-$37, space, "YOU"-$37, space, "MARIO"-$37, exclamation
	txt_mariothx_end
    .db $00 ;eod

LuigiThanksMessage:
;"THANK YOU LUIGI!"
	.db $25, $48, txt_luigithx_end-txt_luigithx_start
	txt_luigithx_start
	.db "THANK"-$37, space, "YOU"-$37, space, "LUIGI"-$37, exclamation
	txt_luigithx_end
    .db $00 ;eod

MushroomRetainerSaved:
;"BUT OUR PRINCESS IS IN"
	.db $25, $c5, txt_toadsaved1_end-txt_toadsaved1_start
	txt_toadsaved1_start
	.db "BUT"-$37, space, "OUR"-$37, space, "PRINCESS"-$37, space, "IS"-$37, space, "IN"-$37
	txt_toadsaved1_end

;"ANOTHER CASTLE!"
	.db $26, $05, txt_toadsaved2_end-txt_toadsaved2_start
	txt_toadsaved2_start
	.db "ANOTHER"-$37, space, "CASTLE"-$37, exclamation
	txt_toadsaved2_end
	.db $00 ;eod

PrincessSaved1:
;"YOUR QUEST IS OVER."
	.db $25, $a7, txt_princess1_end-txt_princess1_start
	txt_princess1_start
	.db "YOUR"-$37, space, "QUEST"-$37, space, "IS"-$37, space, "OVER"-$37, period
	txt_princess1_end
	.db $00 ;eod
	
PrincessSaved2:
;"WE PRESENT YOU A NEW QUEST."
	.db $25, $e3, txt_princess2_end-txt_princess2_start
	txt_princess2_start
	.db "WE"-$37, space, "PRESENT"-$37, space, "YOU"-$37, space, "A"-$37, space, "NEW"-$37, space, "QUEST"-$37, period
	txt_princess2_end
	.db $00 ;eod

WorldSelectMessage1:
;"PUSH BUTTON B"
	.db $26, $4a, txt_worldsel1_end-txt_worldsel1_start
	txt_worldsel1_start
	.db "PUSH"-$37, space, "BUTTON"-$37, space, "B"-$37
	txt_worldsel1_end
	.db $00 ;eod
	
WorldSelectMessage2:
;"TO SELECT A WORLD"
	.db $26, $88, txt_worldsel2_end-txt_worldsel2_start
	txt_worldsel2_start
	.db "TO"-$37, space, "SELECT"-$37, space, "A"-$37, space, "WORLD"-$37
	txt_worldsel2_end
	.db $00 ;eod

;--STATUSBAR--
TopStatusBarLine:
;Mario
	.db $20, $43, txt_mario_end-txt_mario_start  
	txt_mario_start
	.db "MARIO"-$37
	txt_mario_end

;World & Time
	.db $20, $52, txt_topstatus_end-txt_topstatus_start
	txt_topstatus_start
	.db "WORLD"-$37, space, space, "TIME"-$37
	txt_topstatus_end

;Score trail (0) and coin indicator (coin icon and the x)
	.db $20, $68, txt_scoretrail_end-txt_scoretrail_start
	txt_scoretrail_start
	.db 0, space, space, coin, cross
	txt_scoretrail_end
	
;Misc. attributes
	.db $23, $c0, $7f, $aa ;attribute table data, clears name table 0 to palette 2
	.db $23, $c2, $01, $ea ;attribute table data, used for coin icon in status bar
	.db $ff ;eod

;--TRANSITION SCREEN--
WorldLivesDisplay:
;Cross, clear lives display
	.db $21, $cd, txt_cross_end-txt_cross_start
	txt_cross_start
	.db space, space, cross, space, space, space, space
	txt_cross_end

;World and the dash
	.db $21, $4b, txt_worlddisplay_end-txt_worlddisplay_start
	txt_worlddisplay_start
	.db "WORLD"-$37, space, space, dash, space
	txt_worlddisplay_end

;Misc. attributes
	.db $22, $0c, $47, $24 ;possibly used to clear time up
	.db $23, $dc, $01, $ba ;attribute table data for crown if more than 9 lives
	.db $ff ;eod

;--TIME UP--
TwoPlayerTimeUp:
;<!!!>
;2 players, Mario event 
	.db $21, $cd, txt_fixedlength_end-txt_fixedlength_start
	txt_fixedlength_start
	.db "MARIO"-$37
	txt_fixedlength_end
	
OnePlayerTimeUp:
;Time up display
	.db $22, $0c, txt_timeup_end-txt_timeup_start
	txt_timeup_start
	.db "TIME"-$37, space, "UP"-$37
	txt_timeup_end
	.db $ff ;eod

;--GAME OVER--
TwoPlayerGameOver:
;<!!!>
;2 players, Mario event 
	.db $21, $cd, txt_fixedlength_end-txt_fixedlength_start
	.db "MARIO"-$37
	
OnePlayerGameOver:
;Game Over display
	.db $22, $0b, txt_gameover_end-txt_gameover_start
	txt_gameover_start
	.db "GAME"-$37, space, "OVER"-$37
	txt_gameover_end
	.db $ff ;eod

;--WARP ZONE--
WarpZoneWelcome:
;Welcome to Warp Zone!
	.db $25, $84, txt_warpzone_end-txt_warpzone_start
	txt_warpzone_start
	.db "WELCOME"-$37, space, "TO"-$37, space, "WARP"-$37, space, "ZONE"-$37, exclamation
	txt_warpzone_end
	
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

LuigiName:
;<!!!>
  .db "LUIGI"-$37