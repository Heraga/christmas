;This patch fixes a problem with extended sprites having a short despawn range that they despawn when a single pixel of the tile
;goes beyond the left or top edges of the screen.

;NOTES:
;-Extended No Sprite Tile Limits patch is required! Download here: https://www.smwcentral.net/?p=section&a=details&id=24642
; (Not required if More Extended Sprites patch is applied.)
;
;-Not compatiable with my directional quake: https://www.smwcentral.net/?p=section&a=details&id=18776
; unless you remove the hijacks of that patch for extended sprites not to despawn from shifted screen and have this patch
; handle the shifted screen (as stated, despawning boundaries should not use the moved screen by taking the moved screen, and subtract by the
; shake displacement, BUT the OAM handling *MUST* use the shifted screen position so that their image shakes with layer 1. Just like
; any other sprite types (normal, pixi, and others), $1A-$1D and $1462-$1465 may already be the shooked position and not original position.
; In some cases, it is easier just to take the XY 16-bit on-screen position and ADD by the quake displacement,
; check if they're offscreen, then restore it back before writing OAM data into the OAM RAM.

;Note to self: The list of extended sprites can be found via CTRL+F "ExtendedSpritePtrs" on the disassembly.

;No Sprite Tile Limits patch defines (must match!)
	!RAM_ExtOAMIndex = $1869|!addr

;Defines and settings
	;Boundary positions, as you increase the values, the positions of the borders moves rightwards or downwards.
	;-$0000 means the top of the screen on the horizontal axis or vertical axis
	;-$0100 means the right edge of the screen on the horizontal axis, $00E0 means the bottom of the screen on the vertical axis.
		!Despawn_LeftEdge = $FFE0		;>How far left, in pixels sprites have to be at in order to despawn
		!Despawn_RightEdge = $0120		;>Same as above but rightwards
		!Despawn_Top = $FF70			;>Same as above but upwards above the screen
		!Despawn_Bottom = $0100			;>Same as above but bottom of the screen


	!dp = $0000
	!addr = $0000
	!bank = $800000
	!sa1 = 0
	!gsu = 0
	
	!More_ExSprite = 0
	!ExSprSize = $07
	
if read2($029B39) == $0000
	!More_ExSprite = 1
	!ExSprSize = read01(00FAD5)
endif

	!FireballSprSize = !ExSprSize+2
	
if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!bank = $000000
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!sa1 = 1
endif

macro define_ram_addr(name, name2, addr, addr_sa1)
if !sa1 == 0
    !<name> = <addr>
else
    !<name> = <addr_sa1>
endif
    !<name2> = !<name>
endmacro

macro define_ram_exsp(name, name2, exsp, exsp_more)
if !More_ExSprite == 0
    !<name> = <exsp>
else
    !<name> = <exsp_more>
endif
    !<name2> = !<name>
endmacro

; Regular sprite tables
%define_ram_addr(sprite_num, "9E", $9E, $3200)
%define_ram_addr(sprite_speed_y, "AA", $AA, $9E)
%define_ram_addr(sprite_speed_x, "B6", $B6, $B6)
%define_ram_addr(sprite_misc_c2, "C2", $C2, $D8)
%define_ram_addr(sprite_y_low, "D8", $D8, $3216)
%define_ram_addr(sprite_x_low, "E4", $E4, $322C)

%define_ram_addr(sprite_num_16bit, "009E", $009E, $3200)
%define_ram_addr(sprite_speed_y_16bit, "00AA", $00AA, $309E)
%define_ram_addr(sprite_speed_x_16bit, "00B6", $00B6, $30B6)
%define_ram_addr(sprite_misc_c2_16bit, "00C2", $00C2, $30D8)
%define_ram_addr(sprite_y_low_16bit, "00D8", $00D8, $3216)
%define_ram_addr(sprite_x_low_16bit, "00E4", $00E4, $322C)

%define_ram_addr(sprite_status, "14C8", $14C8, $3242)
%define_ram_addr(sprite_y_high, "14D4", $14D4, $3258)
%define_ram_addr(sprite_x_high, "14E0", $14E0, $326E)
%define_ram_addr(sprite_speed_y_frac, "14EC", $14EC, $74C8)
%define_ram_addr(sprite_speed_x_frac, "14F8", $14F8, $74DE)
%define_ram_addr(sprite_misc_1504, "1504", $1504, $74F4)
%define_ram_addr(sprite_misc_1510, "1510", $1510, $750A)
%define_ram_addr(sprite_misc_151c, "151C", $151C, $3284)
%define_ram_addr(sprite_misc_1528, "1528", $1528, $329A)
%define_ram_addr(sprite_misc_1534, "1534", $1534, $32B0)
%define_ram_addr(sprite_misc_1540, "1540", $1540, $32C6)
%define_ram_addr(sprite_misc_154c, "154C", $154C, $32DC)
%define_ram_addr(sprite_misc_1558, "1558", $1558, $32F2)
%define_ram_addr(sprite_misc_1564, "1564", $1564, $3308)
%define_ram_addr(sprite_misc_1570, "1570", $1570, $331E)
%define_ram_addr(sprite_misc_157c, "157C", $157C, $3334)
%define_ram_addr(sprite_blocked_status, "1588", $1588, $334A)
%define_ram_addr(sprite_misc_1594, "1594", $1594, $3360)
%define_ram_addr(sprite_off_screen_horz, "15A0", $15A0, $3376)
%define_ram_addr(sprite_misc_15ac, "15AC", $15AC, $338C)
%define_ram_addr(sprite_slope, "15B8", $15B8, $7520)
%define_ram_addr(sprite_off_screen, "15C4", $15C4, $7536)
%define_ram_addr(sprite_being_eaten, "15D0", $15D0, $754C)
%define_ram_addr(sprite_obj_interact, "15DC", $15DC, $7562)
%define_ram_addr(sprite_oam_index, "15EA", $15EA, $33A2)
%define_ram_addr(sprite_oam_properties, "15F6", $15F6, $33B8)
%define_ram_addr(sprite_misc_1602, "1602", $1602, $33CE)
%define_ram_addr(sprite_misc_160e, "160E", $160E, $33E4)
%define_ram_addr(sprite_index_in_level, "161A", $161A, $7578)
%define_ram_addr(sprite_misc_1626, "1626", $1626, $758E)
%define_ram_addr(sprite_behind_scenery, "1632", $1632, $75A4)
%define_ram_addr(sprite_misc_163e, "163E", $163E, $33FA)
%define_ram_addr(sprite_in_water, "164A", $164A, $75BA)
%define_ram_addr(sprite_tweaker_1656, "1656", $1656, $75D0)
%define_ram_addr(sprite_tweaker_1662, "1662", $1662, $75EA)
%define_ram_addr(sprite_tweaker_166e, "166E", $166E, $7600)
%define_ram_addr(sprite_tweaker_167a, "167A", $167A, $7616)
%define_ram_addr(sprite_tweaker_1686, "1686", $1686, $762C)
%define_ram_addr(sprite_off_screen_vert, "186C", $186C, $7642)
%define_ram_addr(sprite_misc_187b, "187B", $187B, $3410)
%define_ram_addr(sprite_tweaker_190f, "190F", $190F, $7658)
%define_ram_addr(sprite_misc_1fd6, "1FD6", $1FD6, $766E)
%define_ram_addr(sprite_cape_disable_time, "1FE2", $1FE2, $7FD6)

; Map 16
%define_ram_addr(map16_lo, "7EC800", $7EC800, $40C800)
%define_ram_addr(map16_hi, "7FC800", $7FC800, $41C800)

; Other
%define_ram_addr(sprite_load_list, "1938", $1938, $418A00)
%define_ram_addr(sprite_wiggler_mem, "7F9A7B", $7F9A7B, $418800)
%define_ram_addr(sram_index, "700000", $700000, $41C000)

; Romi's Sprite Tool defines.
%define_ram_addr(sprite_extra_bits, "7FAB10", $7FAB10, $6040)
%define_ram_addr(sprite_new_code_flag, "7FAB1C", $7FAB1C, $6056) ;note that this is not a flag at all.
%define_ram_addr(sprite_extra_prop1, "7FAB28", $7FAB28, $6057)
%define_ram_addr(sprite_extra_prop2, "7FAB34", $7FAB34, $606D)
%define_ram_addr(sprite_custom_num, "7FAB9E", $7FAB9E, $6083)

; Extended sprites
%define_ram_exsp(ex_sprite_num, "170B", $170B|!addr, $770B)
%define_ram_exsp(ex_sprite_y_low, "1715", $1715|!addr, $3426)
%define_ram_exsp(ex_sprite_x_low, "171F", $171F|!addr, $343A)
%define_ram_exsp(ex_sprite_y_high, "1729", $1729|!addr, $771F)
%define_ram_exsp(ex_sprite_x_high, "1733", $1733|!addr, $7733)
%define_ram_exsp(ex_sprite_speed_y, "173D", $173D|!addr, $344E)
%define_ram_exsp(ex_sprite_speed_x, "1747", $1747|!addr, $3462)
%define_ram_exsp(ex_sprite_speed_y_frac, "1751", $1751|!addr, $7747)
%define_ram_exsp(ex_sprite_speed_x_frac, "175B", $175B|!addr, $775B)
%define_ram_exsp(ex_sprite_inc, "1765", $1765|!addr, $3476)
%define_ram_exsp(ex_sprite_misc, "176F", $176F|!addr, $776F)
%define_ram_exsp(ex_sprite_layer, "1779", $1779|!addr, $348A)

; PIXI and GIEPY memory defines are not included. Updating this document would be appreciated.


org $029B54 ;volcano lotus seeds
	autoclean JML VolcanoLotusDespawnAndOAM
org $029C61 ;Puff of smoke from yoshi stomp (when yoshi lands on the ground with yellow shell in mouth)
	autoclean JSL SetOnlySizeBitY
	NOP
org $029CF8 ;Coin game cloud and wiggler's flower
	autoclean JML CloudCoin
org $029F93 ;Yoshi fireball
	autoclean JSL SetOnlySizeBitY
	NOP
org $029BA0 ;Volcano lotus
	autoclean JSL ClearOnlySizeBitY
	NOP
org $029D27 ;Wiggler flower
	autoclean JML WigglerFlower
org $029D45 ;Part of the coin cloud OAM handler, we've already finish the OAM XY position
	NOP #5
org $029D3F ;Wiggler flower
	autoclean JSL ClearOnlySizeBitY
	NOP
org $029D54 ;Cloud coin
	autoclean JSL SetOnlySizeBitY
	NOP
org $029E7C ;Torpeto launcher arm
	autoclean JSL SetOnlySizeBitY
	NOP
	
if !More_ExSprite == 0
org $029EA0 ;Lava splash
	autoclean JML LavaSplash
org $029EDD ;Lava splash
	autoclean JSL ClearOnlySizeBitY
	NOP
endif

org $029F2A ;water bubble (spawned by player when in water)
	autoclean JML WaterBubble
org $029FB3 ;Mario's fireball
	autoclean JML MarioFireballDespawnHandler
org $02A19D ;Reznor fireball
	autoclean JSL SetOnlySizeBitX
	NOP
	
org $02A1B1
	;Several extended sprites use this as a base code (this starts at $02A1A4).
	;By Modifiying this, the vast majority of extended sprites (most of them uses this btw)
	;will be affected.
	autoclean JML ExtendedSpriteBaseCode
	
org $02A33D ;hammer
	autoclean JSL SetOnlySizeBitX
	NOP
org $02A208 ;Base code for most extended sprites
	autoclean JSL ClearOnlySizeBitY
	NOP
org $02A2B9 ;baseball
	autoclean JSL ClearOnlySizeBitY
	NOP
org $02A271 ;baseball
	autoclean JML BaseballDespawnAndOAM
org $02A36C ;Smoke puff (outside reznor fight)
	autoclean JML SmokePuffDespawnAndOAM
org $02A3A5 ;Smoke puff (outside reznor fight)
	autoclean JSL SetOnlySizeBitY
	NOP
org $02A3F0 ;Smoke puff (inside reznor fight)
	autoclean JSL Set0460OnlySizeBitY
	NOP
org $02F2FC ;Wiggler's flower fix
	autoclean JML FlowerFix
	NOP
	
freecode
ExtendedSpriteBaseCode: ;JML from $02A1B1
	REP #$20		;\Preserve $01-$04 just in case if they're going to be used for something else
	LDA $01
	PHA
	LDA $03
	PHA
	SEP #$21
	
	LDA !171F,x	;\$01-$02: X position
	SBC $1A			;|
	STA $01			;|
	LDA !1733,x	;|
	SBC $1B			;|
	STA $02			;/
	REP #$20
	LDA $01
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$21
	LDA !1715,x	;\$03-$04: Y position
	SBC $1C			;|
	STA $03			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $04			;/
	REP #$20
	LDA $03
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	.OAM
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve OAM index Y
		LDA !170B,x
		AND #$00FF
		ASL
		TAY
		LDA $03				;\Y position -1 because sprite OAM are shifted 1 px lower
		DEC				;/
		CMP NoDrawOAMBoundary-2,y	;\Y offscreen
		BMI ..NoOAM			;|
		CMP.w #$00E0-1			;|>Because of the Y-1, this position must be shifted as well.
		BPL ..NoOAM			;/
		LDA $01				;\X offscreen
		CMP NoDrawOAMBoundary-2,y	;|
		BMI ..NoOAM			;|
		CMP #$0100			;|
		BPL ..NoOAM			;/
		SEP #$20
		PLY				;>Restore OAM index Y
		
		..XPos
			LDA $01			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $02			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $03			;\Y position
			STA $0201|!addr,y	;/
		BRA ..NoOAMSkipPullY
	
		..NoOAM
			PLY
		..NoOAMSkipPullY
	PLB					;>Restore bank
	REP #$20
	PLA
	STA $03
	PLA
	STA $01
	SEP #$20
	JML $02A1DD				;>Jump back to where it handles the properties
	.Despawn
		PLA
		STA $03
		PLA
		STA $01
		SEP #$20
		JML $02A211
		
	NoDrawOAMBoundary:
	;Negative X and Y positions that is the rightmost or bottomost that cannot be seen on the screen.
	;They differ depending on the tile size (8x8 or 16x16). For bottom and right edges, regardless
	;of their sizes, their positions are always $0100 and $00E0.
	dw $FFF0	;>$01 - Smoke puff
	dw $FFF0	;>$02 - Reznor fireball
	dw $FFF8	;>$03 - Flame left by hopping flame
	dw $FFF0	;>$04 - Hammer
	dw $FFF8	;>$05 - Player fireball
	dw $FFF0	;>$06 - Bone from Dry Bones
	dw $FFF8	;>$07 - Lava splash
	dw $FFF0	;>$08 - Torpedo Ted shooter's arm
	dw $FFF8	;>$09 - Unknown flickering object
	dw $FFF0	;>$0A - Coin from coin cloud game
	dw $FFF8	;>$0B - Piranha Plant fireball
	dw $FFF8	;>$0C - Lava Lotus's fiery objects
	dw $FFF8	;>$0D - Baseball
	dw $FFF8	;>$0E - Wiggler's flower
	dw $FFF0	;>$0F - Trail of smoke (from Yoshi stomping the ground)
	dw $FFF8	;>$10 - Spinjump stars
	dw $FFF0	;>$11 - Yoshi fireballs
	dw $FFF8	;>$12 - Water bubble
	
VolcanoLotusDespawnAndOAM: ;JML from $029B54
	LDA !171F,x	;\$00-$01: X position
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA !1733,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$21
	LDA !1715,x	;\$02-$03: Y position
	SBC $1C			;|
	STA $02			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .CODE_029BA5	;>Equivalent to BMI CODE_029BA5 (skips all OAM-related stuff)
	CMP #!Despawn_Bottom
	BPL .CODE_029BDA	;>Equivalent to CODE_029BDA (despawns the sprite)
	;BRA CODE_029B76	;>Equivalent to BEQ CODE_029B76
	
	PHB				;>Preserve bank of SMW code where my hijack is at
	PHK				;\Switch bank to use the bank of the following table
	PLB				;/
	PHY
	LDA !170B,x		;\Get left boundary index
	ASL				;|
	TAY				;/
	REP #$20
	LDA $00				;\Check if OAM tile is offscreen horizontally
	CMP NoDrawOAMBoundary-2,y	;|
	BMI .NoOAM			;|
	CMP #$0100			;|
	BPL .NoOAM			;/
	LDA $02				;\Same but vertically
	CMP NoDrawOAMBoundary-2,y	;|
	BMI .NoOAM			;|
	CMP.w #$00E0-1			;|
	BPL .NoOAM			;/
	SEP #$20
	PLY
	PLB				;>Restore bank
	
	LDA $00			;\Bits 0-7 X position
	STA $0200|!addr,y	;/
	TYA			;\Bit 8 X position
	LSR #2			;|
	PHY			;|
	TAY			;|
	LDA $01			;|
	AND.b #%00000001	;|
	STA $0420|!addr,y	;|
	PLY			;/
	LDA $02			;\Y position
	STA $0201|!addr,y	;/
	JML $029B84		;>Handle tile prop and number and we are done.
	
	.NoOAM
		PLY
		PLB
	.CODE_029BA5
		SEP #$20
		JML $029BA5
	.CODE_029BDA
	.Despawn
		SEP #$20
		JML $029BDA
CloudCoin: ;JML from $029CF8
	LDA !1715,x	;\$01-$02: Y position
	SEC			;|
	SBC $1C			;|
	STA $01			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $02			;/
	REP #$20
	LDA $01
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	SEP #$21
	LDA !171F,x	;\$03-$04: X position
	SBC $1A			;|
	STA $03			;|
	LDA !1733,x	;|
	SBC $1B			;|
	STA $04			;/
	REP #$20
	LDA $03
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
if !More_ExSprite == 0
	LDY !RAM_ExtOAMIndex
else
	TXA : ASL #2 : ADC #$0080 : TAY
endif
	.OAM
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve OAM index Y
		LDA !170B,x
		AND #$00FF
		ASL
		TAY
		LDA $01				;\Y position -1 because sprite OAM are shifted 1 px lower
		DEC				;/
		CMP NoDrawOAMBoundary-2,y	;\Y offscreen
		BMI ..NoOAM			;|
		CMP.w #$00E0-1			;|>Because of the Y-1, this position must be shifted as well.
		BPL ..NoOAM			;/
		LDA $03				;\X offscreen
		CMP NoDrawOAMBoundary-2,y	;|
		BMI ..NoOAM			;|
		CMP #$0100			;|
		BPL ..NoOAM			;/
		SEP #$20
		PLY				;>Restore OAM index Y
		
		..XPos
			LDA $03			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $04			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $01			;\Y position
			STA $0201|!addr,y	;/
			BRA ..NoOAMSkipPullY
	
		..NoOAM
			PLY
			PLB
			SEP #$20
			JML $029D44
		..NoOAMSkipPullY
	PLB					;>Restore bank
	SEP #$20
	JML $029D20
	.Despawn
		SEP #$20
		JML $029D5A
WigglerFlower: ;JML from $029D27
	;Since we obtain our 16-bit position from a hijack at $029CF8
	;We have:
	;$01-$02: Y position
	;$03-$04: X position
	REP #$21
	LDA $01
	SBC #$0004
	CMP #$FFF8
	BMI .NoOAM
	CMP.w #$00E0-1
	BPL .NoOAM
	SEP #$20
	STA $0201|!addr,y
	JML $029D2F
	.NoOAM
		JML $029D44
		
if !More_ExSprite == 0
LavaSplash: ;JML from $029EA0
	LDA !171F,x	;\$00-$01: X position
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA !1733,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$21
	LDA !1715,x	;\$02-$03: Y position
	SBC $1C			;|
	STA $02			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	.OAM
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve OAM index Y
		LDA !170B,x
		AND #$00FF
		ASL
		TAY
		LDA $02				;\Y position -1 because sprite OAM are shifted 1 px lower
		DEC				;/
		CMP NoDrawOAMBoundary-2,y	;\Y offscreen
		BMI ..NoOAM			;|
		CMP.w #$00E0-1			;|>Because of the Y-1, this position must be shifted as well.
		BPL ..NoOAM			;/
		LDA $00				;\X offscreen
		CMP NoDrawOAMBoundary-2,y	;|
		BMI ..NoOAM			;|
		CMP #$0100			;|
		BPL ..NoOAM			;/
		SEP #$20
		PLY				;>Restore OAM index Y
		
		..XPos
			LDA $00			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $01			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $02			;\Y position
			STA $0201|!addr,y	;/
			BRA ..NoOAMSkipPullY
		
		..NoOAM
			PLY
		..NoOAMSkipPullY
	PLB					;>Restore bank
	SEP #$20
	JML $029EC1
	
	.Despawn
		SEP #$20
		JML $029EE6
endif

WaterBubble: ;JML from $029F2A
;Interesting thing to note: The offscreen check checks the sprite's position as normal (non-offset
;position), but the drawn tiles are offset by a table at $029EEA horizontally and Y+5 at $029F52 after
;getting the base extended sprite values (including the non-offset positions) from calling $02A1A4.

