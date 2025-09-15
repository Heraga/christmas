db $42

JMP ShatterMario : JMP ShatterMario : JMP ShatterMario
JMP Return : JMP Return : JMP ShatterMario : JMP Return
JMP ShatterMario : JMP ShatterMario : JMP ShatterMario

ShatterMario:
	LDA #$32				; \ Play the "multiball" sound effect.
	STA $1DF9|!addr		

	REP #$10
	LDX #$0025
	%change_map16()
	SEP #$10


Return:
	RTL 

print "multiball"