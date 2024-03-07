
;To edit the metatiles' tiles setup, edit Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
;Order of tiles: top left, top right, bottom left, bottom right

;To edit the metatiles' palette, edit Attributes0, Attributes1, Attributes2, Attributes3
;Valid values are pal0, pal1, pal2, pal3

;If you want to edit special metatiles that change on the screen (for example, a brick being bumped)
;edit the following table:
BlockGfxData:
  .byte $47, $47, $48, $48 ;brick with line
  .byte $48, $48, $48, $48 ;brick without line
  .byte $ae, $af, $be, $bf ;used block
  .byte $24, $24, $24, $24 ;air
  .byte $26, $26, $26, $26 ;air, different color

MetatileGraphics_Low:
  .lobytes Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
MetatileGraphics_High:
  .hibytes Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
  
AttributesLo:
  .lobytes Attributes0, Attributes1, Attributes2, Attributes3
AttributesHi:
  .hibytes Attributes0, Attributes1, Attributes2, Attributes3

pal0 = 0 << 6
pal1 = 1 << 6
pal2 = 2 << 6
pal3 = 3 << 6

Palette0_MTiles:
  .byte $24, $24, $24, $24 ;blank
  .byte $27, $27, $27, $27 ;black metatile
  .byte $24, $24, $24, $30 ;bush left
  .byte $31, $25, $32, $25 ;bush middle
  .byte $24, $33, $24, $24 ;bush right
  .byte $24, $34, $34, $26 ;mountain left
  .byte $26, $26, $38, $26 ;mountain left bottom/middle center
  .byte $24, $35, $24, $36 ;mountain middle top
  .byte $37, $26, $24, $37 ;mountain right
  .byte $38, $26, $26, $26 ;mountain right bottom
  .byte $26, $26, $26, $26 ;mountain middle bottom
  .byte $24, $44, $24, $44 ;bridge guardrail
  .byte $24, $cf, $cf, $24 ;chain
  .byte $3e, $4e, $3f, $4f ;tall tree top, top half
  .byte $3e, $4c, $3f, $4d ;short tree top
  .byte $4e, $4c, $4f, $4d ;tall tree top, bottom half
  .byte $50, $60, $51, $61 ;warp pipe end left, points up
  .byte $52, $62, $53, $63 ;warp pipe end right, points up
  .byte $50, $60, $51, $61 ;decoration pipe end left, points up
  .byte $52, $62, $53, $63 ;decoration pipe end right, points up
  .byte $70, $70, $71, $71 ;pipe shaft left
  .byte $26, $26, $72, $72 ;pipe shaft right
  .byte $59, $69, $5a, $6a ;tree ledge left edge
  .byte $5a, $6c, $5a, $6c ;tree ledge middle
  .byte $5a, $6a, $5b, $6b ;tree ledge right edge
  .byte $a0, $b0, $a1, $b1 ;mushroom left edge
  .byte $a2, $b2, $a3, $b3 ;mushroom middle
  .byte $a4, $b4, $a5, $b5 ;mushroom right edge
  .byte $54, $64, $55, $65 ;sideways pipe end top
  .byte $56, $66, $56, $66 ;sideways pipe shaft top
  .byte $57, $67, $71, $71 ;sideways pipe joint top
  .byte $74, $84, $75, $85 ;sideways pipe end bottom
  .byte $26, $76, $26, $76 ;sideways pipe shaft bottom
  .byte $58, $68, $71, $71 ;sideways pipe joint bottom
  .byte $8c, $9c, $8d, $9d ;seaplant
  .byte $24, $24, $24, $24 ;blank, used on bricks or blocks that are hit
  .byte $24, $5f, $24, $6f ;flagpole ball
  .byte $7d, $7d, $7e, $7e ;flagpole shaft
  .byte $24, $24, $24, $24 ;blank, used in conjunction with vines

