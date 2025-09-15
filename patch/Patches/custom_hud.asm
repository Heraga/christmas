;Customizable HUD
;by ASMagician Maks
;
;Includes AAT Sprite HUD by PSI Ninja
;
;Also includes Time Up Fix and code to set Retry System's Hurry Up flag

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

	!sa1 = 0
	!dp = $0000
	!addr = $0000
	!ram = $7E0000
	!bank = $800000
	!bank8 = $80
	!SprSize = $0C
endif


!hudtype	#= $13E6|!addr	;1 byte of FreeRAM, type of HUD to display
!hudl3tilemap	#= $0EF9|!addr
!hudl3tilemapb	#= $0F14|!addr
;!hudl3tilemap2	#= $7FA200
!hudsprhead	#= $0F2F|!addr
!hudsprheadsrc	#= $0F2B|!addr
!hudsprheadslot	#= $0F2E|!addr


;HUD IDs that are equal or above this use layer 3 and IRQ
!hudtypelayer3	#= $03
;HUD IDs that are equal or above this don't use vanilla HUD Upload routine
!hudtypelayer3custom	#= $05


!DeathCounter	#= $41C7ED

!retry_freeram	= $40A400

!HPSettings #= $7C
!HPByte #= $58


macro retry_ram(name,offset)
    !retry_ram_<name> #= !retry_freeram+<offset>
endmacro

%retry_ram(timer,$00)			; 3
%retry_ram(respawn,$03)			; 2
%retry_ram(is_respawning,$05)	; 1
%retry_ram(music_to_play,$06)	; 1
%retry_ram(hurry_up,$07)		; 1


assert !sa1 == 1

org $00D0E6	;Time Up Fix tweak
	LDY.b #$0B
	LDA $0F30|!addr
	BPL ++
	BRA +
	NOP #4
+
org $00D104
++


org $008275
	JMP SetIRQ	;LDA $0D9B

org $008CFF
	autoclean JML InitializeLayer3HUD	;LDA.b #$80 : STA $2115
	NOP

org $008DAC
	JMP UploadLayer3HUD	;STZ $2115


org $008E1A	;Handle various counters and draw HUD
skip 5	;Skip UberASM hijack
	JMP HandleHUD
org $008E5F	;Skip retry hijacks
HandleHUD:
	TSC
	XBA
	CMP.b #$37		;Don't know if anything calls it from SA-1
	BEQ .sa1
	LDA.b #.sa1
	STA $3180
	LDA.b #.sa1>>8
	STA $3181
	LDA.b #.sa1>>16
	STA $3182
	JSR $1E80
	LDA !hudtype
	CMP.b #!hudtypelayer3
	BCS +
	JSL SprCheckHeadUpload
+
	RTS

.sa1
.handlecounters {
.timer
	LDA $1493|!addr				;\
	ORA $9D						;| Don't decrement the timer if:
	BNE .score					;|	- Ending a level
	LDA $0D9B|!addr				;|	- Game frozen
	CMP.b #$C1					;|	- In Bowser
	BEQ .score					;|	- A second hasn't passed
	LDA $0F30|!addr				;|\ Time up fix
	BMI .score					;|/
	DEC $0F30|!addr				;|
	BPL .score					;/
	LDA.b #$28					;> How long a second is. Use with $008D8B.
	STA $0F30|!addr
	LDA $0F31|!addr				;\
	ORA $0F32|!addr				;| If timer is already zero, skip "time up".
	ORA $0F33|!addr				;|
	BEQ .score					;/
	LDX.b #$02					;\
-								;|
	DEC $0F31|!addr,X			;|
	BPL +						;| Decrement timer.
	LDA.b #$09					;|
	STA $0F31|!addr,X			;|
	DEX							;|
	BPL -						;/
+
	LDA $0F31|!addr				;\
	BNE .score					;|
	LDA $0F32|!addr				;|
	AND $0F33|!addr				;| If time is 99, speed up music.
	CMP.b #$09					;|
	BNE +						;|
	LDA.b #$FF					;|\ SFX for the "time is running out!" effect.
	STA $1DF9|!addr				;//
	lda #$01					;\ Retry code
	sta !retry_ram_hurry_up		;/
+
	LDA $0F32|!addr				;\
	ORA $0F33|!addr				;| If time is 0, kill Mario.
	BNE .score					;|
	LDA.b #$FF					;|\ Time Up Flag
	STA $0F30|!addr				;|/
	JSL $00F606|!bank			;/
.score
	LDX $0DB3|!addr
	BEQ +
	LDX.b #$03
+
	LDA $0F34|!addr,X			;\
	SEC							;|
	SBC.b #$3F					;|
	REP #$20					;| Check if the player has reached a score of over 999999.
	LDA $0F35|!addr,x			;|
	SBC.w #$0F42				;|
	BCC .coins					;/
	LDA.w #$0F42				;\
	STA $0F35|!addr,X			;|
	LDA.w #$423F				;| Limit the maximum score to 999999.
	STA $0F34|!addr,X			;/
.coins
	SEP #$20
	LDA $13CC|!addr				;\
	BEQ .lives					;| Add a coin to the player's coin count if applicable.
	DEC $13CC|!addr				;|
	INC $0DBF|!addr				;/
	LDA $0DBF|!addr				;\
	CMP.b #$64					;| How many coins the player needs to get a 1up (100).
	BCC .lives					;/
	INC $18E4|!addr				; Give the player a life.
	LDA $0DBF|!addr				;\
	SEC							;|
	SBC.b #$64					;| How many coins to take away after giving the player a 1up (100).
	STA $0DBF|!addr				;/
.lives
	LDA $0DBE|!addr				;\ If Mario has a negative number of lives (i.e. game over), don't max out the life count.
	BMI .bonusstars				;/
	CMP.b #$62					;\> Maximum number of lives the player can have.
	BCC .bonusstars				;|
	LDA.b #$62					;|| Amount of lives to use if the maximum life limit is reached.
	STA $0DBE|!addr				;/
.bonusstars
	LDX $0DB3|!addr				;\
	LDA $0F48|!addr,X			;|
	CMP.b #$64					;|> Number of bonus stars required to enter the bonus game (100).
	BCC .draw					;|
	LDA.b #$FF					;|\ Set the flag to activate the bonus game after the level is beaten.
	STA $1425|!addr				;|/
	LDA $0F48|!addr,X			;|\
	SEC							;||
	SBC.b #$64					;||> Number of bonus stars to subtract from the counter after getting a bonus game (100).
	STA $0F48|!addr,X			;//
}

