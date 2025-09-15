; VALID VALUES:
; $00 for fast moles + hammers
; $01 for slow moles, but fast hammers
; $02 for slow hammers, but fast moles
; $03 for slow moles + hammers
rates:
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 000-007
	db $02,$02,$02,$02,$02,$02,$00,$02	; levels 008-00F
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 010-017
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 018-01F
	db $02,$02,$02,$02,$02			; levels 020-024

	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 101-108
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 109-110
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 111-118
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 119-120
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 121-128
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 129-130
	db $02,$02,$02,$02,$02,$02,$02,$02	; levels 131-138
	db $02,$02,$02				; levels 139-13B
