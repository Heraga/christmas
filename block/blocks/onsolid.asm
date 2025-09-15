db $37
JMP + : JMP + : JMP +
JMP + : JMP + : JMP + : JMP +
JMP + : JMP +
JMP + : JMP +

+	LDA $14AF|!addr
	BEQ +
	LDY #$00
	LDA #$25
	STA $1693|!addr
	RTL

+	LDY #$01
	LDA #$30
	STA $1693|!addr
	RTL 

print "A block that is solid when the on/off switch is on and passable otherwise."