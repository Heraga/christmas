;MULTIBALL


    !SpriteToGen        = $1C   ; USE $1C for bullet bills, $38 for eeries
    !TimeBetweenSpawns  = $7F   ; needs to be one less than a power of 2
                                ; recommended: $7F for bills, $3F for eeries

    !RAM_ScreenBndryXLo = $1A
    !RAM_ScreenBndryXHi = $1B
    !RAM_ScreenBndryYLo = $1C
    !RAM_ScreenBndryYHi = $1D
    !RAM_MarioDirection = $76
    !RAM_MarioYPos      = $96
    !RAM_MarioYPosHi    = $97
    !RAM_SpritesLocked  = $9D

main:
    LDA $14                     ;\  if not time to spawn sprite
    AND.b #!TimeBetweenSpawns   ; |
    ORA !RAM_SpritesLocked      ; | or if sprites locked,
    BNE .Return                 ;/  branch
    JSL $02A9DE|!bank           ;\  find empty sprite slot
    BMI .Return                 ;/  if no slot found, return
    TYX        
    
    LDA #!SpriteToGen           ;\  set new sprite number
    STA !9E,x                   ;/
    JSL $07F7D2                 ; reset sprite properties
    LDA #$08                    ;\  set new sprite status
    STA !14C8,x                 ;/

    LDA !RAM_MarioYPos          ;\ set new sprite y position to Mario y position
    CLC                         ; |
    ADC #$08                    ; |
    STA !D8,x                   ; |
    LDA !RAM_MarioYPosHi        ; |
    ADC #$00                    ; |
    STA !14D4,x                 ;/

    LDA !RAM_MarioDirection     ;\ use the direction Mario is facing
    TAY                         ;/ to determine sprite direction
    LDA .OffsetXLo,y            ;\  use direction to determine x offset
    CLC                         ; |
    ADC !RAM_ScreenBndryXLo     ; | add screen position
    STA !E4,x                   ; | and set as sprite x position
    LDA !RAM_ScreenBndryXHi     ; |
    ADC .OffsetXHi,y            ; |
    STA !14E0,x                 ;/
    if !SpriteToGen == $1C
        LDA .Dir,y              ;\ set sprite direction
        STA !C2,x               ;/
        LDA #$30                ;\ play sound effect
        STA $1DF9|!addr         ;/
    endif
    if !SpriteToGen == $38
        LDA .SpeedX,y           ;\ set sprite speed
        STA !B6,x               ;/
    endif
.Return:
    RTL


.OffsetXLo: db $F0,$00
.OffsetXHi: db $FF,$01
.Dir:       db $00,$01
.SpeedX:    db $10,$F0


end:	;end because it's after Mario has been drawn
	LDX.b #!sprite_slots-1
-
	LDY !14C8,x
	BEQ .next
	LDA !9E,x
	CMP.b #$1C
	BNE .next
	JSR Interact
.next
	DEX
	BPL -
	RTL


!BoingSFX = $31
!BoingPort = $1DF9

MarioSpeed:
db $40,$C0

Interact:	
	LDA !167A,x
	ORA.b #$82	;Don't use default Mario interaction and also become invincible to Star/Cape/Fire/etc so Yoshi doesn't run away
	STA !167A,x
	CPY.b #$08
	BNE .ret
	LDA !154C,x
	BNE .ret
	JSL $01A7DC|!bank
	BCC .ret

	JSR SubVertPos
.CheckPosition
	LDA $0F
	LDY $187A|!addr	;yoshi check
	BEQ +
	CLC
	ADC.b #$10
+
	CMP.b #$EB
	;BPL TouchesSides
	BPL .SecondCheck

	;LDA $7D		;reduce likelyhood of triggering side interaction when clipping even further
	;BMI TouchesSides

	LDA.b #$1C
	LDY $187A|!addr
	BEQ +
	LDA.b #$2C
+
	STA $00
	STZ $01

	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20

	SEC
	SBC $00
	STA $96
	SEP #$20

	LDA.b #$B8
	STA $7D

	LDA.b #!BoingSFX
	STA !BoingPort|!addr
.ret
	RTS

.SecondCheck
	LDA $00			;both checks failed
	BNE TouchesSides	;player wasn't above the sprite, go away
	JSR SubVertPosActualPos	;double check the position, so that clipping inside bumpty and triggering "touched from side" check is less likely
	INC $00
	BRA .CheckPosition

TouchesSides:
	JSR SubHorzPos
	;TYA		;Don't change the Bullet's direction
	;STA !157C,x
	LDA MarioSpeed,y
	STA $7B
	LDA.b #!BoingSFX
	STA !BoingPort|!addr
	;LDA #$01
	;STA !1504,x		;i forgot what used this but w/e (probably tackling related, but I removed coding for it)
	RTS


SubVertPos:
	LDY #$00
	LDA $96
	SEC
	SBC !D8,x
	STA $0F
	LDA $97
	SBC !14D4,x
	BPL +
	INY
+
	RTS

SubVertPosActualPos:
	LDY #$00
	LDA $D3
	SEC
	SBC !D8,x
	STA $0F
	LDA $D4
	SBC !14D4,x
	BPL +
	INY
+
	RTS

SubHorzPos:
	LDY #$00
	LDA $94
	SEC
	SBC !E4,x
	STA $0E
	LDA $95
	SBC !14E0,x
	STA $0F
	BPL +
	INY
+
	RTS