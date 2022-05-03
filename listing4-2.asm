; Listing 4-2
;
; // Pointer constant demonstration
;
;
; % nasm -f macho64 listing4-2.asm
; % g++ c.cpp listing4-2.o -o listing4-2 -Wl,-no_pie
; % ./listing4-2


	default rel
	bits	64



nl      	equ	10

	section .rodata
ttlStr 	db    "Listing 4-2", 0
fmtStr 	db    "pb's value is %ph", nl
       	db    "*pb's value is %d", nl, 0
       	
	section .data
b      	db    	0
       	db    	1, 2, 3, 4, 5, 6, 7
       	
pb     	equ	b+2
       	
	section .text
        	extern	_printf


; Return program title to C++ program:

         	global	_getTitle
_getTitle:
         	lea 	rax, [ttlStr]
         	ret


; Here is the "asmMain" function.

        
        	global	_asmMain
_asmMain:
; to align stack
                push    rbx

; "Magic" instruction offered without
; explanation at this point:

        	sub     rsp, 48

        	lea     rdi, [fmtStr]
        	mov     rsi, pb
        	movzx   rdx, byte [rsi]
        	call    _printf
        
        	add     rsp, 48
		pop     rbx
        	ret     ;Returns to caller
        
