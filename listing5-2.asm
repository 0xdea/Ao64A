; Listing 5-2
;
; A procedure without a RET instruction
;
; % nasm -f macho64 listing5-2.asm
; % g++ c.cpp listing5-2.o -o listing5-2
; % ./listing5-2


	default rel
	bits	64

nl          equ	10

            section	.rodata
ttlStr      db    	"Listing 5-2", 0
fpMsg       db    	"followingProc was called", nl, 0
        
            section	.text
            extern	_printf

; Return program title to C++ program:

            global _getTitle
_getTitle:
            lea 	rax, [ttlStr]
            ret




; noRet-
; 
;  Demonstrates what happens when a procedure
; does not have a return instruction.

noRet:



followingProc:
          	sub  rsp, 28h
            lea  rdi, fpMsg
            call _printf
            add  rsp, 28h
            ret



; Here is the "asmMain" function.

         	global	_asmMain
_asmMain:
            push    rbx
                
; "Magic" instruction offered without
; explanation at this point:

            sub     rsp, 48

            call    noRet
            
            add     rsp, 48
            pop     rbx
            ret     ;Returns to caller