.draw
	JML DrawHUD


ReserveItemCall:
	PHB
	PHK
	PLB
	JSR.w $009079
	PLB
	RTL


SetIRQ:
	LDA $0D9B|!addr
	BNE .special
	LDA !hudtype
	CMP.b #!hudtypelayer3
	BCS .special
	if !sa1
		LDX #$81			; don't do IRQ (lated stored to $4200)
	else
		LDA #$81			; don't do IRQ
		STA $4200
	endif
	LDA $22				; update mirrors
	STA $2111
	LDA $23
	STA $2111
	LDA $24
	STA $2112
	LDA $25
	STA $2112
	LDA $3E
	STA $2105
	LDA $40
	STA $2131
	JMP.w $0082B0

.special
	JMP.w $00827A



UploadLayer3HUD:
	LDA !hudtype
	CMP.b #!hudtypelayer3
	BCS +
	RTS
+
	STZ $2115
	CMP.b #!hudtypelayer3custom
	BCS +
	JMP.w $008DAF
+
	RTS

print "HUD code in vanilla space ends at: ",pc

assert pc() <= $009045



freecode
DrawHUD:
	LDA $0100|!addr		;Don't draw HUD during title screen or when loading it.
	CMP.b #$08
	BCS +
	RTL
+
	PHB
	PHK
	PLB
	LDA !hudtype
	ASL
	TAX
	JSR (.hudptrs,x)
	PLB
	RTL

.hudptrs
dw DrawSprDefault
dw DrawNone
dw DrawSprMinimal
dw DrawVanilla
dw DrawASMT
dw DrawL3Custom

DrawNone:
	RTS


!oammax	#= $400180
!oammaxm	#= $0180|!addr

!HUDSprX	= $10
!HUDSprY	= $0F

DrawSprDefault: {
	;reserve item
	JSL ReserveItemCall
	LDA #$05	; Map $40:A000-$40:BFFF to $6000-$7FFF
	STA $318F
	STA $2225
	STZ $09
	REP #$30
	LDA.l !oammax
	SEC
	SBC.w #$401C
	TAX
	LDA.l !oammax+2
	SBC.w #$4007
	TAY
	JSR DrawSprLives
	JSR DrawSprCoins
	JSR DrawSprBonus
	JSR DrawSprReserve
	JSR DrawSprTimer
	JSR DrawSprDemos
	JSR DrawSprraocoins
	JSR DrawSprHP
	REP #$21
	TXA
	ADC.w #$401C
	STA.l !oammax
	TYA
	ADC.w #$4007
	STA.l !oammax+2
	SEP #$30
	STZ $318F ; Map $40:0000-$40:1FFF to $6000-$7FFF
	STZ $2225
	RTS
}


