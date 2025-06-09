; ******************************************************************************
;MKBOOT.ASM  - version 1.1 by D. Lausberg
;improved determination of FAT type
; ******************************************************************************
SRC             EQU	$DC
SRCL            EQU	$DC
SRCH		EQU	$DD

DST      	EQU   	$E8
DSTL      	EQU   	$E8     	; Store address Low
DSTH      	EQU   	$E9     	; Store address High

CNT             EQU     $EC
CNTL            EQU     $EC
CNTH            EQU     $ED

PSTR            EQU     $EA

RES             EQU     $20
PCNT            EQU     $21
FIRST_PART      EQU     $22
NUM_PART        EQU     $23
IS_FAT16        EQU     $24
POINT		EQU	$25

MOUNT_TABLE     EQU     $0400
BLOCK_BUFF      EQU     $0600

PART0		EQU	$07BE		; Partition 0 start
PART0_RS	EQU	PART0 + 8 	; Partition 0 relative sector field
BS_SIGN		EQU	$07FE		; signature $AA55

COUT            EQU     $E052
CROUT           EQU     $E05A
CIN             EQU     $E047
STROUT          EQU     $E083
WRSTR           EQU     $E085
HEXOUT          EQU     $E091

CMDDEV          EQU     $E0BA
OPEN_DEVICE     EQU     $E1AA

SDC_ID		EQU     $24

CMD_INIT	EQU	0               ; Init device
CMD_READ_BUF	EQU	37
CMD_WRITE_BUF	EQU	38

;****************************************************************************************
;****************************************************************************************

PROG_START	EQU	$3000		; Program Start Address
USE_XMODEM	EQU	0		; 1 use XModem, 0 don't use XModem

;****************************************************************************************

	IF	USE_XMODEM EQ 1

		ORG	PROG_START-2

		DB    	LOW  PROG_START
		DB	HIGH PROG_START

	ENDI

;****************************************************************************************

		ORG	PROG_START	; the program start address

;****************************************************************************************
;****************************************************************************************

MAIN            LDA     #LOW  MSG
                STA     PSTR
                LDA     #HIGH MSG
                STA     PSTR+1
                LDY     #$00
                JSR     WRSTR
		JSR	WAIT_ENTER
                LDA     #SDC_ID
                JSR     OPEN_DEVICE
                BCC     MAIN_ERROR
                LDA     #CMD_INIT
                JSR     CMDDEV
                BCC     MAIN_ERROR
                LDX     #$FF
                STX     FIRST_PART
		INX
                STX     NUM_PART
MAIN1           STX     PCNT
                JSR     RD_MBR
		JSR	CHK_SIGN	; is it a valid MBR?
		BNE	MAIN_ERROR
                LDX     PCNT
                JSR     RD_PARTITION
                BNE     MAIN3		; if the partition exists then write partition boot block
MAIN2		LDX     PCNT
                INX
                CPX     #$04
                BNE     MAIN1
                JMP     WRITE_MBR       ; write master boot block and end program
                
MAIN3		JSR     RD_BLOCK	; read partition boot block
		JSR	CHK_SIGN	; is it a valid partition boot block?
		BNE	PART_ERROR
		JSR     MSG_MKBOOT	; check for FAT type
MSG_WRITE?      LDY     #MSG3-MSG
                JSR     WRSTR
MAIN4           JSR     CIN
                AND  	#$DF		; convert the input to uppercase char
                CMP     #'Y'
                BEQ     MK_BOOT
                CMP     #'N'
                BEQ     MAIN2
                BNE     MAIN4

MK_BOOT         INC     NUM_PART
                LDX     FIRST_PART
                INX
                BNE     MAIN6
                LDX     PCNT
                STX     FIRST_PART
MAIN6           LDA	#LOW OEM
		STA	POINT
		LDA	#HIGH OEM
		STA	POINT+1
		LDX	#$52+7
		JSR     WRITE_OEM       ; insert OEM string
                JSR     WR_BLOCK        ; write partition boot block
                JMP     MAIN2

PART_ERROR      LDY     #MSG4a-MSG       ; write error message
                JSR     WRSTR
                JMP     MAIN2

MAIN_ERROR      LDY     #MSG4-MSG       ; write error message
                JSR     WRSTR
                JMP     MKBOOT_END

; ******************************************************************************
                
