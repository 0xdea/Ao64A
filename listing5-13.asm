; Listing 5-13

; Accessing a reference parameter on the stack

; % nasm -f macho64 listing5-13.asm
; % g++ c.cpp listing5-13.o -o listing5-13
; % ./listing5-13

        default rel
        bits	64

        nl equ	10

        section	.rodata
ttlStr:
        db 	"Listing 5-13", 0
fmtStr1:
        db 	"Value of parameter: %d", nl, 0

        section	.data
value1:
        dd 	20
value2:
        dd 	30

        section	.text
        extern	_printf

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

        theParm equ +16
RefParm:
        push rbp
        mov rbp, rsp

        sub rsp, 32                    ; Magic instruction

        lea rdi, [fmtStr1]
        mov rax, [theParm+rbp]         ; Dereference parameter
        mov esi, [rax]
        call _printf

        leave
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48

        lea rax, [value1]
        mov [rsp], rax                 ; Store address on stack
        call RefParm

        lea rax, [value2]
        mov [rsp], rax
        call RefParm

; Clean up, as per Microsoft ABI:

        leave
        ret                            ; Returns to caller
