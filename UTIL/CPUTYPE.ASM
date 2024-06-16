;********************************************************
;*							*
;*	    CPU TYPE TESTER				*
;*	    JC II M/OS-65 Version				*
;********************************************************
;
;released:	14 August 2014 (1.00)
;last revision:	12 February 2015 (1.00X)
;			native assembler
;
;M/OS-65 definitions

TPA	=	$3000		;TPA start

;M/OS-65 commands
STROUT	=	$E083		;PRINT STRING

;page $00 cells

PSTR	= $EA			;pointer for strings

;character definitions
EOT	= $00
CR	=	$d		;ASCII CARRIAGE RETURN
;
;code section
	ORG	TPA

	lda	#opnmsg	;point to welcome message
	ldy	#opnmsg/256
	jsr	message		;send it
;now run the test
	lda	#$99
	clc
	sed
	adc	#$01
	cld
	beq	cmos
;we have an NMOS CPU
	lda	#NMOSMsg	;point to message
	ldy	#NMOSMsg/256
	jsr	message		;send it
	RTS

;we have a CMOS CPU
cmos	lda	#CMOSMsg	;point to message
	ldy	#CMOSMsg/256
	jsr	message		;send it
	RTS

;normal message output for message at ay
MESSAGE	STA	PSTR		;DISPLAY THE MESSAGE
	STY	PSTR+1
	jmp	STROUT		;and return
;
;messages
opnmsg	DB	cr,'CPM-65 CPU TYPE TESTER V1.00',cr,EOT
NMOSMsg	DB	cr,'**** CPU is NMOS - 6502 ****',CR,EOT
CMOSMsg	DB	cr,'**** CPU is CMOS - 65C02 ****',CR,EOT
;
	END
