R0 equ 0
R1 equ 1
R2 equ 2
R3 equ 3
R4 equ 4
R5 equ 5
R6 equ 6
R7 equ 7
R8 equ 8
R9 equ 9
R10 equ 10
R11 equ 11
R12 equ 12
R13 equ 13
R14 equ 14
R15 equ 15

; Memory locations
MIN00 equ 0x8000
MIN01 equ 0x8001
MIN02 equ 0x8002
MIN03 equ 0x8003
MIN10 equ 0x8004
MIN11 equ 0x8005
MIN12 equ 0x8006
MIN13 equ 0x8007
MRES0 equ 0x8008
MRES1 equ 0x8009
MRES2 equ 0x800A
MRES3 equ 0x800B
MRES4 equ 0x800C
MRES5 equ 0x800D
MRES6 equ 0x800E
MRES7 equ 0x800F
; Danger: intentionally overlap between TEMP and DIN to save memory!
TEMP0 equ 0x8010
TEMP1 equ 0x8011
TEMP2 equ 0x8012
TEMP3 equ 0x8013
DIN00 equ 0x8010
DIN01 equ 0x8011
DIN02 equ 0x8012
DIN03 equ 0x8013
DIN04 equ 0x8014
DIN05 equ 0x8015
SQRT_RESULT0 equ 0x8016
SQRT_RESULT1 equ 0x8017
SQRT_RESULT2 equ 0x8018
SQRT_RESULT3 equ 0x8019

; Register conventions
; R2 always points to SPI_WAIT subroutine for fast access
; R9 points to memory-mapped IO locations (R9.1 never needs to be reloaded as a result)
; R0 is the default PC
; R1 is the default SP
; R6 is the standard subroutine PC (for any other routine than SPI_WAIT)
; Leaving R3, R4, R5, R7 and R8 - R15 free
; R3, R4, R5, R7 and R9.1 need to be pushed to stack if used by subroutine
	
	org 0
START:
	NOP
	LDI SPI_WAIT&0xFF
	PLO R2
	LDI SPI_WAIT>>8
	PHI R2
	LDI 0xFF
	PHI R9
	LDI 0xF4
	PLO R9
	SEX R9
	
	; SPI clock div
	LDI 250
	STXD
	; Transmit 0 as sync char
	LDI 0
	STXD
	SEP R2
	
	; Stack at 0x807F
	LDI 0x80
	PHI R1
	LDI 0x7F
	PLO R1
	SEX R1
	
	; Print Hello Message
	LDI HELLO_TEXT>>8
	PHI R3
	LDI HELLO_TEXT&255
	PLO R3
	LDI 0xF5
	PLO R9
PRINT_LOOP:
	LDN R3
	INC R3
	BZ PRINT_LOOP_DONE
	STR R9
	SEP R2
	BR PRINT_LOOP
PRINT_LOOP_DONE:

	; For several reasons, we want all subroutines to be defined before the main program code
	; So let’s do that, and branch to the rest of the program here
	LBR TEST_MUL

	; Infinite loop of blinking Q
END:
	LSQ
	SEQ
	SKP
	REQ
	LDI 0xFF
	PHI R9
	PLO R9
END_LOOP:
	DEC R9
	GHI R9
	BNZ END_LOOP
	GLO R9
	BNZ END_LOOP
	BR END

	; Wait for SPI TX complete subroutine
SPI_WAIT:
	GLO R9
	STXD
	LDI 0xF3
	PLO R9
SPI_WAIT_LOOP:
	LDN R9
	ANI 4
	BNZ SPI_WAIT_LOOP
	IRX
	LDX
	PLO R9
	SEP R0
	BR SPI_WAIT

	; Display a string of memory as hex
	; R3 = Pointer to most-significant byte
	; R4.0 = Length of string
PRINT_HEX:
	GLO R9
	STXD
	GLO R0
	STXD
	GHI R0
	STXD
	GHI R4
	STXD
	GLO R5
	STXD
	GHI R5
	STXD
	LDI PRINT_HEX_LOOP&255
	PLO R0
	LDI PRINT_HEX_LOOP>>8
	PHI R0
	SEP R0
	IRX
	LDX
	PHI R5
	IRX
	LDX
	PLO R5
	IRX
	LDX
	PHI R4
	IRX
	LDX
	PHI R0
	IRX
	LDX
	PLO R0
	IRX
	LDX
	PLO R9
	SEP R0
	BR PRINT_HEX
PRINT_HEX_LOOP:
	LDI 0xF5
	PLO R9
	LDN R3
	DEC R3
	PHI R4
	SHR
	SHR
	SHR
	SHR
	ADI HEX_DIGITS&255
	PLO R5
	LDI 0
	ADCI HEX_DIGITS>>8
	PHI R5
	LDN R5
	STR R9
	SEP R2
	GHI R4
	ANI 15
	ADI HEX_DIGITS&255
	PLO R5
	LDI 0
	ADCI HEX_DIGITS>>8
	PHI R5
	LDN R5
	STR R9
	SEP R2
	GLO R4
	SMI 1
	PLO R4
	BNZ PRINT_HEX_LOOP
	SEP R6

MUL_8x32:
	LDI MIN10>>8
	PHI R3
	LDI MIN10&255
	PLO R3
	LDA R3
	PLO R10
	LDA R3
	PHI R10
	LDA R3
	PLO R11
	LDA R3
	PHI R11
	LDI 0
	PHI R8
	SEX R3
MUL_8x32_LOOP:
	GLO R8
	SHR
	PLO R8
	BNF MUL_8x32_NO_CARRY
	LDI MRES3&255
	PLO R3
	GLO R10
	ADD
	STR R3
	INC R3
	GHI R10
	ADC
	STR R3
	INC R3
	GLO R11
	ADC
	STR R3
	INC R3
	GHI R11
	ADC
	STR R3
	INC R3
	GHI R8
	ADC
	STR R3