COPY_BLOCK      LDY     #$00
COPY_BYTE       LDA     (SRC),Y
                STA     (DST),Y
INC_SRC         INC     SRC
                BNE     INC_DST
                INC     SRC+1
INC_DST         INC     DST
                BNE     DEC_CNT
                INC     DST+1
DEC_CNT         LDA     CNT
                BNE     DEC_CNT1
                DEC     CNT+1
DEC_CNT1        DEC     CNT
                BNE     COPY_BYTE
                LDA     CNT+1
                BNE     COPY_BYTE
                RTS
                
; ******************************************************************************
                
RD_PARTITION    LDA     #$04
                STA     RES
                TXA
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                ORA     #$03
                TAX
                LDY     #$03
L1              LDA     PART0_RS,X
                STA     MOUNT_TABLE,Y
                BNE     L2
                DEC     RES
L2              DEX
                DEY
                BPL     L1
                LDA     RES
                RTS
                
; ******************************************************************************
                
MSG_MKBOOT      LDY     #MSG1-MSG	; determine FAT type and prepare boot sector
                JSR     WRSTR
                LDA     PCNT
                CLC
                ADC     #49
                JSR     COUT
		LDY     #MSG2-MSG
                JSR     WRSTR
                LDA     #$00
                STA     IS_FAT16
                LDX     #$17
                LDA     BLOCK_BUFF,X	; check BPB_FATSz16 = $0000
                STA 	RES
		DEX
                LDA     BLOCK_BUFF,X
		ORA	RES
		BEQ	MSG_FAT_TYPE2	; is it FAT32?
		LDA	BLOCK_BUFF+20	; is BPB_TotSec16 = 0?
		BNE	MSG_MKB3
		LDA	BLOCK_BUFF+19
		BEQ	MSG_FAT_16
MSG_MKB3	LDA	BLOCK_BUFF+20	; HIGH BPB_TotSec16
		LDX	BLOCK_BUFF+13	; BPB_SecPerClus
MSG_MKB1	PHA			; BPB_TotSec16/BPB_SecPerClus
		TXA
		LSR A
		TAX
		PLA
		BCS	MSG_MKB2
		LSR A
		JMP	MSG_MKB1

MSG_MKB2	CMP	#16		; < 4096 Cluster (should be < 4085 data cluster)
		BCC	MSG_FAT_12
MSG_FAT_16	LDA     #$16		; FAT16
                JSR     HEXOUT
		LDA	#LOW FAT16
		STA	POINT
		LDA	#HIGH FAT16
		STA	POINT+1
		BNE	MSG_FAT1x	;jump always

MSG_FAT_12      LDA     #$12		; FAT12
                JSR     HEXOUT
		LDA	#LOW FAT12
		STA	POINT
		LDA	#HIGH FAT12
		STA	POINT+1
MSG_FAT1x	LDX	#$36+7
		JSR	WRITE_OEM
		RTS


MSG_FAT_TYPE2	LDA     #$01
                STA     IS_FAT16
                LDA     #$32		; FAT32
                JSR     HEXOUT
		LDA	#LOW FAT32
		STA	POINT
		LDA	#HIGH FAT32
		STA	POINT+1
		LDX	#$52+7
		JSR	WRITE_OEM
		RTS


; ******************************************************************************

MKBOOT_FAT16    LDA     FAT16_LOADER
                STA     DSTL
                LDA     FAT16_LOADER+1
                STA     DSTH
                LDA     FAT16_LOADER+2
                STA     CNTL
                LDA     FAT16_LOADER+3
                STA     CNTH
                LDA     #LOW  FAT16_LOADER1
                STA     SRCL
                LDA     #HIGH FAT16_LOADER1
                STA     SRCH
                JSR     COPY_BLOCK
                RTS
                
; ******************************************************************************
                
MKBOOT_FAT32    LDA     FAT32_LOADER
                STA     DSTL
                LDA     FAT32_LOADER+1
                STA     DSTH
                LDA     FAT32_LOADER+2
                STA     CNTL
                LDA     FAT32_LOADER+3
                STA     CNTH
                LDA     #LOW  FAT32_LOADER1
                STA     SRCL
                LDA     #HIGH FAT32_LOADER1
                STA     SRCH
                JSR     COPY_BLOCK
                RTS
                
; ******************************************************************************

