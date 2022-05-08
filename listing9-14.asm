; Listing 9-14

; String to numeric conversion

; % nasm -f macho64 listing9-14.asm
; % g++ c.cpp listing9-14.o -o listing9-14
; % ./listing9-14

        default rel
        bits 64

        nl equ 10
        tab equ 9
        false equ 0
        true equ 1

        section .rodata
ttlStr:
        db "Listing 9-14", 0
fmtStr1:
        db "strtou: String='%s'", nl
        db " value=%zu", nl, 0

fmtStr2:
        db "Overflow: String='%s'", nl
        db " value=%zx", nl, 0

fmtStr3:
        db "strtoi: String='%s'", nl
        db " value=%zi", nl, 0

unexError:
        db "Unexpected error in program", nl, 0

value1:
        db " 1", 0
value2:
        db "12 ", 0
value3:
        db " 123 ", 0
value4:
        db "1234", 0
value5:
        db "1234567890123456789", 0
value6:
        db "18446744073709551615", 0
OFvalue:
        db "18446744073709551616", 0
OFvalue2:
        db "999999999999999999999", 0

ivalue1:
        db " -1", 0
ivalue2:
        db "-12 ", 0
ivalue3:
        db " -123 ", 0
ivalue4:
        db "-1234", 0
ivalue5:
        db "-1234567890123456789", 0
ivalue6:
        db "-9223372036854775807", 0
OFivalue:
        db "-9223372036854775808", 0
OFivalue2:
        db "-999999999999999999999", 0

        section .data
buffer:
        db 30 dup (0)

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; strtou-
; Converts string data to a 64-bit unsigned integer.

; Input-
; RDI-    Pointer to buffer containing string to convert

; Output-
; RAX-    Contains converted string (if success), error code
; if an error occurs.

; RDI-    Points at first char beyond end of numeric string.
; If error, RDI's value is restored to original value.
; Caller can check character at [RDI] after a
; successful result to see if the character following
; the numeric digits is a legal numeric delimiter.

; C       (carry flag) Set if error occurs, clear if
; conversion was successful. On error, RAX will
; contain 0 (illegal initial character) or
; 0ffffffffffffffffh (overflow).

strtou:
        push rdi                       ; In case we have to restore RDI
        push rdx                       ; Munged by mul
        push rcx                       ; Holds input char

        xor edx, edx                   ; Zero extends!
        xor eax, eax                   ; Zero extends!

; The following loop skips over any whitespace (spaces and
; tabs) that appear at the beginning of the string.

        dec rdi                        ; Because of inc below.
skipWS:
        inc rdi
        mov cl, [rdi]
        cmp cl, ' '
        je skipWS
        cmp al, tab
        je skipWS

; If we don't have a numeric digit at this point,
; return an error.

        cmp cl, '0'                    ; Note: '0' < '1' < ... < '9'
        jb badNumber
        cmp cl, '9'
        ja badNumber

; Okay, the first digit is good. Convert the string
; of digits to numeric form:

convert:
        and ecx, 0fh                   ; Convert to numeric in RCX
        mul qword [ten]                ; Accumulator *= 10
        jc overflow
        add rax, rcx                   ; Accumulator += digit
        jc overflow
        inc rdi                        ; Move on to next character
        mov cl, [rdi]
        cmp cl, '0'
        jb endOfNum
        cmp cl, '9'
        jbe convert

; If we get to this point, we've successfully converted
; the string to numeric form:

endOfNum:
        pop rcx
        pop rdx

; Because the conversion was successful, this procedure
; leaves RDI pointing at the first character beyond the
; converted digits. As such, we don't restore RDI from
; the stack. Just bump the stack pointer up by 8 bytes
; to throw away RDI's saved value.

        add rsp, 8
        clc                            ; Return success in carry flag
        ret

; badNumber- Drop down here if the first character in
; the string was not a valid digit.

badNumber:
        mov rax, 0
        pop rcx
        pop rdx
        pop rdi
        stc                            ; Return error in carry flag
        ret

overflow:
        mov rax, -1                    ; 0FFFFFFFFFFFFFFFFh
        pop rcx
        pop rdx
        pop rdi
        stc                            ; Return error in carry flag
        ret

ten:
        dq 10

; strtoi-
; Converts string data to a 64-bit signed integer.

; Input-
; RDI-    Pointer to buffer containing string to convert

; Output-
; RAX-    Contains converted string (if success), error code
; if an error occurs.

; RDI-    Points at first char beyond end of numeric string.
; If error, RDI's value is restored to original value.
; Caller can check character at [RDI] after a
; successful result to see if the character following
; the numeric digits is a legal numeric delimiter.

; C       (carry flag) Set if error occurs, clear if
; conversion was successful. On error, RAX will
; contain 0 (illegal initial character) or
; 0ffffffffffffffffh (overflow).

strtoi:

        push rdi                       ; In case we have to restore RDI
        sub rsp, 16

