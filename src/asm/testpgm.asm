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
	
	org 0
	NOP
	LDI 0xFF
	PHI R9
	LDI 0b11110001
	PLO R9
	SEX R9
	LDI 0
	STXD
	LDI 8
	STR R9
	LDI 0x57
	INC R9
	INC R9
	STXD
START:
	SEQ
	NOP
	NOP
	REQ
	LBR START
