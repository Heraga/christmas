;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file is where you put the RAM addresses that will be saved
;; to the Extra Save File and their default values.
;; 
;; How to add a RAM address to save.
;; 1) Select which things you want to save in a save file, for example,
;; Mario and Luigi coins, lives, powerup, item box and yoshi color.
;; 
;; 2) Go to the extra_save_table label and add the RAM address AND
;; the amount of bytes to save:
;;
;;		dl $400DB4 : dw $000A
;; 
;; 3) Then go to extra_save_defaults label and put the default values of
;; your RAM address when loading a new file. Make sure that the default
;; values are in the same order as the ones under extra_save_table to not
;; get weird values when loading a save file.
;; 
;; The maximum amount of bytes that an Extra Save File can save is 2048.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!ram_checkpoint	#= $40A430



extra_save_table:
;Put save ram addresses here, not after .end.
dl !ram_checkpoint	: dw $00C0
dl $400DB4	: dw $000A	;Player lives, powerups, coins etc.
dl $400F34	: dw $0006	;Player score
dl $400F48	: dw $0002	;Player Bonus Stars
.end


	
extra_save_defaults:
;dl !ram_checkpoint : dw $00C0
	dw $0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007
	dw $0008,$0009,$000A,$000B,$000C,$000D,$000E,$000F
	dw $0010,$0011,$0012,$0013,$0014,$0015,$0016,$0017
	dw $0018,$0019,$001A,$001B,$001C,$001D,$001E,$001F
	dw $0020,$0021,$0022,$0023,$0024,$0101,$0102,$0103
	dw $0104,$0105,$0106,$0107,$0108,$0109,$010A,$010B
	dw $010C,$010D,$010E,$010F,$0110,$0111,$0112,$0113
	dw $0114,$0115,$0116,$0117,$0118,$0119,$011A,$011B
	dw $011C,$011D,$011E,$011F,$0120,$0121,$0122,$0123
	dw $0124,$0125,$0126,$0127,$0128,$0129,$012A,$012B
	dw $012C,$012D,$012E,$012F,$0130,$0131,$0132,$0133
	dw $0134,$0135,$0136,$0137,$0138,$0139,$013A,$013B

;dl $400DB4	: dw $000A
	db $09,$09,$00,$00,$00,$00,$00,$00,$00,$00
;dl $400F34	: dw $0006
	dl $000000,$000000
;dl $400F48	: dw $0002
	db $00,$00

;Format: db $xx,$xx,$xx...
;^valid sizes: db (byte), dw (word, meaning 2 bytes: $xxxx), and dl
;(long, 3-bytes: $xxxxxx). The $ (dollar) symbol isn't mandatory,
;just represents hexadecimal type of value.
