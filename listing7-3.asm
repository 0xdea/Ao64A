; Listing 7-3

; Initializing qword values with the
; addresses of statement labels.

; nasm -f macho64 listing7-3.asm -o listing7-3.o

        section .data
lblsInProc: 
        dq globalLbl1, globalLbl2      ; From procWLabels

        section .text

; procWLabels-
; Just a procedure containing private (lexically scoped)
; and global symbols. This really isn't an executable
; procedure.

procWLabels:
.privateLbl:
        nop                            ; "No operation" just to consume space

globalLbl1:
        jmp globalLbl2
globalLbl2:
        nop

.privateLbl2:
        ret
dataInCode:
        ;dq privateLbl, globalLbl1     ; Symbol not defined
        dq procWLabels.privateLbl, globalLbl1
        ;dq globalLbl2, privateLbl2    ; Symbol not defined
        dq globalLbl2, globalLbl2.privateLbl2
