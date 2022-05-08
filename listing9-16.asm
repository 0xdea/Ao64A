; Listing 9-16

; 128-bit hexadecimal string to numeric conversion

; % nasm -f macho64 listing9-16.asm
; % g++ c.cpp listing9-16.o -o listing9-16
; % ./listing9-16

        default rel
        bits 64

        nl equ 10
        tab equ 9
        false equ 0
        true equ 1

        section .rodata
ttlStr:
        db "Listing 9-16", 0
fmtStr1:
        db "strtoh128: String='%s' value=%zx%zx", nl, 0

hexStr:
        db "1234567890abcdef1234567890abcdef", 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; strtoh128-
; Converts string data to a 128-bit unsigned integer.

; Input-
; RDI-    Pointer to buffer containing string to convert

; Output-
; RDX:RAX-Contains converted string (if success), error code
; if an error occurs.

; RDI-    Points at first char beyond end of hex string.
; If error, RDI's value is restored to original value.
; Caller can check character at [RDI] after a
; successful result to see if the character following
; the numeric digits is a legal numeric delimiter.

; C       (carry flag) Set if error occurs, clear if
; conversion was successful. On error, RAX will
; contain 0 (illegal initial character) or
; 0ffffffffffffffffh (overflow).

strtoh128:
        push rbx                       ; Special mask value
        push rcx                       ; Input char to process
        push rdi                       ; In case we have to restore RDI

; This code will use the value in RDX to test and see if overflow
; will occur in RAX when shifting to the left 4 bits:

        mov rbx, 0F000000000000000h
        xor eax, eax                   ; Zero out accumulator.
        xor edx, edx

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

; If we don't have a hexadecimal digit at this point,
; return an error.

        cmp cl, '0'                    ; Note: '0' < '1' < ... < '9'
        jb badNumber
        cmp cl, '9'
        jbe convert
        and cl, 5fh                    ; Cheesy LC->UC conversion
        cmp cl, 'A'
        jb badNumber
        cmp cl, 'F'
        ja badNumber
        sub cl, 7                      ; Maps 41h..46h->3ah..3fh

; Okay, the first digit is good. Convert the string
; of digits to numeric form:

convert:
        test rdx, rbx                  ; See if adding in the current
        jnz overflow                   ; digit will cause an overflow

        and ecx, 0fh                   ; Convert to numeric in RCX

; Multiple 64-bit accumulator by 16 and add in new digit:

        shld rdx, rax, 4
        shl rax, 4
        add al, cl                     ; Never overflows outside LO 4 bits

; Move on to next character

        inc rdi
        mov cl, [rdi]
        cmp cl, '0'
        jb endOfNum
        cmp cl, '9'
        jbe convert

        and cl, 5fh                    ; Cheesy LC->UC conversion
        cmp cl, 'A'
        jb endOfNum
        cmp cl, 'F'
        ja endOfNum
        sub cl, 7                      ; Maps 41h..46h->3ah..3fh
        jmp convert

; If we get to this point, we've successfully converted
; the string to numeric form:

endOfNum:

; Because the conversion was successful, this procedure
; leaves RDI pointing at the first character beyond the
; converted digits. As such, we don't restore RDI from
; the stack. Just bump the stack pointer up by 8 bytes
; to throw away RDI's saved value; must also remove

        add rsp, 8                     ; Remove original RDI value
        pop rcx                        ; Restore RCX
        pop rbx                        ; Restore RBX
        clc                            ; Return success in carry flag
        ret

; badNumber- Drop down here if the first character in
; the string was not a valid digit.

badNumber:
        xor rax, rax
        jmp errorExit

overflow:
        or rax, -1                     ; Return -1 as error on overflow
errorExit:
        pop rdi                        ; Restore RDI if an error occurs
        pop rcx
        pop rbx
        stc                            ; Return error in carry flag
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage
        and rsp, -16

; Test hexadecimal conversion:

        lea rdi, [hexStr]
        call strtoh128

        lea rdi, [fmtStr1]
        lea rsi, [hexStr]
        mov rcx, rax                   ; RDX is already populated by strtoh128
        call _printf

allDone:
        leave
        ret                            ; Returns to caller
