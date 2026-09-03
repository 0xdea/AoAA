// listing5-12b.S - Demonstrates passing a large object by reference on the stack (array on the stack)
//
// ```
// $ ./build listing5-12b
// $ ./listing5-12b
// Calling Listing 5-12b:
// points_array[0].x = 0	points_array[0].y = 0
// points_array[1].x = 0	points_array[1].y = 1
// points_array[2].x = 0	points_array[2].y = 2
// points_array[3].x = 0	points_array[3].y = 3
// points_array[4].x = 0	points_array[4].y = 4
// points_array[5].x = 0	points_array[5].y = 5
// points_array[6].x = 0	points_array[6].y = 6
// points_array[7].x = 0	points_array[7].y = 7
// points_array[8].x = 1	points_array[8].y = 0
// points_array[9].x = 1	points_array[9].y = 1
// points_array[10].x = 1	points_array[10].y = 2
// points_array[11].x = 1	points_array[11].y = 3
// points_array[12].x = 1	points_array[12].y = 4
// points_array[13].x = 1	points_array[13].y = 5
// points_array[14].x = 1	points_array[14].y = 6
// points_array[15].x = 1	points_array[15].y = 7
// points_array[16].x = 2	points_array[16].y = 0
// points_array[17].x = 2	points_array[17].y = 1
// points_array[18].x = 2	points_array[18].y = 2
// points_array[19].x = 2	points_array[19].y = 3
// points_array[20].x = 2	points_array[20].y = 4
// points_array[21].x = 2	points_array[21].y = 5
// points_array[22].x = 2	points_array[22].y = 6
// points_array[23].x = 2	points_array[23].y = 7
// Listing 5-12b terminated.
// ```

#include "include.S"

// point struct size
pt_size = 2

// number of points in the array
pt_count = 24

// offsets of elements in the struct
x = 0
y = 1

.code

.global _getTitle
.global _asmMain

// char *_getTitle(void);
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// init_points_array(points_array *ptr);
//
// Initializes the points_array (array of points) at the given address.
//
// Parameters:
// - ptr: The address of the points_array to initialize.

// offset to ptr from fp
ptr = 0x10

#define index x0
#define array x1

init_points_array:
	enter 0

	// array = ptr
	ldr array, [fp, #ptr]

	// loop over points_array and initialize each element
	// for (index = 0; index < pt_count; index++) ...
	mov index, xzr

foreach_element:
	cmp index, #pt_count
	bhs end_foreach

	// compute the address of points_array[index] in x3
	// x3 = array + index * pt_size
	add x3, array, index, lsl #1

	// x1[index].x = index / 8
	lsr  x2, index, #3
	strb w2, [x3, #x]

	// x1[index].y = index % 8
	and  x2, index, #7
	strb w2, [x3, #y]

	// index++
	add index, index, #1
	b   foreach_element

end_foreach:
	leave
	ret

// void _asmMain(void);

// offset to points_array from fp
points_array = -(pt_count * pt_size)

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

fmtx:
	.asciz "points_array[%d].x = %d\t"

fmty:
	.asciz "points_array[%d].y = %d\n"

title:
	.asciz "Listing 5-12b"
