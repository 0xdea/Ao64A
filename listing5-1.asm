; Listing 5-1
;
; Simple procedure call .
;
;
; % nasm -f macho64 listing5-1.asm
; % g++ c.cpp listing5-1.o -o listing5-1
; % ./listing5-1


	default rel
	bits	64



nl       	equ	10

         	section	.rodata
ttlStr   	db    	"Listing 5-1", 0

 
        	section	.data
dwArray 	dd   	256 dup (1)

        
        	section	.text

; Return program title to C++ program:

         	global	_getTitle
_getTitle:
         	lea 	rax, [ttlStr]
         	ret




; Here is the user-written procedure
; that zeros out a buffer.

zeroBytes:
          	mov eax, 0
          	mov edx, 256
repeatlp: 	mov [rcx+rdx*4-4], eax
          	dec rdx
          	jnz repeatlp
          	ret



; Here is the "asmMain" function.

        	global	_asmMain
_asmMain:

; "Magic" instruction offered without
; explanation at this point:

        	sub     rsp, 48

        	lea     rcx, [dwArray]
        	call    zeroBytes 

        	add     rsp, 48 ;Restore RSP
        	ret     ;Returns to caller
