; Listing 5-11
;
; Demonstration passing parameters in the code stream.
;
; % nasm -f macho64 listing5-11.asm
; % g++ c.cpp listing5-11.o -o listing5-11
; % ./listing5-11


	default rel
	bits	64

nl          equ	10

            section	.rodata
ttlStr      db    	"Listing 5-11", 0
        
        
            section	.text
            

; Magic function that prints a string under macOS.
; Note that macOS system calls do not require stack
; alignment because they don't actually use the
; user program's stack.

writeStr:
        mov     rdx, rsi        ; Number of chars to print
        mov     rsi, rdi        ; Address of string to print
        mov     eax, 0x2000004  ; system call 0x2000004 is write
        mov     rdi, 1          ; file handle 1 is stdout
        syscall                 ; invoke operating system to do the write
        ret

; Return program title to C++ program:

            global	_getTitle
_getTitle:
            lea     rax, [ttlStr]
            ret


; Here's the print procedure.
; It expects a zero-terminated string
; to follow the call to print.


print:
            push    rbp
            mov     rbp, rsp
            and     rsp, -16            ;Ensure stack 16-byte aligned
            sub     rsp, 48             ;Set up stack for ABI
            
; Get the pointer to the string immediately following the
; call instruction and scan for the zero-terminating byte.
            
            mov     rdi, [rbp+8]        ;Return address is here
            lea     rsi, [rdi-1]        ;RSI = return address - 1
search4_0:  inc     rsi                 ;Move on to next char
            cmp     byte [rsi], 0       ;At end of string?
            jne     search4_0
            
; Fix return address and compute length of string:

            inc     rsi                 ;Point at new return address
            mov     [rbp+8], rsi        ;Save return address
            sub     rsi, rdi            ;Compute string length
            dec     rsi                 ;Don't include 0 byte

; Call writeStr to print the string to the console
;
; writeStr( bufAdrs, len );
;
; Note: pointer to string is already in RDI.
; and string length is in RSI. So just call writeStr
; function:

; Note: pointer to the buffer (string) is already
; in RDX. The len is already in R8. Just need to
; load the file descriptor (handle) into RCX:

            call writeStr

            leave
            ret


; Here is the "asmMain" function.

        
            global	_asmMain
_asmMain:
            push    rbp
            mov     rbp, rsp
            sub     rsp, 40
        

; Demonstrate passing parameters in code stream
; by calling the print procedure:

            call    print
            db      "Hello, World!", nl, 0

; Clean up, as per Microsoft ABI:

            leave
            ret     ;Returns to caller
        
