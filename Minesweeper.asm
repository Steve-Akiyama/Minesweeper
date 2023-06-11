TITLE Minesweeper(Minesweeper.asm)

; Author(s) : Kaitlyn Laurie, Steve Akiyama
; Course / Project ID Date : 6 / 10 / 2023
; Description: Computes composite numbers.

INCLUDE Irvine32.inc

.data

checkR MACRO boardlength
	; Sets eax to address of right
	mov eax, ebx
	inc eax

	; Range check
	cdq
	div boardlength; Dividing to check if it is out of range
endm

checkUR MACRO boardlength
mov eax, ebx
endm

checkU MACRO boardlength
mov eax, ebx
endm

checkUL MACRO boardlength
mov eax, ebx

; Range check
cdq
div boardLength
cmp edx, 0
endm

checkL MACRO boardlength
; Sets eax to starting address
mov eax, ebx

; Range check
cdq
div boardLength; Dividing to check if it is out of range
endm

checkDL MACRO boardlength
mov eax, ebx
add eax, boardlength
endm

checkD MACRO boardlength
mov eax, ebx
add eax, boardlength
endm

checkDR MACRO boardlength
; Sets eax to address of right
mov eax, ebx
inc eax

; Range check(No need to check down, as it is impossible to reach this without checking down)
cdq
div boardLength; Dividing to check if it is out of range
endm



welcome BYTE "Welcome to Minesweeper, by Kaitlyn Laurie and Steve Akiyama.", 0
instructions_1 BYTE "Please input the board size you would like.", 0
instructions_2 BYTE "(Enter a number between 8 and 30): ", 0
instructions_3 BYTE "Please enter the column of the space you'd like to dig.", 0
instructions_4 BYTE "Please enter the row of the space you'd like to dig.", 0
goodbye BYTE "Thank you for playing Minesweeper! Goodbye!", 0

unvisitedCell   DWORD 0

boardsize DWORD 64
boardlength DWORD 8
minecount DWORD 10
game_state DWORD 1
target DWORD ?

; constants
BOARD_MINSIZE = 8
BOARD_MAXSIZE = 30
MAX_BOARDSIZE = 900
MINE_IDX = 9
SPACE_INI = 10

; Array
board		DWORD MAX_BOARDSIZE Dup(SPACE_INI)

; display characters
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
gameLoop :


push OFFSET board
push boardsize
call displayList

; push game_state
; push boardlength
; call DisplayBoard
call userInput
push target
call checkLocation
call checkWin
jmp gameLoop



; Some form of jump to gameLoop if checkWin is false

call farewell

exit
main ENDP

displayList PROC
push ebp
mov  ebp, esp
mov	 ebx, 0
mov  esi, [ebp + 12]
mov	 ecx, [ebp + 8]
displayLoop :
mov		eax, [esi]
call	WriteDec
mov		edx, OFFSET space1
call	WriteString
inc		ebx
cmp		ebx, boardlength
jl		skipCarry
call	CrLf
mov		ebx, 0
skipCarry:
add		esi, 4
loop	displayLoop
endDisplayLoop :
pop		ebp
ret		8
displayList ENDP

; ******************************************************************************************************
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
	getInputs :
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
mov ecx, [ebp + 4]; Address of how many mines to generate
mov ebx, [ebp + 8]; Address of how many tiles are available
pushad

generateMineLoop :
mov eax, ebx
call RandomRange
cmp board[eax * 4], SPACE_INI
je nextMine
jmp generateMineLoop
nextMine :
mov board[eax * 4], MINE_IDX
loop generateMineLoop

popad
ret 8
generation ENDP

userInput PROC
	pushad
	call crlf
	call crlf

	getInput1 : ; Get the column
		mov	edx, OFFSET instructions_3
		call WriteString
		call crlf
		call ReadInt
		cmp eax, 1
		jl getInput1
		cmp eax, boardlength
		jg getInput1
		dec eax
		mov ebx, eax
	getInput2 : ; Get the row
		mov	edx, OFFSET instructions_4
		call WriteString
		call crlf
		call ReadInt
		cmp eax, 1
		jl getInput2
		cmp eax, boardlength
		jg getInput2
		dec eax
		mul boardlength

	add eax, ebx
	mov target, eax

	popad
	ret
userInput ENDP

;******************************************************************************************************
; checkLocation PROCEDURE :
; Description:		 checks a tile and tiles around it if needed, recursively
; Receives:		     n, a 4 byte int noting which tile should be checked initially
; Returns:			 nothing, but updates board
; Preconditions:	 board is initialized
; Registers Changed : N / A
; ******************************************************************************************************

