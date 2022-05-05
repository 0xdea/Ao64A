; Listing 5-15

; Recursive quicksort

; % nasm -f macho64 listing5-15.asm
; % g++ c.cpp listing5-15.o -o listing5-15
; % ./listing5-15

        default rel
        bits	64

        nl equ 10
        numElements equ	10

        section	.rodata
ttlStr:
        db 	"Listing 5-15", 0
fmtStr1:
        db 	"Data before sorting: ", nl, 0
fmtStr2:
        db 	"%d "                      ; Use nl and 0 from fmtStr3
fmtStr3:
        db 	nl, 0
fmtStr4:
        db 	"Data after sorting: ", nl, 0

        section	.data
theArray:
        dd 	1, 10, 2, 9, 3, 8, 4, 7, 5, 6

        section	.text
        extern	_printf

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea rax, [ttlStr]
        ret

; quicksort-

; Sorts an array using the quicksort algorithm.

; Here's the algorithm in C, so you can follow along:

; void quicksort(int a[], int low, int high)
; {
; int i,j,Middle;
; if( low < high)
; {
; Middle = a[(low+high)/2];
; i = low;
; j = high;
; do
; {
; while(a[i] <= Middle) i++;
; while(a[j] > Middle) j--;
; if( i <= j)
; {
; swap(a[i],a[j]);
; i++;
; j--;
; }
; } while( i <= j );

; // recursively sort the two sub arrays

; if( low < j ) quicksort(a,low,j-1);
; if( i < high) quicksort(a,j+1,high);
; }
; }

; Args:
; RCX (_a):      Pointer to array to sort
; RDX (_lowBnd): Index to low bound of array to sort
; R8 (_highBnd): Index to high bound of array to sort

        _a equ +16                     ; Ptr to array
        _lowBnd equ +24                ; Low bounds of array
        _highBnd equ +32               ; High bounds of array

; Local variables (register save area)

        saveR9 equ +40                 ; Shadow storage for R9
        saveRDI	 equ -8
        saveRSI equ -16
        saveRBX equ -24
        saveRAX equ -32

; Within the procedure body, these registers
; have the following meaning:

; RCX: Pointer to base address of array to sort
; EDX: Lower bound of array (32-bit index).
; r8d: Higher bound of array (32-bit index).

; edi: index (i) into array.
; esi: index (j) into array.
; r9d: Middle element to compare against

quicksort:
        push rbp
        mov rbp, rsp
        sub rsp, 32

; This code doesn't mess with RCX. No
; need to save it. When it does  mess
; with RDX and R8, it saves those registers
; at that point.

; Preserve other registers we use:

        mov [saveRAX+rbp], rax
        mov [saveRBX+rbp], rbx
        mov [saveRSI+rbp], rsi
        mov [saveRDI+rbp], rdi
        mov [saveR9+rbp], r9

        mov edi, edx                   ; i=low
        mov esi, r8d                   ; j=high

; Compute a pivotal element by selecting the
; physical middle element of the array.

        lea rax, [rsi+rdi*1]           ; RAX=i+j
        shr rax, 1                     ; (i+j)/2
        mov r9d, [rcx+rax*4]           ; Middle = ary[(i+j)/2]

; Repeat until the edi and esi indexes cross one
; another (edi works from the start towards the end
; of the array, esi works from the end towards the
; start of the array).

rptUntil:

; Scan from the start of the array forward
; looking for the first element greater or equal
; to the middle element).

        dec edi                        ; to counteract inc, below
while1:
        inc edi                        ; i = i + 1
        cmp r9d, [rcx+rdi*4]           ; While middle > ary[i]
        jg while1

; Scan from the end of the array backwards looking
; for the first element that is less than or equal
; to the middle element.

        inc esi                        ; To counteract dec, below
while2:
        dec esi                        ; j = j - 1
        cmp r9d, [rcx+rsi*4]           ; while Middle < ary[j]
        jl while2

; If we've stopped before the two pointers have
; passed over one another, then we've got two
; elements that are out of order with respect
; to the middle element, so swap these two elements.

        cmp edi, esi                   ; If i <= j
        jnle endif1

        mov eax, [rcx+rdi*4]           ; Swap ary[i] and ary[j]
        mov r9d, [rcx+rsi*4]
        mov [rcx+rsi*4], eax
        mov [rcx+rdi*4], r9d

        inc edi                        ; i = i + 1
        dec esi                        ; j = j - 1

endif1:
        cmp edi, esi                   ; Until i > j
        jng rptUntil

; We have just placed all elements in the array in
; their correct positions with respect to the middle
; element of the array. So all elements at indexes
; greater than the middle element are also numerically
; greater than this element. Likewise, elements at
; indexes less than the middle (pivotal) element are
; now less than that element. Unfortunately, the
; two halves of the array on either side of the pivotal
; element are not yet sorted. Call quicksort recursively
; to sort these two halves if they have more than one
; element in them (if they have zero or one elements, then
; they are already sorted).

        cmp edx, esi                   ; if lowBnd < j
        jnl endif2

; Note: a is still in RCX,
; Low is still in RDX
; Need to preserve R8 (High)
; Note: quicksort doesn't require stack alignment

        push r8
        mov r8d, esi
        call quicksort                 ; ( a, Low, j )
        pop r8

endif2:
        cmp edi, r8d                   ; if i < High
        jnl endif3

; Note: a is still in RCX,
; High is still in R8d
; Need to preserve RDX (low)
; Note: quicksort doesn't require stack alignment

        push rdx
        mov edx, edi
        call quicksort                 ; ( a, i, High )
        pop rdx

; Restore registers and leave:

endif3:
        mov rax, [saveRAX+rbp]
        mov rbx, [saveRBX+rbp]
        mov rsi, [saveRSI+rbp]
        mov rdi, [saveRDI+rbp]
        mov r9, [saveR9+rbp]
        leave
        ret

; Little utility to print the array elements:

printArray:
        push r15
        push rbp
        mov rbp, rsp
        sub rsp, 40                    ; Shadow parameters

        lea r9, [theArray]
        mov r15d, 0
whileLT10:
        cmp r15d, numElements
        jnl endwhile1

        lea rdi, fmtStr2
        lea r9, [theArray]
        mov esi, [r9+r15*4]
        call _printf

        inc r15d
        jmp whileLT10

endwhile1: 
        lea rdi, [fmtStr3]
        call _printf
        leave
        pop r15
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:
        push rbp
        mov rbp, rsp
        sub rsp, 32                    ; Shadow storage

; Display unsorted array:

        lea rdi, [fmtStr1]
        call _printf
        call printArray

; Sort the array

        lea rcx, [theArray]
        xor rdx, rdx                   ; low = 0
        mov r8d, numElements-1         ; high= 9
        call quicksort                 ; (theArray, 0, 9)

; Display sorted results:

        lea rdi, [fmtStr4]
        call _printf
        call printArray

        leave
        ret                            ; Returns to caller
