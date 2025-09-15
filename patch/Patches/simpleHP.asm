;SimpleHP
;Lord Ruby

;A simple HP system, providing a framework for level code to make use of.
;Depends on SA-1.

;;;Usage:
;To activate, set bit 7 of HP settings in _every sublevel_. Initialize the HP byte to the starting value, but only once per level, as it carries over between sublevels; I suggest checking for whether to initialize or not by checking if the HP byte is zero, as the default byte is cleared when loading the overworld. 
;
;HP is decreased when hurt, and increased when getting a powerup. Demo is killed when hurt at 1 HP. You're free to manipulate the HP byte whenever, but note that Demo doesn't automatically die when it's set to zero.


;;;Defines:
if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!bank8 = $00
	!sa1 = 1
else
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!bank8 = $80
	!sa1 = 0
endif
macro define_sprite_table(name, name2, addr, addr_sa1)
	if !sa1 == 0
		!<name> #= <addr>
	else
		!<name> #= <addr_sa1>
	endif

	!<name2> #= !<name>
endmacro
%define_sprite_table(sprite_misc_1534, "1534", $1534, $32B0)


;;RAM Bytes:
;HP settings.
!HPSettings = $7C
;Bit 7	- Enable the HP System
;Bit 6	- Clear to use AAT powerup/powerdown animations
;Bit 5	- Set to keep current powerup at 1 HP, otherwise turn small
;Bit 4	- Set to make powerups give you reserve items and make reserve items not heal you
;Bit 3	- Unused
;Bits 2-0	- Current Max HP-1

;HP byte. A RAM byte that is cleared on overworld load, but not level load (or otherwise in levels) is recommended. 
!HPByte = $58


;;Values:
;Hurt and heal sound effects.
!HitSFXA = $04
!HitSFXB = $00
!AATHitSFXA = $0C
!AATHitSFXB = $00
!HealSFXA = $00
!HealSFXB = $0B
;Stun time.
!StunTime = $11
!AATStunTime = $11


!LuigiMusic = $06		; Change this.


;;;Hijacks
;Hurt
org $00F5D5
autoclean JML Hurt

;Death
org $00F60C
	JML Death
	NOP

;Get powerup
org $01C53F|!bank
	JML GetPowerup

;Vanilla Fire Flower routine
org $01C5F7
	JML GivePlayerFire

;Get Fire Flower Animation
org $00D158
-
org $00D16F
	LDA $149B|!addr
	BEQ +
	DEC $149B|!addr
	BEQ -
	RTS
+
	;Repurpose animation as generic show pose for X frames animation
	LDA $1496|!addr
	BEQ -
	DEC $1496|!addr
	LDA $1492|!addr
	STA $13E0|!addr
	RTS

assert pc() <= $00D18D


;;;Code
freedata

GetPowerup:
	TAY
	BIT !HPSettings
	BMI .hpsystem			;Bit 7 of settings unset, use default behavior
.default
	LDA.w $01C510,y			;Load new item box item from table (data bank should still be 01)
	JML $01C543|!bank

.hpsystem
	LDA.w $01C524,y			;Load new powerup status from table (data bank should still be 01)
	CMP #$02
	BEQ .default			;Star, use default behavior
	CMP #$05
	BEQ .default			;1-up, use default behavior
	PHA

	LDA !HPSettings
	BIT.b #%00010000
	BEQ .dontgiveitem
	LDA.w $01C510,y
	BEQ .dontgiveitem
	CMP.b #$01
	BNE .giveitem
	LDX $0DC2|!addr
	BNE +
.giveitem
	STA $0DC2|!addr
+
	LDX $15E9|!addr
	LDA.b #$0B
	STA $1DFC|!addr

.dontgiveitem
	BIT !HPSettings
	LDA !1534,x
	BVC .aat
	BEQ .notreserve
	LDA !HPSettings
	BIT.b #%00010000
	BEQ .notreserve
	PLA
	BRA ++

.notreserve
	INC !HPByte
	LDA !HPSettings
	AND.b #$07
	INC
	CMP !HPByte
	BCS +
	STA !HPByte
+
	PLA
	CMP.b #$01
	BEQ .effect
++
	JML $01C54D|!bank		;Execute the rest of powerup code

.effect
	;Sound effects
	if !HealSFXA
		LDA #!HealSFXA
		STA $1DF9|!addr		;A
	endif
	if !HealSFXB
		LDA #!HealSFXB
		STA $1DFC|!addr		;B
	endif
.noeffect
	JML $01C56F|!bank	;Give points


.aat
	BEQ .aatnotreserve
	LDA !HPSettings
	BIT.b #%00010000
	PLA
	CMP.b #$01
	BEQ .noeffect
	BRA .nothp
.aatnotreserve
	INC !HPByte
	LDA !HPSettings
	AND.b #$07
	INC
	CMP !HPByte
	BCS +
	STA !HPByte
+
	PLA
	CMP.b #$01
	BEQ .effect
.nothp
	BCC .mush
	DEC
	BRA .firecape
.mush
	INC
.firecape
	STA $19
	LDA $13ED|!addr
	AND.b #$80
	ORA $1407|!addr
	BEQ .effect
	STZ $1407|!addr
	LDA $13ED|!addr
	AND.b #$7F
	STA $13ED|!addr
	STZ $13E0|!addr
	BRA .effect


