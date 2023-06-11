TITLE Minesweeper (Minesweeper.asm)

; Author(s) : Kaitlyn Laurie, Steve Akiyama
; Course / Project ID Date : 6 / 10 / 2023
; Description: Computes composite numbers.

INCLUDE Irvine32.inc

.data

welcome BYTE "Welcome to Minesweeper, by Kaitlyn Laurie and Steve Akiyama.", 0
instructions_1 BYTE "Please input the board size you would like.", 0
instructions_2 BYTE "(Enter a number between 8 and 30): ", 0
goodbye BYTE "Thank you for playing Minesweeper! Goodbye!", 0

unvisitedCell   DWORD 0

boardsize DWORD 64
boardlength DWORD 8
minecount DWORD 16
game_state DWORD 1

; constants
BOARD_MINSIZE = 8
BOARD_MAXSIZE = 30
MAX_BOARDSIZE = 900

; Array
board		DWORD MAX_BOARDSIZE Dup(10)

;display characters
space1		BYTE   "     ", 0
line		BYTE   " | ", 0
underscore  BYTE   "---", 0
space2         BYTE   " ", 0
mine		BYTE   "*", 0


.code
main PROC

	call introduction
	call getData

	mov eax, boardsize
	push eax
	mov eax, minecount
	push eax
	call generation

	mov ESI, OFFSET board
	gameLoop:
		call userInput
		call checkLocation
		call checkWin

		push OFFSET board
		push game_state
		push boardlength
		call DisplayBoard
		
		; Some form of jump to gameLoop if checkWin is false

	call farewell

exit
main ENDP

;******************************************************************************************************
; INTRODUCTION PROCEDURE :
; Description:		 Procedure to give the user instructions and an introduction to the program.
; Receives:			 welcome, instructions_1, and instructions_2 are global variables
; Returns:		     nothing
; Preconditions:	 welcome, instructions_1, and instructions_2 must be set to strings
; Registers Changed : edx,
; ******************************************************************************************************

introduction PROC
	call Randomize
	call CrLf
	mov edx, OFFSET welcome
	call WriteString
	call CrLf

	mov	edx, OFFSET instructions_1
	call WriteString
	call CrLf
	ret

introduction ENDP

getData PROC
	pushad
	getInputs:
		mov	edx, OFFSET instructions_2
		call WriteString
		call crlf
		call ReadInt
		cmp eax, BOARD_MINSIZE
		jl getInputs
		cmp eax, BOARD_MAXSIZE
		jg getInputs
		mov boardlength, eax
		mul boardlength
		mov boardsize, eax
	popad
	ret
getData ENDP

generation PROC
	mov ebp, esp
	mov ecx, [ebp + 4] ;Address of how many mines to generate
	mov ebx, [ebp + 8] ;Address of how many tiles are available
	pushad

	generateMineLoop:
		mov eax, ebx
		call RandomRange
		cmp board[eax * 4], 10
		je nextMine
		jmp generateMineLoop
	nextMine:
		mov board[eax * 4], 9
		loop generateMineLoop

	popad
	ret
generation ENDP

userInput PROC
	
	ret
userInput ENDP

checkLocation PROC
	ret
checkLocation ENDP

checkWin PROC
	ret
checkWin ENDP

;******************************************************************************************************
; DisplayBoard PROCEDURE :
; Description:		 display the state of game on screen
; Receives:		     game_state:   1 if user is alive
;					 board:        array of values representing board
;					 board_length: n for board size n x n
; Returns:			 nothing
; Preconditions:	 board is initialized
; Registers Changed : N / A
; ******************************************************************************************************

DisplayBoard PROC
	push EBP
	mov EBP, ESP
	pushad

	mov EBX, [EBP + 12]  ;game_state in EBX
	mov ECX, [EBP + 8]   ;boardlength in ECX

	mov EAX, 1 ;starting index

	;whitespace
	mov EDX, OFFSET space1
	call WriteString
	mov EDX, OFFSET line
	call WriteString

	displayTop :
		call WriteDec
		mov EDX, OFFSET space2
		call WriteString
		mov EDX, OFFSET line
		call WriteString
		inc EAX
		loop displayTop

	call crlf
	mov ECX, [EBP + 8]; boardlength in ECX
	mov EDX, OFFSET space1
	call WriteString
	mov EDX, OFFSET space2
	call WriteString

	displayTopBorder :
		mov EDX, OFFSET space2
		call WriteString
		mov EDX, OFFSET underscore
		call WriteString
		mov EDX, OFFSET space2
		call WriteString
		loop displayTopBorder


	mov ECX, [EBP + 8]  ;boardsize in ECX
	mov EDX, 1           ;index counter
	mov EDI, 0

	outerLoop:
		call crlf
		
		;side display
		mov EAX, EDX
		call WriteDec
		push EDX
		mov EDX, OFFSET line
		call WriteString
		mov EDX, OFFSET space2
		call WriteString
		mov EDX, OFFSET line
		call WriteString
		pop EDX

		;set up inner loop counter
		push ECX
		mov ECX, [EBP + 8]

		innerLoop:
			;value check control structure
			mov EAX, [ESI]
			call WriteDec
			cmp EAX, 0
			je unvisited
			cmp EAX, 9
			jl cleared

			;check if game is over
			cmp EBX, 1
			jl gameOver

			unvisited :
				;display mine on unfinished game as empty or unvisited block
				push EDX
				mov EDX, OFFSET space2
				call WriteString
				mov EDX, OFFSET line
				call WriteString
				pop EDX

				jmp endOfLoop

			endOfLoop :
				add ESI, 4
				loop innerLoop

				; go into outer loop
				inc EDX
				pop ECX
				loop outerLoop
				jmp endOfProc

			cleared :
				call WriteDec
				mov EDX, OFFSET line
				call WriteString
				jmp endOfLoop

			gameOver :
				push EDX
				mov EDX, OFFSET mine
				call WriteString
				mov EDX, OFFSET line
				call WriteString
				pop EDX
				jmp endOfLoop

	

	endOfProc:
		popad
		pop EBP
		ret 16
DisplayBoard ENDP




;******************************************************************************************************
; FAREWELL PROCEDURE :
; Description:		 Procedure to say goodbye to the user.
; Receives:		     goodbye is global variables.
; Returns:			 nothing
; Preconditions:	 goodbyte must be set to strings.
; Registers Changed : edx,
; ******************************************************************************************************

farewell PROC
	; say goodbye

	call CrLf
	mov	edx, OFFSET goodbye
	call WriteString
	call CrLf
	call CrLf
	exit
farewell ENDP

END main