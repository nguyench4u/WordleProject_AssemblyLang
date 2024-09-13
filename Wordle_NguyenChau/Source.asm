;// Title: Final Project 
;// name: Chau Nguyen
;// description: Wordle - EC: idk yet (SUCCESSFUL CODE BEFORE EXTRA CREDIT) 

include irvine32.inc
;// symbolic constants
newline TEXTEQU <0Ah, 0Dh>
move EQU mov
jump EQU jmp

.data
errorMsg byte "You have entered an invalid option, please try again.", newline, 0h
Opt byte 0h
player1wins byte 0h
player2wins byte 0h
roundCount byte 0h
wordleArray byte 5Fh, 5Fh, 5Fh, 5Fh, 5Fh, 0h
wordOne byte 6 DUP(?), 0h ;// 5+1 for null terminator
wordTwo byte 6 DUP(?), 0h

.code
mainMenu PROTO
RandomStarter PROTO
MatchWordsIt PROTO
DisplayWordle PROTO
CheckLetters PROTO
CheckLettersTwo PROTO
BlackColor PROTO
BlueColor PROTO
YellowColor PROTO
NormalColor PROTO
OnePlayerMode PROTO
TwoPlayerMode PROTO

main PROC
call Randomize

starthere: 						;// return here unless 3(Exit) is entered 
call clrscr						;// clears screen if user inputs an incorrect option 
mov esi, offset Opt				;// pass Opt address to function ESI
invoke mainMenu
mov edx, offset wordOne
mov edx, offset wordTwo
mov edx, offset wordleArray		;// Spaces for the Wordle (_|_|_|_|_)
;// MAIN MENU SELECT: 1-3
cmp al, 1	
je option1
cmp al, 2
je option2
cmp al, 3
je quit

;// INVALID ENTRY
mov edx, offset errorMsg
call writestring
call waitmsg
jmp starthere

option1:
call OnePlayerMode
jmp starthere

option2:						;// address of theStr is in edx, theActualLen is in ebx
call TwoPlayerMode 
jmp starthere

quit:  
exit
main ENDP

;// Procedure 1: _________________________________________________________
mainMenu PROC
;// Desc: Display menu and get user option input
;// returns: User Input in ESI 
;// requires: Offset of opt var in ESI
.data
menuPrompt byte " Welcome to WORDS! Please Select a Mode: ", newline, 
" 1. One-Player Game ", newline, 
" 2. Two-Player Game ", newline, 
" 3. Exit" , newline, 
" ", newline,
" Select Your Option: ", 0h

.code
call clrscr						;// clears screen if user inputs an incorrect option 
mov edx, offset menuPrompt		;// prompt address in EDX by writestring call 
call writestring
call readDec					;// saves input option in AL 
mov byte ptr[esi], al			;// saves input address in ESI 

ret
mainMenu ENDP

;// Procedure 2: _________________________________________________________
RandomStarter PROC
;// Desc: Decides which Player Goes First, Also Use for Coin Flip! 
;// returns: EAX 1 or 2
.code
mov eax, 0
Loop1: 
;// Decides either 1 or 2 for a 50/50
mov eax, 2
call RandomRange
add eax, 1
ret
RandomStarter ENDP

;// Procedure 3: _________________________________________________________
MatchWordsIt PROC
;// Desc: Matches each element of input 1 to input 2
;// returns: Updated wordleArray
;// requires: Offset of variables

.code
mov ecx, 5
mov esi, 0				;// esi increment for matching
mov ebx, 0				;// check if entire word is correct

loop1:
push esi
push ecx
mov al, wordOne[esi]
cmp al, wordTwo[esi]
jne wrongLetter
jmp rightLetter

wrongLetter: 
mov wordleArray[esi], 5Fh
mov ecx, 5
mov edi, 0
letterPresent: 
mov al, wordTwo[esi]	;// player2 word is in AL
cmp wordOne[edi], al	;// inc player1 char, to compare to player2 letter one by one
je letterExists
jmp nextChar

letterExists:
mov wordleArray[esi], 01h	;// indicate letter is existent

