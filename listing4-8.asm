; Listing 4-8

; Sample struct initialization example.

; % nasm -f macho64 listing4-8.asm
; % g++ c.cpp listing4-8.o -o listing4-8
; % ./listing4-8

        default rel
        bits	64

        nl 	equ 10

        section	.rodata
ttlStr:
        db 	"Listing 4-8", 0
fmtStr:
        db 	"aString: maxLen:%d, len:%d, string data:'%s'"
        db 	nl, 0

; Define a struct for a string descriptor:

struc	        strDesc
        .maxLen resd 	1
        .len    resd 	1
        .strPtr resq    1
endstruc

        section	.data

; Here's the string data we will initialize the
; string descriptor with:

charData:
        db 	"Initial String Data", 0
        len 	equ	($-charData)          ; Includes zero byte

; Create a string descriptor initialized with
; the charData string value:

aString:
        dd	len
        dd	len
        dq	charData

        section	.text
        extern	_printf

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

; Display the fields of the string descriptor.

        lea rdi, [fmtStr]
        mov esi, [aString+strDesc.maxLen] ; Zero extends!
        mov edx, [aString+strDesc.len]    ; Zero extends!
        mov rcx, [aString+strDesc.strPtr]
        call _printf

        add rsp, 56                       ; Restore RSP
        ret                               ; Returns to caller
