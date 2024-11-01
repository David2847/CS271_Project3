TITLE Temperature Statistics Calculator     (Proj3_jantzd.asm)

; Author: David Jantz
; Last Modified: 11/1/2024
; OSU email address: jantzd@oregonstate.edu
; Course number/section:   CS271
; Project Number: 3                Due Date: 11/3/2024
; Description: This project collects temperature information from the
;				user within a certain range and calculates some statistics
;				based on that information.

INCLUDE Irvine32.inc

; (insert macro definitions here)

NUM_TEMPS = 7

.data

	programTitle			BYTE	"Temperature Statistics Calculator",13,10,0
	attribution				BYTE	"Created by David Jantz",13,10,0
	enterNameInstruction	BYTE	"Enter your name: ",0
	userName				BYTE	33 DUP(0) ; 33 bytes allocated
	greeting1				BYTE	"Hi there, ",0
	greeting2				BYTE	"! Thanks for participating!",13,10,0
	instruction1			BYTE	"Enter seven temperature readings in Celsius.",13,10,0
	instruction2			BYTE	"Make sure temperatures are integers in the range [-30, 50] inclusive.",13,10,0
	instruction3			BYTE	"Several statistics will be calculated and displayed for your enjoyment :)",13,10,0
	tempReading				BYTE	"Temperature #",0
	tempNumber				DWORD	? ; to be calculated and changed several times
	colon					BYTE	": ",0
	invalidRangeMessage		BYTE	"Bro, can't you follow directions? Enter a value in the valid range...",13,10,0
	cold					DWORD	0
	cool					DWORD	0
	warm					DWORD	0
	hot 					DWORD	0

.code
main PROC
	
	; Introduction -- Display program title and programmer's name
	MOV		EDX, OFFSET programTitle
	CALL	writeString
	MOV		EDX, OFFSET attribution
	CALL	writeString

	; Get user information
	CALL	CrLf
	MOV		EDX, OFFSET enterNameInstruction
	CALL	writeString
	MOV		EDX, OFFSET userName
	MOV		ECX, SIZEOF userName - 1 ; specify max size of input string
	CALL	readString

	; Greet user
	MOV		EDX, OFFSET greeting1
	CALL	writeString
	MOV		EDX, OFFSET userName
	CALL	writeString
	MOV		EDX, OFFSET greeting2
	CALL	writeString

	; Display instructions
	CALL	CrLf
	MOV		EDX, OFFSET instruction1
	CALL	writeString
	MOV		EDX, OFFSET instruction2
	CALL	writeString
	MOV		EDX, OFFSET instruction3
	CALL	writeString
	CALL	CrLf
	
	; Collect temperature readings
	MOV		ECX, NUM_TEMPS
	_CollectDatum:
		MOV		EDX, OFFSET tempReading
		CALL	writeString
		MOV		EAX, NUM_TEMPS ; Begin performing subtraction to tell user which temperature reading this is
		SUB		EAX, ECX
		ADD		EAX, 1
		CALL	WriteDec
		MOV		EDX, OFFSET colon
		CALL	WriteString
		CALL	readInt ; writes signed integer to EAX
	
	; Validate user input as within acceptable range
	CMP		EAX, -30 ; if less than -30, reject and jump back to data collection
	JL		_BadInput
	CMP		EAX, 50 ; if greater than 50, reject and jump back to data collection
	JG		_BadInput
	JMP		_GoodInput ; input must be within range
	
	; Handle out of range inputs with error message and repeat that temp reading
	_BadInput:
		MOV		EDX, OFFSET invalidRangeMessage
		CALL	WriteString
		JMP		_CollectDatum

	; Valid range inputs prompt decrease of loop counter, data binning, and stats calculations
	_GoodInput:
		CMP		EAX, 0 ; if less than 0, inc cold and jump to end or repeat data
		JL		_IncreaseColdCount
		CMP		EAX, 16 ; if less than 16, inc cool and jump
		JL		_IncreaseCoolCount
		CMP		EAX, 31 ; if less than 31, inc warm and jump
		JL		_IncreaseWarmCount
		JMP		_IncreaseHotCount; inc hot and jump

	_IncreaseColdCount:
		INC		cold
		DEC		ECX
		JNZ		_CollectDatum
		JMP		_End ; jump to end if loop is complete

	_IncreaseCoolCount:
		INC		cool
		DEC		ECX
		JNZ		_CollectDatum
		JMP		_End ; jump to end if loop is complete

	_IncreaseWarmCount:
		INC		warm
		DEC		ECX
		JNZ		_CollectDatum
		JMP		_End ; jump to end if loop is complete

	_IncreaseHotCount:
		INC		hot
		DEC		ECX
		JNZ		_CollectDatum
		JMP		_End ; jump to end if loop is complete
		
	_End:
		Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
