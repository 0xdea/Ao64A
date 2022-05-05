; Listing 5-8

; Demonstrate obtaining the address
; of a static variable using offset
; operator.

; nasm -Ov -f macho64 listing5-8.asm -o listing5-8.o

        default rel
        bits	64

        section	.data
staticVar:
        dd 	0

        section	.text
        extern	someFunc

getAddress:

        mov rcx, staticVar
        call someFunc

        ret
