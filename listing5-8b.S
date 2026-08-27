// listing5-8b.S - Demonstrates passing a local variable by reference and by value as a function parameter
//
// ```
// $ ./build listing5-8b
// $ ./listing5-8b
// ```

#include "include.S"

.code

.global _getTitle
.global _asmMain

// char *_getTitle(void);
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// void byval(word w0);
//
// Prints the value of w0.
//
// Arguments:
// - w0: The value to print.
byval:
	enter 8

	// printf("value=%d\n", w0);
	str  w0, [sp]
	adrl x0, fmtval
	bl   _printf

	leave
	ret

// void byref(word *x0);
//
// Prints the address of x0 and the value at that address.
//
// Arguments:
// - x0: The address of the word to print.
byref:
	enter 16

	// printf("address=%p, value=%d\n", x0, *x0);
	ldr  x1, [x0]
	str  x1, [sp, #8]
	str  x0, [sp]
	adrl x0, fmtref
	bl   _printf

	leave
	ret

// void _asmMain(void);
//
// Calls byval() and byref() passing a local variable by value and by reference, respectively.
//
// Local variables:
// - value: a word at offset -4 from the frame pointer.

#define value -4

_asmMain:
	enter 8

	// value = 42
	mov w0, #42
	str w0, [fp, #value]

	// byval(value);
	ldr w0, [fp, #value]
	bl  byval

	// byref(&value);
	add x0, fp, #value
	bl  byref

	leave
	ret

.data

fmtref:
	.asciz "address=%p, value=%d\n"

fmtval:
	.asciz "value=%d\n"

title:
	.asciz "Listing 5-8b"
