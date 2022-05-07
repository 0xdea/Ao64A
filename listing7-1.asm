; Listing 7-1

; Demonstration of local symbols.
; Note that this program will not
; compile; it fails with an
; undefined symbol error.

; NASM local symbols are any symbol beginning with "."
; The scope of the symbol is limited to the pair of
; normal (non-local) symbols before and after the local symbol.

; nasm -f macho64 listing7-1.asm -o listing7-1.o
; listing7-1.asm:27: error: symbol `asmMain.localStmtLbl' not defined

        section .text
hasLocalLbl:

.localStmLbl:
        ret

; Here is the "asmMain" function.

asmMain:

.asmLocal:
        jmp .asmLocal                  ; This is okay
        jmp .localStmtLbl              ; Undefined in asmMain