;$02A1B1 is hijacked within $02A1A4 btw, so we don't need to expand the no-despawn-zone here.

;The code at $02A1A4 already have an offscreen check (deletes the sprite when outside the screen),
;which that checks the extended sprite's non-offset position. Therefore I have to rewrite this
;entire thing from scratch.
	PHK
	PEA.w .jslrtsreturn-1
	PEA $A772-1		;>RTL at $02A772
	JML $02A1A4
	.jslrtsreturn
	
	LDA.W !1765,X		;\$00 = horizontal displacement (offset)
	AND.B #$0C			;|
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.W $029EEA,Y			;|
	STA $00				;/
	.OAMHighByte
		BMI ..NegativeX			;\Add a high byte to make this a signed 16-bit number
		..PositiveX
			STZ $01
			BRA ..Skip
			
		..NegativeX
			LDA #$FF
			STA $01
		..Skip				;/
	LDA !1733,x		;\This mimicks a part of the code in $02A1A4 that deals with simply
	XBA				;|getting their onscreen OAM X position at $02A1B1.
	LDA !171F,x		;|
	REP #$21			;|
	ADC $00				;\...And move by offset
	SEC				;|
	SBC $1A				;/
	STA $00				;>$00-$01 = 16-bit X position of the OAM tile would be at relative to the screen, with offset.
	SEP #$21
	LDA !1729,x		;\This mimicks a part of the code in $02A1A4 that deals with simply
	XBA				;|getting their onscreen OAM Y position at $02A1C0.
	LDA !1715,x		;|
	REP #$20			;|
	SBC $1C				;/
	CLC				;\...And move by offset
	ADC #$0005			;/
	STA $02				;>$02-$03 = 16-bit Y position of the OAM tile would be at relative to the screen, with offset.

