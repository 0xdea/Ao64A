; Listing 2-2

; Demonstrate AND, OR, XOR, and NOT logical instructions.

; % nasm -f macho64 listing2-2.asm
; % g++ c.cpp listing2-2.o -o listing2-2
; % ./listing2-2

        default rel
        bits	64

        nl 	equ	10                     ; ASCII code for newline

        section .data                  ; Initialized data segment
leftOp:
        dd 	0f0f0f0fh
rightOp1:
        dd 	0f0f0f0f0h
rightOp2:
        dd 	12345678h

titleStr:
        db 	'Listing 2-2', 0

fmtStr1:
        db 	"%lx AND %lx = %lx", nl, 0
fmtStr2:
        db 	"%lx OR %lx = %lx", nl, 0
fmtStr3:
        db 	"%lx XOR %lx = %lx", nl, 0
fmtStr4:
        db 	"NOT %lx = %lx", nl, 0

        section .text
        extern	_printf

; Return program title to C++ program:

        global	_getTitle
_getTitle:

; Load address of "titleStr" into the RAX register (RAX holds the
; function return result) and return back to the caller:

        lea rax, [titleStr]
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:

; "Magic" instruction offered without explanation at this point:

        sub rsp, 56

; Demonstrate the AND instruction

        lea rdi, [fmtStr1]
        mov esi, [leftOp]
        mov edx, [rightOp1]
        mov ecx, esi                   ; Compute [leftOp]
        and ecx, edx                   ; AND [rightOp1]
        call _printf

        lea rdi, [fmtStr1]
        mov esi, [leftOp]
        mov edx, [rightOp2]
        mov ecx, edx
        and ecx, esi
        call _printf

; Demonstrate the OR instruction

        lea rdi, [fmtStr2]
        mov esi, [leftOp]
        mov edx, [rightOp1]
        mov ecx, esi                   ; Compute [leftOp]
        or ecx, edx                    ; OR [rightOp1]
        call _printf

        lea rdi, [fmtStr2]
        mov esi, [leftOp]
        mov edx, [rightOp2]
        mov ecx, edx
        or ecx, esi
        call _printf

; Demonstrate the XOR instruction

        lea rdi, fmtStr3
        mov esi, [leftOp]
        mov edx, [rightOp1]
        mov ecx, esi                   ; Compute [leftOp]
        xor ecx, edx                   ; XOR [rightOp1]
        call _printf

        lea rdi, [fmtStr3]
        mov esi, [leftOp]
        mov edx, [rightOp2]
        mov ecx, edx
        xor ecx, esi
        call _printf

; Demonstrate the NOT instruction

        lea rdi, [fmtStr4]
        mov esi, [leftOp]
        mov edx, esi                   ; Compute not [leftOp]
        not edx
        call _printf

        lea rdi, [fmtStr4]
        mov esi, [rightOp1]
        mov edx, esi                   ; Compute not [rightOp1]
        not edx
        call _printf

        lea rdi, [fmtStr4]
        mov esi, [rightOp2]
        mov edx, esi                   ; Compute not [rightOp2]
        not edx
        call _printf

; Another "magic" instruction that undoes the effect of the previous
; one before this procedure returns to its caller.

        add rsp, 56

        ret                            ; Returns to caller
