;>bytes 2
%require_uber_ver(2, 0)

; Free RAM addresses
!HPSettings = $7C		;\
!HPByte = $58			;/ Need to be the same as in the simpleHP.asm patch.

;=================================
; Initialize the HP system
;=================================

load:
	LDA !HPByte
	BNE .SetMax
	
	LDY.b #$01
	LDA ($00),y
	STA !HPByte
	CMP.b #$02	;Set Demo's powerup to big if she's small and the initial HP is more than 1
	BCC .SetMax
	LDA $19
	BNE .SetMax
	LDA.b #$01
	STA $19
.SetMax
	LDA ($00)
	STA !HPSettings
	AND.b #$07
	INC
	CMP !HPByte
	BCS +
	STA !HPByte
+
	RTL