nextChar:
inc edi						;// move to next player1 element
loop letterPresent
mov ecx, 5
inc esi
cmp esi, 5
jne letterPresent
jmp nextLetter

rightLetter: 
mov wordleArray[esi], 02h
add ebx, 1
jmp nextLetter

nextLetter: 
pop ecx
pop esi
inc esi
loop loop1

ret
MatchWordsIt ENDP

;// Procedure 4: _________________________________________________________
DisplayWordle PROC
;// Desc: Displays Wordle and colored spaces 
;// receives: Both modes MatchWordsIt
;// returns: wordleArray
.data
divideChar byte 7Ch, 0h
spaceChar byte 20h, 0h
.code

mov ecx, 5				;// resets Word Count
mov esi, 0				;// reset increment
printCheckWord:
mov eax, 0
mov edx, offset wordleArray
mov al, byte ptr[edx + esi]
cmp al, 5Fh
je BlackSpace
cmp al, 01h
je YellowSpace
jmp BlueSpace

BlackSpace: 
invoke BlackColor
mov edx, offset spaceChar
call writestring
jmp nextSpace

YellowSpace: 
invoke YellowColor
mov edx, offset spaceChar
call writestring
jmp nextSpace

BlueSpace: 
invoke BlueColor
mov edx, offset spaceChar
call writestring

nextSpace:
cmp ecx, 1
je done
invoke NormalColor
mov edx, offset divideChar
call writestring
inc esi
loop printCheckWord

done:
invoke NormalColor
ret 
DisplayWordle ENDP

;// Procedure 5: _________________________________________________________
CheckLetters PROC
;// Desc: Checks if the entry has letters only 
;// receives: wordOne

.code
mov ecx, 5
mov esi, 0                        ;// loop set up 
mov ebx, 0

LetterLoop: 
mov al, wordOne[esi]
isUpperA:
cmp al, 41h                     ;// is it an ‘A’? 
jae isUpperZ                   ;// if it is BELOW 41h, jump 
jmp notALetter
isUpperZ:
cmp al, 5Ah                        ;// is it a ‘Z’?
jbe changeLower                     ;// if it is ABOVE 5Ah, jump 
isLowerA:
cmp al, 61h                     ;// is it an ‘a’? 
jae isLowerZ                     ;// if it is ABOVE 61h, jump 
jmp notALetter
isLowerZ:
cmp al, 7Ah                        ;// is it a ‘z’?
jbe isALetter						;// if it is BELOW 7A, jump
jmp notALetter

changeLower:
add wordOne[esi], 20h
jmp isALetter

notALetter:
inc esi
add ebx, 1

isALetter:
inc esi
loop LetterLoop

ret 
CheckLetters ENDP

;// Procedure 6: _________________________________________________________
CheckLettersTwo PROC
;// Desc: Checks if the entry has letters only 
;// receives: wordTwo

.code
mov ecx, 5
mov esi, 0                        ;// loop set up 
mov ebx, 0

LetterLoop2: 
mov al, wordTwo[esi]
isUpperA2:
cmp al, 41h                     ;// is it an ‘A’? 
jae isUpperZ2                   ;// if it is BELOW 41h, jump 
jmp notALetter2
isUpperZ2:
cmp al, 5Ah                        ;// is it a ‘Z’?
jbe changeLower2                     ;// if it is ABOVE 5Ah, jump 
isLowerA2:
cmp al, 61h                     ;// is it an ‘a’? 
jae isLowerZ2                     ;// if it is ABOVE 61h, jump 
jmp notALetter2
isLowerZ2:
cmp al, 7Ah                        ;// is it a ‘z’?
jbe isALetter2						;// if it is BELOW 7A, jump
jmp notALetter2

changeLower2:
add wordTwo[esi], 20h
jmp isALetter2

notALetter2:
inc esi
add ebx, 1

isALetter2:
inc esi
loop LetterLoop2

CheckLettersTwo ENDP

;// Procedure 7: _________________________________________________________
BlackColor PROC
;// Desc: Make Space Black
.code
mov eax, black + (black * 16)
call SetTextColor
ret 
BlackColor ENDP

