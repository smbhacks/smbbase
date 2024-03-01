
;To edit the metatiles' tiles setup, edit Palette0_MTiles, Palette1_MTiles, Palette2_MTiles, Palette3_MTiles
;Order of tiles: top left, top right, bottom left, bottom right

;To edit the metatiles' palette, edit Attributes0, Attributes1, Attributes2, Attributes3
;Valid values are pal0, pal1, pal2, pal3

;If you want to edit special metatiles that change on the screen (for example, a brick being bumped)
;edit the following table:
BlockGfxData:
       .db $47, $47, $48, $48 ;brick with line
       .db $48, $48, $48, $48 ;brick without line
       .db $ae, $af, $be, $bf ;used block
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
  .db $24, $24, $24, $30 ;bush left
  .db $31, $25, $32, $25 ;bush middle
  .db $24, $33, $24, $24 ;bush right
  .db $24, $34, $34, $26 ;mountain left
  .db $26, $26, $38, $26 ;mountain left bottom/middle center
  .db $24, $35, $24, $36 ;mountain middle top
  .db $37, $26, $24, $37 ;mountain right
  .db $38, $26, $26, $26 ;mountain right bottom
  .db $26, $26, $26, $26 ;mountain middle bottom
  .db $24, $44, $24, $44 ;bridge guardrail
  .db $24, $cf, $cf, $24 ;chain
  .db $3e, $4e, $3f, $4f ;tall tree top, top half
  .db $3e, $4c, $3f, $4d ;short tree top
  .db $4e, $4c, $4f, $4d ;tall tree top, bottom half
  .db $50, $60, $51, $61 ;warp pipe end left, points up
  .db $52, $62, $53, $63 ;warp pipe end right, points up
  .db $50, $60, $51, $61 ;decoration pipe end left, points up
  .db $52, $62, $53, $63 ;decoration pipe end right, points up
  .db $70, $70, $71, $71 ;pipe shaft left
  .db $26, $26, $72, $72 ;pipe shaft right
  .db $59, $69, $5a, $6a ;tree ledge left edge
  .db $5a, $6c, $5a, $6c ;tree ledge middle
  .db $5a, $6a, $5b, $6b ;tree ledge right edge
  .db $a0, $b0, $a1, $b1 ;mushroom left edge
  .db $a2, $b2, $a3, $b3 ;mushroom middle
  .db $a4, $b4, $a5, $b5 ;mushroom right edge
  .db $54, $64, $55, $65 ;sideways pipe end top
  .db $56, $66, $56, $66 ;sideways pipe shaft top
  .db $57, $67, $71, $71 ;sideways pipe joint top
  .db $74, $84, $75, $85 ;sideways pipe end bottom
  .db $26, $76, $26, $76 ;sideways pipe shaft bottom
  .db $58, $68, $71, $71 ;sideways pipe joint bottom
  .db $8c, $9c, $8d, $9d ;seaplant
  .db $24, $24, $24, $24 ;blank, used on bricks or blocks that are hit
  .db $24, $5f, $24, $6f ;flagpole ball
  .db $7d, $7d, $7e, $7e ;flagpole shaft
  .db $24, $24, $24, $24 ;blank, used in conjunction with vines

Palette1_MTiles:
  .db $7d, $7d, $7e, $7e ;vertical rope
  .db $5c, $24, $5c, $24 ;horizontal rope
  .db $24, $7d, $5d, $6d ;left pulley
  .db $5e, $6e, $24, $7e ;right pulley
  .db $24, $24, $24, $24 ;blank used for balance rope
  .db $77, $48, $78, $48 ;castle top
  .db $48, $48, $27, $27 ;castle window left
  .db $48, $48, $48, $48 ;castle brick wall
  .db $27, $27, $48, $48 ;castle window right
  .db $79, $48, $7a, $48 ;castle top w/ brick
  .db $7b, $27, $7c, $27 ;entrance top
  .db $27, $27, $27, $27 ;entrance bottom
  .db $73, $73, $73, $73 ;green ledge stump
  .db $3a, $4a, $3b, $4b ;fence
  .db $3c, $3c, $3d, $3d ;tree trunk
  .db $A6, $4e, $A7, $4f ;mushroom stump top
  .db $4e, $4e, $4f, $4f ;mushroom stump bottom
  .db $47, $48, $47, $48 ;breakable brick w/ line 
  .db $48, $48, $48, $48 ;breakable brick 
  .db $47, $48, $47, $48 ;breakable brick (not used)
  .db $82, $92, $83, $93 ;cracked rock terrain
  .db $47, $48, $47, $48 ;brick with line (power-up)
  .db $47, $48, $47, $48 ;brick with line (vine)
  .db $47, $48, $47, $48 ;brick with line (star)
  .db $47, $48, $47, $48 ;brick with line (coins)
  .db $47, $48, $47, $48 ;brick with line (1-up)
  .db $48, $48, $48, $48 ;brick (power-up)
  .db $48, $48, $48, $48 ;brick (vine)
  .db $48, $48, $48, $48 ;brick (star)
  .db $48, $48, $48, $48 ;brick (coins)
  .db $48, $48, $48, $48 ;brick (1-up)
  .db $24, $24, $24, $24 ;hidden block (1 coin)
  .db $24, $24, $24, $24 ;hidden block (1-up)
  .db $80, $90, $81, $91 ;solid block (3-d block)
  .db $b6, $b7, $b6, $b7 ;solid block (white wall)
  .db $45, $24, $45, $24 ;bridge
  .db $86, $96, $87, $97 ;bullet bill cannon barrel
  .db $88, $98, $89, $99 ;bullet bill cannon top
  .db $94, $94, $95, $95 ;bullet bill cannon bottom
  .db $24, $24, $24, $24 ;blank used for jumpspring
  .db $24, $48, $24, $48 ;half brick used for jumpspring
  .db $8a, $9a, $8b, $9b ;solid block (water level, green rock)
  .db $24, $48, $24, $48 ;half brick (???)
  .db $54, $64, $55, $65 ;water pipe top
  .db $74, $84, $75, $85 ;water pipe bottom
  .db $24, $5f, $24, $6f ;flag ball (residual object)

Palette2_MTiles:
  .db $24, $24, $24, $30 ;cloud left
  .db $31, $25, $32, $25 ;cloud middle
  .db $24, $33, $24, $24 ;cloud right
  .db $24, $24, $40, $24 ;cloud bottom left
  .db $41, $24, $42, $24 ;cloud bottom middle
  .db $43, $24, $24, $24 ;cloud bottom right
  .db $46, $26, $46, $26 ;water/lava top
  .db $26, $26, $26, $26 ;water/lava
  .db $8e, $9e, $8f, $9f ;cloud level terrain
  .db $39, $49, $39, $49 ;bowser's bridge
      
Palette3_MTiles:
  .db $a8, $b8, $a9, $b9 ;question block (coin)
  .db $a8, $b8, $a9, $b9 ;question block (power-up)
  .db $aa, $ba, $ab, $bb ;coin
  .db $ac, $bc, $ad, $bd ;underwater coin
  .db $ae, $be, $af, $bf ;empty block
  .db $cb, $cd, $cc, $ce ;axe

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
	