; Listing 3-1

; Demonstrate address expressions

; % nasm -f macho64 listing3-1.asm
; % g++ c.cpp listing3-1.o -o listing3-1
; % ./listing3-1

        default rel
        bits	64

        nl 	equ	10                     ; ASCII code for newline

        section .rodata
ttlStr:
        db 	'Listing 3-1', 0
fmtStr1:
        db	'i[0]=%d ', 0
fmtStr2:
        db	'i[1]=%d ', 0
fmtStr3:
        db	'i[2]=%d ', 0
fmtStr4:
        db	'i[3]=%d', nl, 0

        section .data
i:
        db 0, 1, 2, 3

        section .text
        extern 	_printf

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbx

; "Magic" instruction offered without
; explanation at this point:

        sub rsp, 48

        lea rdi, [fmtStr1]
        movzx rsi, byte [i]
        call _printf

        lea rdi, fmtStr2
        movzx rsi, byte [i+1]
        call _printf

        lea rdi, fmtStr3
        movzx rsi, byte [i+2]
        call _printf

        lea rdi, fmtStr4
        movzx rsi, byte [i+3]
        call _printf

        add rsp, 48
        pop rbx
        ret                            ; Returns to caller
