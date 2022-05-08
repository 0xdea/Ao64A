; Listing 9-19

; Real string to floating-point conversion

; % nasm -f macho64 listing9-19.asm
; % g++ c.cpp listing9-19.o -o listing9-19
; % ./listing9-19

        default rel
        bits 64

        nl equ 10
        tab equ 9
        false equ 0
        true equ 1

        section .rodata
ttlStr:
        db "Listing 9-19", 0
fmtStr1:
        db "strToR10: str='%s', value=%e", nl, 0

fStr1a:
        db "1.234e56", 0
fStr1b:
        db "-1.234e56", 0
fStr1c:
        db "1.234e-56", 0
fStr1d:
        db "-1.234e-56", 0
fStr2a:
        db "1.23", 0
fStr2b:
        db "-1.23", 0
fStr3a:
        db "1", 0
fStr3b:
        db "-1", 0
fStr4a:
        db "0.1", 0
fStr4b:
        db "-0.1", 0
fStr4c:
        db "0000000.1", 0
fStr4d:
        db "-0000000.1", 0
fStr4e:
        db "0.1000000", 0
fStr4f:
        db "-0.1000000", 0
fStr4g:
        db "0.0000001", 0
fStr4h:
        db "-0.0000001", 0
fStr4i:
        db ".1", 0
fStr4j:
        db "-.1", 0

values:
        dq fStr1a, fStr1b, fStr1c, fStr1d
        dq fStr2a, fStr2b
        dq fStr3a, fStr3b
        dq fStr4a, fStr4b, fStr4c, fStr4d
        dq fStr4e, fStr4f, fStr4g, fStr4h
        dq fStr4i, fStr4j
        dq 0

        align 8
PotTbl:
        dt 1.0e+4096
        dt 1.0e+2048
        dt 1.0e+1024
        dt 1.0e+512
        dt 1.0e+256
        dt 1.0e+128
        dt 1.0e+64
        dt 1.0e+32
        dt 1.0e+16
        dt 1.0e+8
        dt 1.0e+4
        dt 1.0e+2
        dt 1.0e+1
        dt 1.0e+0

        section .data
r8Val:
        dq 0

        section .text
        extern _printf

; Return program title to C++ program:

        global _getTitle
_getTitle:
        lea rax, ttlStr
        ret

; Used for debugging:

print:
        push    rdi
        push    rsi
        push    rdx
        push    rcx
        push    r8
        push    r9
        push    r10
        push    r11
        push    rax

        push rbp
        mov rbp, rsp
        sub rsp, 40
        and rsp, -16

        mov rdi, [rbp+80]              ; Return address
        call _printf

        mov rsi, [rbp+80]
        dec rsi
skipTo0:
        inc rsi
        cmp byte [rsi], 0
        jne skipTo0
        inc rsi
        mov [rbp+80], rsi

        leave
        pop     rax
        pop     r11
        pop     r10
        pop     r9
        pop     r8
        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        ret

; *********************************************************

; strToR10-

; RSI points at a string of characters that represent a
; floating point value.  This routine converts that string
; to the corresponding FP value and leaves the result on
; the top of the FPU stack.  On return, ESI points at the
; first character this routine couldn't convert.

; Like the other ATOx routines, this routine raises an
; exception if there is a conversion error or if ESI
; contains NULL.

; *********************************************************

strToR10:

        %define DigitStr rbp-24
        %define BCDValue rbp-34
        %define rsiSave rbp-44

        push rbp
        mov rbp, rsp
        sub rsp, 44

        push rbx
        push rcx
        push rdx
        push r8
        push rax

; Verify that RSI is not NULL.

        test rsi, rsi
        jz refNULL

; Zero out the DigitStr and BCDValue arrays.

        xor rax, rax
        mov qword [DigitStr], rax
        mov qword [DigitStr+8], rax
        mov dword [DigitStr+16], eax

        mov qword [BCDValue], rax
        mov word [BCDValue+8], ax

; Skip over any leading space or tab characters in the sequence.

        dec rsi