Palette1_MTiles:
  .byte $7d, $7d, $7e, $7e ;vertical rope
  .byte $5c, $24, $5c, $24 ;horizontal rope
  .byte $24, $7d, $5d, $6d ;left pulley
  .byte $5e, $6e, $24, $7e ;right pulley
  .byte $24, $24, $24, $24 ;blank used for balance rope
  .byte $77, $48, $78, $48 ;castle top
  .byte $48, $48, $27, $27 ;castle window left
  .byte $48, $48, $48, $48 ;castle brick wall
  .byte $27, $27, $48, $48 ;castle window right
  .byte $79, $48, $7a, $48 ;castle top w/ brick
  .byte $7b, $27, $7c, $27 ;entrance top
  .byte $27, $27, $27, $27 ;entrance bottom
  .byte $73, $73, $73, $73 ;green ledge stump
  .byte $3a, $4a, $3b, $4b ;fence
  .byte $3c, $3c, $3d, $3d ;tree trunk
  .byte $A6, $4e, $A7, $4f ;mushroom stump top
  .byte $4e, $4e, $4f, $4f ;mushroom stump bottom
  .byte $47, $48, $47, $48 ;breakable brick w/ line 
  .byte $48, $48, $48, $48 ;breakable brick 
  .byte $47, $48, $47, $48 ;breakable brick (not used)
  .byte $82, $92, $83, $93 ;cracked rock terrain
  .byte $47, $48, $47, $48 ;brick with line (power-up)
  .byte $47, $48, $47, $48 ;brick with line (vine)
  .byte $47, $48, $47, $48 ;brick with line (star)
  .byte $47, $48, $47, $48 ;brick with line (coins)
  .byte $47, $48, $47, $48 ;brick with line (1-up)
  .byte $48, $48, $48, $48 ;brick (power-up)
  .byte $48, $48, $48, $48 ;brick (vine)
  .byte $48, $48, $48, $48 ;brick (star)
  .byte $48, $48, $48, $48 ;brick (coins)
  .byte $48, $48, $48, $48 ;brick (1-up)
  .byte $24, $24, $24, $24 ;hidden block (1 coin)
  .byte $24, $24, $24, $24 ;hidden block (1-up)
  .byte $80, $90, $81, $91 ;solid block (3-d block)
  .byte $b6, $b7, $b6, $b7 ;solid block (white wall)
  .byte $45, $24, $45, $24 ;bridge
  .byte $86, $96, $87, $97 ;bullet bill cannon barrel
  .byte $88, $98, $89, $99 ;bullet bill cannon top
  .byte $94, $94, $95, $95 ;bullet bill cannon bottom
  .byte $24, $24, $24, $24 ;blank used for jumpspring
  .byte $24, $48, $24, $48 ;half brick used for jumpspring
  .byte $8a, $9a, $8b, $9b ;solid block (water level, green rock)
  .byte $24, $48, $24, $48 ;half brick (???)
  .byte $54, $64, $55, $65 ;water pipe top
  .byte $74, $84, $75, $85 ;water pipe bottom
  .byte $24, $5f, $24, $6f ;flag ball (residual object)

Palette2_MTiles:
  .byte $24, $24, $24, $30 ;cloud left
  .byte $31, $25, $32, $25 ;cloud middle
  .byte $24, $33, $24, $24 ;cloud right
  .byte $24, $24, $40, $24 ;cloud bottom left
  .byte $41, $24, $42, $24 ;cloud bottom middle
  .byte $43, $24, $24, $24 ;cloud bottom right
  .byte $46, $26, $46, $26 ;water/lava top
  .byte $26, $26, $26, $26 ;water/lava
  .byte $8e, $9e, $8f, $9f ;cloud level terrain
  .byte $39, $49, $39, $49 ;bowser's bridge
      
Palette3_MTiles:
  .byte $a8, $b8, $a9, $b9 ;question block (coin)
  .byte $a8, $b8, $a9, $b9 ;question block (power-up)
  .byte $aa, $ba, $ab, $bb ;coin
  .byte $ac, $bc, $ad, $bd ;underwater coin
  .byte $ae, $be, $af, $bf ;empty block
  .byte $cb, $cd, $cc, $ce ;axe

