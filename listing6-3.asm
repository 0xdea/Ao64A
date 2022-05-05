; Listing 6-3

; Demonstration of various forms of fmul

; % nasm -f macho64 listing6-3.asm
; % g++ c.cpp listing6-3.o -o listing6-3
; % ./listing6-3

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 6-3", 0
fmtSt0St1:
        db "st(0):%f, st(1):%f", nl, 0
fmtMul1:
        db "fmul: st0:%f", nl, 0
fmtMul2:
        db "fmulp: st0:%f", nl, 0
fmtMul3:
        db "fmul st(1), st(0): st0:%f, st1:%f", nl, 0
fmtMul4:
        db "fmul st(0), st(1): st0:%f, st1:%f", nl, 0
fmtMul5:
        db "fmulp st(1), st(0): st0:%f", nl, 0
fmtMul6:
        db "fmul mem: st0:%f", nl, 0

zero:
        dq 0.0
three:
        dq 3.0
minusTwo:
        dq -2.0

        section .data
fst0:
        dq 0.0
fst1:
        dq 0.0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; printFP- Prints values of fst0 and (possibly) fst1.
; Caller must pass in ptr to fmtStr in RDI.

printFP:
        sub rsp, 40

; Note: if only one double arg in format
; string, printf call will ignore 2nd
; value in XMM1.

        movsd xmm0, [fst0]
        movsd xmm1, [fst1]
        mov al, 2                     ; Two args in XMM regs
        call _printf
        add rsp, 40
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48                    ; Shadow storage

; Demonstrate various fmul instructions:

        mov rax, qword [three]
        mov qword [fst1], rax
        mov rax, qword [minusTwo]
        mov qword [fst0], rax
        lea rdi, [fmtSt0St1]
        call printFP

; fmul (same as fmulp)

        fld qword [three]
        fld qword [minusTwo]
        fmul                           ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtMul1]
        call printFP

; fmulp:

        fld qword [three]
        fld qword [minusTwo]
        fmulp                          ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtMul2]
        call printFP

; fmul st(1), st(0)

        fld qword [three]
        fld qword [minusTwo]
        fmul st1, st0
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtMul3]
        call printFP

; fmul st0, st1

        fld qword [three]
        fld qword [minusTwo]
        fmul st0, st1
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtMul4]
        call printFP

; fmulp st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fmulp st1, st0
        fstp qword [fst0]

        lea rdi, [fmtMul5]
        call printFP

; fmulp mem64

        fld qword [three]
        fmul qword [minusTwo]
        fstp qword [fst0]

        lea rdi, [fmtMul6]
        call printFP

        leave
        ret                            ; Returns to caller
