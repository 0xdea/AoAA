// listing4-5.S - Demonstrates calling C stdlib string functions
//
// ```
// $ ./build listing4-5
// $ ./listing4-5
// Calling Listing 4-5:
// After strncpy, result_str = 'Hello, '
// Length of result_str is 7
// After strncat, result_str = 'Hello, world!'
// After strcmp (3), WO = 0
// After strcmp (4), WO = -32
// After strcmp (5), WO = 32
// After strchr, XO = ', world!'
// After strstr, XO = 'world!'
// Listing 4-5 terminated.
// ```

.macro adrl reg, mem
adrp   \reg, \mem@PAGE
add    \reg, \reg, \mem@PAGEOFF
.endm

.macro vparm2 mem
adrl   x1, \mem
ldr    x1, [x1]
str    x1, [sp]
.endm

.macro vparm3 mem
adrl   x2, \mem
ldr    x2, [x2]
str    x2, [sp, #8]
.endm

.macro vparm4 mem
adrl   x3, \mem
ldr    x3, [x3]
str    x3, [sp, #16]
.endm

.macro vparm5 mem
adrl   x4, \mem
ldr    x4, [x4]
str    x4, [sp, #24]
.endm

maxlen = 256

.text
.balign 4

.global _getTitle
.global _asmMain

_getTitle:
	adrl x0, title
	ret

_asmMain:
	// function prologue
	str lr, [sp, #-16]!
	sub sp, sp, #64

	// strncpy(result_str, str1, maxlen - 1);
	adrl x0, result_str
	adrl x1, str1
	mov  x2, #maxlen - 1
	bl   _strncpy

	adrl   x0, fmt1
	vparm2 result_ptr
	bl     _printf

	// length = strnlen(result_str, maxlen);
	adrl x0, result_str
	mov  x1, #maxlen
	bl   _strnlen

	adrl x1, length
	str  x0, [x1]

	adrl   x0, fmt8
	vparm2 length
	bl     _printf

	// strncat(result_str, str2, maxlen - strlen(result_str) - 1);
	// this prevents a buffer overflow present in the original code in the book
	adrl x0, result_str
	adrl x1, str2
	mov  x2, #maxlen
	sub  x2, x2, #1
	adrl x3, length
	ldr  x3, [x3]
	sub  x2, x2, x3
	bl   _strncat

	adrl   x0, fmt2
	vparm2 result_ptr
	bl     _printf

	// result = strcmp(result_str, str3);
	adrl x0, result_str
	adrl x1, str3
	bl   _strcmp
	adrl x1, result
	str  x0, [x1]

	adrl   x0, fmt3
	vparm2 result
	bl     _printf

	// result = strcmp(result_str, str4);
	adrl x0, result_str
	adrl x1, str4
	bl   _strcmp
	adrl x1, result
	str  x0, [x1]

	adrl   x0, fmt4
	vparm2 result
	bl     _printf

	// result = strcmp(result_str, str5);
	adrl x0, result_str
	adrl x1, str5
	bl   _strcmp
	adrl x1, result
	str  x0, [x1]

	adrl   x0, fmt5
	vparm2 result
	bl     _printf

	// result = strchr(result_str, ',');
	adrl x0, result_str
	mov  x1, #','
	bl   _strchr
	adrl x1, result
	str  x0, [x1]

	adrl   x0, fmt6
	vparm2 result
	bl     _printf

	// result = strstr(result_str, str2);
	adrl x0, result_str
	adrl x1, str2
	bl   _strstr
	adrl x1, result
	str  x0, [x1]

	adrl   x0, fmt7
	vparm2 result
	bl     _printf

	// function epilogue
	add sp, sp, #64
	ldr lr, [sp], #16

	ret

.data
.balign 8

result_str:
	.space maxlen

result_ptr:
	.8byte result_str

length:
	.8byte 0

result:
	.8byte 0

prompt:
	.asciz "Input a string: "

fmt1:
	.asciz "After strncpy, result_str = '%s'\n"

fmt2:
	.asciz "After strncat, result_str = '%s'\n"

fmt3:
	.asciz "After strcmp (3), WO = %d\n"

fmt4:
	.asciz "After strcmp (4), WO = %d\n"

fmt5:
	.asciz "After strcmp (5), WO = %d\n"

fmt6:
	.asciz "After strchr, XO = '%s'\n"

fmt7:
	.asciz "After strstr, XO = '%s'\n"

fmt8:
	.asciz "Length of result_str is %d\n"

str1:
	.asciz "Hello, "

str2:
	.asciz "world!"

str3:
	.asciz "Hello, world!"

str4:
	.asciz "hello, world!"

str5:
	.asciz "HELLO, WORLD!"

title:
	.asciz "Listing 4-5"
