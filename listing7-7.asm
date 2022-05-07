; Listing 7-6

; An indirect jump state machine example

; % nasm -f macho64 listing7-7.asm
; % g++ c.cpp listing7-7.o -o listing7-7
; % ./listing7-7

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db "Listing 7-6", 0
fmtStr0:
        db "Calling StateMachine, "
        db "state=0, EAX=5, ECX=6", nl, 0

fmtStr0b:
        db "Calling StateMachine, "
        db "state=0, EAX=1, ECX=2", nl, 0

fmtStrx:
        db "Back from StateMachine, "
        db "EAX=%d", nl, 0

fmtStr1:
        db "Calling StateMachine, "
        db "state=1, EAX=50, ECX=60", nl, 0

fmtStr2:
        db "Calling StateMachine, "
        db "state=2, EAX=10, ECX=20", nl, 0

fmtStr3:
        db "Calling StateMachine, "
        db "state=3, EAX=50, ECX=5", nl, 0

        section .data
state:
        dq state0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; StateMachine version 2.0- using an indirect jump.

StateMachine:

        jmp qword [state]

; State 0: Add ecx to eax and switch to State 1:

state0:
        add eax, ecx
        lea rcx, [state1]
        mov qword [state], rcx
        ret

; State 1: Subtract ecx from eax and switch to state 2:

state1:
        sub eax, ecx
        lea rcx, [state2]
        mov qword [state], rcx
        ret

; If this is State 2, multiply ecx by eax and switch to state 3:

state2:
        imul eax, ecx
        lea rcx, [state3]
        mov qword [state], rcx
        ret

state3:
        push rdx                       ; Preserve this 'cause it gets whacked by div.
        xor edx, edx                   ; Zero extend eax into edx.
        div ecx
        pop rdx                        ; Restore edx's value preserved above.
        lea rcx, [state0]
        mov qword [state], rcx
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 48                    ; Shadow storage

        lea rcx, [state0]
        mov qword [state], rcx         ; Just to be safe

; Demonstrate state 0:

        lea rdi, [fmtStr0]
        call _printf

        mov eax, 5
        mov ecx, 6
        call StateMachine

        lea rdi, [fmtStrx]
        mov rsi, rax
        call _printf

; Demonstrate state 1:

        lea rdi, [fmtStr1]
        call _printf

        mov eax, 50
        mov ecx, 60
        call StateMachine

        lea rdi, [fmtStrx]
        mov rsi, rax
        call _printf

; Demonstrate state 2:

        lea rdi, [fmtStr2]
        call _printf

        mov eax, 10
        mov ecx, 20
        call StateMachine

        lea rdi, [fmtStrx]
        mov rsi, rax
        call _printf

; Demonstrate state 3:

        lea rdi, [fmtStr3]
        call _printf

        mov eax, 50
        mov ecx, 5
        call StateMachine

        lea rdi, [fmtStrx]
        mov rsi, rax
        call _printf

; Demonstrate back in state 0:

        lea rdi, [fmtStr0b]
        call _printf

        mov eax, 1
        mov ecx, 2
        call StateMachine

        lea rdi, [fmtStrx]
        mov rsi, rax
        call _printf

        leave
        ret                            ; Returns to caller
