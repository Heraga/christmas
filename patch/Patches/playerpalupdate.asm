;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Manual Player Palette Update Patch, by imamelia
;; Rewritten by ASMagician Maks to allow arbitrarily sized player palettes and fix Boss Clear fade in mode 7 rooms
;;
;; This patch allows up to change the player's palette on the fly (in the middle of
;; a level or whatever you want) by setting a flag in RAM.
;;
;; Usage instructions:
;;
;; To change the player's palette, store a 24-bit pointer to the new color values
;; to !RAM_PlayerPalPtr and set whatever bit of !RAM_PalUpdateFlag is specified
;; (bit 0 by default).  Note that this flag must be set every frame you want to use
;; the custom palette; it clears every time the palette upload routine is run, and
;; the colors don't carry over into the next frame.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
	!FreeRAM	= $418AFF	;4 bytes
	!RAM_PlayerPalPtr = !FreeRAM
	!RAM_PalUpdateFlag = !FreeRAM+3
else
	lorom
	!addr = $0000
	!bank = $800000
	!FreeRAM	= $7FA034	;4 bytes
	!RAM_PlayerPalPtr = !FreeRAM
	!RAM_PalUpdateFlag = !FreeRAM+3
endif


!FlagValue = $01
!PaletteStart	= $83	;\ AAT edit: Player colors use more of the palette.
!PaletteLength	= $0D	;/
;!PaletteStart	= $86
;!PaletteLength	= $0A


org $00A309
	LDY.b #!PaletteStart

org $00A311
	autoclean JML PlayerPaletteHack
	NOP

Mode7NMIHijack:
	JSR.w $00A488
	LDA $143A|!addr
	JMP.w $0082CD

assert pc() <= $00A31F

org $00A31F
	LDA.w #!PaletteLength*2	;> AAT edit: Player colors use more of the palette.


org $0082CA	;Move generic palette upload handling before Mario palette upload in mode 7 NMI
	JMP Mode7NMIHijack
org $0082EB
	BRA +
	NOP
+

org $00B048	;Fix Boss Clear fade in mode 7 rooms
	REP #$30
	BRA +
org $00B05F
+

org $00E2A2
dw DefaultPalette_Mario,DefaultPalette_Luigi
dw DefaultPalette_Mario,DefaultPalette_Luigi
dw DefaultPalette_Mario,DefaultPalette_Luigi
dw DefaultPalette_FireMario,DefaultPalette_FireLuigi


freecode

PlayerPaletteHack:
	STA $4320
	LDA !RAM_PalUpdateFlag-1
	BIT.w #!FlagValue<<8
	BEQ .NormalPalette
	AND.w #((!FlagValue^$FF)<<8)|$00FF
	STA !RAM_PalUpdateFlag-1
	TAY
	STY $4324
	LDA $0D82|!addr
	SEC
	SBC.w #DefaultPalette
	CLC
	ADC !RAM_PlayerPalPtr
	STA $4322
	JML $00A31F|!bank

.NormalPalette
	LDY.b #DefaultPalette>>16
	STY $4324
	LDA $0D82|!addr
	STA $4322
	JML $00A31F|!bank



DefaultPalette:
.Mario
dw $0054,$023F,$0F3F,	$6B9F,$259A,$4ADF,$318C,$62D4,$2422,$3CE3,$5584,$76A9,$7FD6
.FireMario
dw $0054,$023F,$0F3F,	$6B9F,$259A,$4ADF,$318C,$62D4,$000C,$0011,$24BE,$465F,$66DF
.Luigi
dw $4C8E,$59B3,$7299,	$6B9F,$259A,$4ADF,$318C,$62D4,$0D22,$15A3,$2E4A,$3EAF,$4AD1
.FireLuigi
dw $4C8E,$59B3,$7299,	$6B9F,$259A,$4ADF,$318C,$62D4,$2426,$342D,$4C74,$60B8,$79BE



print "Freespace used: ",freespaceuse," bytes."
