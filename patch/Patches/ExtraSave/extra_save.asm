;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra Save by ASMagician Maks
;;
;; Based on BW-RAM Plus by LX5
;; 
;; This patch allows you to expand the intact vanilla save file with the
;; ability to save bytes from any RAM address into an Extra Save File.
;;
;; Unlike other patches, this one keeps a buffer to preserve how SMW
;; acts in cases like Game Overing, and to prevent desyncs between
;; vanilla save file and Extra Save File.
;;
;; This is currently only meant for SA-1 ROMs.
;; 
;; The maximum amount of bytes that an Extra Save File can save is 2048.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sa1rom
!addr	= $6000
!bank	= $000000
!save	= $41C000
!extra_save	= $41A000



org $009F06	;Load Empty File into buffer
skip 2
	JML transfer_init_to_buffer_fileselect
	NOP #2
;	LDX.b #$8D
;-
;	STZ $1F48|!addr,x
;	DEX
;	BNE -


org $009CF5	;Load existing File into buffer
	JML transfer_save_to_buffer_validfile
	NOP #2
;	BNE $009D22
;	PHX
;	STZ $0109|!addr


org $009BCF	;Save the buffer to File
	autoclean JML transfer_buffer_to_save_savegame
;	LDA.w $009CCB,x
;	XBA


org $00A195	;Load the buffer into corresponding RAM addresses
	JML transfer_buffer_to_ram_common
	NOP
;	REP #$10
;	LDX.w #$008C


org $04904F	;Reflect RAM changes to the buffer
	JML transfer_ram_to_buffer_saveprompt
	NOP
;	LDA.b #$05
;	STA $1B87|!addr



org $009E13	;Set various player addresses after fully loading a File
	JML extra_post_file_load
;	JSL $04DAAD


org $00976C	;Request Continue/End menu on Game Over screen
	JML extra_gameover_clear
	NOP #2
;	STZ $0DC1|!addr
;	LDA $0DB4|!addr


org $00A0F6	;Continue/End menu will be shown on the overworld
	JML extra_gameover_file_load	
	NOP
;	LDA $1F2E|!addr
;	BNE $00A101


org $009BA0	;Continue is selected after a Game Over
	JML extra_gameover_continue
	NOP #2
;	BNE $009BA5
;	JMP $009E17

	


freedata

extra_save_slots:
dw !extra_save+$0000	;MARIO A
dw !extra_save+$0800	;MARIO B
dw !extra_save+$1000	;MARIO C

!buffer	#= !extra_save+$1800	;Buffer


transfer_init_to_buffer:
	PHP
	PHB
	REP #$30
	LDX.w #extra_save_defaults
	LDY.w #!buffer
	LDA.w #$0800-1	;Max save file size
	MVN !extra_save>>16,extra_save_defaults>>16	;Y <- X
	PLB
	PLP
	RTS


transfer_save_to_buffer:
	PHP
	PHB
	REP #$30
	LDA $010A|!addr
	AND.w #$00FF
	ASL
	TAX
	LDA.l extra_save_slots,x
	TAX
	LDY.w #!buffer
	LDA.w #$0800-1	;Max save file size
	MVN !extra_save>>16,!extra_save>>16	;Y <- X
	PLB
	PLP
	RTS


	
transfer_buffer_to_save:
	LDA.l $005000
	PHP
	PHB
	REP #$30
	LDA $010A|!addr
	AND.w #$00FF
	ASL
	TAX
	LDA.l extra_save_slots,x
	TAY
	LDX.w #!buffer
	LDA.w #$0800-1	;Max save file size
	MVN !extra_save>>16,!extra_save>>16	;Y <- X
	PLB
	PLP
	RTS



transfer_buffer_to_ram:
	LDA.l $005000
	PHP
	PHB
	REP #$30
	LDX.w #!buffer
	LDA.w #$0000		;Initialize loop.
	BRA .start
.next
	STX $00
	TAX
	PHX
	LDA.l extra_save_table,x	;Get low and high bytes of the address.
	TAY
	LDA.l extra_save_table+3,x	;Get how many bytes we will load from buffer.
	DEC
	PHA
	LDA.l extra_save_table+2,x	;Get bank byte of the address.
	LDX $00
	AND.w #$00FF
	BEQ .use_00
	CMP.w #$0040
	BEQ .use_40
	CMP.w #$0041
	BEQ .use_41
	CMP.w #$007E
	BEQ .use_7E
	;CMP.w #$007F
	;BEQ .use_7F
