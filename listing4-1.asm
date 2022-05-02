; Listing 4-1
;
; // Type checking errors
;
; Note: NASM doesn't support type checking.
; This file is left in MASM form.

        option  casemap:none

nl      =       10  ;ASCII code for newline


        .data
i8      sbyte   ?
i16     sword   ?
i32     sdword  ?
i64     sqword  ?

        .code

; Here is the "asmMain" function.

        
        public  asmMain
asmMain proc

        mov     eax, i8
        mov     al, i16
        mov     rax, i32
        mov     ax, i64
        
        ret     ;Returns to caller
asmMain endp
        end
