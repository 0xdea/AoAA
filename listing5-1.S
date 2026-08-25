// listing5-1.S - Demonstrates procedure calls
//
// ```
// $ ./build listing5-1
// $ ./listing5-1
// Calling Listing 5-1:
// array[0] = 0xffffffff
// array[1] = 0xffffffff
// array[2] = 0xffffffff
// array[3] = 0xffffffff
// ...
// array[252] = 0xffffffff
// array[253] = 0xffffffff
// array[254] = 0xffffffff
// array[255] = 0xffffffff
// array[0] = 0x0
// array[1] = 0x0
// array[2] = 0x0
// array[3] = 0x0
// ...
// array[252] = 0x0
// array[253] = 0x0
// array[254] = 0x0
// array[255] = 0x0
// Listing 5-1 terminated.
// ```

#include "include.S"

// array length
len = 256

.code

.global _getTitle
.global _asmMain

// char *_getTitle(void);
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// void zerobytes(word *array);
//
// Zeroes out a #len-word array. Doesn't use any standard ABI.
//
// Parameters:
// - array: Pointer to the array of words.
zerobytes:
	mov x1, #len * 4

0:
	subs x1, x1, #4
	str  wzr, [x0, x1]
	bne  0b

	ret

// void printarray(word *array, dword size);
//
// Prints the contents of an array of words. Uses the macOS ABI.
//
// Parameters:
// - array: Pointer to the array of words.
// - size: Number of words in the array.
//
// Local variables:
// - arr: Pointer to the array of words.
// - i: Loop counter.
// - val: Current array element.
// - size: Number of words in the array.

#define arr x19
#define i x20
#define val w21
#define size x22

printarray:
	// preserve non-volatile registers used for local variables
	stp x19, x20, [sp, #-16]!
	stp x21, x22, [sp, #-16]!

	// allocate stack space for variadic arguments
	enter 64

	// initialize local variables in registers
	mov arr, x0
	mov size, x1
	mov i, xzr

	// while (i < size) ...
0:
	// printf("arr[%d] = 0x%x\n", i, arr[i]);
	ldr val, [arr, i, lsl #2]

	adrl x0, fmt
	str  i, [sp]
	str  val, [sp, #8]
	bl   _printf

	// i++;
	add i, i, #1
	cmp i, size
	blo 0b

	// release stack space for variadic arguments
	leave

	// restore non-volatile registers used for local variables
	ldp x21, x22, [sp], #16
	ldp x19, x20, [sp], #16

	ret

// void _asmMain(void);
_asmMain:
	enter 64

	// print the initial array contents
	// printarray(&array, len);
	adrl x0, array
	mov  x1, #len
	bl   printarray

	// zero out the array
	// zerobytes(&array);
	adrl x0, array
	bl   zerobytes

	// print the zeroed array contents
	// printarray(&array, len);
	adrl x0, array
	mov  x1, #len
	bl   printarray

	leave
	ret

.data

// 4byte/word array of #len elements initialized to 0xffffffff
array:
	.space len * (4), 0xff

fmt:
	.asciz "array[%d] = 0x%x\n"

title:
	.asciz "Listing 5-1"