Hurt:
	BIT !HPSettings			;o:nv
	BMI .hpsystem			;i:n ;Bit 7 of settings unset, use default behavior
	LDA $19					;Set up accumulator: Powerup status
	BEQ .death				;If small, kill Demo
	JML $00F5D9|!bank
.death
	JML $00F606|!bank

.hpsystem
	LDA $19
	CMP #$02
	BNE .hit				;Cape check
	LDA $1407|!addr
	BEQ .hit				;Flying check
	JML $00F5E2|!bank		;Cancel soaring

.hit:
	DEC !HPByte				;o:nz;Decrease HP
	BEQ .death
	BMI .death				;i: z;If HP was just 1, kill
	LDY !HPByte
	CPY.b #$02
	BIT !HPSettings
	BVC .aateffect
	BCS .hphitanim
	LDA !HPSettings
	BIT.b #%00100000
	BNE .hphitanim
	LDA $19
	BEQ .hphitanim
	JML $00F5F3|!bank		;Powerdown

.hphitanim
	;Sound effects
	if !HitSFXA
		LDA #!HitSFXA
		STA $1DF9|!addr		;A
	endif
	if !HitSFXB
		LDA #!HitSFXB
		STA $1DFC|!addr		;B
	endif

	;Contact
	LDY.b #$03
-
	LDA $17C0|!addr,y
	BEQ +					;Check if smoke slot is open
	DEY
	BPL -					;Loop with next slot
	LDY $1863|!addr
	DEY						;If none are open, get the oldest one (and overwrite it)
	BPL ++
	LDY #$03				;(Wrap in 00-03 range)
++
	STY $1863|!addr			;Store youngest slot
+
	LDA #$02
	STA $17C0|!addr,y		;Contact graphic
	LDA #$04
	STA $17CC|!addr,y		;Timer
	LDA $96					;Demo Y
	CLC : ADC #$10			;Offset Y by C
	STA $17C4|!addr,y		;Contact Y
	LDA $94
	STA $17C8|!addr,y		;Contact X from Demo


	;Hurt animation timers
	LDA.b #!StunTime
	STA $1496|!addr			;Animation timer
	STA $9D					;Pause sprites
	LDA #$04
	STA $71
	LDA.b #$16
	;LDA.b #$0D
	STA $13E0|!addr
	STA $1492|!addr			;Reuse victory pose timer as pose backup
	LDA.b #$FF
	STA $78
	LDA #$3F
	STA $1497|!addr			;Invincibility frames (about 2 seconds)
	RTL


.aateffect
	BCS .notsmall
	LDA !HPSettings
	BIT.b #%00100000
	BNE .notsmall
	STZ $19
.notsmall

	;Sound effects
	if !AATHitSFXA
		LDA #!AATHitSFXA
		STA $1DF9|!addr		;A
	endif
	if !AATHitSFXB
		LDA #!AATHitSFXB
		STA $1DFC|!addr		;B
	endif

	;Sparkle
	LDY.b #$03
-
	LDA $17C0|!addr,y
	BEQ +					;Check if smoke slot is open
	DEY
	BPL -					;Loop with next slot
	LDY $1863|!addr
	DEY						;If none are open, get the oldest one (and overwrite it)
	BPL ++
	LDY #$03				;(Wrap in 00-03 range)
++
	STY $1863|!addr			;Store youngest slot
+
	LDA #$05
	STA $17C0|!addr,y		;Sparkle
	LDA #$1B
	STA $17CC|!addr,y		;Timer
	LDA $96					;Demo Y
	CLC : ADC #$08			;Offset Y by C
	STA $17C4|!addr,y		;Sparkle Y
	LDA $94
	STA $17C8|!addr,y		;Sparkle X from Demo


	;Cape animation timers
	LDA.b #!AATStunTime
	STA $1496|!addr			;Animation timer
	STA $9D					;Pause sprites
	LDA #$03
	STA $71					;Set cape animation (freeze with invisible Demo; hurt breaks?).
	LDA #$7F
	STA $1497|!addr			;Invincibility frames (about 2 seconds)

	STZ $13E4|!addr			;> Clear run timer (p-meter)
	STZ $149F|!addr			;> Clear flight rise timer
	LDA $72					;\
	CMP #$0C				;| If air state is running jump/flying, set it to normal jump
	BNE +					;|
	DEC $72					;/
+
	RTL



Death:
	STA $1DFB|!addr
	LDA $0DB3|!addr			; Alternate Death Music for Luigi code.
	BEQ .mario				; please excuse this trash -The Kobbs
	LDA #!LuigiMusic
	STA $1DFB|!addr
.mario
	LDA !HPSettings
	BPL +
	STZ !HPByte
+
	LDA #$FF				;Some music thing
	JML $00F611|!bank


GivePlayerFire:	;Move the cape check to the powerup code instead of animation code, so it doesn't show up for 1 frame
	LDA $13ED|!addr
	AND.b #$80
	ORA $1407|!addr
	BEQ +
	STZ $1407|!addr
	LDA $13ED|!addr
	AND.b #$7F
	STA $13ED|!addr
	STZ $13E0|!addr
+
	LDA.b #$03
	STA $19
	JML $01C56F|!bank