DrawSprMinimal: {
		;reserve item
	JSL ReserveItemCall
	LDA #$05	; Map $40:A000-$40:BFFF to $6000-$7FFF
	STA $318F
	STA $2225
	STZ $09
	REP #$30
	LDA.l !oammax
	SEC
	SBC.w #$401C
	TAX
	LDA.l !oammax+2
	SBC.w #$4007
	TAY
	JSR DrawSprLives
	JSR DrawSprCoins

	LDA.l $401424
	AND.w #$00FF
	BEQ +
	JSR DrawSprBonus
+

	LDA.l $400DC2
	AND.w #$00FF
	BEQ +
	JSR DrawSprReserve
+

	LDA.l $400F31
	ORA.l $400F32
	BNE +
	LDA.l $400F30-1
	BPL ++
+
	JSR DrawSprTimer
++
	LDA.w #(($04+!HUDSprY)<<8)|($B8+!HUDSprX)
	STA $1C,x
	LDA.w #(($04+!HUDSprY)<<8)|($C0+!HUDSprX)
	STA $18,x
	LDA.w #(($04+!HUDSprY)<<8)|($C8+!HUDSprX)
	STA $14,x
	LDA.w #(($04+!HUDSprY)<<8)|($D0+!HUDSprX)
	STA $10,x
	LDA.w #(($04+!HUDSprY)<<8)|($D8+!HUDSprX)
	STA $0C,x
	JSR DrawSprraocoins_alt
	REP #$21
	TXA
	ADC.w #$401C
	STA.l !oammax
	TYA
	ADC.w #$4007
	STA.l !oammax+2
	SEP #$30
	STZ $318F ; Map $40:0000-$40:1FFF to $6000-$7FFF
	STZ $2225
	RTS
}


SprDigit:
db $20,$21,$22,$23,$30	;> 0, 1, 2, 3, 4
db $31,$32,$33,$38,$39	;> 5, 6, 7, 8, 9
db $1D,$1D,$1D,$1D,$1D
db $1D


DrawSprLives: {
	LDA.w #(($00+!HUDSprY)<<8)|($00+!HUDSprX)
	STA $1C,x
	LDA.w #(($04+!HUDSprY)<<8)|($10+!HUDSprX)
	STA $18,x
	LDA.w #(($04+!HUDSprY)<<8)|($20+!HUDSprX)
	STA $14,x
	LDA.w #(($04+!HUDSprY)<<8)|($18+!HUDSprX)
	STA $10,x
.alt
	LDA.w #(($30)<<8)|($44)
	STA $1E,x
	LDA.w #(($30)<<8)|($29)
	STA $1A,x
	LDA.w #(($02)<<8)|($00)
	STA $0006,y
	LDA.w #(($00)<<8)|($00)
	STA $0004,y
	;LDA.w #$FFFD
	;STA $00
	;STA $02

	;LDA.w #$0000	;Clearing high byte is not necessary
	SEP #$20
	LDA.l $400DBE
	INC
	STY $00
	JSR HexToDec2
	TAY
	LDA.w SprDigit,y
	STA $16,x
	LDA.b #$30
	STA $17,x
	STA $13,x
	LDY $08
	BEQ .noten
	LDA.w SprDigit,y
	STA $12,x
	REP #$21
	TXA
	ADC.w #$FFF0
	TAX
	LDA.w #$FFFC-1
	BRA .end
.noten
	;LDA $00
	;ASL #2
	;STA $02
	;REP #$21
	;PLA
	;ADC $00
	;TAY
	;TXA
	;CLC
	;ADC $02
	;TAX
	REP #$21
	TXA
	ADC.w #$FFF4
	TAX
	LDA.w #$FFFD-1
.end
	ADC $00
	TAY
	RTS
}

DrawSprCoins: {
	LDA.w #(($08+!HUDSprY)<<8)|($88+!HUDSprX)
	STA $1C,x
	LDA.w #(($08+!HUDSprY)<<8)|($90+!HUDSprX)
	STA $18,x
	LDA.w #(($08+!HUDSprY)<<8)|($A0+!HUDSprX)
	STA $14,x
	LDA.w #(($08+!HUDSprY)<<8)|($98+!HUDSprX)
	STA $10,x
.alt
	LDA.w #(($30)<<8)|($46)
	STA $1E,x
	LDA.w #(($30)<<8)|($29)
	STA $1A,x
	LDA.w #(($00)<<8)|($00)
	STA $0006,y
	STA $0004,y

	;LDA.w #$0000	;Clearing high byte is not necessary
	SEP #$20
	LDA.l $400DBF
	STY $00
	JSR HexToDec2
	TAY
	LDA.w SprDigit,y
	STA $16,x
	LDA.b #$30
	STA $17,x
	STA $13,x
	LDY $08
	BEQ .noten
	LDA.w SprDigit,y
	STA $12,x
	REP #$21
	TXA
	ADC.w #$FFF0
	TAX
	LDA.w #$FFFC-1
	BRA .end
.noten
	REP #$21
	TXA
	ADC.w #$FFF4
	TAX
	LDA.w #$FFFD-1
.end
	ADC $00
	TAY
	RTS
}

DrawSprBonus: {
	LDA.w #(($08+!HUDSprY)<<8)|($34+!HUDSprX)
	STA $1C,x
	LDA.w #(($08+!HUDSprY)<<8)|($3C+!HUDSprX)
	STA $18,x
	LDA.w #(($08+!HUDSprY)<<8)|($4C+!HUDSprX)
	STA $14,x
	LDA.w #(($08+!HUDSprY)<<8)|($44+!HUDSprX)
	STA $10,x
.alt
	LDA.w #(($30)<<8)|($EF)
	STA $1E,x
	LDA.w #(($30)<<8)|($29)
	STA $1A,x
	LDA.w #(($00)<<8)|($00)
	STA $0006,y
	STA $0004,y

	;LDA.w #$0000	;Clearing high byte is not necessary
	SEP #$20
	LDA.l $400DB3
	BEQ +
	LDA.l $400F49
	BRA ++
+
	LDA.l $400F48
++
	STY $00
	JSR HexToDec2
	TAY
	LDA.w SprDigit,y
	STA $16,x
	LDA.b #$30
	STA $17,x
	STA $13,x
	LDY $08
	BEQ .noten
	LDA.w SprDigit,y
	STA $12,x
	REP #$21
	TXA
	ADC.w #$FFF0
	TAX
	LDA.w #$FFFC-1
	BRA .end
.noten
	REP #$21
	TXA
	ADC.w #$FFF4
	TAX
	LDA.w #$FFFD-1
.end
	ADC $00
	TAY
	RTS
}