if !More_ExSprite == 0
	LDY !RAM_ExtOAMIndex		;>Y = OAM index
else
	TXA : ASL #2 : ADC #$0080 : TAY
endif
	;We now have our 16-bit OAM XY position in $00-$01 and $02-$03.
	;We need to write our own OAM handler aside from "ExtendedSpriteBaseCode"
	;only takes the non-offset positions.
	.CheckIfTileOnScreen
		LDA $00
		CMP #$FFF8
		BMI .NoOAM
		CMP #$0100
		BPL .NoOAM
		LDA $02
		CMP #$FFF8
		BMI .NoOAM
		CMP.w #$00E0-1
		BPL .NoOAM
	.DrawOAMXY
		SEP #$20
		..XPos
			LDA $00			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $01			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $02			;\Y position
			STA $0201|!addr,y	;/
			BRA .SkipNoOAM
	.NoOAM
		SEP #$20
		LDA #$F0			;\Had to write this because the non-offset Y pos
		STA $0201|!addr,y		;/may be set this to non $F0 values when the offsetted image is offscreen
	.SkipNoOAM
		SEP #$20
	.DrawOAMTileNumb
		LDA #$1C
		STA $0202|!addr,y
	JML $029F60

MarioFireballDespawnHandler: ;JML from $029FB3
	REP #$20
	LDA $00
	PHA
	LDA $02
	PHA
	SEP #$21
	LDA !1715,x	;\$00-$01: Y position
	SBC $1C			;|
	STA $00			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	;REP #$20
	PLA
	STA $02
	PLA
	STA $00
	SEP #$20
	JML $029FC2
	.Despawn
		;REP #$20
		PLA
		STA $02
		PLA
		STA $00
		SEP #$20
		JML $02A211
