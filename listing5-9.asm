; Listing 5-9

; Demonstrate obtaining the address
; of a variable using the lea instruction

; nasm -Ov -f macho64 listing5-9.asm -o listing5-9.o

        default rel
        bits	64

        section	.data
staticVar:
        dd	0

        section	.text
        extern	someFunc

getAddress:

        lea rcx, staticVar
        call someFunc

        ret