;// Procedure 8: _________________________________________________________
BlueColor PROC
;// Desc: Make Space Blue
.code
mov eax, black + (blue * 16)
call SetTextColor
ret 
BlueColor ENDP

;// Procedure 9: _________________________________________________________
YellowColor PROC
;// Desc: Make Space Yellow
.code
mov eax, black + (yellow * 16)
call SetTextColor
ret 
YellowColor ENDP

;// Procedure 10: _________________________________________________________
NormalColor PROC
;// Desc: Make Space Yellow
.code
mov eax, white + (black * 16)
call SetTextColor
ret 
NormalColor ENDP

;// Procedure 11: _________________________________________________________
OnePlayerMode PROC
;// Desc: Randomly chosen word in 94 Words, 470 letters.
;// receives: 
;// returns: 
;// requires: 
.data
player1prompt2 byte "User 1: Please enter a word: Type -1 to Quit. ", 0h
winnerMsg2 byte "Congratulations! You win Words. ", 0h
errorIn2 byte "You have entered a word too long / too short, or it has non-letter characters. Try Again: ", 0h
loserMsg2 byte "You have run out of attempts, you lose. ", 0h
listOfWords byte "About", "Abyss", "Adult", "Ample", "Ankle",
	"Armor", "Aroma", "Began", "Blind", "Braid",
	"Brick", "Brisk", "Bumpy", "Cabby", "Cable",
	"Child", "Chive", "Cloth", "Clown", "Comet",
	"Crate", "Crawl", "Daddy", "Dance", "Debit",

listOfWords2 byte "Doggy", "Doubt", "Eager", "Eagle", "Early",
	"Eight", "Eject", "Enemy", "Extra", "Fable",
	"Facet", "Final", "Gable", "Grade", "Green",
	"Horse", "Ichor", "Image", "Imbue", "Inure",
	"Kabob", "Kafir", "Kitty", "Macaw", "Metal",

listOfWords3 byte "Mimic", "Missy", "Money", "Nicer", "Oasis",
	"Owlet", "Panel", "Panic", "Phase", "Phone",
	"Place", "Purse", "Ranch", "Rifle", "Rugby",
	"Sabre", "Scowl", "Seven", "Shark", "Shirt",
	"Snake", "Snark", "Sonny", "Spade", "Spark",

listOfWords4 byte "Spelt", "Stack", "Stark", "State", "Steam",
	"Stick", "Story", "Sunny", "Sword", "Table",
	"Today", "Touch", "Towel", "Trade", "Trace",
	"Udder", "Watch", "Vista", "Zebra",

.code
mov ecx, 5
mov esi, 0
mov edx, offset listOfWords
mov edx, offset listOfWords2
mov edx, offset listOfWords3
mov edx, offset listOfWords4
mov edx, offset wordleArray
mov edx, offset wordOne
mov eax, 4
call RandomRange
cmp eax, 0
je listOne
cmp eax, 1
je listTwo
cmp eax, 2
je listThree
jmp listFour

listOne:
mov eax, 25d
call RandomRange
imul eax, 5d
sub eax, 5d
mov ebx, eax
jmp storeWord1
listTwo:
mov eax, 25d
call RandomRange
imul eax, 5d
sub eax, 5d
mov ebx, eax
jmp storeWord2
listThree:
mov eax, 25d
call RandomRange
imul eax, 5d
sub eax, 5d
mov ebx, eax
jmp storeWord3
listFour:
mov eax, 19d
call RandomRange
imul eax, 5d
sub eax, 5d
mov ebx, eax
jmp storeWord4

storeWord1:
movzx eax, byte ptr listOfWords[ebx + esi]
mov wordOne[esi], al
inc esi
loop storeWord1
jmp startRound
storeWord2:
movzx eax, byte ptr listOfWords2[ebx + esi]
mov wordOne[esi], al
inc esi
loop storeWord2
jmp startRound
storeWord3:
movzx eax, byte ptr listOfWords3[ebx + esi]
mov wordOne[esi], al
inc esi
loop storeWord3
jmp startRound
storeWord4:
movzx eax, byte ptr listOfWords4[ebx + esi]
mov wordOne[esi], al
inc esi
loop storeWord4
jmp startRound

