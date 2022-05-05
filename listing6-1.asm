; Listing 6-1

; Demonstration of various forms of fadd

; % nasm -f macho64 listing6-1.asm
; % g++ c.cpp listing6-1.o -o listing6-1
; % ./listing6-1

        default rel
        bits	64

        nl equ	10

        section	.rodata
ttlStr:
        db 	"Listing 6-1", 0
fmtSt0St1:
        db 	"st(0):%f, st(1):%f", nl, 0
fmtAdd1:
        db 	"fadd: st0:%f", nl, 0
fmtAdd2:
        db 	"faddp: st0:%f", nl, 0
fmtAdd3:
        db 	"fadd st(1), st(0): st0:%f, st1:%f", nl, 0
fmtAdd4:
        db 	"fadd st(0), st(1): st0:%f, st1:%f", nl, 0
fmtAdd5:
        db 	"faddp st(1), st(0): st0:%f", nl, 0
fmtAdd6:
        db 	"fadd mem: st0:%f", nl, 0

zero:
        dq 	0.0
one:
        dq 	1.0
two:
        dq 	2.0
minusTwo:
        dq 	-2.0

        section	.data
fst0:
        dq 	0.0
fst1:
        dq 	0.0

        section	.text
        extern	_printf

; Return program title to C++ program:

        global	_getTitle
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

        global	_asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48                    ; Shadow storage

; Demonstrate various fadd instructions:

        mov rax, [one]
        mov [fst1], rax
        mov rax, [minusTwo]
        mov [fst0], rax
        lea rdi, [fmtSt0St1]
        call printFP

; fadd (same as faddp)

        fld qword [one]
        fld qword [minusTwo]
        fadd                           ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtAdd1]
        call printFP

; faddp:

        fld qword [one]
        fld qword [minusTwo]
        faddp                          ; Pops st(0)!
        fstp qword [fst0]

        lea rdi, [fmtAdd2]
        call printFP

; fadd st(1), st(0)

        fld qword [one]
        fld qword [minusTwo]
        fadd st1, st0
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, [fmtAdd3]
        call printFP

; fadd st(0), st(1)

        fld qword [one]
        fld qword [minusTwo]
        fadd st0, st1
        fstp qword [fst0]
        fstp qword [fst1]

        lea rdi, fmtAdd4
        call printFP

; faddp st(1), st(0)

        fld qword [one]
        fld qword [minusTwo]
        faddp st1, st0
        fstp qword [fst0]

        lea rdi, [fmtAdd5]
        call printFP

; faddp mem64

        fld qword [one]
        fadd qword [two]
        fstp qword [fst0]

        lea rdi, [fmtAdd6]
        call printFP

        leave
        ret                            ; Returns to caller