DrawSprReserve: {
	LDA.w #(($07)<<8)|($70)
	STA $1C,x
	LDA.w #(($07)<<8)|($80)
	STA $18,x
	LDA.w #(($17)<<8)|($70)
	STA $14,x
	LDA.w #(($17)<<8)|($80)
	STA $10,x
	LDA.l $400DB3
	AND.w #$00FF
	BEQ +
	LDA.w #(($3A)<<8)|($68)
	STA $1E,x
	LDA.w #(($7A)<<8)|($68)
	STA $1A,x
	LDA.w #(($BA)<<8)|($68)
	STA $16,x
	LDA.w #(($FA)<<8)|($68)
	BRA ++
+
	LDA.w #(($36)<<8)|($68)
	STA $1E,x
	LDA.w #(($76)<<8)|($68)
	STA $1A,x
	LDA.w #(($B6)<<8)|($68)
	STA $16,x
	LDA.w #(($F6)<<8)|($68)
++
	STA $12,x
	LDA.w #(($02)<<8)|($02)
	STA $0006,y
	STA $0004,y

	TXA
	CLC
	ADC.w #$FFF0
	TAX
	DEY #4
	RTS
}

DrawSprTimer: {
	LDA.w #(($00+!HUDSprY)<<8)|($88+!HUDSprX)
	STA $1C,x
	LDA.w #(($00+!HUDSprY)<<8)|($A0+!HUDSprX)
	STA $18,x
	LDA.w #(($00+!HUDSprY)<<8)|($98+!HUDSprX)
	STA $14,x
	LDA.w #(($00+!HUDSprY)<<8)|($90+!HUDSprX)
	STA $10,x
.alt
	LDA.w #(($30)<<8)|($7E)
	STA $1E,x
	LDA.w #(($00)<<8)|($00)
	STA $0006,y
	STA $0004,y

	;LDA.w #$0000	;Clearing high byte is not necessary
	SEP #$20
	LDA.b #$30
	STA $1B,x
	STA $17,x
	STA $13,x
	LDA.l $400F33
	STY $00
	TAY
	LDA.w SprDigit,y
	STA $1A,x
	LDA.l $400F31
	BEQ .nohun
	TAY
	LDA.w SprDigit,y
	STA $12,x
	LDA.l $400F32
	TAY
	LDA.w SprDigit,y
	STA $16,x
	REP #$21
	TXA
	ADC.w #$FFF0
	TAX
	LDA.w #$FFFC-1
	BRA ++
.nohun
	LDA.l $400F32
	BEQ .noten
	TAY
	LDA.w SprDigit,y
	STA $16,x
	REP #$21
	TXA
	ADC.w #$FFF4
	TAX
	LDA.w #$FFFD-1
++
	ADC $00
	TAY
	BRA .end
.noten
	REP #$21
	TXA
	ADC.w #$FFF8
	TAX
	LDY $00
	DEY #2
.end
	RTS
}