BaseballDespawnAndOAM: ;JML from $02A271
if !More_ExSprite == 0
	LDY !RAM_ExtOAMIndex	;>My hijack happens to occur before it even gets the OAM index.
else
	TXA : ASL #2 : ADC #$80 : TAY
endif
	LDA !171F,x	;\$00-$01: X position on screen
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA !1733,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	;Interisting info to note: In the original game, the baseballs (thrown from pitchin' chuck)
	;do not get deleted offscreen if they are going in one direction away opposite from the edges
	;of the screen (if they're going left, then the right edge of the screen will not despawn them)
	.DespawnHoriz
		..DespawnHandlerLeftEdge
			LDA $00
			CMP #!Despawn_LeftEdge
			BPL ..DespawnHandlerRightEdge
			SEP #$20
			LDA !1747,x
			BMI .DespawnBaseball
			REP #$20
		..DespawnHandlerRightEdge
			LDA $00
			CMP #!Despawn_RightEdge
			BMI ..NoDespawnHoriz
			SEP #$20
			LDA !1747,x
			BPL .DespawnBaseball
		..NoDespawnHoriz
	SEP #$21
	LDA !1715,x	;\$02-$03: Y position on screen
	SBC $1C			;|
	STA $02			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .DespawnBaseball
	CMP #!Despawn_Bottom
	BPL .DespawnBaseball
	SEP #$20
	.ShouldItBeDrawn
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve Y index (OAM index)
		LDA !170B,x		;\Get left boundary index
		ASL				;|
		TAY				;/
		REP #$20
		LDA $00				;\Check if OAM tile is offscreen horizontally
		CMP NoDrawOAMBoundary-2,y	;|
		BMI .NoOAM			;|
		CMP #$0100			;|
		BPL .NoOAM			;/
		LDA $02				;\Same but vertically
		CMP NoDrawOAMBoundary-2,y	;|
		BMI .NoOAM			;|
		CMP.w #$00E0-1			;|
		BPL .NoOAM			;/
		SEP #$20
		PLY				;>Restore Y index (OAM index)
		PLB				;>Restore bank
	.HandleOAM
		LDA $00			;\Bits 0-7 X position
		STA $0200|!addr,y	;/
		TYA			;\Bit 8 X position
		LSR #2			;|
		PHY			;|
		TAY			;|
		LDA $01			;|
		AND.b #%00000001	;|
		STA $0420|!addr,y	;|
		PLY			;/
		LDA $02			;\Y position
		STA $0201|!addr,y	;/
	.Done
		JML $02A2A3
	.NoOAM
		SEP #$20
		PLY				;>Restore Y index (OAM index)
		PLB
		JML $02A2BE
	
	
	.DespawnBaseball
	SEP #$20
	JML $02A2BF
SmokePuffDespawnAndOAM: ;JML from $02A36C
	LDA !171F,x	;\$00-$01: X position
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA !1733,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$21
	LDA !1715,x	;\$02-$03: Y position
	SBC $1C			;|
	STA $02			;|
	LDA !1729,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	
	LDA $00
	CMP #$FFF0
	BMI .NoOAM
	CMP #$0100
	BPL .NoOAM
	LDA $02
	CMP #$FFF0
	BMI .NoOAM
	CMP.w #$00E0-1
	BPL .NoOAM
	.DrawOAMXY
		SEP #$20
		..XPos
			LDA $00			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $01			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $02			;\Y position
			STA $0201|!addr,y	;/
	.Done
		JML $02A386
	
	.NoOAM
		SEP #$20
		JML $02A3AA	;>Skip all tile write-related code
	
	.Despawn
		SEP #$20
		JML $02A211
SetOnlySizeBitX:
	;In the original game, it sets the entire byte to %00000010,
	;therefore clearing the high bit of the X position. This means
	;it's X position is restricted to a screen graphically.
	LDA $0420|!addr,x
	AND.b #%00000011		;>Just in case a 0.001% that some random code would set any bits in bits 2-7
	ORA.b #%00000010		;>Set only the size bit.
	STA $0420|!addr,x
	RTL
	
ClearOnlySizeBitY:
	LDA $0420|!addr,y
	AND.b #%00000001
	STA $0420|!addr,y
	RTL
SetOnlySizeBitY:
	LDA $0420|!addr,y
	AND.b #%00000011		;>Just in case a 0.001% that some random code would set any bits in bits 2-7
	ORA.b #%00000010		;>Set only the size bit.
	STA $0420|!addr,y
Set0460OnlySizeBitY:
	LDA $0460|!addr,y
	ORA.b #%00000010
	STA $0460|!addr,y
	RTL
	

FlowerFix:
	LDA !14D4,x
	STA !1729,y
	JML $02F301
	