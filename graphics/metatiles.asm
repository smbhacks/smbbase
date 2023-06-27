
;To edit the metatiles' tiles setup, edit Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
;Order of tiles: top left, top right, bottom left, bottom right

;To edit the metatiles' palette, edit Attributes0, Attributes1, Attributes2, Attributes3
;Valid values are pal0, pal1, pal2, pal3

;If you want to edit special metatiles that change on the screen (for example, a brick being bumped)
;edit the following table:
BlockGfxData:
       .db $45, $45, $47, $47 ;brick with line
       .db $47, $47, $47, $47 ;brick without line
       .db $57, $58, $59, $5a ;used block
       .db $24, $24, $24, $24 ;air
       .db $26, $26, $26, $26 ;air, different color

MetatileGraphics_Low:
  .dl Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
MetatileGraphics_High:
  .dh Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
  
AttributesLo:
  .dl Attributes0, Attributes1, Attributes2, Attributes3
AttributesHi:
  .dh Attributes0, Attributes1, Attributes2, Attributes3

pal0 = 0 << 6
pal1 = 1 << 6
pal2 = 2 << 6
pal3 = 3 << 6

Palette0_MTiles:
  .db $24, $24, $24, $24 ;blank
  .db $27, $27, $27, $27 ;black metatile
  .db $24, $24, $24, $35 ;bush left
  .db $36, $25, $37, $25 ;bush middle
  .db $24, $38, $24, $24 ;bush right
  .db $24, $30, $30, $26 ;mountain left
  .db $26, $26, $34, $26 ;mountain left bottom/middle center
  .db $24, $31, $24, $32 ;mountain middle top
  .db $33, $26, $24, $33 ;mountain right
  .db $34, $26, $26, $26 ;mountain right bottom
  .db $26, $26, $26, $26 ;mountain middle bottom
  .db $24, $c0, $24, $c0 ;bridge guardrail
  .db $24, $7f, $7f, $24 ;chain
  .db $b8, $ba, $b9, $bb ;tall tree top, top half
  .db $b8, $bc, $b9, $bd ;short tree top
  .db $ba, $bc, $bb, $bd ;tall tree top, bottom half
  .db $60, $64, $61, $65 ;warp pipe end left, points up
  .db $62, $66, $63, $67 ;warp pipe end right, points up
  .db $60, $64, $61, $65 ;decoration pipe end left, points up
  .db $62, $66, $63, $67 ;decoration pipe end right, points up
  .db $68, $68, $69, $69 ;pipe shaft left
  .db $26, $26, $6a, $6a ;pipe shaft right
  .db $4b, $4c, $4d, $4e ;tree ledge left edge
  .db $4d, $4f, $4d, $4f ;tree ledge middle
  .db $4d, $4e, $50, $51 ;tree ledge right edge
  .db $6b, $70, $2c, $2d ;mushroom left edge
  .db $6c, $71, $6d, $72 ;mushroom middle
  .db $6e, $73, $6f, $74 ;mushroom right edge
  .db $86, $8a, $87, $8b ;sideways pipe end top
  .db $88, $8c, $88, $8c ;sideways pipe shaft top
  .db $89, $8d, $69, $69 ;sideways pipe joint top
  .db $8e, $91, $8f, $92 ;sideways pipe end bottom
  .db $26, $93, $26, $93 ;sideways pipe shaft bottom
  .db $90, $94, $69, $69 ;sideways pipe joint bottom
  .db $a4, $e9, $ea, $eb ;seaplant
  .db $24, $24, $24, $24 ;blank, used on bricks or blocks that are hit
  .db $24, $2f, $24, $3d ;flagpole ball
  .db $a2, $a2, $a3, $a3 ;flagpole shaft
  .db $24, $24, $24, $24 ;blank, used in conjunction with vines