DrawSprDemos: {
	LDA.w #(($00+!HUDSprY)<<8)|($B4+!HUDSprX)
	STA $1C,x
	LDA.w #(($00+!HUDSprY)<<8)|($BC+!HUDSprX)
	STA $18,x
	LDA.w #(($00+!HUDSprY)<<8)|($C4+!HUDSprX)
	STA $14,x
	LDA.w #(($00+!HUDSprY)<<8)|($CC+!HUDSprX)
	STA $10,x
	LDA.w #(($08+!HUDSprY)<<8)|($CC+!HUDSprX)
	STA $0C,x
	LDA.w #(($08+!HUDSprY)<<8)|($C4+!HUDSprX)
	STA $08,x
	LDA.w #(($08+!HUDSprY)<<8)|($BC+!HUDSprX)
	STA $04,x
	LDA.w #(($08+!HUDSprY)<<8)|($B4+!HUDSprX)
	STA $00,x
.alt
	LDA.w #(($36)<<8)|($0C)
	STA $1E,x
	LDA.w #(($36)<<8)|($0D)
	STA $1A,x
	LDA.w #(($36)<<8)|($1A)
	STA $16,x
	LDA.w #(($36)<<8)|($1B)
	STA $12,x
	LDA.w #(($00)<<8)|($00)
	STA $0006,y
	STA $0004,y
	STA $0002,y
	STA $0000,y

	;LDA.w #$0000
	SEP #$20
	LDA.l $40010A
	STA $04
	ASL
	ADC $04
	STX $04
	TAX
	LDA.l !DeathCounter+2,x
	REP #$20
	BNE +
	STA $02
	LDA.l !DeathCounter,x
	CMP.w #$2710
	BCC ++
+
	STZ $02
	LDA.w #$270F
++
	STA $00
	LDX $04
	JSR HexToDec6
	STY $00
	TAY
	LDA.w SprDigit,y
	STA $0E,x
	LDA.b #$30
	STA $0F,x
	STA $0B,x
	STA $07,x
	STA $03,x
	LDA $06
	BEQ .nok
	TAY
	LDA.w SprDigit,y
	STA $02,x
	LDA $07
	TAY
	LDA.w SprDigit,y
	STA $06,x
	LDY $08
	LDA.w SprDigit,y
	STA $0A,x
	REP #$21
	TXA
	ADC.w #$FFE0
	TAX
	LDA.w #$FFF8-1
	BRA .end
.nok
	LDA $07
	BEQ .nohun
	TAY
	LDA.w SprDigit,y
	STA $06,x
	LDY $08
	LDA.w SprDigit,y
	STA $0A,x
	REP #$21
	TXA
	ADC.w #$FFE4
	TAX
	LDA.w #$FFF9-1
	BRA .end
.nohun
	LDY $08
	BEQ .noten
	LDA.w SprDigit,y
	STA $0A,x
	REP #$21
	TXA
	ADC.w #$FFE8
	TAX
	LDA.w #$FFFA-1
	BRA .end
.noten
	REP #$21
	TXA
	ADC.w #$FFEC
	TAX
	LDA.w #$FFFB-1
.end
	ADC $00
	TAY
	RTS
}

DrawSprraocoins: {
	;eh
	LDA.w #(($00+!HUDSprY)<<8)|($30+!HUDSprX)
	STA $1C,x
	LDA.w #(($00+!HUDSprY)<<8)|($38+!HUDSprX)
	STA $18,x
	LDA.w #(($00+!HUDSprY)<<8)|($40+!HUDSprX)
	STA $14,x
	LDA.w #(($00+!HUDSprY)<<8)|($48+!HUDSprX)
	STA $10,x
	LDA.w #(($00+!HUDSprY)<<8)|($50+!HUDSprX)
	STA $0C,x
.alt
	LDA.w #$0000
	SEP #$20
	LDA.l $401422
	BNE +
	PHY
	PHX
	LDA.l $4013BF
	LSR #3
	TAX
	LDA.l $4013BF
	AND.b #$07
	TAY
	LDA.l $401F2F,x
	AND.w BitTable,y
	BEQ .skip
	LDA.b #$05
	STA.l $401422
	PLX
	PLY
+
	REP #$20
	STA $00
	LDA.w #$0004
	STA $02
	LDA.w #(($00)<<8)|($00)
	STA $0006,y
	STA $0004,y
	STA $0002,y
	LDA.w #(($30)<<8)|($46)
-
	DEC $00
	BPL +
	LDA.w #(($30)<<8)|($47)
+
	STA $1E,x
	DEX #4
	DEY
	DEC $02
	BPL -
	RTS
.skip
	PLX
	PLY
	REP #$20
	RTS
}

BitTable:
db $80,$40,$20,$10,$08,$04,$02,$01


DrawSprHP: {
	BIT !HPSettings-1
	BMI +
	RTS
+
	SEP #$20
	LDA $71
	BVC .aat
	CMP.b #$04
	CLC
	BNE .nothit
	LDA.l $40149B
	BNE .nothit
	;LDA.l $4013E0	;In case animation 3 gets used for something other than powerdown
	;CMP.b #$16
	;BNE .nothit
	BRA .hit
.aat
	CMP.b #$03		;\ Check for get cape animation, which is repurposed as a hurt animation
	CLC				;| ;o:c
	BNE .nothit	;/
.hit
	LDA.l $401496	;\ Use animation timer to time blinks
	LSR #2			;/ ;o:c
.nothit
	LDA !HPByte		;\ If the last hit point was just lost, make it blink a little
	ADC.b #$00		;/ ;i:c
	STA $00			;\ Store HP to scratch ram $00, 8 to 16 bit
	STZ $01			;/
	BPL +
	DEC $01
+
	LDA !HPSettings
	AND.b #$07
		;ASL
	STA $02
	STZ $03
	REP #$21
	LDA.w #(($28)<<8)|($0C)
	STA $04
		;PHX
		;LDX $02
		;LDA.l SprEyeOffset,x
		;PLX
	BRA .open

.openloop
	LDA $04
	CLC
	ADC.w #(($10)<<8)|($00)
		;PHX
		;LDX $02
		;LDA.l SprEyeOffset,x
		;PLX
	STA $04
.open
	DEC $00
	BMI .closed
	STA $1C,x
	ADC.w #(($00)<<8)|($10)
	STA $18,x
	ADC.w #(($08)<<8)|($00)
	STA $14,x
	LDA.w #(($31)<<8)|($CC)
	STA $1E,x
	LDA.w #(($71)<<8)|($CC)
	STA $1A,x
	LDA.w #(($71)<<8)|($DC)
	STA $16,x
	LDA.w #(($02)<<8)|($00)
	STA $0006,y
	LDA.w #(($00)<<8)|($00)
	STA $0004,y
	TXA
	CLC
	ADC.w #$FFF4
	TAX
	DEY #3
	DEC $02
		;DEC $02
	BPL .openloop
	RTS

.closed
	LDA $04
	ADC.w #(($08)<<8)|($00)
		;PHX
		;LDX $02
		;LDA.l SprEyeOffset2,x
		;PLX
	BRA +
.closedloop
	LDA $04
	CLC
	ADC.w #(($10)<<8)|($00)
		;PHX
		;LDX $02
		;LDA.l SprEyeOffset2,x
		;PLX
+
	STA $04
	STA $1C,x
	ADC.w #(($00)<<8)|($08)
	STA $18,x
	ADC.w #(($00)<<8)|($08)
	STA $14,x
	LDA.w #(($31)<<8)|($EC)
	STA $1E,x
	LDA.w #(($31)<<8)|($ED)
	STA $1A,x
	LDA.w #(($71)<<8)|($EC)
	STA $16,x
	LDA.w #(($00)<<8)|($00)
	STA $0006,y
	STA $0004,y
	TXA
	CLC
	ADC.w #$FFF4
	TAX
	DEY #3
	DEC $02
		;DEC $02
	BPL .closedloop
	RTS
}

