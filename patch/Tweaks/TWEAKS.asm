;This file contains various Tweaks and Hex Edits
;Based on SMWC's Tweaks v1.1 (2025-07-19)



; SA-1 detection code
if read1($00FFD5) == $23
    sa1rom

    !sa1 = 1
    !dp = $3000
    !addr = $6000
    !ram = $400000
    !bank = $000000
    !bank8 = $00
    !SprSize = $16
else
    lorom

    !sa1 = 0                ; SA-1 flag
    !dp = $0000             ; Direct Page remap ($0000 - LoROM/FastROM, $3000 - SA-1 ROM)
    !addr = $0000           ; Address remap ($0000 - LoROM/FastROM, $6000 - SA-1 ROM)
    !ram = $7E0000          ; WRAM/BW-RAM remap ($7E0000 - LoROM/FastROM, $400000 - SA-1 ROM)
    !bank = $800000         ; Long address remap ($800000 - FastROM, $000000 - SA-1 ROM)
    !bank8 = $80            ; Bank byte remap ($80 - FastROM, $00 - SA-1 ROM)
    !SprSize = $0C          ; Number of sprite slots (12 - FastROM, 22 - SA-1 ROM)
endif

!EXLEVEL = 0

if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
    !EXLEVEL = 1
endif

macro define_sprite_table(name, name2, addr, addr_sa1)
    if !sa1 == 0
        !<name> #= <addr>
    else
        !<name> #= <addr_sa1>
    endif

    !<name2> #= !<name>
endmacro

; Regular sprite tables
%define_sprite_table(sprite_num, "9E", $9E, $3200)
%define_sprite_table(sprite_speed_y, "AA", $AA, $9E)
%define_sprite_table(sprite_speed_x, "B6", $B6, $B6)
%define_sprite_table(sprite_misc_c2, "C2", $C2, $D8)
%define_sprite_table(sprite_y_low, "D8", $D8, $3216)
%define_sprite_table(sprite_x_low, "E4", $E4, $322C)
%define_sprite_table(sprite_status, "14C8", $14C8, $3242)
%define_sprite_table(sprite_y_high, "14D4", $14D4, $3258)
%define_sprite_table(sprite_x_high, "14E0", $14E0, $326E)
%define_sprite_table(sprite_speed_y_frac, "14EC", $14EC, $74C8)
%define_sprite_table(sprite_speed_x_frac, "14F8", $14F8, $74DE)
%define_sprite_table(sprite_misc_1504, "1504", $1504, $74F4)
%define_sprite_table(sprite_misc_1510, "1510", $1510, $750A)
%define_sprite_table(sprite_misc_151c, "151C", $151C, $3284)
%define_sprite_table(sprite_misc_1528, "1528", $1528, $329A)
%define_sprite_table(sprite_misc_1534, "1534", $1534, $32B0)
%define_sprite_table(sprite_misc_1540, "1540", $1540, $32C6)
%define_sprite_table(sprite_misc_154c, "154C", $154C, $32DC)
%define_sprite_table(sprite_misc_1558, "1558", $1558, $32F2)
%define_sprite_table(sprite_misc_1564, "1564", $1564, $3308)
%define_sprite_table(sprite_misc_1570, "1570", $1570, $331E)
%define_sprite_table(sprite_misc_157c, "157C", $157C, $3334)
%define_sprite_table(sprite_blocked_status, "1588", $1588, $334A)
%define_sprite_table(sprite_misc_1594, "1594", $1594, $3360)
%define_sprite_table(sprite_off_screen_horz, "15A0", $15A0, $3376)
%define_sprite_table(sprite_misc_15ac, "15AC", $15AC, $338C)
%define_sprite_table(sprite_slope, "15B8", $15B8, $7520)
%define_sprite_table(sprite_off_screen, "15C4", $15C4, $7536)
%define_sprite_table(sprite_being_eaten, "15D0", $15D0, $754C)
%define_sprite_table(sprite_obj_interact, "15DC", $15DC, $7562)
%define_sprite_table(sprite_oam_index, "15EA", $15EA, $33A2)
%define_sprite_table(sprite_oam_properties, "15F6", $15F6, $33B8)
%define_sprite_table(sprite_misc_1602, "1602", $1602, $33CE)
%define_sprite_table(sprite_misc_160e, "160E", $160E, $33E4)
%define_sprite_table(sprite_index_in_level, "161A", $161A, $7578)
%define_sprite_table(sprite_misc_1626, "1626", $1626, $758E)
%define_sprite_table(sprite_behind_scenery, "1632", $1632, $75A4)
%define_sprite_table(sprite_misc_163e, "163E", $163E, $33FA)
%define_sprite_table(sprite_in_water, "164A", $164A, $75BA)
%define_sprite_table(sprite_tweaker_1656, "1656", $1656, $75D0)
%define_sprite_table(sprite_tweaker_1662, "1662", $1662, $75EA)
%define_sprite_table(sprite_tweaker_166e, "166E", $166E, $7600)
%define_sprite_table(sprite_tweaker_167a, "167A", $167A, $7616)
%define_sprite_table(sprite_tweaker_1686, "1686", $1686, $762C)
%define_sprite_table(sprite_off_screen_vert, "186C", $186C, $7642)
%define_sprite_table(sprite_misc_187b, "187B", $187B, $3410)
%define_sprite_table(sprite_tweaker_190f, "190F", $190F, $7658)
%define_sprite_table(sprite_misc_1fd6, "1FD6", $1FD6, $766E)
%define_sprite_table(sprite_cape_disable_time, "1FE2", $1FE2, $7FD6)

