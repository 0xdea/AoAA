// listing5-6.S - Demonstrates accessing local variables with frame pointer offsets and equates
//
// ```
// $ ./build listing5-6
// $ ./listing5-6
// Calling Listing 5-6:
// w0=23, w1=42
// Listing 5-6 terminated.
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

// void local_vars(word w0, word w1);
//
// Prints the values of w0 and w1 using a format string.
//
// Parameters:
// - w0: The first word to print.
// - w1: The second word to print.
//
// Local variables:
// - a: The first word to print at offset -4 from the frame pointer.
// - b: The second word to print at offset -8 from the frame pointer.

#define a [fp, #-4]
#define b [fp, #-8]

local_vars:
	// allocate 8 bytes for local variables plus 16 bytes for printf arguments on stack
	enter (4 * 2) + (8 * 2)

	// a = w0; b = w1;
	str w0, a
	str w1, b

	// printf("w0=%d, w1=%d\n", a, b);
	adrl x0, fmt
	ldr  x1, a
	str  w1, [sp]
	ldr  x2, b
	str  w2, [sp, #8]
	bl   _printf

	leave

	ret

// void _asmMain(void);
_asmMain:
	enter 0

	mov w0, #23
	mov w1, #42
	bl  local_vars

	leave
	ret

.data

fmt:
	.asciz "w0=%d, w1=%d\n"

title:
	.asciz "Listing 5-6"
