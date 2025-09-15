;>bytes 1
%require_uber_ver(2, 0)

load:
	LDA ($00)
	STA $13E6|!addr
	RTL