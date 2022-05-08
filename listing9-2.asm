; Listing 8-5

; Numeric to hex string functions

; % nasm -f macho64 listing9-2.asm
; % g++ c.cpp listing9-2.o -o listing9-2
; % ./listing9-2

        default rel
        bits 64

        nl equ 10

        section .rodata
ttlStr:
        db 	"Listing 8-5", 0
fmtStr1:
        db 	"btoStr: Value=%zx, string=%s"
        db 	nl, 0

fmtStr2:
        db 	"wtoStr: Value=%zx, string=%s"
        db 	nl, 0

fmtStr3:
        db 	"dtoStr: Value=%zx, string=%s"
        db 	nl, 0

fmtStr4:
        db 	"qtoStr: Value=%zx, string=%s"
        db 	nl, 0

        section	.data
buffer:
        db 	20 dup (0)

        section	.text
        extern	_printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
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

; btoStr-

; Converts the byte in AL to a string of hexadecimal
; characters and stores them at the buffer pointed at
; by RDI. Buffer must have room for at least 3 bytes.
; This function zero-terminates the string.

btoStr:
        push rax
        call btoh                      ; Do conversion here

; Create a zero-terminated string at [RDI] from the
; two characters we converted to hex format:

        mov [rdi], ah
        mov [rdi+1], al
        mov byte [rdi+2], 0
        pop rax
        ret

; wtoStr-

; Converts the word in AX to a string of hexadecimal
; characters and stores them at the buffer pointed at
; by RDI. Buffer must have room for at least 5 bytes.
; This function zero-terminates the string.

wtoStr:
        push rdi
        push rax                       ; Note: leaves LO byte at [rsp]

; Use btoStr to convert HO byte to a string:

        mov al, ah
        call btoStr

        mov al, [rsp]                  ; Get LO byte
        add rdi, 2                     ; Skip HO chars
        call btoStr

        pop rax
        pop rdi
        ret

; dtoStr-

; Converts the dword in EAX to a string of hexadecimal
; characters and stores them at the buffer pointed at
; by RDI. Buffer must have room for at least 9 bytes.
; This function zero-terminates the string.

dtoStr:
        push rdi
        push rax                       ; Note: leaves LO word at [rsp]

; Use wtoStr to convert HO word to a string:

        shr eax, 16
        call wtoStr

        mov ax, [rsp]                  ; Get LO word
        add rdi, 4                     ; Skip HO chars
        call wtoStr

        pop rax
        pop rdi
        ret

; qtoStr-

; Converts the qword in RAX to a string of hexadecimal
; characters and stores them at the buffer pointed at
; by RDI. Buffer must have room for at least 17 bytes.
; This function zero-terminates the string.

qtoStr:
        push rdi
        push rax                       ; Note: leaves LO dword at [rsp]

; Use dtoStr to convert HO dword to a string:

        shr rax, 32
        call dtoStr

        mov eax, [rsp]                 ; Get LO dword
        add rdi, 8                     ; Skip HO chars
        call dtoStr

        pop rax
        pop rdi
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rdi
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage
        and rsp, -16                   ; Guarantee RSP is now 16-byte-aligned

; Demonstrate call to btoStr:
        lea rdi, [buffer]
        mov al, 0aah
        call btoStr

        mov rdx, rdi
        lea rdi, [fmtStr1]
        mov esi, eax
        call _printf

; Demonstrate call to wtoStr:
        lea rdi, [buffer]
        mov ax, 0a55ah
        call wtoStr

        mov rdx, rdi
        lea rdi, [fmtStr2]
        mov esi, eax
        call _printf

; Demonstrate call to dtoStr:
        lea rdi, [buffer]
        mov eax, 0aa55FF00h
        call dtoStr

        mov rdx, rdi
        lea rdi, [fmtStr3]
        mov esi, eax
        call _printf

; Demonstrate call to qtoStr:
        lea rdi, [buffer]
        mov rax, 1234567890abcdefh
        call qtoStr

        mov rdx, rdi
        lea rdi, [fmtStr4]
        mov rsi, rax
        call _printf

        leave
        pop rdi
        ret                            ; Returns to caller