whileDelimLoop:
        inc rsi
        mov al, [rsi]
        cmp al, ' '
        je whileDelimLoop
        cmp al, tab
        je whileDelimLoop

; Check for + or -

        cmp al, '-'
        sete cl
        je doNextChar
        cmp al, '+'
        jne notPlus
doNextChar:
        inc rsi                        ; Skip the '+' or '-'
        mov al, [rsi]

notPlus:

; Initialize edx with -18 since we have to account
; for BCD conversion (which generates a number *10^18 by
; default). EDX holds the value's decimal exponent.

        mov rdx, -18

; Initialize ebx with 18, the number of significant
; digits left to process and also the index into the
; DigitStr array.

        mov ebx, 18                    ; Zero extends!

; At this point we're beyond any leading sign character.
; Therefore, the next character must be a decimal digit
; or a decimal point.

        mov [rsiSave], rsi             ; Save to look ahead 1 digit.
        cmp al, '.'
        jne notPeriod

; If the first character is a decimal point, then the
; second character needs to be a decimal digit.

        inc rsi
        mov al, [rsi]

notPeriod:
        cmp al, '0'
        jb convError
        cmp al, '9'
        ja convError
        mov rsi, [rsiSave]             ; Go back to orig char
        mov al, [rsi]
        jmp testWhlAL0

; Eliminate any leading zeros (they do not affect the value or
; the number of significant digits).

whileAL0:
        inc rsi
        mov al, [rsi]
testWhlAL0:
        cmp al, '0'
        je whileAL0

; If we're looking at a decimal point, we need to get rid of the
; zeros immediately after the decimal point since they don't
; count as significant digits.  Unlike zeros before the decimal
; point, however, these zeros do affect the number's value as
; we must decrement the current exponent for each such zero.

        cmp al, '.'
        jne testDigit

        inc edx                        ; Counteract dec below
repeatUntilALnot0:
        dec edx
        inc rsi
        mov al, [rsi]
        cmp al, '0'
        je repeatUntilALnot0
        jmp testDigit2

; If we didn't encounter a decimal point after removing leading
; zeros, then we've got a sequence of digits before a decimal
; point.  Process those digits here.

; Each digit to the left of the decimal point increases
; the number by an additional power of ten.  Deal with
; that here.

whileADigit:
        inc edx

; Save all the significant digits, but ignore any digits
; beyond the 18th digit.

        test ebx, ebx
        jz Beyond18

        mov [DigitStr+rbx*1 ], al
        dec ebx

Beyond18:
        inc rsi
        mov al, [rsi]

testDigit:
        sub al, '0'
        cmp al, 10
        jb whileADigit

        cmp al, '.'-'0'
        jne testDigit2

        inc rsi                        ; Skip over decimal point.
        mov al, [rsi]
        jmp testDigit2

; Okay, process any digits to the right of the decimal point.

whileDigit2:
        test ebx, ebx
        jz Beyond18_2

        mov [DigitStr+rbx*1 ], al
        dec ebx

Beyond18_2:
        inc rsi
        mov al, [rsi]

testDigit2:
        sub al, '0'
        cmp al, 10
        jb whileDigit2

; At this point, we've finished processing the mantissa.
; Now see if there is an exponent we need to deal with.

        mov al, [rsi]
        cmp al, 'E'
        je hasExponent
        cmp al, 'e'
        jne noExponent

hasExponent:
        inc rsi
        mov al, [rsi]                  ; Skip the "E".
        cmp al, '-'
        sete ch
        je doNextChar_2
        cmp al, '+'
        jne getExponent

doNextChar_2:
        inc rsi                        ; Skip '+' or '-'
        mov al, [rsi]

; Okay, we're past the "E" and the optional sign at this
; point.  We must have at least one decimal digit.

getExponent:
        sub al, '0'
        cmp al, 10
        jae convError

        xor ebx, ebx                   ; Compute exponent value in ebx.
        ExpLoop: movzx eax, byte [rsi] ; Zero extends to rax!
        sub al, '0'
        cmp al, 10
        jae ExpDone

        imul ebx, 10
        add ebx, eax
        inc rsi
        jmp ExpLoop

