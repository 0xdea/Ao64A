; Listing 8-1

; 128-bit multiplication

; % nasm -f macho64 listing8-1.asm
; % g++ c.cpp listing8-1.o -o listing8-1
; % ./listing8-1

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 8-1", 0
fmtStr1:
        db "%d * %d = %lld (verify:%lld)", nl, 0

        section .data
op1:
        dq 123456789
op2:
        dq 234567890
product:
        dq 0, 0
product2:
        dq 0, 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; mul64-

; Multiplies two 64-bit values passed in rdx and rax by
; doing a 64x64-bit multiplication, producing a 128-bit result.
; Algorithm is easily extended to 128x128 bits by switching the
; 32-bit registers for 64-bit registers.

; Stores result to location pointed at by R8.

        %define mp(d) [rbp+d-16]       ; Multiplier
        %define mc(d) [rbp+d-8]        ; Multiplicand
        %define prd(d) [r8+d]          ; Product

mul64:
        push rbp
        mov rbp, rsp
        sub rsp, 24

        push rbx                       ; Preserve these register values
        push rcx

; Save parameters passed in registers:

        mov mp(0), rax
        mov mc(0), rdx

; Multiply the LO dword of Multiplier times Multiplicand.

        mov eax, mp(0)
        mul dword mc(0)                ; Multiply LO dwords.
        mov prd(0), eax                ; Save LO dword of product.
        mov ecx, edx                   ; Save HO dword of partial product result.

        mov eax, mp(0)
        mul dword mc(4)                ; Multiply mp(LO) * mc(HO)
        add eax, ecx                   ; Add to the partial product.
        adc edx, 0                     ; Don't forget the carry!
        mov ebx, eax                   ; Save partial product for now.
        mov ecx, edx

; Multiply the HO word of Multiplier with Multiplicand.

        mov eax, mp(4)                 ; Get HO dword of Multiplier.
        mul dword mc(0)                ; Multiply by LO word of Multiplicand.
        add eax, ebx                   ; Add to the partial product.
        mov prd(4), eax                ; Save the partial product.
        adc ecx, edx                   ; Add in the carry!

        mov eax, mp(4)                 ; Multiply the two HO dwords together.
        mul dword mc(4)
        add eax, ecx                   ; Add in partial product.
        adc edx, 0                     ; Don't forget the carry!

        mov prd(8), eax                ; Save HO qword of result
        mov prd(12), edx

; EDX:EAX contains 64-bit result at this point

        pop rcx                        ; Restore these registers
        pop rbx
        leave
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage

; Test the mul64 function:

        mov rax, [op1]
        mov rdx, [op2]
        lea r8, [product]
        call mul64

; Use a 64-bit multiply to test the result

        mov rax, [op1]
        mov rdx, [op2]
        imul rax, rdx
        mov [product2], rax

; Print the results:

        lea rdi, [fmtStr1]
        mov rsi, [op1]
        mov rdx, [op2]
        mov rcx, [product]
        mov r8, [product2]
        call _printf

        leave
        ret                            ; Returns to caller
