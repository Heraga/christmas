
!sram = $700000
!addr = $0000
if read1($00FFD5) == $23
	sa1rom
	!sram = $41C000
	!addr = $6000
endif


!DeathCounter	#= !sram+$07ED	;9 bytes of SRAM for the death counter, 3 for each save file

!freeram = $18BB|!addr	;> Free RAM flag to toggle whether or not the death counter should be updated.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; everything after here is coded by yoshicookiezeus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Conflicts with SimpleHP. Hijack moved by Lord Ruby.
;org $00F60F				; original code:
;	autoclean JSL IncreaseDeaths	; LDA.B #$FF
;	NOP				; STA.W $0DDA
org $00F614						;This also saves a NOP, ought to have put it here in the first place :/
autoclean JSL IncreaseDeaths	;Original code: LDA #$09 : STA $71

freecode

IncreaseDeaths:
	LDA !freeram		;\ Don't update death counter
	BNE +				;/ if flag is set.
	PHX
	LDA $010A|!addr
	ASL
	CLC
	ADC $010A|!addr
	TAX
	REP #$20		; set 16-bit accumulator
	LDA !DeathCounter,x	; \ increase death counter by one
	CLC			; |
	ADC #$0001		; |
	STA !DeathCounter,x	; /
	SEP #$20		; 8-bit accumulator
	LDA !DeathCounter+2,x	; \ if carry flag set, increase high byte of death counter by one
	ADC #$00		; |
	STA !DeathCounter+2,x	; /
	PLX

+
	LDA #$09 : STA $71	;Restore (set animation to dying)

	RTL
