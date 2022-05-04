; Listing 4-6

; Calling C Standard Libary string functions

; % nasm -f macho64 listing4-6.asm
; % g++ c.cpp listing4-6.o -o listing4-6
; % ./listing4-6

        default rel
        bits	64

        nl 	equ	10
        maxLen 	equ	256

        section	.rodata
ttlStr:
        db 	"Listing 4-6", 0
prompt:
        db 	"Input a string: ", 0
fmtStr1:
        db 	"After strncpy, resultStr='%s'", nl, 0
fmtStr2:
        db 	"After strncat, resultStr='%s'", nl, 0
fmtStr3:
        db 	"After strcmp (3), eax=%d", nl, 0
fmtStr4:
        db 	"After strcmp (4), eax=%d", nl, 0
fmtStr5:
        db 	"After strcmp (5), eax=%d", nl, 0
fmtStr6:
        db 	"After strchr, rax='%s'", nl, 0
fmtStr7:
        db 	"After strstr, rax='%s'", nl, 0
fmtStr8:
        db 	"resultStr length is %d", nl, 0

str1:
        db 	"Hello, ", 0
str2:
        db 	"World!", 0
str3:
        db 	"Hello, World!", 0
str4:
        db 	"hello, world!", 0
str5:
        db 	"HELLO, WORLD!", 0

        section	.data
strLength:
        dd 	0
resultStr:
        db 	maxLen dup (0)

        section	.text
        extern 	_readLine
        extern 	_printf
        extern 	_malloc
        extern 	_free

; Some C standard library string functions:

; size_t strlen(char *str)

        extern	_strlen

; char *strncat(char *dest, const char *src, size_t n)

        extern	_strncat

; char *strchr(const char *str, int c)

        extern	_strchr

; int strcmp(const char *str1, const char *str2)

        extern	_strcmp

; char *strncpy(char *dest, const char *src, size_t n)

        extern	_strncpy

; char *strstr(const char *inStr, const char *search4)

        extern	_strstr

; Return program title to C++ program:

        global	_getTitle
_getTitle:
        lea 	rax, [ttlStr]
        ret

; Here is the "asmMain" function.

        global	_asmMain
_asmMain:

; "Magic" instruction offered without
; explanation at this point:

        sub rsp, 56

; Demonstrate the strncpy function to copy a
; string from one location to another:

        lea rdi, [resultStr]           ; Destination string
        lea rsi, [str1]                ; Source string
        mov rdx, maxLen                ; Max number of chars to copy
        call _strncpy

        lea rdi, [fmtStr1]
        lea rsi, [resultStr]
        call _printf

; Demonstrate the strncat function to concatenate str2 to
; the end of [resultStr]:

        lea rdi, [resultStr]
        lea rsi, [str2]
        mov rdx, maxLen
        call _strncat

        lea rdi, [fmtStr2]
        lea rsi, [resultStr]
        call _printf

; Demonstrate the strcmp function to compare [resultStr]
; with str3, str4, and str5:

        lea rdi, [resultStr]
        lea rsi, [str3]
        call _strcmp

        lea rdi, [fmtStr3]
        mov rsi, rax
        call _printf

        lea rdi, [resultStr]
        lea rsi, [str4]
        call _strcmp

        lea rdi, [fmtStr4]
        mov rsi, rax
        call _printf

        lea rdi, [resultStr]
        lea rsi, [str5]
        call _strcmp

        lea rdi, [fmtStr5]
        mov rsi, rax
        call _printf

; Demonstrate the strchr function to search for
; ',' in [resultStr]

        lea rdi, [resultStr]
        mov rsi, ', '
        call _strchr

        lea rdi, [fmtStr6]
        mov rsi, rax
        call _printf

; Demonstrate the strstr function to search for
; str2 in [resultStr]

        lea rdi, [resultStr]
        lea rsi, [str2]
        call _strstr

        lea rdi, [fmtStr7]
        mov rsi, rax
        call _printf

; Demonstrate a call to the strlen function

        lea rdi, [resultStr]
        call _strlen

        lea rdi, [fmtStr8]
        mov rsi, rax
        call _printf

        add rsp, 56
        ret                            ; Returns to caller

