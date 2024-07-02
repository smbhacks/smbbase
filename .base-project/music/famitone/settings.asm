FT_BASE_ADR		= $7f00	;page in the RAM used for FT2 variables, should be $xx00
FT_DPCM_OFF		= $c000	;$c000..$ffc0, 64-byte steps
FT_SFX_STREAMS	= 4		;number of sound effects played at once, 1..4
FT_DPCM_ENABLE	= 0		;undefine to exclude all DMC code
FT_SFX_ENABLE	= 1		;undefine to exclude all sound effects code