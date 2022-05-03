; Listing 2-1
;
; Displays some numeric values on the console.
;
;
; % nasm -f macho64 listing2-1.asm
; % g++ c.cpp listing2-1.o -o listing2-1
; % ./listing2-1


	default rel
	bits	64

nl      	equ	10  ;ASCII code for newline

	section .data                           ; Initialized data segment
i        	dq  	1
j        	dq  	123
k        	dq	456789
  
titleStr 	db   	'Listing 2-1', 0

fmtStrI  	db   	"i=%d, converted to hex=%x", nl, 0
fmtStrJ  	db   	"j=%d, converted to hex=%x", nl, 0
fmtStrK  	db   	"k=%d, converted to hex=%x", nl, 0

        	section	.text
        	extern	_printf

; Return program title to C++ program:

         global	_getTitle
_getTitle:

; Load address of "titleStr" into the RAX register (RAX holds
; the function return result) and return back to the caller:

         	lea rax, [titleStr]
         	ret
        
; Here is the "asmMain" function.

        
        	global	_asmMain
_asmMain:
                           
; "Magic" instruction offered without explanation at this point:

        	sub     rsp, 56
                


;  Call printf three times to print the three values i, j, and k:
; 
; printf( "i=%d, converted to hex=%x\n", i, i );
 
        	lea     rdi, [fmtStrI]
        	mov     rsi, [i]
        	mov     rdx, rsi
        	call    _printf

; printf( "j=%d, converted to hex=%x\n", j, j );
 
        	lea     rdi, [fmtStrJ]
        	mov     rsi, [j]
        	mov     rdx, rsi
        	call    _printf

; printf( "k=%d, converted to hex=%x\n", k, k );
 
        	lea     rdi, [fmtStrK]
        	mov     rsi, [k]
        	mov     rdx, rsi
        	call    _printf


; Another "magic" instruction that undoes the effect of the previous
; one before this procedure returns to its caller.
;        
        	add     rsp, 56
        
        
        	ret     ;Returns to caller
        