MUL_8x32_NO_CARRY:
	GLO R10
	SHL
	PLO R10
	GHI R10
	SHLC
	PHI R10
	GLO R11
	SHLC
	PLO R11
	GHI R11
	SHLC
	PHI R11
	GHI R8
	SHLC
	PHI R8
	GLO R8
	LBNZ MUL_8x32_LOOP
	SEX R1
	SEP R6
	LBR MUL_8x32

ZERO_MUL_RES:
	LDI MRES7>>8
	PHI R3
	LDI MRES7&255
	PLO R3
	LDI 0
	SEX R3
	STXD
	STXD
	STXD
	STXD
	STXD
	STXD
	STXD
	STXD
	SEX R1
	LBR ZERO_MUL_RES_DONE

	; R15.0 stores sign of result
MUL_32x32_SIGNED:
	LDI 0
	PLO R15
	LDI MIN03>>8
	PHI R13
	LDI MIN03&255
	PLO R13
	LDA R13
	ANI 128
	LBZ MUL_32x32_NOT_NEG_A
	LDI MIN00>>8
	PHI R12
	LDI MIN00&255
	PLO R12
	LDN R12
	XRI 0xFF
	ADI 1
	STR R12
	INC R12
	LDN R12
	XRI 0xFF
	ADCI 0
	STR R12
	INC R12
	LDN R12
	XRI 0xFF
	ADCI 0
	STR R12
	INC R12
	LDN R12
	XRI 0xFF
	ADCI 0
	STR R12
	LDI 1
	PLO R15
MUL_32x32_NOT_NEG_A:
	INC R13
	INC R13
	INC R13
	LDN R13
	ANI 128
	LBZ MUL_32x32_NOT_NEG_B
	LDI MIN10&255
	PLO R12
	LDI MIN10>>8
	PHI R12
	LDN R12
	XRI 0xFF
	ADI 1
	STR R12
	INC R12
	LDN R12
	XRI 0xFF
	ADCI 0
	STR R12
	INC R12
	LDN R12
	XRI 0xFF
	ADCI 0
	STR R12
	INC R12
	LDN R12
	XRI 0xFF
	ADCI 0
	STR R12
	GLO R15
	XRI 1
	PLO R15
MUL_32x32_NOT_NEG_B:
	
	GLO R15
	LSKP
MUL_32x32_UNSIGNED:
	LDI 0
	PLO R15
	GLO R3
	STXD
	GHI R3
	STXD
	LBR ZERO_MUL_RES
ZERO_MUL_RES_DONE:
	LDI 4
	PHI R15
	LDI MIN00>>8
	PHI R13
	LDI MIN00&255
	PLO R13
	LDI MUL_8x32>>8
	PHI R12
	LDI MUL_8x32&255
	PLO R12
MUL_32x32_LOOP:

	; result >>= 8
	LDI MRES1>>8
	PHI R3
	LDI MRES1&255
	PLO R3
	LDI 7
	PLO R14
MUL_32x32_SHIFT_RES_LOOP:
	LDN R3
	DEC R3
	STR R3
	INC R3
	INC R3
	GLO R14
	SMI 1
	PLO R14
	BNZ MUL_32x32_SHIFT_RES_LOOP
	DEC R3
	LDI 0
	STR R3
	
	LDN R13
	PLO R8
	INC R13
	SEP R12 ; mul 8x32
	
	GHI R15
	SMI 1
	PHI R15
	BNZ MUL_32x32_LOOP
	
	GLO R15
	LBZ MUL_32x32_RES_NOT_NEG
	; Sign of result is negative
	; Negate result
	LDI MRES0>>8
	PHI R3
	LDI MRES0&255
	PLO R3
	LDI 0xFF
	ADI 0xFF
MUL_32x32_NEGATE_RES_LOOP:
	LDN R3
	XRI 0xFF
	ADCI 0
	STR R3
	INC R3
	GLO R3
	XRI (MRES7+1)&255
	BNZ MUL_32x32_NEGATE_RES_LOOP
MUL_32x32_RES_NOT_NEG:
	IRX
	LDX
	PHI R3
	IRX
	LDX
	PLO R3
	SEP R0
	LBR MUL_32x32_UNSIGNED

	; Pointer to LSB of int in R3
PRINTINT32:
	GLO R8
	STXD
	GLO R9
	STXD
	LDA R3
	PLO R10
	LDA R3
	PHI R10
	LDA R3
	PLO R11
	LDN R3
	PHI R11
	DEC R3
	DEC R3
	DEC R3
	LDI 0
	PLO R14
	PLO R8
	LDI PRINTINT32_DIVS>>8
	PHI R15
	LDI PRINTINT32_DIVS&255
	PLO R15
PRINTINT32_LOOP:
	LDI 0
	PHI R14
	SEX R15
	; while(1) {
PRINTINT32_DIV_LOOP:
	LDI 0xFF
	ADI 0xFF
	; {R13, R12} = {R11, R10} - divs[i];
	GLO R10
	ADD
	PLO R12
	IRX
	GHI R10
	ADC
	PHI R12
	IRX
	GLO R11
	ADC
	PLO R13
	GHI R11
	IRX
	ADC
	PHI R13
	DEC R15
	DEC R15
	DEC R15
	; break if {R13, R12} < 0;
	GHI R13
	ANI 128
	LBNZ PRINTINT32_DIV_LOOP_END
	; R14.1++;
	GHI R14
	ADI 1
	PHI R14
	; {R11, R10} = {R13, R12};
	GLO R12
	PLO R10
	GLO R13
	PLO R11
	GHI R13
	PHI R11
	GHI R12
	PHI R10
	; }
	LBR PRINTINT32_DIV_LOOP
