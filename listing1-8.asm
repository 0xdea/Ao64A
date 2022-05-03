; Listing 1-8
;
; An assembly language program that demonstrate returning
; a function result to a C++ program.
;
; % nasm -f macho64 listing1-8.asm
; % g++ c.cpp listing1-8.o -o listing1-8
; % ./listing1-8


	default rel
	bits	64

nl      	equ	10  ;ASCII code for newline
maxLen  	equ	256 ;Maximum string size + 1

	section .data                           ; Initialized data segment
titleStr 	db    	'Listing 1-8', 0
prompt   	db    	'Enter a string: ', 0
fmtStr   	db    	"User entered: '%s'", nl, 0

; "input" is a buffer having "maxLen" bytes. This program 
; will read a user string into this buffer.
;
; The "maxLen dup (?)" operand tells MASM to make "maxLen" 
; duplicate copies of a byte, each of which is uninitialized.
 
input    	db   maxLen dup (0)

	section	.text                          	; Code segment

        	extern  _printf
        	extern  _readLine


; The C++ function calling this assembly language module 
; expects a function named "getTitle" that returns a pointer 
; to a string as the function result. This is that function:

         	global	_getTitle
_getTitle:

; Load address of "titleStr" into the RAX register (RAX holds 
; the function return result) and return back to the caller:

         	lea 	rax, [titleStr]
         	ret


        
; Here is the "asmMain" function.

        
        	global	_asmMain
_asmMain:
        	sub     rsp, 56
                

; Call the readLine function (written in C++) to read a line 
; of text from the console.
;
; int readLine( char *dest, int maxLen )
;
; Pass a pointer to the destination buffer in the RDI register.
; Pass the maximum buffer size (max chars + 1) in ESI.
; This function ignores the readLine return result.
; Prompt the user to enter a string:

        lea     rdi, [prompt]
        call    _printf


; Ensure the input string is zero terminated (in the event 
; there is an error):

        mov     byte [input], 0
        
; Read a line of text from the user:

        lea     rdi, [input]
        mov     rsi, maxLen
        call    _readLine
        
; Print the string [input] by the user by calling printf:

        lea     rdi, [fmtStr]
        lea     rsi, [input]
        call    _printf
 
        add     rsp, 56
        ret     ;Returns to caller
        
