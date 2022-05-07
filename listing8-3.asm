; Listing 8-3

; 128-bit by 128-bit division

; % nasm -f macho64 listing8-3.asm
; % g++ c.cpp listing8-3.o -o listing8-3
; % ./listing8-3

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 8-3", 0
fmtStr1:
        db "quotient = "
        db "%08x_%08x_%08x_%08x"
        db nl, 0

fmtStr2:
        db "remainder = "
        db "%08x_%08x_%08x_%08x"
        db nl, 0

fmtStr3:
        db "quotient (2) = "
        db "%08x_%08x_%08x_%08x"
        db nl, 0

        section .data

; op1 is a 128-bit value. Initial values were chosen
; to make it easy to verify result.

op1:
        dq 8888666644440000h, 2222eeeeccccaaaah
op2:
        dq 2, 0
op3:
        dq 4444333322220000h, 1111777766665555h
result:
        dq 0, 0
remain:
        dq 0, 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; div128-

; This procedure does a general 128/128 division operation
; using the following algorithm (all variables are assumed
; to be 128-bit objects):

; Quotient := Dividend;
; Remainder := 0;
; for i := 1 to NumberBits do

; Remainder:Quotient := Remainder:Quotient SHL 1;
; if Remainder >= Divisor then

; Remainder := Remainder - Divisor;
; Quotient := Quotient + 1;

; endif
; endfor

; Data passed:

; 128-bit dividend, by reference in RCX
; 128-bit divisor, by reference in RDX

; Data returned:

; Pointer to 128-bit quotient in R8
; Pointer to 128-bit remainder in R9

        %define remainder(d) [rbp+d-16]
        %define dividend(d) [rbp+d-32]
        %define quotient(d) [rbp+d-32] ; Alias of dividend
        %define divisor(d) [rbp+d-48]

div128:
        push rbp
        mov rbp, rsp
        sub rsp, 48

        push rax
        push rcx

        xor rax, rax                   ; Initialize remainder to 0
        mov remainder(0), rax
        mov remainder(8), rax

; Copy the dividend to local storage

        mov rax, [rcx]
        mov dividend(0), rax
        mov rax, [rcx+8]
        mov dividend(8), rax

; Copy the divisor to local storage

        mov rax, [rdx]
        mov divisor(0), rax
        mov rax, [rdx+8]
        mov divisor(8), rax

        mov cl, 128                    ; Count off bits in cl

; Compute Remainder:Quotient := Remainder:Quotient SHL 1:

repeatLp:
        shl qword dividend(0), 1       ; 256-bit extended
        rcl qword dividend(8), 1       ; precision shift
        rcl qword remainder(0), 1      ; through remainder
        rcl qword remainder(8), 1

; Do a 128-bit comparison to see if the remainder
; is greater than or equal to the divisor.

        mov rax, remainder(8)
        cmp rax, divisor(8)
        ja isGE
        jb notGE

        mov rax, remainder(0)
        cmp rax, divisor(0)
        ja isGE
        jb notGE

; Remainder := Remainder - Divisor

isGE:
        mov rax, divisor(0)
        sub remainder(0), rax
        mov rax, divisor(8)
        sbb remainder(8), rax

; Quotient := Quotient + 1;

        add qword quotient(0), 1
        adc qword quotient(8), 0

notGE:
        dec cl
        jnz repeatLp

; Okay, copy the quotient (left in the Dividend variable)
; and the remainder to their return locations.

        mov rax, quotient(0)
        mov [r8], rax
        mov rax, quotient(8)
        mov [r8+8], rax

        mov rax, remainder(0)
        mov [r9], rax
        mov rax, remainder(8)
        mov [r9+8], rax

        pop rcx
        pop rax
        leave
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage

; Test the div128 function:

        lea rcx, [op1]
        lea rdx, [op2]
        lea r8, [result]
        lea r9, [remain]
        call div128

; Print the results:

        lea rdi, [fmtStr1]
        mov esi, dword result[12]
        mov edx, dword result[8]
        mov ecx, dword result[4]
        mov r8d, dword result[0]
        call _printf

        lea rdi, [fmtStr2]
        mov esi, dword remain[12]
        mov edx, dword remain[8]
        mov ecx, dword remain[4]
        mov r8d, dword remain[0]
        call _printf

; Test the div128 function:

        lea rcx, [op1]
        lea rdx, [op3]
        lea r8, [result]
        lea r9, [remain]
        call div128

; Print the results:

        lea rdi, [fmtStr3]
        mov esi, dword result[12]
        mov edx, dword result[8]
        mov ecx, dword result[4]
        mov r8d, dword result[0]
        call _printf

        lea rdi, [fmtStr2]
        mov esi, dword remain[12]
        mov edx, dword remain[8]
        mov ecx, dword remain[4]
        mov r8d, dword remain[0]
        call _printf

        leave
        ret                            ; Returns to caller