PRINTINT32_DIV_LOOP_END:
	SEX R1
	; if(R14.1 != 0 || flag || i == 9) {
	GLO R14
	ADI 0
	BNZ PRINTINT32_DO_PRINT
	GHI R14
	ADI 0
	BNZ PRINTINT32_DO_PRINT
	GLO R8
	XRI 9
	BNZ PRINTINT32_NO_PRINT
PRINTINT32_DO_PRINT:
	; set flag
	LDI 'y'
	PLO R14
	; print '0' + R14.1
	LDI 0xF5
	PLO R9
	GHI R14
	ADI '0'
	STR R9
	; inline SPI wait bc I’m lazy
	LDI 0xF3
	PLO R9
PRINTINT32_SPI_WAIT_LOOP:
	LDN R9
	ANI 4
	BNZ PRINTINT32_SPI_WAIT_LOOP
PRINTINT32_NO_PRINT:
	; }
	
	INC R15
	INC R15
	INC R15
	INC R15
	GLO R8
	ADI 1
	PLO R8
	XRI 10
	LBNZ PRINTINT32_LOOP
	
	IRX
	LDX
	PLO R9
	IRX
	LDX
	PLO R8
	SEP R0
	LBR PRINTINT32

	; Pointer to LSB of int in R3
PRINTINT64:
	GLO R8
	STXD
	GHI R8
	STXD
	GLO R9
	STXD
	GLO R2
	STXD
	GHI R2
	STXD
	GLO R3
	STXD
	GHI R3
	STXD
	GLO R4
	STXD
	GHI R4
	STXD
	GLO R5
	STXD
	GHI R5
	STXD
	
	LDI 0
	PLO R14
	GLO R8
	LDA R3
	PLO R10
	LDA R3
	PHI R10
	LDA R3
	PLO R11
	LDA R3
	PHI R11
	LDA R3
	PLO R12
	LDA R3
	PHI R12
	LDA R3
	PLO R13
	LDN R3
	PHI R13
	LDI PRINTINT64_DIVS>>8
	PHI R2
	LDI PRINTINT64_DIVS&255
	PLO R2
PRINTINT64_LOOP:
	LDI 0
	PHI R14
	SEX R2
PRINTINT64_DIV_LOOP:
	LDI 0xFF
	ADI 0xFF
	; {R15, R5, R3, R4} = {R13, R12, R11, R10} - divs[i];
	GLO R10
	ADD
	PLO R4
	IRX
	GHI R10
	ADC
	PHI R4
	GLO R11
	IRX
	ADC
	PLO R3
	IRX
	GHI R11
	ADC
	IRX
	PHI R3
	GLO R12
	ADC
	PLO R5
	IRX
	GHI R12
	ADC
	PHI R5
	IRX
	GLO R13
	ADC
	PLO R15
	GHI R13
	IRX
	ADC
	PHI R15
	DEC R2
	DEC R2
	DEC R2
	DEC R2
	DEC R2
	DEC R2
	DEC R2
	; break if {R15, R5, R3, R4} < 0;
	GHI R15
	ANI 128
	BNZ PRINTINT64_DIV_LOOP_END
	; {R13, R12, R11, R10} = {R15, R5, R3, R4}
	GLO R4
	PLO R10
	GHI R4
	PHI R10
	GLO R3
	PLO R11
	GHI R3
	PHI R11
	GLO R5
	PLO R12
	GHI R5
	PHI R12
	GLO R15
	PLO R13
	GHI R15
	PHI R15
	; R14.1++;
	GHI R14
	ADI 1
	PHI R14
	LBR PRINTINT64_DIV_LOOP
PRINTINT64_DIV_LOOP_END:
	SEX R1
	; if(R14.1 != 0 || flag || i == 18) {
	GLO R14
	ADI 0
	BNZ PRINTINT64_DO_PRINT
	GHI R14
	ADI 0
	BNZ PRINTINT64_DO_PRINT
	GLO R8
	XRI 18
	BNZ PRINTINT64_NO_PRINT
PRINTINT64_DO_PRINT:
	; set flag
	LDI 'y'
	PLO R14
	; print '0' + R14.1
	LDI 0xF5
	PLO R9
	GHI R14
	ADI '0'
	STR R9
	; inline SPI wait bc R2 used to store data in this routine
	LDI 0xF3
	PLO R9
PRINTINT64_SPI_WAIT_LOOP:
	LDN R9
	ANI 4
	BNZ PRINTINT64_SPI_WAIT_LOOP
PRINTINT64_NO_PRINT:
	; }
	
	GLO R2
	ADI 8
	PLO R2
	GHI R2
	ADCI 0
	PHI R2
	GLO R8
	ADI 1
	PLO R8
	SMI 19
	LBNZ PRINTINT64_LOOP
	
	IRX
	LDX
	PHI R5
	IRX
	LDX
	PLO R5
	IRX
	LDX
	PHI R4
	IRX
	LDX
	PLO R4
	IRX
	LDX
	PHI R3
	IRX
	LDX
	PLO R3
	IRX
	LDX
	PHI R2
	IRX
	LDX
	PLO R2
	IRX
	LDX
	PLO R9
	IRX
	LDX
	PHI R8
	IRX
	LDX
	PLO R8
	SEP R0
	LBR PRINTINT64

	; Pointer to LSB of fixed-point number in R3
PRINT_FIXED:
	GLO R9
	STXD
	GLO R3
	STXD
	GHI R3
	STXD
	
	LDA R3
	PLO R10
	LDA R3
	PHI R10
	LDA R3
	PLO R11
	LDN R3
	PHI R11
	ANI 128
	LBZ PRINT_FIXED_NOT_NEG
	; Print '-'
	LDI 0xF5
	PLO R9
	LDI '-'
	STR R9
	LDI 0xF3
	PLO R9
PRINT_FIXED_SPI_WAIT_LOOP_1:
	LDN R9
	ANI 4
	BNZ PRINT_FIXED_SPI_WAIT_LOOP_1
	; Negate fixed-point number
	GLO R10
	XRI 0xFF
	ADI 1
	PLO R10
	GHI R10
	XRI 0xFF
	ADCI 0
	PHI R10
	GLO R11
	XRI 0xFF
	ADCI 0
	PLO R11
	GHI R11
	XRI 0xFF
	ADCI 0
	PHI R11
