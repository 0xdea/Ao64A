; Listing 6-5

; Demonstration of fcom instructions

; % nasm -f macho64 listing6-5.asm
; % g++ c.cpp listing6-5.o -o listing6-5
; % ./listing6-5

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 6-5", 0
fcomFmt:
        db "fcom %f < %f is %d", nl, 0
fcomFmt2:
        db "fcom(2) %f < %f is %d", nl, 0
fcomFmt3:
        db "fcom st(1) %f < %f is %d", nl, 0
fcomFmt4:
        db "fcom st(1) (2) %f < %f is %d", nl, 0
fcomFmt5:
        db "fcom mem %f < %f is %d", nl, 0
fcomFmt6:
        db "fcom mem %f (2) < %f is %d", nl, 0
fcompFmt:
        db "fcomp %f < %f is %d", nl, 0
fcompFmt2:
        db "fcomp (2) %f < %f is %d", nl, 0
fcompFmt3:
        db "fcomp st(1) %f < %f is %d", nl, 0
fcompFmt4:
        db "fcomp st(1) (2) %f < %f is %d", nl, 0
fcompFmt5:
        db "fcomp mem %f < %f is %d", nl, 0
fcompFmt6:
        db "fcomp mem (2) %f < %f is %d", nl, 0
fcomppFmt:
        db "fcompp %f < %f is %d", nl, 0
fcomppFmt2:
        db "fcompp (2) %f < %f is %d", nl, 0

three:
        dq 3.0
zero:
        dq 0.0
minusTwo:
        dq -2.0

        section .data
fst0:
        dq 0
fst1:
        dq 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; printFP- Prints values of [fst0] and (possibly) [fst1].
; Caller must pass in ptr to fmtStr in RDI.

printFP:
        sub rsp, 40

; Note: if only one double arg in format
; string, printf call will ignore 2nd
; value in XMM1.

        movsd xmm0, [fst0]
        movsd xmm1, [fst1]
        movzx rsi, al
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

; fcom demo

        xor eax, eax
        fld qword [three]
        fld qword [zero]
        fcom
        fstsw ax
        sahf
        setb al
        fstp qword [fst0]
        fstp qword [fst1]
        lea rdi, [fcomFmt]
        call printFP

; fcom demo 2

        xor eax, eax
        fld qword [zero]
        fld qword [three]
        fcom
        fstsw ax
        sahf
        setb al
        fstp qword [fst0]
        fstp qword [fst1]
        lea rdi, [fcomFmt2]
        call printFP

; fcom st(i) demo

        xor eax, eax
        fld qword [three]
        fld qword [zero]
        fcom st1
        fstsw ax
        sahf
        setb al
        fstp qword [fst0]
        fstp qword [fst1]
        lea rdi, [fcomFmt3]
        call printFP

; fcom st(i) demo 2

        xor eax, eax
        fld qword [zero]
        fld qword [three]
        fcom st1
        fstsw ax
        sahf
        setb al
        fstp qword [fst0]
        fstp qword [fst1]
        lea rdi, [fcomFmt4]
        call printFP

; fcom mem64 demo

        xor eax, eax
        fld qword [three]              ; Never on stack so
        fstp qword [fst1]              ; copy for output
        fld qword [zero]
        fcom qword [three]
        fstsw ax
        sahf
        setb al
        fstp qword [fst0]
        lea rdi, [fcomFmt5]
        call printFP

; fcom mem64 demo 2

        xor eax, eax
        fld qword [zero]               ; Never on stack so
        fstp qword [fst1]              ; copy for output
        fld qword [three]
        fcom qword [zero]
        fstsw ax
        sahf
        setb al
        fstp qword [fst0]
        lea rdi, [fcomFmt6]
        call printFP

; fcomp demo

        xor eax, eax
        fld qword [zero]
        fld qword [three]
        fst qword [fst0]               ; Because this gets popped
        fcomp
        fstsw ax
        sahf
        setb al
        fstp qword [fst1]
        lea rdi, [fcompFmt]
        call printFP

; fcomp demo 2

        xor eax, eax
        fld qword [three]
        fld qword [zero]
        fst qword [fst0]               ; Because this gets popped
        fcomp
        fstsw ax
        sahf
        setb al
        fstp qword [fst1]
        lea rdi, [fcompFmt2]
        call printFP

; fcomp demo 3

        xor eax, eax
        fld qword [zero]
        fld qword [three]
        fst qword [fst0]               ; Because this gets popped
        fcomp st1
        fstsw ax
        sahf
        setb al
        fstp qword [fst1]
        lea rdi, [fcompFmt3]
        call printFP

; fcomp demo 4

        xor eax, eax
        fld qword [three]
        fld qword [zero]
        fst qword [fst0]               ; Because this gets popped
        fcomp st1
        fstsw ax
        sahf
        setb al
        fstp qword [fst1]
        lea rdi, [fcompFmt4]
        call printFP

; fcomp demo 5

        xor eax, eax
        fld qword [three]
        fstp qword [fst1]
        fld qword [zero]
        fst qword [fst0]               ; Because this gets popped
        fcomp qword [three]
        fstsw ax
        sahf
        setb al
        lea rdi, [fcompFmt5]
        call printFP

; fcomp demo 6

        xor eax, eax
        fld qword [zero]
        fstp qword [fst1]
        fld qword [three]
        fst qword [fst0]               ; Because this gets popped
        fcomp qword [zero]
        fstsw ax
        sahf
        setb al
        lea rdi, [fcompFmt6]
        call printFP

; fcompp demo

        xor eax, eax
        fld qword [zero]
        fst qword [fst1]               ; Because this gets popped
        fld qword [three]
        fst qword [fst0]               ; Because this gets popped
        fcompp
        fstsw ax
        sahf
        setb al
        lea rdi, [fcomppFmt]
        call printFP

; fcompp demo 2

        xor eax, eax
        fld qword [three]
        fst qword [fst1]               ; Because this gets popped
        fld qword [zero]
        fst qword [fst0]               ; Because this gets popped
        fcompp
        fstsw ax
        sahf
        setb al
        lea rdi, [fcomppFmt2]
        call printFP

        leave
        ret                            ; Returns to caller
