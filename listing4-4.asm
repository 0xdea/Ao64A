; Listing 4-4
;
; Uninitialized pointer demonstration.
; Note that this program will not
; run properly
;
;
; % nasm -f macho64 listing4-4.asm
; % g++ c.cpp listing4-4.o -o listing4-4
; % ./listing4-4


	default rel
	bits	64

nl      	equ	10

        	section	.rodata
ttlStr  	db    	"Listing 4-4", 0
fmtStr  	db    	"Pointer value= %p", nl, 0
        
        	section	.data
ptrVar  	dq   	0
        
        	section	.text
        	extern	_printf


; Return program title to C++ program:

         	global	_getTitle
_getTitle:
         	lea 	rax, [ttlStr]
         	ret


; Here is the "asmMain" function.

        
        	global	_asmMain
_asmMain:

; "Magic" instruction offered without
; explanation at this point:

        	sub     rsp, 56


        	lea     rdi, [fmtStr]
        	mov     rsi, [ptrVar]
        	mov     rsi, [rsi]      ; Will crash system
        	call    _printf


        	add     rsp, 56
        	ret     ;Returns to caller
        