PRINT_FIXED_NOT_NEG:
	; Print integer portion
	LDI TEMP0>>8
	PHI R3
	LDI TEMP0&255
	PLO R3
	GLO R11
	STR R3
	INC R3
	GHI R11
	STR R3
	INC R3
	LDI 0
	STR R3
	INC R3
	STR R3
	DEC R3
	DEC R3
	DEC R3
	; The pain of doing nested subroutine calls on this arch
	GLO R0
	STXD
	GHI R0
	STXD
	LDI PRINT_FIXED_CONT_1>>8
	PHI R0
	LDI PRINT_FIXED_CONT_1&255
	PLO R0
	SEP R0
PRINT_FIXED_CONT_1:
	; Push R10, we won’t care about R11 anymore after this
	GLO R10
	STXD
	GHI R10
	STXD
	LDI PRINTINT32>>8
	PHI R6
	LDI PRINTINT32&255
	PLO R6
	SEP R6
	; Print '.'
	LDI 0xF5
	PLO R9
	LDI '.'
	STR R9
	SEP R2
	IRX
	LDX
	PHI R10
	IRX
	LDX
	PLO R10
	; Print fraction portion
	LDI MIN00>>8
	PHI R3
	LDI MIN00&255
	PLO R3
	LDI 0
	STR R3
	INC R3
	STR R3
	INC R3
	LDI 10
	STR R3
	INC R3
	ANI 0
	STR R3
	LDI MUL_32x32_UNSIGNED>>8
	PHI R6
	LDI MUL_32x32_UNSIGNED&255
	PLO R6
	LDI 6
	PLO R15
PRINT_FIXED_LOOP:
	DEC R15
	GLO R15
	LBZ PRINT_FIXED_LOOP_END
	STXD
	LDI MIN10>>8
	PHI R3
	LDI MIN10&255
	PLO R3
	GLO R10
	STR R3
	INC R3
	GHI R10
	STR R3
	INC R3
	LDI 0
	STR R3
	INC R3
	STR R3
	SEP R6
	LDI MRES2>>8
	PHI R3
	LDI MRES2&255
	PLO R3
	LDA R3
	PLO R10
	LDA R3
	PHI R10
	LDN R3
	ADI '0'
	STR R9
	SEP R2
	
	IRX
	LDX
	PLO R15
	GLO R10
	BNZ PRINT_FIXED_LOOP
	GHI R10
	BNZ PRINT_FIXED_LOOP
PRINT_FIXED_LOOP_END:
	; Return
	LDI PRINT_FIXED_CONT_2>>8
	PHI R6
	LDI PRINT_FIXED_CONT_2&255
	PLO R6
	SEP R6
PRINT_FIXED_CONT_2:
	IRX
	LDX
	PHI R0
	IRX
	LDX
	PLO R0
	IRX
	LDX
	PHI R3
	IRX
	LDX
	PLO R3
	IRX
	LDX
	PLO R9
	SEP R0
	LBR PRINT_FIXED

DIV_48x32_SIGNED:
	LDI 0
	PHI R15
	LDI DIN05>>8
	PHI R13
	LDI DIN05&255
	PLO R13
	LDN R13
	ANI 128
	LBZ DIV_48x32_NO_NEG_A
	LDI DIN00>>8
	PHI R13
	LDI DIN00&255
	PLO R13
	LDN R13
	XRI 0xFF
	ADI 1
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	LDI 1
	PHI R15
DIV_48x32_NO_NEG_A:
	LDI MIN03>>8
	PHI R13
	LDI MIN03&255
	PLO R13
	LDN R13
	ANI 128
	LBZ DIV_48x32_NO_NEG_B
	LDI MIN03>>8
	PHI R13
	LDI MIN03&255
	PLO R13
	LDN R13
	XRI 0xFF
	ADI 1
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	INC R13
	LDN R13
	XRI 0xFF
	ADCI 0
	STR R13
	GHI R15
	XRI 1
	PHI R15
DIV_48x32_NO_NEG_B:
	GHI R15
	LSKP
DIV_48x32_UNSIGNED:
	LDI 0
	PHI R15
	LDI MRES5>>8
	PHI R13
	LDI MRES5&255
	PLO R13
	SEX R13
	LDI 0
	STXD
	STXD
	STXD
	STXD
	STXD
	STXD
	SEX R1
	GLO R2
	STXD
	GHI R2
	STXD
	GLO R3
	STXD
	GHI R3
	STXD
	GLO R8
	STXD
	GHI R8
	STXD
	GLO R4
	STXD
	GHI R4
	STXD
	GLO R7
	STXD
	GHI R7
	STXD
	
	; Cache negative of second input
	LDI MIN00>>8
	PHI R13
	LDI MIN00&255
	PLO R13
	LDI MIN10>>8
	PHI R7
	LDI MIN10&255
	PLO R7
	LDA R13
	XRI 0xFF
	ADI 1
	STR R7
	INC R7
	LDA R13
	XRI 0xFF
	ADCI 0
	STR R7
	INC R7
	LDA R13
	XRI 0xFF
	ADCI 0
	STR R7
	INC R7
	LDA R13
	XRI 0xFF
	ADCI 0
	STR R7
	; LShift overflow
	LDI 0
	PLO R13
	PHI R13
	PLO R14
	PHI R14
	PLO R15
	; To store result
	PLO R8
	PHI R8
	PLO R10
	PHI R10
	PLO R11
	PHI R11
	; Loop counter
	LDI 48
	PLO R4