startRound: 
invoke CheckLetters
call clrscr
mov esi, 0				;// counter for number of attempts
askOnePlayer:
mov edx, offset player1prompt2
call writestring
mov edx, offset WordTwo
mov ecx, 7
call readstring				;// Player 1 word length in EDX offset

mov edi, 0
cmp wordTwo[edi], "-"
je nextOne
nextOne:
inc edi
cmp wordTwo[edi], "1"
je finishP1

CheckLengthP1:
cmp eax, 5
je CheckLetterP1
jmp invalidEntryP1

CheckLetterP1:
mov ebx, 0
push esi
invoke CheckLettersTwo
pop esi
cmp ebx, 1
jb matchWordsP1
jmp invalidEntryP1

invalidEntryP1:
mov edx, offset errorIn
call writestring
call crlf
jmp askOnePlayer

matchWordsP1:
add esi, 1				;// attempt counter
push esi
invoke MatchWordsIt
invoke DisplayWordle
pop esi

doneP1: 
call crlf
cmp ebx, 5
je winGameP1
cmp esi, 5
je loseGameP1
jmp askOnePlayer

winGameP1:
mov edx, offset winnerMsg2
call writestring
call waitmsg
call crlf
jmp finishP1

loseGameP1: 
mov edx, offset loserMsg2
call writestring
call waitmsg
call crlf
jmp finishP1

finishP1:
ret
OnePlayerMode ENDP

;// Procedure 12: _________________________________________________________
TwoPlayerMode PROC 
;// Desc: Being the Two Player Mode, and complete 2 full rounds. 
;// receives: makeWordle in offset 
;// returns: Wordle Array 
.data
player1prompt byte "User 1: Please enter a word: Type -1 to Quit. ", 0h
player2prompt byte "User 2: Please enter a word: Type -1 to Quit. ", 0h
winnerMsg byte "Congratulations! You win this round. ", 0h
errorIn byte "You have entered a word too long / too short, or it has non-letter characters. Try Again: ", 0h
loserMsg byte "You have run out of attempts, you lose this round. ", 0h
winAll byte "The Official Winner of Wordle is: ", 0h
tieMsg byte "The Game Has Ended As A Tie. A Coin Will Be Flipped to Determine the Winner. ", 0h
player1Name byte "Player 1!", 0h
player2Name byte "Player 2!", 0h 
stats1 byte "Player 1 Score: ", 0h
stats2 byte "Player 2 Score: ", 0h

.code
mov player2wins, 0d
mov player1wins, 0d
mov roundCount, 0d
invoke RandomStarter
cmp eax, 1
je Player1First
jmp switchTurns

Player1First:
add roundCount, 1
call clrscr
mov esi, 0				;// counter for number of attempts
askUser1:
mov edx, offset player1prompt
call writestring
mov edx, offset wordOne
mov ecx, 7				;// word entry should not exceed 6
call readstring			;// Player 1 word length in EDX offset
call clrscr

mov edi, 0
cmp wordOne[edi], "-"
je nextOne
nextOne:
inc edi
cmp wordOne[edi], "1"
je QuitGame

CheckLength:
cmp eax, 5
je CheckLetter
jmp invalidEntry

CheckLetter:
mov ebx, 0				;// letter checker in Matching loop
push esi
invoke CheckLetters
pop esi
cmp ebx, 1
jb player2Turn
jmp invalidEntry

invalidEntry:
mov edx, offset errorIn
call writestring
call crlf
jmp askUser1

player2Turn:
mov esi, 0				;// counter for number of attempts
mov edx, offset wordleArray
askUser2:
mov edx, offset player2prompt
call writestring
mov edx, offset wordTwo
mov ecx, 7
call readstring			;// Player 2 word length in EDX offset

mov edi, 0
cmp wordTwo[edi], "-"
je nextOne2
nextOne2:
inc edi
cmp wordTwo[edi], "1"
je QuitGame

CheckLength2:
cmp eax, 5
je CheckLetter2
jmp invalidEntry2

