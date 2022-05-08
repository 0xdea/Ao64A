; Listing 9-8

; Extended-precision signed integer
; to string function

; % nasm -f macho64 listing9-8.asm
; % g++ c.cpp listing9-8.o -o listing9-8
; % ./listing9-8

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 9-8", 0
fmtStr1:
        db "otoStr(0): string=%s", nl, 0
fmtStr2:
        db "otoStr(1234567890): string=%s", nl, 0
fmtStr3:
        db "otoStr(2147483648): string=%s", nl, 0
fmtStr4:
        db "otoStr(4294967296): string=%s", nl, 0
fmtStr5:
        db "otoStr(FFF...FFFF): string=%s", nl, 0

        section .data
buffer:
        db 40 dup (0)

b0:
        dq 0, 0
b1:
        dq 1234567890, 0
b2:
        dq 2147483648, 0
b3:
        dq 4294967296, 0

; Largest oword value
; (decimal=340,282,366,920,938,463,463,374,607,431,768,211,455):

b4:
        dq 0FFFFFFFFFFFFFFFFh, 0FFFFFFFFFFFFFFFFh

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, ttlStr
        ret

; DivideBy10-

; Divides "divisor" by 10 using fast
; extended-precision division algorithm
; that employs the div instruction.

; Returns quotient in "quotient".
; Returns remainder in rax.
; Trashes rdx.

; RCX - points at oword dividend and location to
; receive quotient

ten:
        dq 10

DivideBy10:

        xor edx, edx
        mov rax, [rcx+8]
        div qword [ten]
        mov [rcx+8], rax

        mov rax, [rcx]
        div qword [ten]
        mov [rcx], rax
        mov eax, edx                   ; Remainder (always 0..9!)
        ret

; Recursive version of otoStr.
; A separate "shell" procedure calls this so that
; this code does not have to preserve all the registers
; it uses (and DivideBy10 uses) on each recursive call.

; On entry:
; Stack contains oword parameter
; RDI- contains location to place output string

; Note: this function must clean up stack (parameters)
; on return.

rcrsvOtoStr:
        %define value rbp+16
        %define remainder rbp-8
        push rbp
        mov rbp, rsp
        sub rsp, 8
        lea rcx, [value]
        call DivideBy10
        mov [remainder], al

; If the quotient (left in value) is not 0, recursively
; call this routine to output the HO digits.

        mov rax, [value]
        or rax, [value+8]
        jz allDone

        mov rax, [value+8]
        push rax
        mov rax, [value]
        push rax
        call rcrsvOtoStr

allDone: 
        mov al, [remainder]
        or al, '0'
        mov [rdi], al
        inc rdi
        leave
        ret 16                         ; Remove parms from stack

; Nonrecursive shell to the above routine so we don't bother
; saving all the registers on each recursive call.

; On entry:

; RDX:RAX- contains oword to print
; RDI-     buffer to hold string (at least 40 bytes)

otostr:

        push rax
        push rdx
        push rdi

; Special-case zero:

        test rax, rax
        jnz not0
        test rdx, rdx
        jnz not0
        mov byte [rdi], '0'
        inc rdi
        jmp allDone2

not0:
        push rdx
        push rax
        call rcrsvOtoStr

; Zero-terminate string before leaving

allDone2: 
        mov byte [rdi], 0
        pop rdi
        pop rdx
        pop rax
        ret

; i128toStr-
; Converts a 128-bit signed integer to a string

; Inputs;
; RDX:RAX- signed integer to convert
; RDI-     pointer to buffer to receive string

i128toStr:
        push rax
        push rdx
        push rdi

        test rdx, rdx                  ; Is number negative?
        jns notNeg

        mov byte [rdi], '-'
        inc rdi
        neg rdx                        ; 128-bit negation
        neg rax
        sbb rdx, 0

notNeg:
        call otostr
        pop rdi
        pop rdx
        pop rax
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage
        push rdi
        and rsp, -16                   ; Guarantee RSP is now 16-byte-aligned

; Convert b0 to a string and print the result:

        lea rdi, buffer
        mov rax, qword [b0]
        mov rdx, qword [b0+8]
        call i128toStr

        lea rdi, fmtStr1
        lea rsi, buffer
        call _printf

; Convert [b1] to a string and print the result:

        lea rdi, buffer
        mov rax, qword [b1]
        mov rdx, qword [b1+8]
        call i128toStr

        lea rdi, [fmtStr2]
        lea rsi, [buffer]
        call _printf

; Convert [b2] to a string and print the result:

        lea rdi, buffer
        mov rax, qword [b2]
        mov rdx, qword [b2+8]
        call i128toStr

        lea rdi, [fmtStr3]
        lea rsi, [buffer]
        call _printf

; Convert [b3] to a string and print the result:

        lea rdi, buffer
        mov rax, qword [b3]
        mov rdx, qword [b3+8]
        call i128toStr

        lea rdi, [fmtStr4]
        lea rsi, [buffer]
        call _printf

; Convert [b4] to a string and print the result:

        lea rdi, buffer
        mov rax, qword [b4]
        mov rdx, qword [b4+8]
        call i128toStr

        lea rdi, [fmtStr5]
        lea rsi, [buffer]
        call _printf

        pop rdi
        leave
        ret                            ; Returns to caller