; Romi's Sprite Tool defines.
%define_sprite_table(sprite_extra_bits, "7FAB10", $7FAB10, $6040)
%define_sprite_table(sprite_new_code_flag, "7FAB1C", $7FAB1C, $6056)
%define_sprite_table(sprite_extra_prop1, "7FAB28", $7FAB28, $6057)
%define_sprite_table(sprite_extra_prop2, "7FAB34", $7FAB34, $606D)
%define_sprite_table(sprite_custom_num, "7FAB9E", $7FAB9E, $6083)
%define_sprite_table(sprite_extra_byte1, "7FAB40", $7FAB40, $60A4)
%define_sprite_table(sprite_extra_byte2, "7FAB4C", $7FAB4C, $60BA)
%define_sprite_table(sprite_extra_byte3, "7FAB58", $7FAB58, $60D0)
%define_sprite_table(sprite_extra_byte4, "7FAB64", $7FAB64, $60E6)


macro tweak_sprite_prop(num, prop, value)
	if <prop> == $1656
		org $07F26C+<num>
		db <value>
	elseif <prop> == $1662
		org $07F335+<num>
		db <value>
	elseif <prop> == $166E
		org $07F3FE+<num>
		db <value>
	elseif <prop> == $167A
		org $07F4C7+<num>
		db <value>
	elseif <prop> == $1686
		org $07F590+<num>
		db <value>
	elseif <prop> == $190F
		org $07F659+<num>
		db <value>
	endif
endmacro





;	Above Screen Feather Collection Fixes
org $01C5AE
        LDA.b #$18           ;\ Reorder the instructions here so only the smoke is not spawned when above the screen.
        STA.w $1496|!addr    ;|
        LDA.b #$03           ;|
        STA.b $71            ;|
        LDA.b $81            ;|
        ORA.b $7F            ;|
        BNE +                ;/
org $01C5EB
+



;	Same Controller for Both Players
org $0086A0
    stz $0DA0|!addr
    lda $0DA0|!addr
    ldx #$00



;	Always spawn Control Coins from blocks
org $02895F
	BRA +
org $028967
+



;	Disable Funky clear changing normal Koopa colours
org $02A988
	BRA +
org $02A996
+



;	Disable time score tally after beating a level
org $05CD04
;;;	STZ $0F40|!addr



;	Change Yoshi rescue message trigger
org $01EC2C
	LDA #$00
	NOP #2