Attributes0:
	.byte pal0 ;blank
	.byte pal0 ;black metatile
	.byte pal0 ;bush left
	.byte pal0 ;bush middle
	.byte pal0 ;bush right
	.byte pal0 ;mountain left
	.byte pal0 ;mountain left bottom/middle center
	.byte pal0 ;mountain middle top
	.byte pal0 ;mountain right
	.byte pal0 ;mountain right bottom
	.byte pal0 ;mountain middle bottom
	.byte pal0 ;bridge guardrail
	.byte pal0 ;chain
	.byte pal0 ;tall tree top, top half
	.byte pal0 ;short tree top
	.byte pal0 ;tall tree top, bottom half
	.byte pal0 ;warp pipe end left, points up
	.byte pal0 ;warp pipe end right, points up
	.byte pal0 ;decoration pipe end left, points up
	.byte pal0 ;decoration pipe end right, points up
	.byte pal0 ;pipe shaft left
	.byte pal0 ;pipe shaft right
	.byte pal0 ;tree ledge left edge
	.byte pal0 ;tree ledge middle
	.byte pal0 ;tree ledge right edge
	.byte pal0 ;mushroom left edge
	.byte pal0 ;mushroom middle
	.byte pal0 ;mushroom right edge
	.byte pal0 ;sideways pipe end top
	.byte pal0 ;sideways pipe shaft top
	.byte pal0 ;sideways pipe joint top
	.byte pal0 ;sideways pipe end bottom
	.byte pal0 ;sideways pipe shaft bottom
	.byte pal0 ;sideways pipe joint bottom
	.byte pal0 ;seaplant
	.byte pal0 ;blank, used on bricks or blocks that are hit
	.byte pal0 ;flagpole ball
	.byte pal0 ;flagpole shaft
	.byte pal0 ;blank, used in conjunction with vines

Attributes1:
	.byte pal1 ;vertical rope
	.byte pal1 ;horizontal rope
	.byte pal1 ;left pulley
	.byte pal1 ;right pulley
	.byte pal1 ;blank used for balance rope
	.byte pal1 ;castle top
	.byte pal1 ;castle window left
	.byte pal1 ;castle brick wall
	.byte pal1 ;castle window right
	.byte pal1 ;castle top w/ brick
	.byte pal1 ;entrance top
	.byte pal1 ;entrance bottom
	.byte pal1 ;green ledge stump
	.byte pal1 ;fence
	.byte pal1 ;tree trunk
	.byte pal1 ;mushroom stump top
	.byte pal1 ;mushroom stump bottom
	.byte pal1 ;breakable brick w/ line 
	.byte pal1 ;breakable brick 
	.byte pal1 ;breakable brick (not used)
	.byte pal1 ;cracked rock terrain
	.byte pal1 ;brick with line (power-up)
	.byte pal1 ;brick with line (vine)
	.byte pal1 ;brick with line (star)
	.byte pal1 ;brick with line (coins)
	.byte pal1 ;brick with line (1-up)
	.byte pal1 ;brick (power-up)
	.byte pal1 ;brick (vine)
	.byte pal1 ;brick (star)
	.byte pal1 ;brick (coins)
	.byte pal1 ;brick (1-up)
	.byte pal1 ;hidden block (1 coin)
	.byte pal1 ;hidden block (1-up)
	.byte pal1 ;solid block (3-d block)
	.byte pal1 ;solid block (white wall)
	.byte pal1 ;bridge
	.byte pal1 ;bullet bill cannon barrel
	.byte pal1 ;bullet bill cannon top
	.byte pal1 ;bullet bill cannon bottom
	.byte pal1 ;blank used for jumpspring
	.byte pal1 ;half brick used for jumpspring
	.byte pal1 ;solid block (water level, green rock)
	.byte pal1 ;half brick (???)
	.byte pal1 ;water pipe top
	.byte pal1 ;water pipe bottom
	.byte pal1 ;slope indicator
	.byte pal1 ;flag ball (residual object) 
	
Attributes2:
	.byte pal2 ;cloud left
	.byte pal2 ;cloud middle
	.byte pal2 ;cloud right
	.byte pal2 ;cloud bottom left
	.byte pal2 ;cloud bottom middle
	.byte pal2 ;cloud bottom right
	.byte pal2 ;water/lava top
	.byte pal2 ;water/lava
	.byte pal2 ;cloud level terrain
	.byte pal2 ;bowser's bridge
	
Attributes3:
	.byte pal3 ;question block (coin)
	.byte pal3 ;question block (power-up)
	.byte pal3 ;coin
	.byte pal3 ;underwater coin
	.byte pal3 ;empty block
	.byte pal3 ;axe
	