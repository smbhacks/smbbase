;-------------------------------------------------------------------------------------
;SETTINGS
;To enable/disable a setting, delete/add the semicolon (;) before the definition

CustomMusicDriver EQU OriginalSMBMusic		;Use the original SMB audio engine
;CustomMusicDriver EQU Famitone5Music		;Replace SMB's music driver with Famitone5 (compatible with famitracker)
;CustomMusicDriver EQU FamistudioMusic		;Replace SMB's music driver with Famistudio (compatible with famistudio)

;Mario's walking/running speed
	;---> in bank0.asm: "MaxLeftXSpdData" and "MaxRightXSpdData"
	
;Mario's jumping parameters (Jump Ability 1 in SMB-R)
	;---> in bank0.asm: "Player Jump LUTs"

;Metatile tiles data
	;---> in bank0.asm: "METATILE GRAPHICS TABLE"

;Palette data
	;---> in bank0.asm: "PALETTE DATA"

;Bounce off of enemies
y_bounce = -4
y_stomp = -3

;Springboard strength
springboard_bounce = -12
springboard_riding = -7

;Fireball
fb_speed_right = 64
fb_speed_left  = -64
fb_bounce = -3
fb_gravity = 3
fb_direction = 4 ;(kind of)

;Pipes
pipe_ascent_speed = -1
pipe_descent_speed = 1

;Powerups
starman_time = 35
powerup_speed = 16
_1up_always = 0 ;0: default value
				;1: always put down 1-up hidden blocks

;Damage
invincibility_time = 8
speed_at_death = 4

;Lifts
lift_speed_up = 10
lift_speed_down = -10
riding_speed = 16

;Misc.
starting_lives = 3
timer_rate = 24 ;frames before ticking the game timer
world_select_enabled = 0 ;0: after beating the game, 1: always
max_world_select = 8 ;(accepted values are powers of 2: 1, 2, 4, 8, 16, 32, 64, 128, 256)