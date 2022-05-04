; Listing 5-14
;
; Passing a large object by reference
;
; % nasm -f macho64 listing5-14.asm
; % g++ c.cpp listing5-14.o -o listing5-14
; % ./listing5-14


	default rel
	bits	64

nl          equ	10
NumElements equ	24

	struc	Pt
.x          resb	1
.y          resb	1
	endstruc



            section	.rodata
ttlStr      db    	"Listing 5-14", 0
fmtStr1     db    	"RefArrayParm[%d].x=%d ", 0
fmtStr2     db    	"RefArrayParm[%d].y=%d", nl, 0
        
            section	.data
index       dd   	0
Pts         db	(Pt_size*NumElements) dup (0)
        
            section	.text
            extern	_printf
            
; Return program title to C++ program:

            global	_getTitle
_getTitle:
            lea     rax, [ttlStr]
            ret



ptArray     equ     +16 
RefAryParm:
            push    rbp
            mov     rbp, rsp
            
            mov     rdx, [ptArray+rbp]
            xor     rcx, rcx        ;RCX = 0
            
; while ecx < NumElements, initialize each
; array element. x = ecx/8, y=ecx % 8

ForEachEl:  cmp     ecx, NumElements
            jnl     LoopDone
            
            mov     al, cl
            shr     al, 3   ;AL = ecx / 8
            mov     [rdx+rcx*2+Pt.x], al
            
            mov     al, cl
            and     al, 111b ;AL = ecx % 8
            mov     [rdx+rcx*2+Pt.y], al
            inc     ecx
            jmp     ForEachEl
                        
LoopDone:   leave
            ret


; Here is the "asmMain" function.

        
            global	_asmMain
_asmMain:
            push    rbp
            mov     rbp, rsp
            sub     rsp, 48
        
; Initialize the array of points:

            lea     rax, [Pts]
            mov     [rsp], rax      ;Store address on stack
            call    RefAryParm

; Display the array:
            
            mov     dword [index], 0
dispLp:     cmp     dword [index], NumElements
            jnl     dispDone
            
            lea     rdi, [fmtStr1]
            mov     esi, [index]            	;zero extends!
            lea     rdx, [Pts]               	;Get array base
            movzx   rdx, byte[rdx+rsi*2+Pt.x]    	;Get x field
            call    _printf
            
            lea     rdi, [fmtStr2]
            mov     esi, [index]           		;zero extends!
            lea     rdx, Pts                		;Get array base
            movzx   rdx, byte [rdx+rsi*2+Pt.y]    	;Get y field
            call    _printf
            
            inc     dword [index]
            jmp     dispLp
            
            
; Clean up, as per Microsoft ABI:

dispDone:
            leave
            ret     ;Returns to caller
        
