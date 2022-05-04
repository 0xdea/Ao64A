; Listing 4-3

; Demonstration of calls
; to C standard library malloc
; and free functions.

; % nasm -f macho64 listing4-3.asm
; % g++ c.cpp listing4-3.o -o listing4-3 -Wl,-no_pie
; % ./listing4-3

        default rel
        bits	64

        nl 	equ	10

        section	.rodata
ttlStr:
        db 	"Listing 4-3", 0
fmtStr:
        db 	"Addresses returned by malloc: %ph, %ph", nl, 0

        section	.data
ptrVar:
        dq 	0
ptrVar2:
        dq 	0

        section	.text
        extern 	_printf
        extern 	_malloc
        extern 	_free

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:

; "Magic" instruction offered without
; explanation at this point:

        sub rsp, 56

; C standard library malloc function.

; ptr = malloc(byteCnt);

        mov rdi, 256                   ; Allocate 256 bytes
        call _malloc
        mov [ptrVar], rax              ; Save pointer to buffer

        mov rdi, 1024                  ; Allocate 1024 bytes
        call _malloc
        mov [ptrVar2], rax             ; Save pointer to buffer

        lea rdi, fmtStr
        mov rsi, ptrVar
        mov rdx, rax                   ; Print addresses
        call _printf

; Free the storage by calling
; C standard library free function.

; free( bufPtr );

        mov rdi, [ptrVar]
        call _free
        mov rdi, [ptrVar2]
        call _free
        add rsp, 56
        ret                            ; Returns to caller