;	Change "Nintendo Presents" Timer
org $0093C5
;;;	lda.b #$80



;	Disable Title Screen layer 3 palette
org $009A9E
	BRA +
	NOP #4
+



;	Keep sprites drawn on File Select
org $009C9F
	BRA +
	NOP #2
+



;	Change background colour and colour math used for File Select
org $009CD3
	LDA.w #$39C9
	LDY.b #$60



;	Carriable Sprites Through Pipes Fix
org $02AC18
	BRA +
org $02AC48
+



;	Remove Interaction Framerules
org $01A7EE	;Mario Sprite interaction
;;;	AND.b #$00
org $0294FF	;Capespin interaction
;;;	BCC $00
org $02A0B1	;Fireball interaction
;;;	BNE $00



;	Remove Sprite Spawn Framerule
org $02A7FE
;;;	AND.b #$00



;	Reset Local Frame Counter At Level Load
org $00A5F9
;;;	LDA.b #$FF



;	Remove Yellow Koopa Jump Framerule
org $018898
;;;	BRA +
;;;	NOP #5
+



;	Sprite Interaction on Left Edge of Screen Fix
org $01A7F0	;Remove check for the sprite being horizontally offscreen
;;;	BRA +
;;;	NOP
+



;	Fix Highest Sprite Slot Oddities
org $01846C	; Lakitu spawn check
    db !SprSize-1
org $01889F	; Yellow Koopa jump check
	LDY.b #!SprSize-1
org $01BDB9	; Magikoopa spawn check
    db !SprSize-1
org $01E7DC	; Cloud's Lakitu check
    db !SprSize-1
org $02813A	; Explosion sprite interaction
    db !SprSize-1
org $0294CD	; Cape ground pound
    db !SprSize-1
org $02A0B9	; Mario/Yoshi fireballs sprite interaction
    db !SprSize-1
org $02B7AD	; Pokey sprite interaction
    db !SprSize-1
org $02B9C3	; Silver P-Switch effect
    db !SprSize-1
org $02DB65	; Flying Hammer Bro platform check
    db !SprSize-1
org $02EDE5	; Skull Raft despawn check
    db !SprSize-1
org $02EE20	; Unused Skull Raft check
    db !SprSize-1
org $03865F	; Flying Grey Turnblocks check
    db !SprSize-1
org $03A6C9	; Boss end sprite kill
    db !SprSize-1
org $03C210	; Light switch spotlight check
    db !SprSize-1
org $03C4E2	; Spotlight spawn check
    db !SprSize-1




;	Switch Palace Switches always end the level
org $00EEB1
	BNE +
org $00EEB7
+



;	Start Fast BG Scroll Without Grey Platform
org $05C7BC
	BRA +
	NOP #3
+



;	Disable Yoshi Egg spawning egg shards
org $01F7C8
	RTS



;	Enable Yoshi mount dust
org $028BB3
	JSR.w $028BB9



;	Exiting Horizontal Pipe Sound Fix
org $00986A	;\ Prevent Mario's Y speed from being randomly cleared during during game mode 12.
	NOP #2	;/ This allows Mario's pipe Y speed to persist, otherwise the sound will double up when exiting a vertical pipe.
org $00A76A	;\ Prevent a garbage byte from being written to Mario's Y speed during exit pipe state initialization.
	NOP #2	;/ This allows the pipe sound to play the first frame the pipe state routine runs, as was likely intended by Nintendo.



;	Change Door Entry Detection
; width of door enterable region of the door (up to 0x10, default 0x08) 
org $00F44A
;;;	CMP.b #$0A
; offset of door enterable region, which is ($10-above)/2
org $00F446
;;;	ADC.b #$03



;	Fix the glitch where bouncing on a note block can allow you to collect a coin positioned 16 screens away and one block above
; Source: https://www.smwcentral.net/?p=viewthread&t=94186
org $0292AC
	BPL +
org $0292B2
+
org $0292BD
	BPL +
org $0292C3
+
org $0292FF
	BPL +
org $029305
+
org $029310
	BPL +
org $029316
+



