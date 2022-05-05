; Listing 5-12

; Accessing a parameter on the stack

; % nasm -f macho64 listing5-12.asm
; % g++ c.cpp listing5-12.o -o listing5-12
; % ./listing5-12

        default rel
        bits	64

        nl equ	10

        section	.rodata
ttlStr:
        db 	"Listing 5-12", 0
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
ValueParm:
        push rbp
        mov rbp, rsp

        sub rsp, 32                    ; Magic instruction

        lea rdi, [fmtStr1]
        mov esi, [theParm+rbp]
        call _printf

        leave
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48

        mov eax, [value1]
        mov [rsp], eax                 ; Store parameter on stack
        call ValueParm

        mov eax, [value2]
        mov [rsp], eax
        call ValueParm

; Clean up, as per Microsoft ABI:

        leave
        ret                            ; Returns to caller
