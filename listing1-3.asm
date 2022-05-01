; listing 1-3:
; A simple NASM module that contains an empty function to be 
; called by the C++ code in listing 1-2.
; % nasm -f macho64 listing1-3.asm
; % g++ listing1-3.o listing1-2.cpp -o listing1-3


	section	.text                          	; Code segment
        

; Here is the "asmFunc" function.

        	global  _asmFunc
_asmFunc:

; Empty function just returns to C++ code
        
        	ret     ;Returns to caller
        