DIV_48x32_LOOP:
	; {R11, R10, R8} <<= 1
	GLO R8
	SHL
	PLO R8
	GHI R8
	SHLC
	PHI R8
	GLO R10
	SHLC
	PLO R10
	GHI R10
	SHLC
	PHI R10
	GLO R11
	SHLC
	PLO R11
	GHI R11
	SHLC
	PHI R11
	; {R15.0, R14, R13, DIN} <<= 1
	LDI DIN00>>8
	PHI R2
	LDI DIN00&255
	PLO R2
	LDN R2
	SHL
	STR R2
	INC R2
	LDN R2
	SHLC
	STR R2
	INC R2
	LDN R2
	SHLC
	STR R2
	INC R2
	LDN R2
	SHLC
	STR R2
	INC R2
	LDN R2
	SHLC
	STR R2
	INC R2
	LDN R2
	SHLC
	STR R2
	GLO R13
	SHLC
	PLO R13
	GHI R13
	SHLC
	PHI R13
	GLO R14
	SHLC
	PLO R14
	GHI R14
	SHLC
	PHI R14
	GLO R15
	SHLC
	PLO R15
	; {R7, R3} = {R15.0, R14, R13} - MIN
	LDI MIN10>>8
	PHI R2
	LDI MIN10&255
	PLO R2
	SEX R2
	GLO R13
	ADD
	IRX
	PLO R3
	GHI R13
	ADC
	IRX
	PHI R3
	GLO R14
	ADC
	IRX
	PLO R7
	GHI R14
	ADC
	PHI R7
	GLO R15
	ADCI 0xFF
	SEX R1
	BNF DIV_48x32_LESS_THAN ; if carry set
	; then
	; R15.0 is only used to potentially overflow a single bit during unsigned divisions
	; it will *always* be clear after the subtraction if the result is positive
	; R15.0 = 0
	; {R14, R13} = {R7, R3}
	LDI 0
	PLO R15
	GLO R3
	PLO R13
	GHI R3
	PHI R13
	GLO R7
	PLO R14
	GHI R7
	PHI R14
	; {R11, R10, R8} |= 1
	GLO R8
	ORI 1
	PLO R8
DIV_48x32_LESS_THAN:
	GLO R4
	SMI 1
	PLO R4
	LBNZ DIV_48x32_LOOP
	LDI MRES0>>8
	PHI R2
	LDI MRES0&255
	PLO R2
	GLO R8
	STR R2
	INC R2
	GHI R8
	STR R2
	INC R2
	GLO R10
	STR R2
	INC R2
	GHI R10
	STR R2
	INC R2
	GLO R11
	STR R2
	INC R2
	GHI R11
	STR R2
	; Technically, there is also a remainder in R14, R13, but I don’t need it right now

	GHI R15
	LBZ DIV_48x32_NO_NEG_RES
	LDI MRES0>>8
	PHI R2
	LDI MRES0&255
	PLO R2
	LDN R2
	XRI 0xFF
	ADI 1
	STR R2
	INC R2
	LDN R2
	XRI 0xFF
	ADCI 0
	STR R2
	INC R2
	LDN R2
	XRI 0xFF
	ADCI 0
	STR R2
	INC R2
	LDN R2
	XRI 0xFF
	ADCI 0
	STR R2
	INC R2
	LDN R2
	XRI 0xFF
	ADCI 0
	STR R2
	INC R2
	LDN R2
	XRI 0xFF
	ADCI 0
	STR R2
DIV_48x32_NO_NEG_RES:
	IRX
	LDX
	PHI R7
	IRX
	LDX
	PLO R7
	IRX
	LDX
	PHI R4
	IRX
	LDX
	PLO R4
	IRX
	LDX
	PHI R8
	IRX
	LDX
	PLO R8
	IRX
	LDX
	PHI R3
	IRX
	LDX
	PLO R3
	IRX
	LDX
	PHI R2
	IRX
	LDX
	PLO R2
	SEP R0

	; Square-root of fixed-point number pointed to by R3 (LSB)
SQRT:
	GLO R3
	STXD
	GHI R3
	STXD
	GLO R9
	STXD
	GHI R9
	STXD

	INC R3
	INC R3
	INC R3
	; Initial guess X / 2
	LDN R3
	DEC R3
	SHR
	PHI R4
	LDN R3
	DEC R3
	SHRC
	PLO R4
	LDN R3
	DEC R3
	SHRC
	PHI R9
	LDN R3
	SHRC
	PLO R9

	GLO R0
	STXD
	GHI R0
	STXD
	LDI SQRT_CONT_1&255
	PLO R0
	LDI SQRT_CONT_1>>8
	PHI R0
	SEP R0

SQRT_CONT_1:
	; 4 iterations
	LDI 4