checkLocation PROC
	mov ebp, esp
	pushad
	mov ebx, [ebp + 4]; move target to ebx

	mov eax, ebx
	;call crlf
	;call writeint
	;call crlf

	mov ecx, 0 ;mine counter

	cmp board[ebx * 4], 0
	je done ;if this tile has already been checked, then dont check it again
	cmp board[ebx * 4], 9
	je done ;TODO: Add a loss condition! The player hit a mine LOL
	
	checkRight:

		checkR boardlength
		cmp edx, 0
		je checkUp ;If it is out of range, jump to up (UpRight will also be out of range)
		
		mov eax, ebx
		inc eax

		;Check if the space is a mine
		cmp board[eax * 4], MINE_IDX
		jne checkUpRight ;if it is not a mine, jump to next check

		inc ecx ;increment the mine counter

	checkUpRight:

		checkUR boardlength
			
		; Range check
		cmp eax, boardLength
		jl checkLeft; We can skip checking all above indexes, as none will be accessable

		mov eax, ebx
		sub eax, boardLength
		inc eax

		cmp board[eax * 4], MINE_IDX
		jne checkUp

		inc ecx

	checkUp:
		; Sets eax to starting address
		checkU boardlength

		; Range check
		cmp eax, boardLength
		jl checkLeft; We can skip checking all above indexes, as none will be accessable

		mov eax, ebx
		sub eax, boardLength

		cmp board[eax * 4], MINE_IDX
		jne checkUpLeft

		inc ecx

	checkUpLeft:
		checkUL boardlength
		cmp edx, 0
		je checkDown ;We can skip the entire left segment if this is out of range

		mov eax, ebx
		sub eax, boardLength
		dec eax

		cmp board[eax * 4], MINE_IDX
		jne checkLeft

		inc ecx

	checkLeft:

		; Sets eax to starting address
		checkL boardlength
		
		cmp edx, 0
		je checkDown; If it is out of range, jump to the next check

		mov eax, ebx
		dec eax

		; Check if the space is a mine
		cmp board[eax * 4], MINE_IDX
		jne checkDownLeft; if it is not a mine, jump to next check

		inc ecx; increment the mine counter
	
	checkDownLeft:

		checkDL boardlength
		cmp eax, boardsize
		jg finishedCheck ;if this check fails, none of the downward checks would succeed

		mov eax, ebx
		add eax, boardlength
		dec eax

		cmp board[eax * 4], MINE_IDX
		jne checkDown

		inc ecx


	checkDown:

		checkD boardlength

		; Range check
		cmp eax, boardsize
		jg finishedCheck; if this check fails, none of the downward checks would succeed

		mov eax, ebx
		add eax, boardlength

		cmp board[eax * 4], MINE_IDX
		jne checkDownRight

		inc ecx

	checkDownRight:
		checkDR boardlength
		cmp edx, 0
		je finishedCheck; If it is out of range, jump to up(UpRight will also be out of range)

		mov eax, ebx
		inc eax
		add eax, boardLength

		; Check if the space is a mine
		cmp board[eax * 4], MINE_IDX
		jne finishedCheck; if it is not a mine, jump to next check

		inc ecx; increment the mine counter

	finishedCheck:

		; mov eax, ecx
		; call writeint
		; call crlf
		;mov eax, ebx
		;call writeint
		;call crlf


		mov board[ebx * 4], ecx
		cmp ecx, 0
		jne done ;if it is higher than 0, no need to call the recursive check
		
	rightRec:
		checkR boardlength
		cmp edx, 0
		je upRec
		mov eax, 1
		add eax, ebx
		push eax
		call checkLocation
	upRightRec:
		checkUR boardlength
		cmp eax, boardlength
		jl leftRec
		mov eax, ebx
		sub eax, boardlength
		inc eax
		push eax
		call checkLocation
	upRec:
		checkUR boardlength
		cmp eax, boardlength
		jl leftRec
		mov eax, ebx
		sub eax, boardlength
		push eax
		call checkLocation
	upLeftRec:
		checkUL boardlength
		cmp edx, 0
		je downRec
		mov eax, ebx
		sub eax, boardlength
		dec eax
		push eax
		call checklocation
	leftRec:
		checkL boardlength
		cmp edx, 0
		je downRec
		mov eax, ebx
		dec eax
		push eax
		call checklocation
	downLeftRec:
		checkDL boardlength
		cmp eax, boardsize
		jg done
		mov eax, ebx
		add eax, boardlength
		dec eax
		push eax
		call checklocation
	downRec:
		checkDL boardlength
		cmp eax, boardsize
		jg done
		mov eax, ebx
		add eax, boardlength
		push eax
		call checklocation
	downRightRec:
		checkDR boardlength
		cmp edx, 0
		je done
		mov eax, ebx
		add eax, boardlength
		inc eax
		push eax
		call checklocation




		
		



	done:

	popad
	ret 4
checkLocation ENDP


checkWin PROC
	
	ret
checkWin ENDP

; ******************************************************************************************************
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

	mov EBX, [EBP + 12]; game_state in EBX
	mov ECX, [EBP + 8]; boardlength in ECX

	mov EAX, 1; starting index

	; whitespace
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


		mov ECX, [EBP + 8]; boardsize in ECX
		mov EDX, 1; index counter
		mov EDI, 0

	outerLoop:
	call crlf

	; side display
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

	; set up inner loop counter
	push ECX
	mov ECX, [EBP + 8]

	innerLoop:
	; value check control structure
	mov EAX, [ESI]
	call WriteDec
	cmp EAX, 10
	je unvisited
	cmp EAX, 9
	jl cleared

	; check if game is over
	cmp EBX, 1
	jl gameOver

	unvisited :
	; display mine on unfinished game as empty or unvisited block
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




; ******************************************************************************************************
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
