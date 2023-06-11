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
boardsize DWORD 64
boardlength DWORD 8
minecount DWORD 16


; constants
BOARD_MINSIZE = 8
BOARD_MAXSIZE = 30


; Array
board DWORD BOARD_MINSIZE * BOARD_MAXSIZE DUP(-1)


.code
main PROC

	call introduction
	call getData

	mov eax, boardsize
	push eax
	mov eax, minecount
	push eax
	call generation

	
	gameLoop:
		call userInput
		call checkLocation
		call checkWin
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
		cmp board[eax * 4], -1
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

DisplayBoard PROC
	ret
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