;SprEyeOffset:
;dw (($44-8)<<8)|($58-8)
;dw (($60)<<8)|($3C)
;dw (($7C+8)<<8)|($58-8)
;dw (($98)<<8)|($74)
;
;dw (($7C+8)<<8)|($90+8)
;dw (($60)<<8)|($AC)
;dw (($44-8)<<8)|($90+8)
;dw (($28)<<8)|($74)
;
;SprEyeOffset2:
;dw (($44+8-8)<<8)|($58-8)
;dw (($60+8)<<8)|($3C)
;dw (($7C+8+8)<<8)|($58-8)
;dw (($98+8)<<8)|($74)
;
;dw (($7C+8+8)<<8)|($90+8)
;dw (($60+8)<<8)|($AC)
;dw (($44+8-8)<<8)|($90+8)
;dw (($28+8)<<8)|($74)


SprCheckHeadUpload:	;Called by SNES
	CMP.b #$01
	BEQ .skip
	LDY !hudsprhead
	BPL +
	LDX !hudsprheadslot	;Work around if no local nor global ExAnimation is ran
	REP #$20
	LDA.l $7FC0C0,x
	BEQ ++
	LDA.l $7FC0C5,x
	CMP !hudsprheadsrc+1
	BNE ++
	LDA.l $7FC0C4,x
	CMP !hudsprheadsrc
	BNE ++
	LDA.w #$0000
	STA $7FC0C0,x
++
	SEP #$20
	TYA
	AND.b #$7F
	STA !hudsprhead
+
	LDA $19
	CMP !hudsprhead
	BEQ .skip
	ASL
	TAX
	REP #$20
	LDA.l SprHeadGFXOffset,x
	STA $00
	LDX.b #$31
-
	LDA.l $7FC0C0,x
	BEQ .found
	TXA
	SEC
	SBC.w #$0007
	TAX
	BPL -
	SEP #$20
.skip
	RTL
.found
	LDA.w #$0040	;Length
	STA.l $7FC0C0,x
	LDA.w #$6440|$8000	;VRAM address+double upload bit
	STA.l $7FC0C2,x
	LDA $00
	CLC
	ADC.l ($03BCC0)|!bank
	STA.l $7FC0C4,x
	STA !hudsprheadsrc
	SEP #$20
	LDA.l ($03BCC0+2)|!bank
	STA.l $7FC0C6,x
	STA !hudsprheadsrc+2
	LDA $19
	ORA.b #$80
	STX !hudsprheadslot
	STA !hudsprhead
	RTL

SprHeadGFXOffset:
dw $0000,$0000,$0080,$0000