;	Fix SP1 ExGFX
org $00A439
;;;	BRA +	;Probably not needed since LM 2.21
org $00A47E
+



;	Change tileset specific layer 3 for tileset D (Cloud/Forest)
org $009FAC
db $01,$02,$81
org $059072
dl $0595DE|!bank



;	Change Goal Tape carried sprite rewards
org $00FADF	; Shell, throwblock, Goomba, Bob-omb, Mechakoopa, P-balloon, or anything else
db $74,$F0,$F0,$F0,$F1
org $00FAE6	;Springboard, P-Switch
db $74,$F0,$F0,$F0,$F1



;	Edit Sprite Memory 0A to allow 22 sprites with 4 slots reserved for Wigglers
org $02A773+$A
db $13		;Highest slot for normal sprites
org $02A7AC+$A
db $FF		;Lowest slot-1 for normal sprites
org $02A786+$A
db $04		;Highest slot for reserved sprite 1
org $02A799+$A
db $03		;Highest slot for reserved sprite 2 (has a hardcoded lowest slot 0)
org $02A7BF+$A
db $00		;Lowest slot-1 for reserved sprite 1 (Slot 0 is reserved for held items)
org $02A7D2+$A
db $86		;Reserved sprite 1 ID, also applies to custom sprite $86
org $02A7E4+$A
db $FF		;Reserved sprite 2 ID, (Possibly set to one used by a Wiggler disassembly)



;	Dino-Rhino Stuck Against Walls Fix
org $039C6E	;Change how much Dino-Rhinos get pushed back when touching a wall
db $00,$FF,$01	;Low byte
db $00,$FF,$00	;High byte



;	Make Winged Red Coins immune to fireballs
%tweak_sprite_prop($7E,$166E,%00110100)






;		GRAPHIC CHANGES



;	Course Clear text
incsrc "courseclear.asm"



;	Disable the 1 Player Game  2 Player Game stripe
org $05B872
;;;	db $FF



;	Change Mario/Luigi Start text
; DEMO START
org $0090D9
db $15,$4E,$04,$4B,$5E,$FF
org $00910D
db $15,$4E,$14,$4B,$5E,$FF
org $009141
db $34,$34,$34,$34,$B4,$34
org $009172
db $B4,$B4,$34,$B4,$34,$34

; IRIS START
org $0090DF
db $5D,$00,$4C,$00,$FF,$FF
org $009113
db $5D,$00,$5C,$00,$FF,$FF
org $009178
db $F4,$B4,$34,$B4,$34,$00



;	Fix one row of the keyhole triangle shape that's bigger than proceeding and preceeding ones
org $00CBA3
db $49



;	Fix Overworld Yoshi using red palette
org $048A36	;Tiles and properties for 2nd left Yoshi walking frame
db $42,$22,$43,$22,$52,$22,$53,$22



;	Change Castle Entrance Door palette
org $02F6D9
	LDA.b #$25



;	Remap Score Sprites
org $02AD4C	;1st half
db $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A	
db $0A,$0A,$0A,$0A,$0A,$56,$56,$56
db $56,$0A,$0A,$0A,$0A,$0A

org $02AD62	;2nd half
db $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
db $0A,$0A,$0A,$0A,$0A,$57,$57,$57
db $57,$0A,$0A,$0A,$0A,$0A



;	Remap Bounce Sprites
org $0291F1	;Tiles, in the order of $1699.
db $40,$C2,$2A,$42,$EA,$8A,$40
org $028789	;Properties, in the order of $1699.
db $00,$02,$00,$00,$01,$07,$00
db $04,$0A			; Last two are for yellow and green ! blocks respectively.



;	Change Broken Block Particle palette
org $028B8C	;This also affects Throw Block particles
db $04,$04,$84,$84,$84,$C4,$44,$04



;	Remap Water Splash (goodbye tile $68)
org $028D42
db $64,$64,$6A,$6A,$6A,$62,$62,$62
db $64,$64,$64,$64,$66



