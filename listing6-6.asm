; Listing 6-6

; Demonstration of fcomi and fcomip instructions

; % nasm -f macho64 listing6-6.asm
; % g++ c.cpp listing6-6.o -o listing6-6
; % ./listing6-6

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 6-6", 0
fcomiFmt:
        db "fcomi %f < %f is %d", nl, 0
fcomiFmt2:
        db "fcomi(2) %f < %f is %d", nl, 0
fcomipFmt:
        db "fcomip %f < %f is %d", nl, 0
fcomipFmt2:
        db "fcomip (2) %f < %f is %d", nl, 0

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

; printFP- Prints values of fst0 and (possibly) fst1.
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

; Test to see if 0 < 3
; Note: st(0) contains zero, st(2) contains three

        xor eax, eax
        fld qword [three]
        fld qword [zero]
        fcomi st0, st1
        setb al
        fstp qword [fst0]
        fstp qword [fst1]
        lea rdi, [fcomiFmt]
        call printFP

; Test to see if 3 < 0
; Note: st0 contains qword [zero], st(2) contains qword [three]

        xor eax, eax
        fld qword [zero]
        fld qword [three]
        fcomi st0, st1
        setb al
        fstp qword [fst0]
        fstp qword [fst1]
        lea rdi, [fcomiFmt2]
        call printFP

; Test to see if 3 < 0
; Note: st0 contains qword [zero], st(2) contains qword [three]

        xor eax, eax
        fld qword [zero]
        fld qword [three]
        fst qword [fst0]               ; Because this gets popped
        fcomip st0, st1
        setb al
        fstp qword [fst1]
        lea rdi, [fcomipFmt]
        call printFP

; Test to see if 0 < 3
; Note: st0 contains qword [zero], st(2) contains qword [three]

        xor eax, eax
        fld qword [three]
        fld qword [zero]
        fst qword [fst0]               ; Because this gets popped
        fcomip st0, st1
        setb al
        fstp qword [fst1]
        lea rdi, [fcomipFmt2]
        call printFP

        leave
        ret                            ; Returns to caller
