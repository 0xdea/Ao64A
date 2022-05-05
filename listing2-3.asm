; Listing 2-3

; Demonstrate two's complement operation and input of numeric values.

; % nasm -f macho64 listing2-3.asm
; % g++ c.cpp listing2-3.o -o listing2-3
; % ./listing2-3

        default rel
        bits	64

        maxLen 	equ	256
        nl 	equ	10                     ; ASCII code for

        section .data                  ; Initialized data segment
titleStr:
        db 	'Listing 2-3', 0

prompt1:
        db 	"Enter an integer between 0 and 127:", 0
fmtStr1:
        db 	"Value in hexadecimal: %x", nl, 0
fmtStr2:
        db 	"Invert all the bits (hexadecimal): %x", nl, 0
fmtStr3:
        db 	"Add 1 (hexadecimal): %x", nl, 0
fmtStr4:
        db 	"Output as signed integer: %d", nl, 0
fmtStr5:
        db 	"Using neg instruction: %d", nl, 0

intValue:
        dq	0
input:
        db 	maxLen dup (0)

        section .text
        extern 	_printf
        extern 	_atoi
        extern 	_readLine

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, titleStr
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:

; "Magic" instruction offered without explanation at this point:

        sub rsp, 56

; Read an unsigned integer from the user: This code will blindly
; assume that the user's input was correct. The atoi function returns
; zero if there was some sort of error on the user input. Later
; chapters in Ao64A will describe how to check for errors from the
; user.

        lea rdi, [prompt1]
        call _printf

        lea rdi, [input]
        mov rsi, maxLen
        call _readLine

; Call C stdlib atoi function.

; i = atoi( str )

        lea rdi, [input]
        call _atoi
        ; and rax, 0ffh ; Only keep L.O. eight bits
        mov [intValue], rax

; Print the [input] value (in decimal) as a hexadecimal number:

        lea rdi, [fmtStr1]
        mov rsi, rax
        call _printf

; Perform the two's complement operation on the [input] number.
; Begin by inverting all the bits (just work with a byte here).

        mov rdx, [intValue]
        not dl                         ; Only work with 8-bit values!
        mov rsi, rdx
        lea rdi, [fmtStr2]
        call _printf

; Invert all the bits and add 1 (still working with just a byte)

        mov rsi, [intValue]
        not rsi
        add rsi, 1
        and rsi, 0ffh                  ; Only keep L.O. eight bits
        lea rdi, [fmtStr3]
        call _printf

; Negate the value and print as a signed integer (work with a full
; integer here, because C++ %d format specifier expects a 32-bit
; integer. H.O. 32 bits of RSI get ignored by C++.

        mov rsi, [intValue]
        not rsi
        add rsi, 1
        lea rdi, [fmtStr4]
        call _printf

; Negate the value using the neg instruction.

        mov rsi, [intValue]
        neg rsi
        lea rdi, [fmtStr5]
        call _printf

; Another "magic" instruction that undoes the effect of the previous
; one before this procedure returns to its caller.

        add rsp, 56
        ret                            ; Returns to caller