SQRT_LOOP:
	STXD
	; x_n²
	LDI MIN13>>8
	PHI R14
	LDI MIN13&255
	PLO R14
	SEX R14
	GHI R4
	STXD
	GLO R4
	STXD
	GHI R9
	STXD
	GLO R9
	STXD
	GHI R4
	STXD
	GLO R4
	STXD
	GHI R9
	STXD
	GLO R9
	STXD
	SEX R1
	LDI MUL_32x32_SIGNED>>8
	PHI R6
	LDI MUL_32x32_SIGNED&255
	PLO R6
	SEP R6
	; -x_n²
	LDI MRES2>>8
	PHI R10
	LDI MRES2&255
	PLO R10
	LDN R10
	XRI 0xFF
	ADI 1
	PLO R13
	INC R10
	LDN R10
	XRI 0xFF
	ADCI 0
	PHI R13
	INC R10
	LDN R10
	XRI 0xFF
	ADCI 0
	PLO R14
	INC R10
	LDN R10
	XRI 0xFF
	ADCI 0
	PHI R14
	; S + (-x_n²)
	LDI DIN00>>8
	PHI R10
	LDI DIN00&255
	PLO R10
	LDI 0
	STR R10
	INC R10
	STR R10
	INC R10
	SEX R3
	GLO R13
	ADD
	STR R10
	INC R10
	INC R3
	GHI R13
	ADC
	STR R10
	INC R10
	INC R3
	GLO R14
	ADC
	STR R10
	INC R10
	INC R3
	GHI R14
	ADC
	STR R10
	INC R10
	DEC R3
	DEC R3
	DEC R3
	SEX R1
	; 2x_n
	LDI MIN00>>8
	PHI R10
	LDI MIN00&255
	PLO R10
	GLO R9
	SHL
	STR R10
	INC R10
	GHI R9
	SHLC
	STR R10
	INC R10
	GLO R4
	SHLC
	STR R10
	INC R10
	GHI R4
	SHLC
	STR R10
	INC R10
	; a_n =  [S + (-x_n²)] / [2x_n]
	LDI DIV_48x32_SIGNED>>8
	PHI R6
	LDI DIV_48x32_SIGNED&255
	PLO R6
	SEP R6
	; x_n + a_n
	LDI MRES0>>8
	PHI R10
	LDI MRES0&255
	PLO R10
	LDI SQRT_RESULT0>>8
	PHI R11
	LDI SQRT_RESULT0&255
	PLO R11
	SEX R10
	GLO R9
	ADD
	STR R11
	LDX
	PLO R7
	IRX
	INC R11
	GHI R9
	ADC
	STR R11
	LDX
	PHI R7
	IRX
	INC R11
	GLO R4
	ADC
	STR R11
	LDX
	PLO R14
	IRX
	INC R11
	GHI R4
	ADC
	STR R11
	LDX
	PHI R14
	SEX R1
	; a_n²
	LDI MIN13>>8
	PHI R12
	LDI MIN13&255
	PLO R12
	SEX R12
	GHI R14
	STXD
	GLO R14
	STXD
	GHI R7
	STXD
	GLO R7
	STXD
	GHI R14
	STXD
	GLO R14
	STXD
	GHI R7
	STXD
	GLO R7
	STXD
	SEX R1
	LDI MUL_32x32_SIGNED>>8
	PHI R6
	LDI MUL_32x32_SIGNED&255
	PLO R6
	SEP R6
	LDI MRES2>>8
	PHI R10
	LDI MRES2&255
	PLO R10
	LDI DIN00>>8
	PHI R11
	LDI DIN00&255
	PLO R11
	LDI 0
	STR R11
	INC R11
	STR R11
	INC R11
	LDA R10
	STR R11
	INC R11
	LDA R10
	STR R11
	INC R11
	LDA R10
	STR R11
	INC R11
	LDA R10
	STR R11
	INC R11
	; 2[x_n + a_n]
	LDI SQRT_RESULT0&255
	PLO R10
	LDI SQRT_RESULT0>>8
	PHI R10
	LDI MIN00&255
	PLO R11
	LDI MIN00>>8
	PHI R11
	LDA R10
	SHL
	STR R11
	INC R11
	LDA R10
	SHLC
	STR R11
	INC R11
	LDA R10
	SHLC
	STR R11
	INC R11
	LDA R10
	SHLC
	STR R11
	INC R11
	; t_n = [a_n²]/[2(x_n + a_n)]
	LDI DIV_48x32_SIGNED>>8
	PHI R6
	LDI DIV_48x32_SIGNED&255
	PLO R6
	SEP R6
	; -t_n
	LDI MRES0&255
	PLO R10
	LDI MRES0>>8
	PHI R10
	LDA R10
	XRI 0xFF
	ADI 1
	PLO R11
	LDA R10
	XRI 0xFF
	ADCI 0
	PHI R11
	LDA R10
	XRI 0xFF
	ADCI 0
	PLO R12
	LDN R10
	XRI 0xFF
	ADCI 0
	PHI R12
	; x_(n+1) = [x_n + a_n] + [-t_n]
	LDI SQRT_RESULT0>>8
	PHI R10
	LDI SQRT_RESULT0&255
	PLO R10
	SEX R10
	GLO R11
	ADD
	PLO R9
	IRX
	GHI R11
	ADC
	PHI R9
	IRX
	GLO R12
	ADC
	PLO R4
	IRX
	GHI R12
	ADC
	PHI R4
	SEX R1

	; Loop end
	IRX
	LDX
	SMI 1
	LBNZ SQRT_LOOP

SQRT_LOOP_OVER:
	LDI SQRT_RESULT0>>8
	PHI R10
	LDI SQRT_RESULT0&255
	PLO R10
	GLO R9
	STR R10
	INC R10
	GHI R9
	STR R10
	INC R10
	GLO R4
	STR R10
	INC R10
	GHI R4
	STR R10
	INC R10

	LDI SQRT_CONT_2&255
	PLO R6
	LDI SQRT_CONT_2>>8
	PHI R6
	SEP R6
SQRT_CONT_2:
	IRX
	LDX
	PHI R0
	IRX
	LDX
	PLO R0
	; Pop & Return
	IRX
	LDX
	PHI R9
	IRX
	LDX
	PLO R9
	IRX
	LDX
	PHI R3
	IRX
	LDX
	PLO R3
	SEP R0

TEST_MUL:
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2
	LDI MIN13>>8
	PHI R3
	LDI MIN13&255
	PLO R3
	LDI 0x01
	STR R3
	DEC R3
	LDI 0x2B
	STR R3
	DEC R3
	LDI 0xD0
	STR R3
	DEC R3
	LDI 0x08
	STR R3
	DEC R3
	LDI 0x00
	STR R3
	DEC R3
	LDI 0x3F
	STR R3
	DEC R3
	LDI 0x12
	STR R3
	DEC R3
	LDI 0xAB
	STR R3
	
	LDI MIN10>>8
	PHI R3
	LDI MIN10&255
	PLO R3
	LDI PRINTINT32>>8
	PHI R6
	LDI PRINTINT32&255
	PLO R6
	SEP R6
	LDI 0xF5
	PLO R9
	LDI '*'
	STR R9
	SEP R2
	LDI MIN00>>8
	PHI R3
	LDI MIN00&255
	PLO R3
	SEP R6
	LDI 0xF5
	PLO R9
	LDI '='
	STR R9
	SEP R2
	
	LDI MUL_32x32_UNSIGNED>>8
	PHI R6
	LDI MUL_32x32_UNSIGNED&255
	PLO R6
	SEP R6
	
	LDI MRES0>>8
	PHI R3
	LDI MRES0&255
	PLO R3
	LDI 8
	PLO R4
	LDI PRINTINT64>>8
	PHI R6
	LDI PRINTINT64&255
	PLO R6
	SEP R6
	LDI 0xF5
	PLO R9
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2
	
	LDI 0
	PLO R5