.use_7F		
	PLA	
	MVN $7F,!buffer>>16	;Move from buffer to bank $7F addresses (WRAM)
	BRA +
.use_7E		
	PLA	
	MVN $7E,!buffer>>16	;Move from buffer to bank $7E addresses (WRAM)
	BRA +
.use_00		
	PLA	
	MVN $00,!buffer>>16	;Move from buffer to bank $00 addresses (I-RAM)
	BRA +
.use_41
	PLA	
	MVN $41,!buffer>>16	;Move from buffer to bank $41 addresses (BW-RAM)
	BRA +
.use_40	
	PLA	
	MVN $40,!buffer>>16	;Move from buffer to bank $40 addresses (BW-RAM)
+
	PLA
	CLC	
	ADC.w #$0005
.start
	CMP.w #extra_save_table_end-extra_save_table
	BCC .next
	PLB
	PLP
	RTS



transfer_ram_to_buffer:
	LDA.l $005000
	PHP
	PHB
	REP #$30
	LDY.w #!buffer
	LDA.w #$0000		;Initialize loop.
	BRA .start
.next
	TAX
	PHX
	LDA.l extra_save_table,x	;Get low and high bytes of the address.
	STA $00
	LDA.l extra_save_table+3,x	;Get how many bytes we will save from that address.	
	DEC
	PHA
	LDA.l extra_save_table+2,x	;Get bank byte of the address.
	LDX $00
	AND.w #$00FF
	BEQ .use_00
	CMP.w #$0040
	BEQ .use_40
	CMP.w #$0041
	BEQ .use_41
	CMP.w #$007E
	BEQ .use_7E
	;CMP.w #$007F
	;BEQ .use_7F
.use_7F		
	PLA	
	MVN !buffer>>16,$7F	;Move to buffer addresses from bank $7F (WRAM)
	BRA +
.use_7E		
	PLA	
	MVN !buffer>>16,$7E	;Move to buffer addresses from bank $7E (WRAM)
	BRA +
.use_00		
	PLA	
	MVN !buffer>>16,$00	;Move to buffer addresses from bank $00 (I-RAM)
	BRA +
.use_41
	PLA	
	MVN !buffer>>16,$41	;Move to buffer addresses from bank $41 (BW-RAM)
	BRA +
.use_40	
	PLA	
	MVN !buffer>>16,$40	;Move to buffer addresses from bank $40 (BW-RAM)
+
	PLA
	CLC
	ADC.w #$0005
.start
	CMP.w #extra_save_table_end-extra_save_table
	BCC .next
	PLB
	PLP
	RTS



transfer_init_to_buffer_fileselect:
-
	STZ $1F48|!addr,x	;Restore code
	DEX
	BNE -
	JSR transfer_init_to_buffer
	JML $009F0E|!bank


transfer_save_to_buffer_validfile:
	BEQ +	;Hijack a bit earlier so we can also execute code in case of an empty save file
	SEP #$10
	JSR extra_new_file_load
	JML $009D22|!bank
+
	PHX	;Restore code
	STZ $0109|!addr
	JSR transfer_save_to_buffer
	JML $009CFB|!bank


transfer_buffer_to_save_savegame:
	JSR transfer_buffer_to_save
	LDA.w $009CCB,x	;Restore code
	XBA
	JML $009BD3|!bank


transfer_buffer_to_ram_common:
	JSR transfer_buffer_to_ram
	REP #$10	;Restore code
	LDX.w #$008C
	JML $00A19A|!bank


transfer_ram_to_buffer_saveprompt:
	JSR transfer_ram_to_buffer
	LDA.b #$05	;Restore code
	STA $1B87|!addr	
	JML $049054|!bank



