; Routine for spinning coin sprites that fetches information to draw it on screen.
; It handles the offscreen bit and layer 2 offsets.
; 
; Input:
;   N/A
; 
; Output: 
;   $00 = X position within the screen
;   $01 = Y position within the screen
;   $03 = OAM size and offscreen bit
;   Y   = OAM Index
;   C   = Draw status
;       Set     = Ready to be drawn on screen
;       Clear   = Not possible to draw on screen

?main:
    lda !spinning_coin_layer,x
    asl #2
    tay
    rep #$20
    lda.w $1C|!dp,y
    sta $02
    lda.w $1A|!dp,y
    sta $04
    sep #$20
    lda !spinning_coin_y_low,x
    cmp $02
    lda !spinning_coin_y_high,x
    sbc $03
    bne ?.return
    lda !spinning_coin_x_low,x
    sbc $04
    cmp #$F8
    bcs ?.kill
    sta $00
    lda !spinning_coin_y_low,x
    sec 
    sbc $02
    sta $01
    lda.l $0299E9|!BankB,x
    tay
    sec 
    rtl
?.kill
    stz !spinning_coin_num,x
?.return
    clc 
    rtl 