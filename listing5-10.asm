; Listing 5-10

; Demonstrate passing parameters in registers

; nasm -Ov -f macho64 listing5-10.asm -o listing5-10.o

        default rel
        bits	64

        section	.data
staticVar:
        dd	0

        section	.text
        extern	someFunc

; strfill-  Overwrites the data in a string with a character.

; RDI-  Pointer to zero-terminated string
; (e.g., a C/C++ string)
; AL-  Character to store into the string

strfill:
        push rdi                       ; Preserve RDI because it changes

; While we haven't reached the end of the string

whlNot0: 
        cmp byte [rdi], 0
        je endOfStr

; Overwrite character in string with the character
; passed to this procedure in AL

        mov [rdi], al

; Move on to the next character in the string and
; repeat this process:

        inc rdi
        jmp whlNot0

endOfStr:
        pop rdi
        ret
