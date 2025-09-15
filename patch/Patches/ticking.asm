; replaces the P-Switch music with a ticking sound effect while keeping the normal music playing
; by Kil
; PSI Ninja edit: Added directional coin ticking, SA-1 support, and changed the main code hijack.

!addr = $0000
!bank = $800000
if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
endif

!TickingSFX	= $2F
!TickingSFXPort	= $1DF9|!addr
!RunningOutSFX	= $24
!RunningOutSFXPort	= $1DFC|!addr

!RunningOutTime	= $1E	;At what amount remaining does the running out sound play

org $00C533
	autoclean JML Ticking
	NOP #2

freecode

Ticking:
	LDA $14AD|!addr		;  Check the blue p switch timer
	BEQ CHECKSILVER
	CMP.b #!RunningOutTime
	BNE +
	LDY.b #!RunningOutSFX
	STY !RunningOutSFXPort
+
	AND.b #$0F
	CMP.b #$0F
	BNE CHECKSILVER		; Every time the first 4 bits are 1, it plays the sound.
	LDA.b #!TickingSFX
	STA !TickingSFXPort

CHECKSILVER:
	LDA $14AE|!addr		; Check the silver p switch timer
	BEQ CHECKDIRECTIONAL
	CMP.b #!RunningOutTime
	BNE +
	LDY.b #!RunningOutSFX
	STY !RunningOutSFXPort
+
	AND.b #$0F
	CMP.b #$0F
	BNE CHECKDIRECTIONAL	; Every time the first 4 bits are 1, it plays the sound.
	LDA.b #!TickingSFX
	STA !TickingSFXPort

CHECKDIRECTIONAL:
	LDA $190C|!addr		; Check the directional coin timer
	BEQ RETURN
	AND.b #$0F
	CMP.b #$0F
	BNE RETURN		; Every time the first 4 bits are 1, it plays the sound.
	LDA.b #!TickingSFX
	STA !TickingSFXPort
RETURN:
	JML $00C55C|!bank
