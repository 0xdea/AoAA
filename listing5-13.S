// listing5-13.S - Recursive quicksort implementation
//
// ```
// $ ./build listing5-13
// $ ./listing5-13
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
#define pivot x24

quicksort:
	// preserve registers
	stp x19, x20, [sp, #-0x10]!
	stp x21, x22, [sp, #-0x10]!
	stp x23, x24, [sp, #-0x10]!

	enter 0x20

	cmp low, high
	bhs end_if3

	// i = low; j = high
	mov i, low
	mov j, high

	// pivot = ((i + j) / 2) * 4 = ((i + j) * 2)
	add x0, i, j
	lsr x0, x0, #1
	ldr pivot, [arr, x0, lsl #2]

	// do ... while (i <= j);
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
	bge end_if1

	ldr w0, [arr, i, lsl #2]
	ldr w1, [arr, j, lsl #2]
	str w0, [arr, j, lsl #2]
	str w1, [arr, i, lsl #2]

	// i++; j--;
	add i, i, #1
	sub j, j, #1

end_if1:
	cmp i, j
	ble do

	// call quicksort recursively to sort the sub-arrays if they have more than one element
	// if (low < j) quicksort(arr, low, j);
	cmp low, j
	bge end_if2

	// if (j < high) quicksort(arr, j + 1, high);
	cmp j, high
	blt do

end_if2:

end_if3:
	leave

	// restore registers
	ldp x23, x24, [sp], #0x10
	ldp x21, x22, [sp], #0x10
	ldp x19, x20, [sp], #0x10

	ret

// void _asmMain(void);
_asmMain:

	// preserve non-volatile registers
	stp x19, x20, [sp, #-0x10]!

	enter (pt_count * pt_size) + 0x40

	// init_points_array(&points_array);
	add x0, fp, #points_array
	str x0, [sp]
	bl  init_points_array

	// loop over points_array and print each element
	// for (x19 = 0; x19 < pt_count; x19++) ...
	mov x19, xzr

loop:
	cmp x19, #pt_count
	bhs end_loop

	// printf("points_array[%d].x = %d\t", index, x1[index].x);
	adrl x0, fmtx
	mov  x1, x19
	str  x1, [sp]
	add  x3, fp, #points_array
	add  x3, x3, x19, lsl #1
	ldrb w2, [x3, #x]
	str  w2, [sp, #0x8]
	bl   _printf

	// printf("points_array[%d].y = %d\n", index, x1[index].y);
	adrl x0, fmty
	mov  x1, x19
	str  x1, [sp]
	add  x3, fp, #points_array
	add  x3, x3, x19, lsl #1
	ldrb w2, [x3, #y]
	str  w2, [sp, #0x8]
	bl   _printf

	// increment index and repeat
	add x19, x19, #1
	b   loop

end_loop:
	leave

	// restore non-volatile registers
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
