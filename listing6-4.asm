; Listing 6-4

; Demonstration of various forms of fdiv/fdivr

; % nasm -f macho64 listing6-4.asm
; % g++ c.cpp listing6-4.o -o listing6-4
; % ./listing6-4

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 6-4", 0
fmtSt0St1:
        db "st(0):%f, st(1):%f", nl, 0
fmtDiv1:
        db "fdiv: st0:%f", nl, 0
fmtDiv2:
        db "fdivp: st0:%f", nl, 0
fmtDiv3:
        db "fdiv st(1), st(0): st0:%f, st1:%f", nl, 0
fmtDiv4:
        db "fdiv st(0), st(1): st0:%f, st1:%f", nl, 0
fmtDiv5:
        db "fdivp st(1), st(0): st0:%f", nl, 0
fmtDiv6:
        db "fdiv mem: st0:%f", nl, 0
fmtDiv7:
        db "fdivr st(1), st(0): st0:%f, st1:%f", nl, 0
fmtDiv8:
        db "fdivr st(0), st(1): st0:%f, st1:%f", nl, 0
fmtDiv9:
        db "fdivrp st(1), st(0): st0:%f", nl, 0
fmtDiv10:
        db "fdivr mem: st0:%f", nl, 0

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
        lea rax, ttlStr
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

; Demonstrate various fdiv instructions:

        mov rax, qword [three]
        mov qword [fst1], rax
        mov rax, qword [minusTwo]
        mov qword [fst0], rax
        lea rdi, [fmtSt0St1]
        call printFP

; fdiv (same as fdivp)

        fld qword [three]
        fld qword [minusTwo]
        fdiv                           ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtDiv1]
        call printFP

; fdivp:

        fld qword [three]
        fld qword [minusTwo]
        fdivp                          ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtDiv2]
        call printFP

; fdiv st(1), st(0)

        fld qword [three]
        fld qword [minusTwo]
        fdiv st1, st0
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtDiv3]
        call printFP

; fdiv st0, st1

        fld qword [three]
        fld qword [minusTwo]
        fdiv st0, st1
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtDiv4]
        call printFP

; fdivp st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fdivp st1, st0
        fstp qword [fst0]

        lea rdi, [fmtDiv5]
        call printFP

; fdiv mem64

        fld qword [three]
        fdiv qword [minusTwo]
        fstp qword [fst0]

        lea rdi, [fmtDiv6]
        call printFP

; fdivr st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fdivr st1, st0
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtDiv7]
        call printFP

; fdivr st0, st1

        fld qword [three]
        fld qword [minusTwo]
        fdivr st0, st1
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtDiv8]
        call printFP

; fdivrp st1, st0

        fld qword [three]
        fld qword [minusTwo]
        fdivrp st1, st0
        fstp qword [fst0]

        lea rdi, [fmtDiv9]
        call printFP

; fdivr mem64

        fld qword [three]
        fdivr qword [minusTwo]
        fstp qword [fst0]

        lea rdi, [fmtDiv10]
        call printFP

        leave
        ret                            ; Returns to caller