FIXED_TEST_LOOP:
	LDI FIXED_TEST_NUMS&255
	STXD
	IRX
	GLO R5
	ADD
	PLO R7
	LDI FIXED_TEST_NUMS>>8
	ADCI 0
	PHI R7
	
	GHI R7
	PHI R3
	GLO R7
	PLO R3
	LDI PRINT_FIXED>>8
	PHI R6
	LDI PRINT_FIXED&255
	PLO R6
	SEP R6
	LDI '*'
	STR R9
	SEP R2
	GLO R7
	ADI 4
	PLO R3
	GHI R7
	ADCI 0
	PHI R3
	SEP R6
	LDI '='
	STR R9
	SEP R2
	
	LDI MIN00>>8
	PHI R3
	LDI MIN00&255
	PLO R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	
	STR R3
	LDI MUL_32x32_SIGNED>>8
	PHI R6
	LDI MUL_32x32_SIGNED&255
	PLO R6
	SEP R6
	
	LDI MRES5&255
	PLO R3
	LDI MRES5>>8
	PHI R3
	LDN R3
	DEC R3
	STXD
	LDN R3
	DEC R3
	STXD
	LDN R3
	DEC R3
	STXD
	LDN R3
	STXD
	LDI PRINT_FIXED>>8
	PHI R6
	LDI PRINT_FIXED&255
	PLO R6
	SEP R6
	LDI ' '
	STR R9
	SEP R2
	LDI '('
	STR R9
	SEP R2
	LDI MRES2&255
	PLO R3
	LDI MRES2>>8
	PHI R3
	IRX
	LDX
	STR R3
	INC R3
	IRX
	LDX
	STR R3
	INC R3
	IRX
	LDX
	STR R3
	INC R3
	IRX
	LDX
	STR R3
	LDI 4
	PLO R4
	LDI PRINT_HEX>>8
	PHI R6
	LDI PRINT_HEX&255
	PLO R6
	SEP R6
	LDI 0xF5
	PLO R9
	LDI ')'
	STR R9
	SEP R2
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2
	
	GLO R5
	ADI 8
	PLO R5
	SMI 32
	LBNZ FIXED_TEST_LOOP
	
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2
DIVTEST:
	LDI DIN05>>8
	PHI R15
	LDI DIN05&255
	PLO R15
	SEX R15
	LDI 0
	STXD
	STXD
	LDI 0x01
	STXD
	LDI 0x3A
	STXD
	LDI 0x2C
	STXD
	LDI 0x39
	STXD
	LDI MIN03>>8
	PHI R15
	LDI MIN03&255
	PLO R15
	LDI 0
	STXD
	STXD
	LDI 0x01
	STXD
	LDI 0x69
	STXD
	SEX R1
	LDI PRINTINT32>>8
	PHI R6
	LDI PRINTINT32&255
	PLO R6
	LDI DIN00>>8
	PHI R3
	LDI DIN00&255
	PLO R3
	SEP R6
	LDI '/'
	STR R9
	SEP R2
	LDI MIN00>>8
	PHI R3
	LDI MIN00&255
	PLO R3
	SEP R6
	LDI '='
	STR R9
	SEP R2
	LDI DIV_48x32_SIGNED>>8
	PHI R6
	LDI DIV_48x32_SIGNED&255
	PLO R6
	SEP R6
	LDI PRINTINT32>>8
	PHI R6
	LDI PRINTINT32&255
	PLO R6
	LDI MRES0>>8
	PHI R3
	LDI MRES0&255
	PLO R3
	SEP R6
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2

	LDI 0
	PLO R5
FIXED_TEST_LOOP2:
	LDI FIXED_TEST_NUMS&255
	STXD
	IRX
	GLO R5
	ADD
	PLO R7
	LDI FIXED_TEST_NUMS>>8
	ADCI 0
	PHI R7
	
	GHI R7
	PHI R3
	GLO R7
	PLO R3
	LDI PRINT_FIXED>>8
	PHI R6
	LDI PRINT_FIXED&255
	PLO R6
	SEP R6
	LDI '/'
	STR R9
	SEP R2
	GLO R7
	ADI 4
	PLO R3
	GHI R7
	ADCI 0
	PHI R3
	SEP R6
	LDI '='
	STR R9
	SEP R2
	
	LDI DIN00>>8
	PHI R3
	LDI DIN00&255
	PLO R3
	LDI 0
	STR R3
	INC R3
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	LDI MIN00>>8
	PHI R3
	LDI MIN00&255
	PLO R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3
	INC R3
	LDA R7
	STR R3

	LDI DIV_48x32_SIGNED>>8
	PHI R6
	LDI DIV_48x32_SIGNED&255
	PLO R6
	SEP R6
	
	LDI MRES3&255
	PLO R3
	LDI MRES3>>8
	PHI R3
	LDN R3
	DEC R3
	STXD
	LDN R3
	DEC R3
	STXD
	LDN R3
	DEC R3
	STXD
	LDN R3
	STXD
	LDI PRINT_FIXED>>8
	PHI R6
	LDI PRINT_FIXED&255
	PLO R6
	SEP R6
	LDI ' '
	STR R9
	SEP R2
	LDI '('
	STR R9
	SEP R2
	LDI MRES2&255
	PLO R3
	LDI MRES2>>8
	PHI R3
	IRX
	LDX
	STR R3
	INC R3
	IRX
	LDX
	STR R3
	INC R3
	IRX
	LDX
	STR R3
	INC R3
	IRX
	LDX
	STR R3
	LDI 4
	PLO R4
	LDI PRINT_HEX>>8
	PHI R6
	LDI PRINT_HEX&255
	PLO R6
	SEP R6
	LDI 0xF5
	PLO R9
	LDI ')'
	STR R9
	SEP R2
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2
	
	GLO R5
	ADI 8
	PLO R5
	SMI 32
	LBNZ FIXED_TEST_LOOP2

	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2
SQRT_TEST:
	LDI 0
	PLO R5