; Assume we have a non-negative number.

        mov byte [rsp], false

; The following loop skips over any whitespace (spaces and
; tabs) that appear at the beginning of the string.

        dec rdi                        ; Because of inc below.
skipWS2:
        inc rdi
        mov al, [rdi]
        cmp al, ' '
        je skipWS2
        cmp al, tab
        je skipWS2

; If the first character we've encountered is '-',
; then skip it, but remember that this is a negative
; number.

        cmp al, '-'
        jne notNeg
        mov byte [rsp], true
        inc rdi                        ; Skip '-'

notNeg:
        call strtou                    ; Convert string to integer
        jc hadError

; strtou returned success. Check the negative flag and
; negate the input if the flag contains true.

        cmp byte [rsp], true
        jne itsPosOr0

        cmp rax, [tooBig]              ; number is too big
        ja overflow2
        neg rax
itsPosOr0:
        add rsp, 24                    ; Success, so don't restore RDI
        clc                            ; Return success in carry flag
        ret

; If we have an error, we need to restore RDI from the stack

overflow2:
        mov rax, -1                    ; Indicate overflow
hadError:
        add rsp, 16                    ; Remove locals
        pop rdi
        stc                            ; Return error in carry flag
        ret

tooBig:
        dq 7fffffffffffffffh

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage
        and rsp, -16

; Test unsigned conversions:

        lea rdi, [value1]
        call strtou
        jc UnexpectedError

        lea rdi, [fmtStr1]
        lea rsi, [value1]
        mov rdx, rax
        call _printf

        lea rdi, [value2]
        call strtou
        jc UnexpectedError

        lea rdi, [fmtStr1]
        lea rsi, [value2]
        mov rdx, rax
        call _printf

        lea rdi, [value3]
        call strtou
        jc UnexpectedError

        lea rdi, [fmtStr1]
        lea rsi, [value3]
        mov rdx, rax
        call _printf

        lea rdi, [value4]
        call strtou
        jc UnexpectedError

        lea rdi, [fmtStr1]
        lea rsi, [value4]
        mov rdx, rax
        call _printf

        lea rdi, [value5]
        call strtou
        jc UnexpectedError

        lea rdi, [fmtStr1]
        lea rsi, [value5]
        mov rdx, rax
        call _printf

        lea rdi, [value6]
        call strtou
        jc UnexpectedError

        lea rdi, [fmtStr1]
        lea rsi, [value6]
        mov rdx, rax
        call _printf

        lea rdi, [OFvalue]
        call strtou
        jnc UnexpectedError
        test rax, rax                  ; Non-zero for overflow
        jz UnexpectedError

        lea rdi, [fmtStr2]
        lea rsi, [OFvalue]
        mov rdx, rax
        call _printf

        lea rdi, [OFvalue2]
        call strtou
        jnc UnexpectedError
        test rax, rax                  ; Non-zero for overflow
        jz UnexpectedError

        lea rdi, [fmtStr2]
        lea rsi, [OFvalue2]
        mov rdx, rax
        call _printf

; Test signed conversions:

        lea rdi, [ivalue1]
        call strtoi
        jc UnexpectedError

        lea rdi, [fmtStr3]
        lea rsi, [ivalue1]
        mov rdx, rax
        call _printf

        lea rdi, [ivalue2]
        call strtoi
        jc UnexpectedError

        lea rsi, [fmtStr3]
        lea rsi, [ivalue2]
        mov rdx, rax
        call _printf

        lea rdi, [ivalue3]
        call strtoi
        jc UnexpectedError

        lea rdi, [fmtStr3]
        lea rsi, [ivalue3]
        mov rdx, rax
        call _printf

        lea rdi, [ivalue4]
        call strtoi
        jc UnexpectedError

        lea rdi, [fmtStr3]
        lea rsi, [ivalue4]
        mov rdx, rax
        call _printf

        lea rdi, [ivalue5]
        call strtoi
        jc UnexpectedError

        lea rdi, [fmtStr3]
        lea rsi, [ivalue5]
        mov rdx, rax
        call _printf

        lea rdi, [ivalue6]
        call strtoi
        jc UnexpectedError

        lea rdi, [fmtStr3]
        lea rsi, [ivalue6]
        mov rdx, rax
        call _printf

        lea rdi, [OFivalue]
        call strtoi
        jnc UnexpectedError
        test rax, rax                  ; Non-zero for overflow
        jz UnexpectedError

        lea rdi, [fmtStr2]
        lea rsi, [OFivalue]
        mov rdx, rax
        call _printf

        lea rdi, [OFivalue2]
        call strtoi
        jnc UnexpectedError
        test rax, rax                  ; Non-zero for overflow
        jz UnexpectedError

        lea rdi, [fmtStr2]
        lea rsi, [OFivalue2]
        mov rdx, rax
        call _printf

        jmp allDone

UnexpectedError:
        lea rdi, [unexError]
        call _printf

allDone:
        leave
        ret                            ; Returns to caller
