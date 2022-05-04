; Listing 4-7

; A simple bubble sort example

; % nasm -f macho64 listing4-7.asm
; % g++ c.cpp listing4-7.o -o listing4-7
; % ./listing4-7

        default rel
        bits	64

        nl 	equ	10
        maxLen 	equ	256
        true 	equ	1
        false 	equ	0

        section	.rodata
ttlStr:
        db 	"Listing 4-7", 0
fmtStr:
        db 	"Sortme[%d] = %d", nl, 0

        section .data

; sortMe - A 16-element array to sort:

sortMe:
        dd 	1, 2, 16, 14
        dd 	3, 9, 4, 10
        dd 	5, 7, 15, 12
        dd 	8, 6, 11, 13

        sortSize 	equ	($ - sortMe) / 4 ; Number of elements

; didSwap- A Boolean value that indicates
; whether a swap occurred on the
; last loop iteration.

didSwap:
        db	0

        section	.text
        extern	_printf

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; Here's the bubblesort function.

; sort( dword *array, qword count );

; Note: this is not an external (C)
; function, nor does it call any
; external functions. So it will
; dispense with some of the Windows
; calling sequence stuff.

; array- Address passed in RDI
; count- Element count passed in RSI

sort:
        push rax                       ; In pure assembly language
        push rbx                       ; it's always a good idea
        push rdi                       ; to preserve all registers
        push rsi                       ; you modify.
        push rdx

        dec rsi                        ; numElements - 1

; Outer loop

        outer: 	mov byte [didSwap], false

        xor rbx, rbx                   ; RBX = 0
inner:
        cmp rbx, rsi                   ; while rbx < count-1
        jnb xInner

        mov eax, [rdi + rbx*4]         ; eax = sortMe[rbx]
        cmp eax, [rdi + rbx*4 + 4]     ; if eax > sortMe[rbx+1]
        jna dontSwap                   ; then swap

; sortMe[rbx] > sortMe[rbx+1], so swap elements

        mov edx, [rdi + rbx*4 + 4]
        mov [rdi + rbx*4 + 4], eax
        mov [rdi + rbx*4], edx
        mov byte [didSwap], true

dontSwap:
        inc rbx                        ; Next loop iteration
        jmp inner

; exited from inner loop, test for repeat
; of outer loop:

        xInner: 	cmp byte [didSwap], true
        je outer

        pop rdx
        pop rsi
        pop rdi
        pop rbx
        pop rax
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbx

; "Magic" instruction offered without
; explanation at this point:

        sub rsp, 48

; Sort the "sortMe" array:

        lea rdi, [sortMe]
        mov rsi, sortSize              ; 16 elements in array
        call sort

; Display the sorted array:

        xor rbx, rbx
dispLp:                                ; mov     edx, [sortMe+rbx*4]
        lea	rdx, [sortMe]
        mov	edx, [rdx+rbx*4]

        mov rsi, rbx
        lea rdi, [fmtStr]
        call _printf

        inc rbx
        cmp rbx, sortSize
        jb dispLp

        add rsp, 48
        pop rbx
        ret                            ; Returns to caller

