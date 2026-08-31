// listing5-13.S - Recursive quicksort implementation
//
// ```
// $ ./build listing5-13
// $ ./listing5-13
// ```

#include "include.S"

// number of elements in the array
count = 10

.code

.global _getTitle
.global _asmMain

// char *_getTitle(void);
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// void quicksort(int *arr, int low, int high);
//
// Sorts an array of integers using the quicksort algorithm.
//
// Arguments:
// - arr: The address of the array to sort.
// - low: The index of the first element to sort.
// - high: The index of the last element to sort.

#define arr x19
#define low x20
#define high x21
#define i x22
#define j x23
#define pivot w24

quicksort:
	// preserve registers
	stp x19, x20, [sp, #-0x10]!
	stp x21, x22, [sp, #-0x10]!
	stp x23, x24, [sp, #-0x10]!

	enter 0x20

	// if (low >= high) return;
	cmp low, high
	bge end_if3

	// i = low; j = high;
	mov i, low
	mov j, high

	// pivot = arr[((i + j) / 2) * 4] = arr[(i + j) * 2]
	add x0, i, j
	lsr x0, x0, #1
	ldr pivot, [arr, x0, lsl #2]

	// do ...
do:
	// counteract i++ below
	sub i, i, #1

	// scan from the left
while1:
	// i++;
	add i, i, #1

	// while (pivot <= arr[i])
	ldr w1, [arr, i, lsl #2]
	cmp pivot, w1
	bgt while1

	// counteract j-- below
	add j, j, #1

	// scan from the right
while2:
	// j--;
	sub j, j, #1

	// while (pivot >= arr[j])
	ldr w1, [arr, j, lsl #2]
	cmp pivot, w1
	blt while2

	// if (i <= j) swap(arr[i], arr[j]);
	cmp i, j
	bgt end_if1

	ldr w0, [arr, i, lsl #2]
	ldr w1, [arr, j, lsl #2]
	str w0, [arr, j, lsl #2]
	str w1, [arr, i, lsl #2]

	// i++; j--;
	add i, i, #1
	sub j, j, #1

end_if1:
	// ... while (i <= j)
	cmp i, j
	ble do

	// call quicksort recursively to sort the sub-arrays if they have more than one element
	// if (low < j) quicksort(arr, low, j);
	cmp low, j
	bge end_if2

	stp low, high, [sp, #-0x10]!
	mov high, j
	bl  quicksort
	ldp low, high, [sp], #0x10

end_if2:
	// if (i < high) quicksort(arr, i + 1, high);
	cmp i, high
	bge end_if3

	stp low, high, [sp, #-0x10]!
	mov low, i
	bl  quicksort
	ldp low, high, [sp], #0x10

end_if3:
	leave

	// restore registers
	ldp x23, x24, [sp], #0x10
	ldp x21, x22, [sp], #0x10
	ldp x19, x20, [sp], #0x10

	ret

// printarray
//
// Prints the array elements.
//
// Global variables:
// - array: the array to be printed.
//
// Compile-time constants:
// - count: number of elements in the array.
//
// Local variables:
// - ptr: pointer to the array.
// - index: index of the current element.

#define ptr x19
#define index x20

printarray:

	// preserve registers
	stp x19, x20, [sp, #-0x10]!

	enter 0x20

	adrl ptr, array
	mov  index, xzr

loop:
	cmp index, #count
	bge end_loop

	adrl x0, fmt2
	ldr  w1, [ptr, index, lsl #2]
	str  w1, [sp]
	bl   _printf

	add index, index, #1
	b   loop

end_loop:
	adrl x0, fmt3
	bl   _printf

	leave

	// restore registers
	ldp x19, x20, [sp], #0x10

	ret

// void _asmMain(void);
_asmMain:

	// preserve registers
	stp x19, x20, [sp, #-0x10]!
	stp x21, x22, [sp, #-0x10]!

	enter 0x40

	// printf("Data before sorting:\n");
	adrl x0, fmt1
	bl   _printf

	// printarray();
	bl printarray

	// quicksort(array, 0, count - 1);
	adrl arr, array
	mov  low, xzr
	mov  high, #count - 1
	bl   quicksort

	// printf("Data after sorting:\n");
	adrl x0, fmt4
	bl   _printf

	// printarray();
	bl printarray

	// restore registers
	ldp x21, x22, [sp], #0x10
	ldp x19, x20, [sp], #0x10

	ret

.data

fmt1:
	.asciz "Data before sorting:\n"

fmt2:
	.ascii "%d"

fmt3:
	.asciz "\n"

fmt4:
	.asciz "Data after sorting:\n"

fmt5:
	.asciz "arr=%p, low=%d, high=%d\n"

array:
	.word 1, 10, 2, 9, 3, 8, 4, 7, 5, 6

title:
	.asciz "Listing 5-13"