;	Change Hammer palette
org $02A2E7
db $45,$45,$05,$05,$85,$85,$C5,$C5



;	Remap Cluster Boos
org $02FBBF
db $88,$88,$A8,$8E,$AA,$AE,$88,$88



;	Remap Cluster Swooper
org $02FDB8
db $AE,$AE,$C0,$E8



;	Mario 8x8 Tile Remap
incsrc "extendmario.asm"



;	Demo/Iris on Yoshi victory pose fix.
;Source: https://smwc.me/1226116
org $00DCEC+$14
db $00		;> originally: $0E



;	Dolphin Offscreen Tail Fix
%tweak_sprite_prop($43,$190F,%00100101)



;	Disable Fire Flower Flipping
org $01C34B
	AND.b #$00



;	Non-Dynamic Podoboo
; change the Podoboo's tilemap
org $019C35
db $00,$00,$10,$10	;$06,$06,$16,$16
db $01,$01,$11,$11	;$07,$07,$17,$17
db $10,$10,$00,$00	;$16,$16,$06,$06
db $11,$11,$01,$01	;$17,$17,$07,$07

; change a JSR to a JMP, bypassing the dynamic GFX routine
org $01E19A
	JMP.w $019CF3

; make the sprite use the second GFX page
%tweak_sprite_prop($33,$166E,%00110101)



;	Remap some instances of Blank tile ($83). Map to AAT-specific blank tile $0A in GFX00.
org $019BC1	; Jumping Piranha Plant tilemap
db $0A,$0A,$C4,$C4,$0A,$0A,$C5,$C5

org $019C25	; Portable springboard tilemap
db $0A,$0A,$6F,$6F

org $01DEE3	; Bonus Game roulette tilemap
db $58,$59,$0A,$0A
db $48,$49,$58,$59
db $0A,$0A,$48,$49
db $34,$35,$0A,$0A
db $24,$25,$34,$35
db $0A,$0A,$24,$25
db $36,$37,$0A,$0A
db $26,$27,$36,$37
db $0A,$0A,$26,$27



;	Remap Yoshi Egg
org $01F75C	;Pages
db $01,$01,$01,$01
org $01F760	;Tiles
db $02,$02,$02,$00



;	Remap Yoshi's throat tile
org $01F08A	;Tile
	LDA.b #$0A
org $01F096	;Page
	ORA.b #$00



;	Remap Banzai Bill
org $02D5C4	;Tiles
db $80,$82,$84,$86
db $A0,$88,$CE,$EE
db $C0,$C2,$E0,$E2
db $8E,$AE,$E4,$A4
org $02D5D4	;Properties
db $3D,$3D,$3D,$3D
db $3D,$3D,$3D,$3D
db $3D,$3D,$3D,$3D
db $3D,$3D,$3D,$3D



;	Remap Count Lift Digits
org $038E0E
db $B7,$B6,$A7,$A6



;	Remap Block Boo
org $01FA37
db $88,$C8,$CA



;	Fix Stretch Blocks having last part be horizontally flipped
org $01B79C
;;;	BRA $00



;	Remap Chargin' Chuck
org $02CAFA	;Properties for Chargin' Chuck's shoulder in frames 12/13
db $4B,$0B
org $02CB96	;Properties for Diggin' Chuck's shovel or shoulder
db $4B,$0B



;	Change Mega Mole's Palette
org $038881
	LDA.b #$09



;	Change Football's Palette
%tweak_sprite_prop($1B,$166E,%00000101)



;	Change Spike Top's Palette
%tweak_sprite_prop($2E,$166E,%00100101)



;	Change Monty Mole's Palette
org $01E369
	ORA.b #$35
%tweak_sprite_prop($4D,$166E,%00000101)
%tweak_sprite_prop($4E,$166E,%00000101)



;	Change Football's Palette
%tweak_sprite_prop($7D,$166E,%00010101)



;	Change Winged 1UP's Palette
%tweak_sprite_prop($7F,$166E,%00101010)



;	Change Falling Spike's Palette
%tweak_sprite_prop($B2,$166E,%00110101)