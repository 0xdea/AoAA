// listing5-10.S - Demonstrates passing parameters on the stack
//
// ```
// $ ./build listing5-10
// $ ./listing5-10
// Calling Listing 5-10:
// Value of parameter: 20
// Value of parameter: 30
// Listing 5-10 terminated.
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

// onstack
//
// Passed a single word parameter by value on the stack.
//
// Arguments:
// - parm: The word value passed on the stack.

// offset to parm from fp
parm = 0x10

onstack:
	enter 8 + 4

	// printf("Value of parameter: %d\n", parm);
	adrl x0, fmt
	ldr  w1, [fp, #parm]
	str  w1, [sp]
	bl   _printf

	leave
	ret

// void _asmMain(void);
_asmMain:
	enter 4

	// onstack(value1);
	adrl x0, value1
	ldr  w1, [x0]
	str  w1, [sp]
	bl   onstack

	// onstack(value2);
	adrl x0, value2
	ldr  w1, [x0]
	str  w1, [sp]
	bl   onstack

	leave
	ret

.data

value1:
	.word 20

value2:
	.word 30

fmt:
	.asciz "Value of parameter: %d\n"

title:
	.asciz "Listing 5-10"
