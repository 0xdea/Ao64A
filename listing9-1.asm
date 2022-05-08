; Listing 9-1

; Convert a byte value to 2 hexadecimal digits

; % nasm -f macho64 listing9-1.asm
; % g++ c.cpp listing9-1.o -o listing9-1
; % ./listing9-1

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db 	"Listing 9-1", 0
fmtStr1:
        db 	"Value=%x, as hex=%c%c"
        db 	nl, 0

        section	.text
        extern	_printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, ttlStr
        ret

; btoh-

; This procedure converts the binary value
; in the AL register to 2 hexadecimal
; characters and returns those characters
; in the AH (HO hibble) and AL (LO nibble)
; registers.

btoh:

        mov ah, al                     ; Do HO nibble first
        shr ah, 4                      ; Move HO nibble to LO
        or ah, '0'                     ; Convert to char
        cmp ah, '9'+1                  ; Is it 'A'..'F'?
        jb AHisGood

; Convert 3ah..3fh to 'A'..'F'

        add ah, 7

; Process the LO nibble here

AHisGood:
        and al, 0Fh                    ; Strip away HO nibble
        or al, '0'                     ; Convert to char
        cmp al, '9'+1                  ; Is it 'A'..'F'?
        jb ALisGood

; Convert 3ah..3fh to 'A'..'F'

        add al, 7
ALisGood:
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage

        mov al, 0aah
        call btoh

        lea rdi, [fmtStr1]
        mov esi, 0aah
        movzx edx, ax                  ; Can't move ah into dl!
        shr dx, 8
        mov cl, al
        call _printf

        leave
        ret                            ; Returns to caller