Palette1_MTiles:
  .db $a2, $a2, $a3, $a3 ;vertical rope
  .db $99, $24, $99, $24 ;horizontal rope
  .db $24, $a2, $3e, $3f ;left pulley
  .db $5b, $5c, $24, $a3 ;right pulley
  .db $24, $24, $24, $24 ;blank used for balance rope
  .db $9d, $47, $9e, $47 ;castle top
  .db $47, $47, $27, $27 ;castle window left
  .db $47, $47, $47, $47 ;castle brick wall
  .db $27, $27, $47, $47 ;castle window right
  .db $a9, $47, $aa, $47 ;castle top w/ brick
  .db $9b, $27, $9c, $27 ;entrance top
  .db $27, $27, $27, $27 ;entrance bottom
  .db $52, $52, $52, $52 ;green ledge stump
  .db $80, $a0, $81, $a1 ;fence
  .db $be, $be, $bf, $bf ;tree trunk
  .db $75, $ba, $76, $bb ;mushroom stump top
  .db $ba, $ba, $bb, $bb ;mushroom stump bottom
  .db $45, $47, $45, $47 ;breakable brick w/ line 
  .db $47, $47, $47, $47 ;breakable brick 
  .db $45, $47, $45, $47 ;breakable brick (not used)
  .db $b4, $b6, $b5, $b7 ;cracked rock terrain
  .db $45, $47, $45, $47 ;brick with line (power-up)
  .db $45, $47, $45, $47 ;brick with line (vine)
  .db $45, $47, $45, $47 ;brick with line (star)
  .db $45, $47, $45, $47 ;brick with line (coins)
  .db $45, $47, $45, $47 ;brick with line (1-up)
  .db $47, $47, $47, $47 ;brick (power-up)
  .db $47, $47, $47, $47 ;brick (vine)
  .db $47, $47, $47, $47 ;brick (star)
  .db $47, $47, $47, $47 ;brick (coins)
  .db $47, $47, $47, $47 ;brick (1-up)
  .db $24, $24, $24, $24 ;hidden block (1 coin)
  .db $24, $24, $24, $24 ;hidden block (1-up)
  .db $ab, $ac, $ad, $ae ;solid block (3-d block)
  .db $5d, $5e, $5d, $5e ;solid block (white wall)
  .db $c1, $24, $c1, $24 ;bridge
  .db $c6, $c8, $c7, $c9 ;bullet bill cannon barrel
  .db $ca, $cc, $cb, $cd ;bullet bill cannon top
  .db $2a, $2a, $40, $40 ;bullet bill cannon bottom
  .db $24, $24, $24, $24 ;blank used for jumpspring
  .db $24, $47, $24, $47 ;half brick used for jumpspring
  .db $82, $83, $84, $85 ;solid block (water level, green rock)
  .db $24, $47, $24, $47 ;half brick (???)
  .db $86, $8a, $87, $8b ;water pipe top
  .db $8e, $91, $8f, $92 ;water pipe bottom
  .db $24, $2f, $24, $3d ;flag ball (residual object)

Palette2_MTiles:
  .db $24, $24, $24, $35 ;cloud left
  .db $36, $25, $37, $25 ;cloud middle
  .db $24, $38, $24, $24 ;cloud right
  .db $24, $24, $39, $24 ;cloud bottom left
  .db $3a, $24, $3b, $24 ;cloud bottom middle
  .db $3c, $24, $24, $24 ;cloud bottom right
  .db $41, $26, $41, $26 ;water/lava top
  .db $26, $26, $26, $26 ;water/lava
  .db $b0, $b1, $b2, $b3 ;cloud level terrain
  .db $77, $79, $77, $79 ;bowser's bridge
      
Palette3_MTiles:
  .db $53, $55, $54, $56 ;question block (coin)
  .db $53, $55, $54, $56 ;question block (power-up)
  .db $a5, $a7, $a6, $a8 ;coin
  .db $c2, $c4, $c3, $c5 ;underwater coin
  .db $57, $59, $58, $5a ;empty block
  .db $7b, $7d, $7c, $7e ;axe

