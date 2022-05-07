; Listing 8-2

; 256-bit by 64-bit division

; % nasm -f macho64 listing8-2.asm
; % g++ c.cpp listing8-2.o -o listing8-2
; % ./listing8-2

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 8-2", 0
fmtStr1:
        db "quotient = "
        db "%08x_%08x_%08x_%08x_%08x_%08x_%08x_%08x"
        db nl, 0

fmtStr2:
        db "remainder = %llx", nl, 0

        section .data

; op1 is a 256-bit value. Initial values were chosen
; to make it easy to verify result.

op1:
        dq 8888666644440000h, 2222eeeeccccaaaah
        dq 8888666644440000h, 2222eeeeccccaaaah

op2:
        dq 2
result:
        dq 4 dup (0)                   ; Also 256 bits
remain:
        dq 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; div256-
; Divides a 256-bit number by a 64-bit number.

; Dividend - passed by reference in RCX.
; Divisor  - passed in RDX.

; Quotient - passed by reference in R8.
; Remainder- passed by reference in R9.

        %define divisor qword [rbp-8]
        %define dividend(d) [rcx+d]
        %define quotient(d) [r8+d]
        %define remainder [r9]

div256:
        push rbp
        mov rbp, rsp
        sub rsp, 8

        mov divisor, rdx

        mov rax, dividend(24)          ; Begin div with HO qword
        xor rdx, rdx                   ; Zero extend into RDS
        div divisor                    ; Divide HO word
        mov quotient(24), rax          ; Save HO result

        mov rax, dividend(16)          ; Get dividend qword #2
        div divisor                    ; Continue with division
        mov quotient(16), rax          ; Store away qword #2

        mov rax, dividend(8)           ; Get dividend qword #1
        div divisor                    ; Continue with division
        mov quotient(8), rax           ; Store away qword #1

        mov rax, dividend(0)           ; Get LO dividend qword
        div divisor                    ; Continue with division
        mov quotient(0), rax           ; Store away LO qword

        mov remainder, rdx             ; Save away remainder

        leave
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 80                    ; Shadow storage

; Test the div256 function:

        lea rcx, [op1]
        mov rdx, [op2]
        lea r8, [result]
        lea r9, [remain]
        call div256

; Print the results:

        lea rdi, [fmtStr1]
        mov esi, [result+28]
        mov edx, [result+24]
        mov ecx, [result+20]
        mov r8d, [result+16]
        mov r9d, [result+12]
        mov eax, [result+8]
        mov [rsp], rax
        mov eax, [result+4]
        mov [rsp+8], rax
        mov eax, [result+0]
        mov [rsp+16], rax
        call _printf

        lea rdi, [fmtStr2]
        mov rsi, [remain]
        call _printf

        leave
        ret                            ; Returns to caller
