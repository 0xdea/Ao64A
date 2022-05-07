; Listing 7-5

; Demonstration of memory indirect jumps

; % nasm -f macho64 listing7-5.asm
; % g++ c.cpp listing7-5.o -o listing7-5 -Wl,-no_pie
; % ./listing7-5

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 7-5", 0
fmtStr1:
        db "Before indirect jump", nl, 0
fmtStr2:
        db "After indirect jump", nl, 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48                    ; Shadow storage

        lea rdi, [fmtStr1]
        call _printf
        jmp qword [memPtr]

memPtr:
        dq ExitPoint

ExitPoint: 
        lea rdi, [fmtStr2]
        call _printf

        leave
        ret                            ; Returns to caller
