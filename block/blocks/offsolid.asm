db $37
JMP + : JMP + : JMP +
JMP + : JMP + : JMP + : JMP +
JMP + : JMP +
JMP + : JMP +

+	LDY $14AF|!addr
	BEQ +
	LDA #$30
	STA $1693|!addr
	RTL

+	LDA #$25
	STA $1693|!addr
	RTL 

print "A block that is solid when the on/off switch is off and passable otherwise."