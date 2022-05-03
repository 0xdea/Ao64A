; Listing 1-5
;
; A "Hello, World!" program using the C/C++ printf function to 
; provide the output.
;
; % nasm -f macho64 listing1-5.asm
; % g++ listing1-6.cpp listing1-5.o -o listing1-5
; ./listing1-5


	default rel
	bits	64

	section .data                           ; Initialized data segment

; Note: "10" value is a line feed character, also known as the
; "C" newline character.
 
fmtStr  	db    'Hello, World!', 10, 0

	section	.text                          	; Code segment

; External declaration so MASM knows about the C/C++ printf 
; function

        	extern   _printf

        
; Here is the "asmFunc" function.

        
        	global  _asmFunc
_asmFunc:

; "Magic" instruction offered without explanation at this 
; point:

	sub     rsp, 56
                

; Here's where will call the C printf function to print 
; "Hello, World!" Pass the address of the format string
; to printf in the RDI register. Use the LEA instruction 
; to get the address of fmtStr.
        
        	lea     rdi, [fmtStr]
        	call    _printf
 
; Another "magic" instruction that undoes the effect of the 
; previous one before this procedure returns to its caller.
       
        	add     rsp, 56
        
        	ret     ;Returns to caller
        