; If the exponent was negative, negate our computed result.

ExpDone:
        cmp ch, false
        je noNegExp

        neg ebx

noNegExp:

; Add in the BCD adjustment (remember, values in DigitStr, when
; loaded into the FPU, are multiplied by 10^18 by default.
; The value in edx adjusts for this).

        add edx, ebx

noExponent:

; verify that the exponent is between -4930..+4930 (which
; is the maximum dynamic range for an 80-bit FP value).

        cmp edx, 4930
        jg voor                        ; Value out of range
        cmp edx, -4930
        jl voor

; Now convert the DigitStr variable (unpacked BCD) to a packed
; BCD value.

        mov r8, 8
        for8: mov al, [DigitStr+r8*2 +2]
        shl al, 4
        or al, [DigitStr+r8*2 +1 ]
        mov [BCDValue+ r8*1], al

        dec r8
        jns for8

        fbld tword [BCDValue]

; Okay, we've got the mantissa into the FPU.  Now multiply the
; Mantissa by 10 raised to the value of the computed exponent
; (currently in edx).

; This code uses power of 10 tables to help make the
; computation a little more accurate.

; We want to determine which power of ten is just less than the
; value of our exponent.  The powers of ten we are checking are
; 10**4096, 10**2048, 10**1024, 10**512, etc.  A slick way to
; do this check is by shifting the bits in the exponent
; to the left.  Bit #12 is the 4096 bit.  So if this bit is set,
; our exponent is >= 10**4096.  If not, check the next bit down
; to see if our exponent >= 10**2048, etc.

        mov ebx, -10                   ; Initial index into power of ten table.
        test edx, edx
        jns positiveExponent

; Handle negative exponents here.

        neg edx
        shl edx, 19                    ; Bits 0..12 -> 19..31
        lea r8, PotTbl
whileEDXne0:
        add ebx, 10
        shl edx, 1
        jnc testEDX0

        fld tword [r8+rbx*1 ]
        fdivp

testEDX0:
        test edx, edx
        jnz whileEDXne0
        jmp doMantissaSign

; Handle positive exponents here.

positiveExponent:
        lea r8, PotTbl
        shl edx, 19                    ; Bits 0..12 -> 19..31.
        jmp testEDX0_2

whileEDXne0_2:
        add ebx, 10
        shl edx, 1
        jnc testEDX0_2

        fld tword [r8+rbx*1 ]
        fmulp

testEDX0_2:
        test edx, edx
        jnz whileEDXne0_2

; If the mantissa was negative, negate the result down here.

doMantissaSign:
        cmp cl, false
        je mantNotNegative

        fchs

mantNotNegative:
        clc                            ; Indicate Success
        jmp Exit

refNULL:
        mov rax, -3
        jmp ErrorExit

convError:
        mov rax, -2
        jmp ErrorExit

voor:
        mov rax, -1                    ; Value out of range
        jmp ErrorExit

illChar:
        mov rax, -4

ErrorExit:
        stc                            ; Indicate failure
        mov [rsp], rax                 ; Save error code
Exit:
        pop rax
        pop r8
        pop rdx
        pop rcx
        pop rbx
        leave
        ret

; Here is the "asmMain" function.

        global _asmMain
_asmMain:
        push rbx
        push rsi
        push rbp
        mov rbp, rsp
        sub rsp, 64                    ; Shadow storage
        and rsp, -16

; Test floating-point conversion:

        lea rbx, values
ValuesLp: 
        cmp qword [rbx], 0
        je allDone

        mov rsi, [rbx]
        call strToR10
        fstp qword [r8Val]

        lea rdi, [fmtStr1]
        mov rsi, [rbx]
        movsd xmm0, [r8Val]
        mov al, 1
        call _printf
        add rbx, 8
        jmp ValuesLp

allDone:
        leave
        pop rsi
        pop rbx
        ret                            ; Returns to caller
