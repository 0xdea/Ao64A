; Listing 4-5
;
; Demonstration of lack of type
; checking in assembly language
; pointer access
;
;
; % nasm -f macho64 listing4-5.asm
; % g++ c.cpp listing4-5.o -o listing4-5
; % ./listing4-5


	default rel
	bits	64

nl        	equ	10
maxLen    	equ	256

          	section	.rodata
ttlStr    	db    	"Listing 4-5", 0
prompt	db	"Input a string: ", 0
fmtStr    	db    	"%d: Hex value of char read: %x", nl, 0
        
          	section	.data
bufPtr    	dq   	0
bytesRead 	dq   	0
        
          	section	.text
        	extern 	_readLine
        	extern 	_printf
        	extern 	_malloc
        	extern 	_free


; Return program title to C++ program:

         	global	_getTitle
_getTitle:
         	lea rax, [ttlStr]
         	ret


; Here is the "asmMain" function.

        
        	global	_asmMain
_asmMain:
        	push    rbx     ;Preserve RBX

; "Magic" instruction offered without
; explanation at this point:

        	sub     rsp, 48

; C standard library malloc function
; Allocate sufficient characters
; to hold a line of text input
; by the user:

        	mov     rdi, maxLen     	; Allocate 256 bytes
        	call    _malloc
        	mov     [bufPtr], rax   	; Save pointer to buffer
        
; Read a line of text from the user and place in
; the newly allocated buffer:

			lea	rdi, [prompt]		   	; Prompt user to input
			call	_printf				; a line of text.

        	mov     rdi, [bufPtr]   	; Pointer to input buffer
        	mov     rsi, maxLen     	; Maximum input buffer length
        	call    _readLine        	; Read text from user
        	cmp     rax, -1         	; Skip output if error
        	je      allDone
        	mov     [bytesRead], rax  	; Save number of chars read
        
; Display the data input by the user:

        	xor     rbx, rbx        	; Set index to zero
dispLp: 	mov     rcx, [bufPtr]    	; Pointer to buffer
        	mov     rsi, rbx        	; Display index into buffer
        	mov     rdx, [rcx+rbx*1] 	; Read dword rather than byte!
        	lea     rdi, [fmtStr]
        	call    _printf
        
        	inc     rbx             	; Repeat for each char in buffer
        	cmp     rbx, [bytesRead]
        	jb      dispLp

; Free the storage by calling
; C standard library free function.
;
; free( bufPtr );

allDone:
        	mov     rdi, [bufPtr]
        	call    _free


        	add     rsp, 48
        	pop     rbx     ;Restore RBX
        	ret     ;Returns to caller

