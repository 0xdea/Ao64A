; Listing 5-3

; Preserving registers (failure) example

; % nasm -f macho64 listing5-3.asm
; % g++ c.cpp listing5-3.o -o listing5-3
; % ./listing5-3

        default rel
        bits	64

        nl equ	10

        section	.rodata
ttlStr:
        db 	"Listing 5-3", 0
space:
        db 	" ", 0
asterisk:
        db 	'*, %d', nl, 0

        section	.text
        extern	_printf

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; print40Spaces-

; Prints out a sequence of 40 spaces
; to the console display.

print40Spaces:
        sub rsp, 56                   ; "Magic" instruction
        mov ebx, 40
printLoop:	
        lea rdi, [space]
        call _printf
        dec ebx
        jnz printLoop                 ; Until ebx==0
        add rsp, 56                   ; "Magic" instruction
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbx

; "Magic" instruction offered without
; explanation at this point:

        sub rsp, 48

        mov rbx, 20
astLp:
        call print40Spaces
        lea rdi, [asterisk]
        mov rsi, rbx
        call _printf
        dec rbx
        jnz astLp

        add rsp, 48
        pop rbx
        ret                            ; Returns to caller