DrawVanilla: {
	;timer
	LDX.b #$00
	LDA.b #$FC
-
	LDY $0F31|!addr,x
	BNE +
	STA !hudl3tilemapb+$11,x
	INX
	CPX.b #$02
	BNE -
	BRA ++
+
-
	LDA $0F31|!addr,x
	STA !hudl3tilemapb+$11,x
	INX
	CPX.b #$02
	BNE -
++
	LDA $0F33|!addr
	STA !hudl3tilemapb+$13
	;score
	LDX $0DB3|!addr
	BEQ +
	LDX.b #$03
+
	LDA $0F36|!addr,x
	STA $02
	STZ $03
	REP #$20
	LDA $0F34|!addr,x
	STA $00
	JSR HexToDec6
	PHA
	LDX.b #$00
	LDA.b #$FC
-
	LDY $04,x
	BNE +
	STA !hudl3tilemapb+$15,x
	INX
	CPX.b #$05
	BNE -
	BRA ++
+
-
	LDA $04,x
	STA !hudl3tilemapb+$15,x
	INX
	CPX.b #$05
	BNE -
++
	PLA
	BNE +
	TYX
	BNE +
	LDA.b #$FC
+
	STA !hudl3tilemapb+$1A

	;lives
	LDA $0DBE|!addr
	INC
	JSR HexToDec2V
	TXY
	BNE +
	LDX.b #$FC
+
	STX !hudl3tilemapb+$02
	STA !hudl3tilemapb+$03

	;coins
	LDA $0DBF|!addr
	JSR HexToDec2V
	TXY
	BNE +
	LDX.b #$FC
+
	STX !hudl3tilemap+$1A
	STA !hudl3tilemap+$1B

	;bonus stars
	LDX $0DB3|!addr
	LDA $0F48|!addr,x
	JSR HexToDec2V
	TAY
	LDA L3BonusStarTop,y
	STA !hudl3tilemap+$0B
	LDA L3BonusStarBottom,y
	STA !hudl3tilemapb+$0B
	TXY
	BNE +
	LDY.b #$0A
+
	LDA L3BonusStarTop,y
	STA !hudl3tilemap+$0A
	LDA L3BonusStarBottom,y
	STA !hudl3tilemapb+$0A

	;reserve item
	JSL ReserveItemCall

	;player name
	LDY.b #L3Mario-L3PlayerName+$04
	LDA $0DB3|!addr
	BEQ +
	LDY.b #L3Luigi-L3PlayerName+$04
+
	LDX.b #$04
-
	LDA.w L3PlayerName,y
	STA !hudl3tilemap,x
	DEY
	DEX
	BPL -

	;yoshi coins
	LDA.w $1422|!addr
	CMP.b #$05
	BCC +
	LDA.b #$00	;Draw 0 Yoshi Coins if 5 or more have been collected
+
	STA $00
	LDX.b #$00
	LDA.b #$2E
-
	DEC $00
	BPL +
	LDA.b #$FC
+
	STA !hudl3tilemap+$6,x
	INX
	CPX.b #$04
	BNE -
	RTS
}


DrawASMT: {
	;timer
	LDX.b #$00
	LDA.b #$FC
-
	LDY $0F31|!addr,x
	BNE +
	STA !hudl3tilemap+$12,x
	INX
	CPX.b #$02
	BNE -
	BRA ++
+
-
	LDA $0F31|!addr,x
	STA !hudl3tilemap+$12,x
	INX
	CPX.b #$02
	BNE -
++
	LDA $0F33|!addr
	STA !hudl3tilemap+$14
	;demos
	LDA $010A|!addr
	STA $00
	ASL
	ADC $00
	TAX
	LDA.l !DeathCounter+2,x
	STA $02
	STZ $03
	REP #$20
	LDA.l !DeathCounter,x
	STA $00
	JSR HexToDec6
	STA !hudl3tilemapb+$1A
	LDX.b #$00
	LDA.b #$FC
-
	LDY $04,x
	BNE +
	STA !hudl3tilemapb+$15,x
	INX
	CPX.b #$05
	BNE -
	BRA ++
+
-
	LDA $04,x
	STA !hudl3tilemapb+$15,x
	INX
	CPX.b #$05
	BNE -
++
	;lives
	LDA $0DBE|!addr
	INC
	JSR HexToDec2V
	TXY
	BNE +
	LDX.b #$FC
+
	STX !hudl3tilemapb+$02
	STA !hudl3tilemapb+$03

	;coins
	LDA $0DBF|!addr
	JSR HexToDec2V
	TXY
	BNE +
	LDX.b #$FC
+
	STX !hudl3tilemapb+$12
	STA !hudl3tilemapb+$13

	;bonus stars
	LDX $0DB3|!addr
	LDA $0F48|!addr,x
	JSR HexToDec2V
	TAY
	LDA L3BonusStarTop,y
	STA !hudl3tilemap+$0B
	LDA L3BonusStarBottom,y
	STA !hudl3tilemapb+$0B
	TXY
	BNE +
	LDY.b #$0A
+
	LDA L3BonusStarTop,y
	STA !hudl3tilemap+$0A
	LDA L3BonusStarBottom,y
	STA !hudl3tilemapb+$0A

	;reserve item
	JSL ReserveItemCall

	;player name
	LDY.b #L3Mario-L3PlayerName+$04
	LDA $0DB3|!addr
	BEQ +
	LDY.b #L3Luigi-L3PlayerName+$04
+
	LDX.b #$04
-
	LDA.w L3PlayerName,y
	STA !hudl3tilemap,x
	DEY
	DEX
	BPL -

	;yoshi coins
	LDA.w $1422|!addr
	CMP.b #$05
	BCC +
	LDA.b #$00	;Draw 0 Yoshi Coins if 5 or more have been collected
+
	STA $00
	LDX.b #$00
	LDA.b #$2E
-
	DEC $00
	BPL +
	LDA.b #$FC
+
	STA !hudl3tilemap+$6,x
	INX
	CPX.b #$04
	BNE -
	RTS
}


