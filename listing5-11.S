// listing5-11.S - Demonstrates passing parameters by reference on the stack
//
// ```
// $ ./build listing5-11
// $ ./listing5-11
// Calling Listing 5-11:
// Value of reference parameter: 20
// Value of reference parameter: 30
// Listing 5-11 terminated.
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

// onstackbyref
//
// Expects a single word parameter passed by reference on the stack.
//
// Arguments:
// - parm: The word value passed on the stack.

// offset to parm from fp
parm = 0x10

onstackbyref:
	enter 0x40

	// printf("Value of reference parameter: %d\n", *parm);
	adrl x0, fmt
	ldr  x1, [fp, #parm]
	ldr  w1, [x1]
	str  w1, [sp]
	bl   _printf

	leave
	ret

// void _asmMain(void);
_asmMain:
	enter 0x40

	// onstackbyref(value1);
	adrl x0, value1
	str  x0, [sp]
	bl   onstackbyref

	// onstackbyref(value2);
	adrl x0, value2
	str  x0, [sp]
	bl   onstackbyref

	leave
	ret

.data

value1:
	.word 20

value2:
	.word 30

fmt:
	.asciz "Value of reference parameter: %d\n"

title:
	.asciz "Listing 5-11"
