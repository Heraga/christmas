;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Fire-Spitting Piranha Plant, by imamelia
;;
;; This is a Piranha Plant that spits fireballs when it emerges from its pipe.
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is clear, the plant will spit only one pair of fireballs.
;; If the first extra bit is set, the plant will spit three pairs of fireballs.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;incsrc subroutinedefsx.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; $151C,x = holder for the sprite's initial Y position low byte
; $1528,x = holder for the sprite's initial X position low byte

Speed:			; the Piranha Plant's speed for each sprite state (inverted for down and right plants)
db $00,$F0,$00,$10		; in the pipe, moving forward, resting at the apex, moving backward

TimeInState:		; the time the sprite will spend in each sprite state, indexed by bits 2, 4, and 5 of the behavior table

db $30,$20,$30,$20	; long Piranha Plants
db $30,$18,$30,$18	; short Piranha Plants

!StemYOffset = $10		;

HeadTilemap:
db $AE,$AC

!StemTile = $CE

; These two are indexed by ------lc, where c = color and l = length.
; Add 1 to each of these values if you want the tile to use the second graphics page.

StemPalette:			; the palette of the stem tiles
db $0A,$08,$0A,$08

HeadPalette:			; the palette of the head tiles
db $08,$08,$0A,$08

; This tile will be invisible because it has sprite priority setting 0,
; but it will go in front of the plant tiles to cover it up when it is in a pipe.
; That way, the plant tiles don't need to have hardcoded priority.
; This tile should be as close to square as possible.
; Note: The default value WILL NOT completely hide the tiles unless you have changed its graphics!
; But the only completely square tile in a vanilla GFX00/01 is the message box tile, which is set to be overwritten by default.

!CoverUpTile = $40			; the invisible tile used to cover up the sprite when it is in a pipe

!InitOffsetYLo = $FF
!InitOffsetYHi = $FF
!InitOffsetXLo = $08
!InitOffsetXHi = $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
PHB
PHK
PLB
JSR PiranhaInit
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaInit:

LDA !7FAB28,x	;
AND #$04	;
LSR #2		;
STA !1510,x	;

LDA !D8,x	;
CLC		;
ADC #!InitOffsetYLo	; Y position low byte
STA !D8,x	;
LDA !14D4,x	;
ADC #!InitOffsetYHi	; Y position high byte
STA !14D4,x	;
LDA !E4,x	;
CLC		;
ADC #!InitOffsetXLo	; X position low byte
STA !E4,x		;
LDA !14E0,x	;
ADC #!InitOffsetXHi	; X position high byte
STA !14E0,x	;

LDA !1510,x	; get the bits for the sprite state timer index
AND #$01	;
ASL #2		;
STA !1504,x	;

LDA !D8,x	;
STA !151C,x	; back up the sprite's initial XY position (low bytes)
LDA !E4,x	;
STA !1528,x	;

RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR PiranhaPlantsMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EndMain:
RTS

PiranhaPlantsMain:

;LDA $1594,x		; if the sprite is in a pipe and the player is near...
;BNE NoGFX		; don't draw the sprite
LDA !C2,x		;
BEQ NoGFX		;

JSR PiranhaPlantGFX	; draw the sprite

NoGFX:			;

LDA $9D			; if sprites are locked...
BNE EndMain		; terminate the main routine right here

%SubOffScreen()		;

PiranhaAnimation:		;

JSR SetAnimationFrame	; determine which frame the plant should show

LDA !1594,x		; if the plant is in a pipe...
BNE NoInteraction	; don't let it interact with the player

JSL $01803A|!BankB	; interact with the player and other sprites

NoInteraction:		;

LDA !C2,x		; if the extra bit is set...
CMP #$02		; then make sure it's in the correct sprite state (resting at the apex)
BNE NoFireCheck		;

LDA !7FAB10,x		;
AND #$04		; if the extra bit isn't set...
BEQ NoFireCheck		; don't check certain timer values to see if it should spit a fireball

LDA !1540,x		;
CMP #$20		; if the fire timer
BEQ Fire		; is at certain numbers...
CMP #$10		; spit a fireball
BEQ Fire		;

NoFireCheck:

LDA !C2,x		; use the sprite state
AND #$03		; to determine what the sprite's speed should be
TAY			;
LDA !1540,x		; if the timer for changing states has run out...
BEQ ChangePiranhaState	;

LDA Speed,y		; load the base speed
STA !AA,x		; store the speed value to the sprite Y speed table
JSL $01801A|!BankB	; update sprite Y position without gravity
RTS			;

ChangePiranhaState:	;

LDA !C2,x		; sprite state
AND #$03		; 4 possible states, so we need only 2 bits
STA $00			; store to scratch RAM for subsequent use
LDA !1510,x		;
AND #$02		; if the plant is a red one...
ORA $00			; or the sprite isn't in the pipe...
BNE NoProximityCheck	; don't check to see if the player is near

%SubHorzPos()		; get the horizontal distance between the player and the sprite

LDA #$01		;
STA !1594,x		; set the invisibility flag if necessary
LDA $0E			;
CLC			;
ADC #$1B		; if the sprite is within a certain distance...
CMP #$37		;
BCC EndStateChange	; don't change the sprite state

NoProximityCheck:	;