MKBOOT_MBR      LDA     MBR_LOADER
                STA     DSTL
                LDA     MBR_LOADER+1
                STA     DSTH
                LDA     MBR_LOADER+2
                STA     CNTL
                LDA     MBR_LOADER+3
                STA     CNTH
                LDA     #LOW  MBR_LOADER1
                STA     SRCL
                LDA     #HIGH MBR_LOADER1
                STA     SRCH
                JSR     COPY_BLOCK
                RTS
                
; ******************************************************************************
                
WRITE_OEM       LDY     #$07
WRITE_NEXT_CHR  LDA     (POINT),Y
                STA     BLOCK_BUFF,X
                DEX
		DEY
                BPL     WRITE_NEXT_CHR
                RTS
                
; ******************************************************************************
                
WRITE_MBR	JSR     RD_MBR		; read MBR
		LDA     FIRST_PART
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                TAX
                LDA     #$80
                STA     PART0,X
                LDX     NUM_PART
                BEQ     MKBOOT_END	; WRITE_MBR_END
                DEX
                BEQ     WR_MBR
                JSR     MKBOOT_MBR
WR_MBR          JSR     WR_BLOCK
WRITE_MBR_END   LDY     #MSG5-MSG       ; write message
                JSR     WRSTR
                
MKBOOT_END      LDY     #MSG6-MSG	; end message
                JSR     WRSTR
		LDY     #MSG0a-MSG	; and press <ENTER>
                JSR     WRSTR
WAIT_ENTER      JSR     CIN
                CMP     #13		; was it <ENTER>?
                BNE     WAIT_ENTER
		JMP	CROUT

; ******************************************************************************
                
RD_MBR          LDA     #$00
                STA     MOUNT_TABLE
                STA     MOUNT_TABLE+1
                STA     MOUNT_TABLE+2
                STA     MOUNT_TABLE+3
                
; ******************************************************************************
                
RD_BLOCK        LDX     #LOW  MOUNT_TABLE
                LDY     #HIGH MOUNT_TABLE
                LDA     #CMD_READ_BUF
                JMP     CMDDEV
                
; ******************************************************************************
                
WR_BLOCK        LDX     #LOW  MOUNT_TABLE
                LDY     #HIGH MOUNT_TABLE
                LDA     #CMD_WRITE_BUF
                JMP     CMDDEV
                
; ******************************************************************************

CHK_SIGN	LDA	BS_SIGN		; check for $AA55 at $1FE in BLOCK_BUFF
		CMP 	#$55
		BNE	CHK_SIGNX
		LDA	BS_SIGN+1
		CMP	#$AA
CHK_SIGNX	RTS			; Z=1 ok   Z=0 Error

; ******************************************************************************

MSG             DB      $0D
                TEXT    "MKBOOT 1.1 for M/OS 65" ; - 2023 by Joerg Walke"
                DB      $0D,$0D
MSG0            TEXT    "Insert SD-Card"
MSG0a		TEXT	" and press <ENTER>"
                DB      $00
MSG1            DB      $0D
                TEXT    "Partition "
                DB      $00
MSG2            TEXT    " format is FAT"
                DB      $00
MSG3            TEXT    ". Write Boot Block? (y/n)"
                DB      $00
                
MSG4            DB      $0D
                TEXT    "Error: SD-Card or MBR not valid."
                DB      $00

MSG4a           DB      $0D
                TEXT    "Error: inv. part. boot block."
                DB      $00

MSG5            DB      $0D,$0D
                TEXT    "MBR and Boot Block(s) written."
                DB      $00

MSG6            DB      $0D,$0D
                TEXT    "Reinsert System SD"
                DB      $00
                
OEM             TEXT    "JCOS    "
FAT12           TEXT    "FAT12   "
FAT16           TEXT    "FAT16   "
FAT32           TEXT    "FAT32   "
                
FAT16_LOADER    DB      $3E,$06,$C2,$01
FAT16_LOADER1           ; insert BootCode_FAT16.bin with HexEdit

                ORG     FAT16_LOADER1+450
FAT32_LOADER    DB      $5A,$06,$A6,$01
FAT32_LOADER1           ; insert BootCode_FAT32.bin with HexEdit

                ORG     FAT32_LOADER1+422
MBR_LOADER      DB      $00,$06,$BE,$01
MBR_LOADER1		; insert BootMenu.bin with HexEdit

                ORG     MBR_LOADER1+446
                END
