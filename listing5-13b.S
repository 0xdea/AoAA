// listing5-13b.S - Recursive quicksort implementation (macOS ABI compliant)
//
// ```
// $ ./build listing5-13b
// $ ./listing5-13b
// Calling Listing 5-13b:
// Data before sorting:
// 	1
// 	10
// 	2
// 	9
// 	3
// 	8
// 	4
// 	7
// 	5
// 	6
//
// Data after sorting:
// 	1
// 	2
// 	3
// 	4
// 	5
// 	6
// 	7
// 	8
// 	9
// 	10
//
// Listing 5-13b terminated.
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
// Sorts an array of integers in-place, using the quicksort algorithm.
//
// Arguments:
// - arr: The address of the array to sort.
// - low: The index of the first element to sort.
// - high: The index of the last element to sort.
//
// Local variables:
// - i: The index of the current left element being compared.
// - j: The index of the current right element being compared.
// - pivot: The value of the pivot element.

#define arr x0
#define low x1
#define high x2
#define i x19
#define j x20
#define pivot w21

quicksort:
	stp x19, x20, [sp, #-0x10]!
	stp x21, x22, [sp, #-0x10]!

	enter 0x20

	// if (low < high) ...
	cmp low, high
	bge end_if3

	// pivot = arr[((low + high) / 2) * 4] = arr[(low + high) * 2]
	add x3, low, high
	lsr x3, x3, #1
	ldr pivot, [arr, x3, lsl #2]

	// i = low; j = high;
	mov i, low
	mov j, high

	// do ...
do:
	// counteract i++ below
	sub i, i, #1

	// scan from the left
while1:
	// while (arr[i] <= pivot) i++;
	add i, i, #1

	ldr w3, [arr, i, lsl #2]
	cmp pivot, w3
	bgt while1

	// counteract j-- below
	add j, j, #1

	// scan from the right
while2:
	// while (arr[j] >= pivot) j--;
	sub j, j, #1

	ldr w3, [arr, j, lsl #2]
	cmp pivot, w3
	blt while2

	// if (i <= j) { swap(arr[i], arr[j]); i++; j--; }
	cmp i, j
	bgt end_if1

	ldr w3, [arr, i, lsl #2]
	ldr w4, [arr, j, lsl #2]
	str w3, [arr, j, lsl #2]
	str w4, [arr, i, lsl #2]

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

	stp arr, high, [sp, #-0x10]!
	mov high, j
	bl  quicksort
	ldp arr, high, [sp], #0x10

end_if2:
	// if (i < high) quicksort(arr, i, high);
	cmp i, high
	bge end_if3

	stp arr, low, [sp, #-0x10]!
	mov low, i
	bl  quicksort
	ldp arr, low, [sp], #0x10

end_if3:
	leave

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
	stp x19, x20, [sp, #-0x10]!

	enter 0x20

	// ptr = array; index = 0;
	adrl ptr, array
	mov  index, xzr

	// while (index < count) {
loop:
	cmp index, #count
	bge end_loop

	// printf("%d", arr[index]);
	adrl x0, fmt2
	ldr  w1, [ptr, index, lsl #2]
	str  w1, [sp]
	bl   _printf

	// index++
	add index, index, #1
	b   loop

end_loop:
	// printf("\n");
	adrl x0, fmt3
	bl   _printf

	leave

	ldp x19, x20, [sp], #0x10

	ret

// void _asmMain(void);
_asmMain:
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

	leave

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
	.asciz "Listing 5-13b"