L3PlayerName:
L3Mario:
db $30,$31,$32,$33,$34
L3Luigi:
db $40,$41,$42,$43,$44
L3BonusStarTop:
db $B7,$B8,$BA,$BA,$BC
db $BE,$C0,$C1,$C2,$B7,$FC
L3BonusStarBottom:
db $C3,$B9,$BB,$BF,$BD
db $BF,$C3,$B9,$C4,$C5,$FC

DrawL3Custom:
	RTS


HexToDec2V:
	LDX.b #$00
-
	CMP.b #$0A
	BCC +
	SBC.b #$0A
	INX
	BRA -
+
	RTS


HexToDec2:	;8 bit A, output $08 and A from most to least significant
	STZ $08
	SEC
	BRA HexToDec6_ten

HexToDec4:	;16 bit A, output $06-$08 and A from most to least significant
	STZ $06
	STZ $08
	SEC
	BRA HexToDec6_onek

HexToDec6:	;16 bit A, output $04-$08 and A from most to least significant
	STZ $04
	STZ $06
	STZ $08
	SEC
	BRA .hunk
-
	STA $02
	INC $04
.hunk
	LDA $00
	SBC.w #$86A0
	STA $00
	LDA $02
	SBC.w #$0001
	BCS -

	LDA $00
	ADC.w #$86A0
	SEC
	BRA .tenk
-
	STA $02
	INC $05
	LDA $00
.tenk
	SBC.w #$2710
	STA $00
	LDA $02
	SBC.w #$0000
	BCS -

	LDA $00
	ADC.w #$2710
	SEC
	BRA .onek
-
	INC $06
.onek
	SBC.w #$03E8
	BCS -

	ADC.w #$03E8
	BRA .hun
-
	INC $07
.hun
	SBC.w #$0064
	BCS -

	ADC.w #$0064
	SEP #$21
	BRA .ten
-
	INC $08
.ten
	SBC.b #$0A
	BCS -

	ADC.b #$0A
	RTS



InitializeLayer3HUD:
	LDA !hudtype
	SEC
	SBC.b #!hudtypelayer3
	BCC HUDInitEnd
	ASL
	TAX
	LDA.b #$80
	STA $2115
	JMP (.hudptrs,x)
.hudptrs
dw HUDInitVanilla
dw HUDInitASMT
dw HUDInitL3Custom


HUDInitL3Custom:
HUDInitEnd:
	LDX.b #$36	;Clear RAM used by vanilla HUD
-
	STZ !hudl3tilemap,x
	DEX
	BPL -
	JML $008D8A|!bank	;Set how long the first second lasts


HUDInitVanilla:
	JML $008D04|!bank


HUDInitASMT:
	REP #$20
	LDA.w #$1801
	STA $4320
	LDX.b #HUDASMTLine1>>16
	STX $4324
	LDX.b #$04
	
	LDA.w #$502E
	STA $2116
	LDA.w #HUDASMTLine1
	STA $4322
	LDA.w #$0008
	STA $4325
	STX $420B

	LDA.w #$5042
	STA $2116
	LDA.w #HUDASMTLine2
	STA $4322
	LDA.w #$0038
	STA $4325
	STX $420B

	LDA.w #$5063
	STA $2116
	LDA.w #HUDASMTLine3
	STA $4322
	LDA.w #$0036
	STA $4325
	STX $420B

	LDA.w #$508E
	STA $2116
	LDA.w #HUDASMTLine4
	STA $4322
	LDA.w #$0008
	STA $4325
	STX $420B

	SEP #$20
	LDY.b #$36
	LDX.b #$6C
-
	LDA.l HUDASMTLine2,x
	STA !hudl3tilemap,y
	DEX
	DEX
	DEY
	BPL -
	JML $008D8A|!bank


HUDASMTLine1:
db $3A,$38,$3B,$38,$3B,$38,$3A,$78
HUDASMTLine2:
db $30,$28,$31,$28,$32,$28,$33,$28
db $34,$28,$FC,$38,$FC,$3C,$FC,$3C
db $FC,$3C,$FC,$3C,$FC,$38,$FC,$38
db $4A,$38,$FC,$38,$FC,$38,$4A,$78
db $76,$3C,$77,$3C,$FC,$3C,$FC,$3C
db $00,$3C,$FC,$38,$0D,$28,$0E,$28
db $16,$28,$18,$28,$1C,$28,$FC,$38
HUDASMTLine3:
db		   $26,$38,$FC,$38,$00,$38
db $FC,$38,$FC,$38,$FC,$38,$64,$28
db $26,$38,$FC,$38,$FC,$38,$FC,$38
db $4A,$38,$FC,$38,$FC,$38,$4A,$78
db $2E,$3C,$26,$38,$FC,$38,$00,$38
db $FC,$38,$FC,$38,$FC,$38,$FC,$38
db $FC,$38,$FC,$38,$FC,$38,$FC,$38
HUDASMTLine4:
db $3A,$B8,$3B,$B8,$3B,$B8,$3A,$F8