STZ !1594,x		; if the sprite is out of range, clear the invisibility flag
LDA !C2,x		;
INC			; increment the sprite state
AND #$03		;
STA !C2,x		;
STA $00			;
LDA !1510,x		;
AND #$01		; use the stem length bit
ASL #2			;
ORA $00
TAY			; to set the timer for changing sprite state
LDA TimeInState,y		;
STA !1540,x		; set the time to change state
CPY #$02		; if the sprite state isn't 02...
BNE EndStateChange	; don't spit fire

JSR SpitFireballs		;

EndStateChange:		;

RTS

SetAnimationFrame:		;

INC !1570,x		; $1570,x - individual sprite frame counter, in this context
LDA !1570,x		;
LSR #3			; change image every 8 frames
AND #$01		;
STA !1602,x		; set the resulting image
RTS

Fire:			;
JMP SpitFireballs		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaPlantGFX:		; I made my own graphics routine, since the Piranha Plant uses a shared routine.

%GetDrawInfo() 		; set some variables up for writing to OAM

LDA !1510,x		;
AND #$04		; stem length
LSR			;
STA $04			;
LDA !1510,x		;
AND #$08		;
LSR #3			; plus color
TSB $04			;

LDA !1602,x		;
STA $03			; frame = bit 0 of the index

LDA !1510,x		;
AND #$01		; if the plant has a short stem...
BNE AlwaysCovered		; then the stem is always partially obscured by the cover-up tile

LDA !C2,x		;
CMP #$02			; if the sprite is all the way out of the pipe...
BEQ StemOnly		; then draw just the stem

AlwaysCovered:		;

LDA !D8,x		;
SEC			;
SBC !151C,x		;
STA $06			;
LDA !E4,x		;
SEC			;
SBC !1528,x		;
CLC			;
ADC $06			;
CLC			;
ADC #$10		;
CMP #$20			;
BCC CoverUpTileOnly	;

StemAndCoverUpTile:	;

JSR DrawCoverUpTile	;
INY #4			;
JSR DrawStem		;
LDA #$02			;
EndGFX:			;
PHA			;
INY #4			;
LDX $03			;
JSR DrawHead		; the head tile is always drawn
PLA			;
LDY #$02			;
LDX $15E9|!Base2		;
JSL $01B7B3|!BankB		;
RTS			;

StemOnly:		;

JSR DrawStem		;
LDA #$01			;
BRA EndGFX		;

CoverUpTileOnly:		;

JSR DrawCoverUpTile	;
LDA #$01			;
BRA EndGFX		;

DrawHead:

LDA $00			;
STA $0300|!Base2,y		;

LDA $01			;
STA $0301|!Base2,y		;

LDA HeadTilemap,x		; set the tile for the head
STA $0302|!Base2,y

LDX $04			; load the palette index
LDA HeadPalette,x		; add in the palette/GFX page bits
ORA $64			; and the level's sprite priority
STA $0303|!Base2,y		;

RTS

DrawStem:

LDX $03

LDA $00			;
STA $0300|!Base2,y		;

LDA $01			;
CLC			;
ADC #$10		;
STA $0301|!Base2,y		;

LDA #!StemTile		; set the tile for the stem
STA $0302|!Base2,y

LDX $04			; load the palette index
LDA StemPalette,x		; add in the palette/GFX page bits
ORA $64			; and the level's sprite priority
STA $0303|!Base2,y		;

RTS			;

DrawCoverUpTile:		;

LDX $15E9|!Base2		;

LDA !1528,x		;
STA $09			;
LDA !151C,x		; make backups of the XY init positions
STA $0A			;

LDA $09			;
SEC			;
SBC $1A			;
STA $0300|!Base2,y		;

LDA $0A			;
SEC			;
SBC $1C			;
STA $0301|!Base2,y		;

LDA #!CoverUpTile		;
STA $0302|!Base2,y		;

LDA #$00			;
STA $0303|!Base2,y		;

RTS			;

LDX $15E9|!Base2		; sprite index back into X
LDY #$02			; the tiles were 16x16
LDA $05			; we drew 2 or 3 tiles
JSL $01B7B3|!BankB		;

RTS			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; fireball-spit routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FireXOffset = $04
!FireYSpeed = $D0
FireXSpeeds:
db $10,$F0

SpitFireballs:

LDA !E4,x
STA $01
LDA !14E0,x
STA $02
LDA !D8,x
STA $03
LDA !14D4,x
STA $04

LDX #$01

SpitFireballLoop:

LDY #$07
ExSpriteLoop:
LDA $170B|!Base2,y
BEQ FoundExSlot
DEY
BPL ExSpriteLoop
RTS

FoundExSlot:

STY $00

LDA #$0B
STA $170B|!Base2,y

LDA $01
CLC
ADC #!FireXOffset
STA $171F|!Base2,y
LDA $02
ADC #$00
STA $1733|!Base2,y

LDA $03
STA $1715|!Base2,y
LDA $04
STA $1729|!Base2,y

LDA FireXSpeeds,x
STA $1747|!Base2,y
LDA #!FireYSpeed
STA $173D|!Base2,y

LDA #$FF
STA $176F|!Base2,y

DEX
BPL SpitFireballLoop

LDX $15E9|!Base2
RTS