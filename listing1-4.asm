; Listing 1-4
; A simple demonstration of a user-defined procedure.
; % nasm -f macho64 listing1-4.asm
; % g++ listing1-4.o -o listing1-4
; % ./listing1-4


	section	.text                          	; Code segment

; A sample user-defined procedure that this program can call.

        global myProc
myProc:
        ret    ; Immediately return to the caller


; Here is the "main" procedure.

        global _main
_main:

; Call the user-define procedure

        call   myProc

        ret     ;Returns to caller