Attributes0:
	.db pal0 ;blank
	.db pal0 ;black metatile
	.db pal0 ;bush left
	.db pal0 ;bush middle
	.db pal0 ;bush right
	.db pal0 ;mountain left
	.db pal0 ;mountain left bottom/middle center
	.db pal0 ;mountain middle top
	.db pal0 ;mountain right
	.db pal0 ;mountain right bottom
	.db pal0 ;mountain middle bottom
	.db pal0 ;bridge guardrail
	.db pal0 ;chain
	.db pal0 ;tall tree top, top half
	.db pal0 ;short tree top
	.db pal0 ;tall tree top, bottom half
	.db pal0 ;warp pipe end left, points up
	.db pal0 ;warp pipe end right, points up
	.db pal0 ;decoration pipe end left, points up
	.db pal0 ;decoration pipe end right, points up
	.db pal0 ;pipe shaft left
	.db pal0 ;pipe shaft right
	.db pal0 ;tree ledge left edge
	.db pal0 ;tree ledge middle
	.db pal0 ;tree ledge right edge
	.db pal0 ;mushroom left edge
	.db pal0 ;mushroom middle
	.db pal0 ;mushroom right edge
	.db pal0 ;sideways pipe end top
	.db pal0 ;sideways pipe shaft top
	.db pal0 ;sideways pipe joint top
	.db pal0 ;sideways pipe end bottom
	.db pal0 ;sideways pipe shaft bottom
	.db pal0 ;sideways pipe joint bottom
	.db pal0 ;seaplant
	.db pal0 ;blank, used on bricks or blocks that are hit
	.db pal0 ;flagpole ball
	.db pal0 ;flagpole shaft
	.db pal0 ;blank, used in conjunction with vines

Attributes1:
	.db pal1 ;vertical rope
	.db pal1 ;horizontal rope
	.db pal1 ;left pulley
	.db pal1 ;right pulley
	.db pal1 ;blank used for balance rope
	.db pal1 ;castle top
	.db pal1 ;castle window left
	.db pal1 ;castle brick wall
	.db pal1 ;castle window right
	.db pal1 ;castle top w/ brick
	.db pal1 ;entrance top
	.db pal1 ;entrance bottom
	.db pal1 ;green ledge stump
	.db pal1 ;fence
	.db pal1 ;tree trunk
	.db pal1 ;mushroom stump top
	.db pal1 ;mushroom stump bottom
	.db pal1 ;breakable brick w/ line 
	.db pal1 ;breakable brick 
	.db pal1 ;breakable brick (not used)
	.db pal1 ;cracked rock terrain
	.db pal1 ;brick with line (power-up)
	.db pal1 ;brick with line (vine)
	.db pal1 ;brick with line (star)
	.db pal1 ;brick with line (coins)
	.db pal1 ;brick with line (1-up)
	.db pal1 ;brick (power-up)
	.db pal1 ;brick (vine)
	.db pal1 ;brick (star)
	.db pal1 ;brick (coins)
	.db pal1 ;brick (1-up)
	.db pal1 ;hidden block (1 coin)
	.db pal1 ;hidden block (1-up)
	.db pal1 ;solid block (3-d block)
	.db pal1 ;solid block (white wall)
	.db pal1 ;bridge
	.db pal1 ;bullet bill cannon barrel
	.db pal1 ;bullet bill cannon top
	.db pal1 ;bullet bill cannon bottom
	.db pal1 ;blank used for jumpspring
	.db pal1 ;half brick used for jumpspring
	.db pal1 ;solid block (water level, green rock)
	.db pal1 ;half brick (???)
	.db pal1 ;water pipe top
	.db pal1 ;water pipe bottom
	.db pal1 ;slope indicator
	.db pal1 ;flag ball (residual object) 
	
Attributes2:
	.db pal2 ;cloud left
	.db pal2 ;cloud middle
	.db pal2 ;cloud right
	.db pal2 ;cloud bottom left
	.db pal2 ;cloud bottom middle
	.db pal2 ;cloud bottom right
	.db pal2 ;water/lava top
	.db pal2 ;water/lava
	.db pal2 ;cloud level terrain
	.db pal2 ;bowser's bridge
	
Attributes3:
	.db pal3 ;question block (coin)
	.db pal3 ;question block (power-up)
	.db pal3 ;coin
	.db pal3 ;underwater coin
	.db pal3 ;empty block
	.db pal3 ;axe
	