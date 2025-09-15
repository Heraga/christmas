norom
arch spc700

org $000000
incsrc "asm/main.asm"
base $1EEF

org $008000


	jmp UnpauseMusic_silent