SQRT_TEST_LOOP:
	LDI FIXED_TEST_NUMS&255
	STXD
	IRX
	GLO R5
	ADD
	PLO R3
	LDI FIXED_TEST_NUMS>>8
	ADCI 0
	PHI R3

	INC R3
	INC R3
	INC R3
	LDN R3
	ANI 128
	LBNZ SQRT_TEST_SKIP
	DEC R3
	DEC R3
	DEC R3

	LDI 's'
	STR R9
	SEP R2
	LDI 'q'
	STR R9
	SEP R2
	LDI 'r'
	STR R9
	SEP R2
	LDI 't'
	STR R9
	SEP R2
	LDI '('
	STR R9
	SEP R2
	LDI PRINT_FIXED>>8
	PHI R6
	LDI PRINT_FIXED&255
	PLO R6
	SEP R6
	LDI ')'
	STR R9
	SEP R2
	LDI '='
	STR R9
	SEP R2

	LDI SQRT>>8
	PHI R6
	LDI SQRT&255
	PLO R6
	SEP R6
	LDI SQRT_RESULT0>>8
	PHI R3
	LDI SQRT_RESULT0&255
	PLO R3
	LDI PRINT_FIXED>>8
	PHI R6
	LDI PRINT_FIXED&255
	PLO R6
	SEP R6
	LDI 13
	STR R9
	SEP R2
	LDI 10
	STR R9
	SEP R2

SQRT_TEST_SKIP:
	GLO R5
	ADI 4
	PLO R5
	SMI 28
	LBNZ SQRT_TEST_LOOP
	
FROM_RAM:
	LDI RAMCODE>>8
	PHI R3
	LDI RAMCODE&255
	PLO R3
	LDI 0x80
	PHI R4
	LDI 0x00
	PLO R4
FROM_RAM_SETUP_LOOP:
	LDA R3
	STR R4
	INC R4
	GLO R3
	XRI BEGIN_DATA&255
	BNZ FROM_RAM_SETUP_LOOP
	GHI R3
	XRI BEGIN_DATA>>8
	BNZ FROM_RAM_SETUP_LOOP
	
	LDI 0x80
	PHI R4
	LDI 0x00
	PLO R4
	SEP R4
	
	LBR END

RAMCODE:
	LDI 0x80
	PHI R3
	LDI 0x1B
	PLO R3
	; +6h
	LDI 0xF5
	PLO R9
	LDA R3
	LBZ 0x801A
	STR R9
	LDI 0xF3
	PLO R9
	; +11h
	LDN R9
	ANI 4
	LBNZ 0x8011
	LBR 0x8006
	; +1Ah
	SEP R0
	; +1Bh
	db 10
	db 13
	db 'Hi from RAM!'
	db 13
	db 10
	db 13
	db 10
	db 0
BEGIN_DATA:
	db 0
	; End of code, begin data
HELLO_TEXT:
	db 10
	db 13
	db 'Hello from TinyTapeout 3.5!'
	db 13
	db 10
	db 0
HEX_DIGITS:
	db '0123456789ABCDEF'
PRINTINT32_DIVS:
	; -1000000000
	db 0x00, 0x36, 0x65, 0xC4
	; -100000000
	db 0x00, 0x1F, 0x0A, 0xFA
	; -10000000
	db 0x80, 0x69, 0x67, 0xFF
	; -1000000
	db 0xC0, 0xBD, 0xF0, 0xFF
	; -100000
	db 0x60, 0x79, 0xFE, 0xFF
	; -10000
	db 0xF0, 0xD8, 0xFF, 0xFF
	; -1000
	db 0x18, 0xFC, 0xFF, 0xFF
	; -100
	db 0x9C, 0xFF, 0xFF, 0xFF
	; -10
	db 0xF6, 0xFF, 0xFF, 0xFF
	; -1
	db 0xFF, 0xFF, 0xFF, 0xFF
PRINTINT64_DIVS:
	; -1000000000000000000
	db 0x00, 0x00, 0x9C, 0x58, 0x4C, 0x49, 0x1F, 0xF2
	; -100000000000000000
	db 0x00, 0x00, 0x76, 0xA2, 0x87, 0xBA, 0x9C, 0xFE
	; -10000000000000000
	db 0x00, 0x00, 0x3F, 0x90, 0x0D, 0x79, 0xDC, 0xFF
	; -1000000000000000
	db 0x00, 0x80, 0x39, 0x5B, 0x81, 0x72, 0xFC, 0xFF
	; -100000000000000
	db 0x00, 0xC0, 0x85, 0xEF, 0x0C, 0xA5, 0xFF, 0xFF
	; -10000000000000
	db 0x00, 0x60, 0x8D, 0xB1, 0xE7, 0xF6, 0xFF, 0xFF
	; -1000000000000
	db 0x00, 0xF0, 0x5A, 0x2B, 0x17, 0xFF, 0xFF, 0xFF
	; -100000000000
	db 0x00, 0x18, 0x89, 0xB7, 0xE8, 0xFF, 0xFF, 0xFF
	; -10000000000
	db 0x00, 0x1C, 0xF4, 0xAB, 0xFD, 0xFF, 0xFF, 0xFF
	; -1000000000
	db 0x00, 0x36, 0x65, 0xC4, 0xFF, 0xFF, 0xFF, 0xFF
	; -100000000
	db 0x00, 0x1F, 0x0A, 0xFA, 0xFF, 0xFF, 0xFF, 0xFF
	; -10000000
	db 0x80, 0x69, 0x67, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -1000000
	db 0xC0, 0xBD, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -100000
	db 0x60, 0x79, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -10000
	db 0xF0, 0xD8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -1000
	db 0x18, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -100
	db 0x9C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -10
	db 0xF6, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	; -1
	db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
FIXED_TEST_NUMS:
	db 0x08, 0xD0, 0x2B, 0x01, 0xAD, 0x39, 0x00, 0x00
	db 0x12, 0x8D, 0x95, 0xFA, 0xFF, 0x63, 0x10, 0x00
	db 0x3F, 0x24, 0x03, 0x00, 0x00, 0x00, 0x02, 0x00
	db 0xAD, 0xDF, 0x02, 0x00, 0xAD, 0xDF, 0x02, 0x00
