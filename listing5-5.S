// listing5-5.S - Demonstrates accessing local variables with frame pointer offsets
//
// ```
// $ ./build listing5-5
// $ ./listing5-5
// Calling Listing 5-5:
// w0=23, w1=42
// Listing 5-5 terminated.
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
// Arguments:
// - w0: The first word to print.
// - w1: The second word to print.
//
// Local variables:
// - a: The first word to print.
// - b: The second word to print.
local_vars:
	// allocate 8 bytes for local variables plus 16 bytes for printf arguments on stack
	enter (4 * 2) + (8 * 2)

	// a = w0; b = w1;
	str w0, [fp, #-4]
	str w1, [fp, #-8]

	// printf("w0=%d, w1=%d\n", a, b);
	adrl x0, fmt
	ldr  x1, [fp, #-4]
	str  w1, [sp]
	ldr  x2, [fp, #-8]
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
	.asciz "Listing 5-5"