extra_post_file_load:
	JSL $04DAAD|!bank	;Restore code
	LDA.b #$FF	;Fade music after loading a save file and selecting players
	STA $1DFB|!addr

	;Set lives, powerup, coins, if they're not loaded from the save file
	;Comment the ones that are saved in the save file
	REP #$20
	;LDA.w #$0404
	;STA $0DB4|!addr	;Lives
	;STZ $0DB6|!addr	;Coins
	;STZ $0DB8|!addr	;Powerup
	;STZ $0DBA|!addr	;Yoshi
	;STZ $0DBC|!addr	;Reserve
	;STZ $0F48|!addr	;Bonus Stars
	;STZ $0F34|!addr	;\
	;STZ $0F36|!addr	;|Score
	;STZ $0F38|!addr	;/

	;Set the current player's lives, coins, powerup, yoshi, and reserve
	SEP #$20
	LDX $0DB3|!addr
	LDA $0DB4|!addr,x
	STA $0DBE|!addr
	LDA $0DB6|!addr,x
	STA $0DBF|!addr
	LDA $0DB8|!addr,x
	STA $19
	LDA $0DBA|!addr,x
	STA $0DC1|!addr
	STA $13C7|!addr
	STA $187A|!addr
	LDA $0DBC|!addr,x
	STA $0DC2|!addr
	JML $009E5C|!bank


!DeathCounter	= !save+$07ED
extra_new_file_load:
	;Reset Demo Counter if loading a new file
	LDA $010A|!addr
	STA $00
	ASL
	ADC $00
	TAX
	LDA.b #$00
	STA !DeathCounter,x
	STA !DeathCounter+1,x
	STA !DeathCounter+2,x
	RTS


extra_gameover_clear:
	STZ $0DC1|!addr	;Erase current player's Yoshi
	LDA $0DB2|!addr
	BEQ +
	LDA $0DB4|!addr	;Check if it's a 2 Player Game and if so, check if one player already had 0 lives
	ORA $0DB5|!addr
	BPL .end
+
	INC $13C9|!addr	;Request Continue/End menu
;	LDX.b #$0C	;Uncomment this if you want vanilla behaviour and you don't have these saved
;-
;	STZ $1F2F|!addr,x	;Reset collected Yoshi Coins
;	STZ $1FEE|!addr,x	;Reset collected Moons
;	DEX
;	BPL -
.end
	JML $009788|!bank


extra_gameover_file_load:
	;If lives and powerups are saved then they will be reloaded before the Continue/End menu is shown
	LDX $0DB3|!addr
	LDA.b #$FF
	LDY $0DB2|!addr
	BEQ +
	LDX.b #$00
	REP #$20
	LDA.b #$FFFF	;In 2 player game do it for both players, so both have halos over them and no Yoshis
+
	STA $0DB4|!addr,x	;Lives
	STZ $0DB8|!addr,x	;Powerup
	STZ $0DBA|!addr,x	;Yoshi

	;The rest is just standard clear
	STZ $0DB6|!addr,x	;Coins
	STZ $0DBC|!addr,x	;Reserve
	STZ $0F48|!addr,x	;Bonus Stars
	TYA
	BEQ +
	STZ $0F34|!addr	;\
	STZ $0F36|!addr	;|Score
	STZ $0F38|!addr	;/
	BRA .end
+
	TXY
	BEQ +
	LDX.b #$03
+
	STZ $0F34|!addr,x	;\
	STZ $0F35|!addr,x	;|Score
	STZ $0F36|!addr,x	;/
.end
	LDA $1F2E|!addr	;Restore code
	BNE +
	JML $00A0FB|!bank
+
	JML $00A101|!bank


extra_gameover_continue:
	BNE +	;Restore code
	;extra_gameover_file_load already clears several addresses, but lives are set to 0 for the halo to show up
	LDA.b #$04	;Amount of lives you get from selecting Continue
	STA $0DB4|!addr
	STA $0DB5|!addr
	STA $0DBE|!addr
	;LDA.b #$FF	;Fade out music upon selecting Continue, AMK usually disables this however
	;STA $1DFB|!addr
	STZ $13C9|!addr	;Terminate Continue/End menu
	JML $009E5C|!bank
+
	JML $009BA5|!bank



print "Freespace used by Extra Save routines: ",freespaceuse," bytes."

print "Extra Save tables are located at: $",pc

reset bytes
incsrc extra_save_tables.asm

print "Freespace used by Extra Save tables: ",bytes," bytes."
