TITLE Temperature Statistics Calculator     (Proj3_jantzd.asm)

; Author: David Jantz
; Last Modified: 11/3/2024
; OSU email address: jantzd@oregonstate.edu
; Course number/section:   CS271
; Project Number: 3                Due Date: 11/3/2024
; Description: This project collects temperature information from the
;				user within a certain range and calculates some statistics
;				based on that information.

INCLUDE Irvine32.inc

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
	colon					BYTE	": ",0
	invalidRangeMessage		BYTE	"Bro, can't you follow directions? Enter a value in the valid range...",13,10,0
	maxAllowedTemp			SDWORD	50
	minAllowedTemp			SDWORD	-30
	maxRecordedTemp			SDWORD	-30 ; start at the lowest value to ensure it does not exceed actual user input
	minRecordedTemp			SDWORD	50 ; same idea as above
	coldThreshold			SDWORD -1
	coolThreshold			SDWORD	15
	warmThreshold			SDWORD	30
	coldDays				DWORD	0
	coolDays				DWORD	0
	warmDays				DWORD	0
	hotDays			    	DWORD	0
	mean					SDWORD	?
	maxTempMessage			BYTE	"The maximum valid temperature reading was ",0
	minTempMessage			BYTE	"The minimum valid temperature reading was ",0
	meanTempMessage			BYTE	"The average temperature was ",0
	coldDaysMessage			BYTE	"Number of cold days: ",0
	coolDaysMessage			BYTE	"Number of cool days: ",0
	warmDaysMessage			BYTE	"Number of warm days: ",0
	hotDaysMessage			BYTE	"Number of hot days: ",0
	partingMessage			BYTE	", thanks for playing :) Have a great day!",0


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
	MOV		ECX, SIZEOF userName - 1	; specify max size of input string
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
	
	; Housekeeping prior to temperature collection
	MOV		ECX, NUM_TEMPS
	MOV		EBX, 0						; start EBX accumulator at zero

	; Collect a single data point from user
	_CollectDatum:
		MOV		EDX, OFFSET tempReading
		CALL	writeString
		MOV		EAX, NUM_TEMPS			; Begin performing subtraction to tell user which temperature reading this is
		SUB		EAX, ECX
		ADD		EAX, 1
		CALL	WriteDec
		MOV		EDX, OFFSET colon
		CALL	WriteString
		CALL	readInt					; writes signed integer to EAX
	
	; Validate user input as within acceptable range
	CMP		EAX, minAllowedTemp			; if less than -30, reject and jump back to data collection
	JL		_BadInput
	CMP		EAX, maxAllowedTemp			; if greater than 50, reject and jump back to data collection
	JG		_BadInput
	JMP		_GoodInput					; input must be within range
	
	; Handle out of range inputs with error message and repeat that temp reading
	_BadInput:
		MOV		EDX, OFFSET invalidRangeMessage
		CALL	WriteString
		JMP		_CollectDatum

	; Valid range inputs prompt decrease of loop counter, data binning, and stats calculations
	_GoodInput:
		ADD		EBX, EAX				; tally up temps in accumulator for average calculations
		CMP		EAX, maxRecordedTemp
		JLE		_CheckMin
		MOV		maxRecordedTemp, EAX
		_CheckMin:
			CMP		EAX, minRecordedTemp
			JGE		_IncreaseCategoryCounts
			MOV		minRecordedTemp, EAX
			
		_IncreaseCategoryCounts:
			CMP		EAX, coldThreshold	; if less than 0, inc cold and jump to end or repeat data
			JLE		_IncreaseColdCount
			CMP		EAX, coolThreshold	; if less than 16, inc cool and jump
			JLE		_IncreaseCoolCount
			CMP		EAX, warmThreshold	; if less than 31, inc warm and jump
			JLE		_IncreaseWarmCount
			JMP		_IncreaseHotCount	; inc hot and jump

	_IncreaseColdCount:
		INC		coldDays
		DEC		ECX
		JNZ		_CollectDatum			; repeat loop if less than 7 data points are collected
		JMP		_CalculateAverage		; jump to end if loop is complete

	_IncreaseCoolCount:
		INC		coolDays
		DEC		ECX
		JNZ		_CollectDatum			; repeat loop if less than 7 data points are collected
		JMP		_CalculateAverage		; jump to end if loop is complete

	_IncreaseWarmCount:
		INC		warmDays
		DEC		ECX
		JNZ		_CollectDatum			; repeat loop if less than 7 data points are collected
		JMP		_CalculateAverage		; jump to end if loop is complete

	_IncreaseHotCount:
		INC		hotDays
		DEC		ECX
		JNZ		_CollectDatum			; repeat loop if less than 7 data points are collected
		JMP		_CalculateAverage		; jump to end if loop is complete

	_CalculateAverage:
		MOV		EAX, EBX
		CDQ								; apparently conversion to DQWORD is necessary for 32-bit division with IDIV
		MOV		ECX, 7
		IDIV	ECX						; Divide by 7. EAX holds quotient, EDX holds remainder

		; Round average to nearest int. n.5 always goes to the right on the number line
		CMP		EDX, 3						; if remainder is greater than 3, add one to round positive number up
		JG		_RoundUp
		CMP		EDX, -3						; if remainder is less than -3, subtract one
		JL		_RoundDown
		JMP		_StoreMean					; otherwise we don't need to modify average at all
		_Roundup:
			INC		EAX
			JMP		_StoreMean
		_RoundDown:
			DEC		EAX
		_StoreMean:
			MOV		mean, EAX

	; Display temperature statistics
	CALL	CrLf
	MOV		EDX, OFFSET maxTempMessage
	CALL	WriteString
	MOV		EAX, maxRecordedTemp
	CALL	WriteInt
	CALL	CrLf
	MOV		EDX, OFFSET minTempMessage
	CALL	WriteString
	MOV		EAX, minRecordedTemp
	CALL	WriteInt
	CALL	CrLf
	MOV		EDX, OFFSET meanTempMessage
	CALL	WriteString
	MOV		EAX, mean
	CALL	WriteInt
	CALL	CrLf
	MOV		EDX, OFFSET coldDaysMessage
	CALL	WriteString
	MOV		EAX, coldDays
	CALL	WriteDec
	CALL	CrLf
	MOV		EDX, OFFSET coolDaysMessage
	CALL	WriteString
	MOV		EAX, coolDays
	CALL	WriteDec
	CALL	CrLf
	MOV		EDX, OFFSET warmDaysMessage
	CALL	WriteString
	MOV		EAX, warmDays
	CALL	WriteDec
	CALL	CrLf
	MOV		EDX, OFFSET hotDaysMessage
	CALL	WriteString
	MOV		EAX, hotDays
	CALL	WriteDec
	CALL	CrLf

	; Parting message
	CALL	CrLf
	MOV		EDX, OFFSET userName
	CALL	WriteString
	MOV		EDX, OFFSET partingMessage
	CALL	WriteString
	CALL	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
