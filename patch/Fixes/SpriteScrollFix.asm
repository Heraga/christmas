;This patch makes sprites always spawn from the direction the camera moved last

!Displacement = 0
;^Set this  to 1 if you wanted to use a number that is the amount of pixels
;the screen has been moved.

!Freeram_ScrnDisplace = $60
;[4 bytes], this ram is used if !Displacement is set to 1. This ram address
;holds the amount of pixels the screen has moved. Format:
;-First 2 bytes = moved horizontally
;-Last 2 = vertical.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA1 detector:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if read1($00FFD5) == $23
	sa1rom
	!dp = $3000		;>$0000-$00FF -> $3000-$30FF
	!addr = $6000		;>$0100-$0FFF -> $6100-$6FFF and $1000-$1FFF -> $7000-$7FFF
	!bank = $000000
else
	; Non SA-1 base addresses
	!dp = $0000
	!addr = $0000
	!bank = $800000
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hijack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
org $00F728				;>Routine that depends on mario's x pos on-screen that sets $55/$56.
	bra +
	nop #2
+

org $00F80C				;>Routine that depends on mario's y pos on-screen that sets $55/$56.
	bra +
	nop #2
+

org $00F7C2
	autoclean JML CheckScrollDir

freedata

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;code to be inserted to freespace
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckScrollDir:
	LDY.b #$02
	LDA $5B
	LSR
	BCS .vert

	LDA $1A
	SEC
	SBC.l $7F831F
if !Displacement
	STA !Freeram_ScrnDisplace
endif
	BEQ .end
	BPL .downright
	BRA .upleft

.vert
	LDA $1C
	SEC
	SBC.l $7F8321
if !Displacement
	STA !Freeram_ScrnDisplace+2
endif
	BEQ .end
	BPL .downright
.upleft
	LDY.b #$00
.downright
	STY $55
	STY $56
.end
	SEP #$20
	LDA $1A
	JML $00F7C6|!bank


if read1($0FFFE6) == $FF || read1($0FFFE6) == $00
	error "You need to insert Lunar Magic's VRAM patch before inserting this patch!"
endif
