; Listing 6-2

; Demonstration of various forms of fsub/fsubrl

; % nasm -f macho64 listing6-2.asm
; % g++ c.cpp listing6-2.o -o listing6-2
; % ./listing6-2

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 6-2", 0
fmtSt0St1:
        db "st(0):%f, st(1):%f", nl, 0
fmtSub1:
        db "fsub: st0:%f", nl, 0
fmtSub2:
        db "fsubp: st0:%f", nl, 0
fmtSub3:
        db "fsub st(1), st(0): st0:%f, st1:%f", nl, 0
fmtSub4:
        db "fsub st(0), st(1): st0:%f, st1:%f", nl, 0
fmtSub5:
        db "fsubp st(1), st(0): st0:%f", nl, 0
fmtSub6:
        db "fsub mem: st0:%f", nl, 0
fmtSub7:
        db "fsubr st(1), st(0): st0:%f, st1:%f", nl, 0
fmtSub8:
        db "fsubr st(0), st(1): st0:%f, st1:%f", nl, 0
fmtSub9:
        db "fsubrp st(1), st(0): st0:%f", nl, 0
fmtSub10:
        db "fsubr mem: st0:%f", nl, 0

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
        push rbp
        mov rbp, rsp
        sub rsp, 48

; Note: if only one double arg in format
; string, printf call will ignore 2nd
; value in XMM1.

        movsd xmm0, [fst0]
        movsd xmm1, [fst1]
        mov al, 2                     ; Two args in XMM regs
        call _printf
        leave
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48                    ; Shadow storage

; Demonstrate various fsub instructions:

        mov rax, [three]
        mov [fst1], rax
        mov rax, [minusTwo]
        mov [fst0], rax
        lea rdi, [fmtSt0St1]
        call printFP

; fsub (same as fsubp)

        fld qword [three]
        fld qword [minusTwo]
        fsub                           ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtSub1]
        call printFP

; fsubp:

        fld qword [three]
        fld qword [minusTwo]
        fsubp                          ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtSub2]
        call printFP

; fsub st(1), st(0)

        fld qword [three]
        fld qword [minusTwo]
        fsub st1, st0
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtSub3]
        call printFP

; fsub st0, st1

        fld qword [three]
        fld qword [minusTwo]
        fsub st0, st1
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, fmtSub4
        call printFP

; fsubp st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fsubp st1, st0
        fstp qword [fst0]

        lea rdi, [fmtSub5]
        call printFP

; fsub mem64

        fld qword [three]
        fsub qword [minusTwo]
        fstp qword [fst0]

        lea rdi, [fmtSub6]
        call printFP

; fsubr st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fsubr st1, st0
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtSub7]
        call printFP

; fsubr st0, st1

        fld qword [three]
        fld qword [minusTwo]
        fsubr st0, st1
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtSub8]
        call printFP

; fsubrp st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fsubrp st1, st0
        fstp qword [fst0]

        lea rdi, [fmtSub9]
        call printFP

; fsubr mem64

        fld qword [three]
        fsubr qword [minusTwo]
        fstp qword [fst0]

        lea rdi, [fmtSub10]
        call printFP

        leave
        ret                            ; Returns to caller