CheckLetter2:
mov ebx, 0
push esi
invoke CheckLettersTwo
pop esi
cmp ebx, 1
jb matchWords
jmp invalidEntry2

invalidEntry2:
mov edx, offset errorIn
call writestring
call crlf
jmp askUser2

matchWords:
add esi, 1				;// attempt counter
push esi
invoke MatchWordsIt
invoke DisplayWordle
pop esi

done: 
call crlf
cmp ebx, 5
je winGame
cmp esi, 5
je loseGame
jmp askUser2 

winGame:
add player2wins, 1d
mov edx, offset winnerMsg
call writestring
call waitmsg
call crlf
cmp roundCount, 4d
je finish
jmp switchTurns

loseGame: 
mov edx, offset loserMSg
call writestring
call waitmsg
call crlf
cmp roundCount, 4d
je finish

;//----------------------------------SWITCH ROLES
switchTurns:
add roundCount, 1		;// round counter
mov ebx, 0				;// letter checker in Matching loop
mov esi, 0				;// counter for number of attempts
call clrscr

askUser2P2:
mov edx, offset player2prompt
call writestring
mov edx, offset wordOne
mov ecx, 7
call readstring			;// Player 2 word length in EDX offset
call clrscr

mov edi, 0
cmp wordOne[edi], "-"
je nextOne3
nextOne3:
inc edi
cmp wordOne[edi], "1"
je QuitGame

CheckLength3:
cmp eax, 5
je CheckLetter3
jmp invalidEntry3

CheckLetter3:
mov ebx, 0				;// letter checker in Matching loop
push esi
invoke CheckLetters
pop esi
cmp ebx, 1
jb player1Turn
jmp invalidEntry3

invalidEntry3:
mov edx, offset errorIn
call writestring
call crlf
jmp askUser2P2

player1Turn:
mov edx, offset wordleArray
mov esi, 0				;// counter for number of attempts
askUser1P2:
mov edx, offset player1prompt
call writestring
mov edx, offset wordTwo
mov ecx, 7
call readstring			;// Player 1 word length in EDX offset

mov edi, 0
cmp wordTwo[edi], "-"
je nextOne4
nextOne4:
inc edi
cmp wordTwo[edi], "1"
je QuitGame

CheckLength4:
cmp eax, 5
je CheckLetter4
jmp invalidEntry4

CheckLetter4:
mov ebx, 0
push esi
invoke CheckLettersTwo
pop esi
cmp ebx, 1
jb matchWords2
jmp invalidEntry4

invalidEntry4:
mov edx, offset errorIn
call writestring
call crlf
jmp askUser1P2

matchWords2:
add esi, 1				;// attempt counter
push esi
invoke MatchWordsIt
invoke DisplayWordle
pop esi

done2: 
call crlf
cmp ebx, 5
je winGame2
cmp esi, 5
je loseGame2
jmp askUser1P2 

winGame2:
add player1wins, 1d
mov edx, offset winnerMsg
call writestring
call waitmsg
call crlf
cmp roundCount, 4d
je finish
jmp player1First

loseGame2: 
mov edx, offset loserMsg
call writestring
call waitmsg
call crlf
cmp roundCount, 4d
je finish
jmp player1First

finish:
call clrscr
mov edx, offset stats1
call writestring
mov al, player1wins
call writeDec
call crlf
mov edx, offset stats2
call writestring
mov al, player2wins
call writeDec
call crlf

mov eax, 0
mov bl, player1wins
mov al, player2wins
cmp bl, al
je FlipTie
jb P2Wins
jmp P1Wins

P1Wins:
mov edx, offset winAll
call writestring 
mov edx, offset player1Name
call writestring
call crlf
call waitmsg
jmp QuitGame

P2Wins: 
mov edx, offset winAll
call writestring 
mov edx, offset player2Name
call writestring
call crlf
call waitmsg
jmp QuitGame

FlipTie:
mov edx, offset tieMsg
call writestring 
call crlf
invoke RandomStarter
cmp eax, 1
je P1Wins
jmp P2Wins

QuitGame: 
ret
TwoPlayerMode ENDP

END main 