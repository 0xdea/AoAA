// listing7-3.S - Demonstrates handling complex boolean expressions with the ccmp instruction
//
// ```
// $ ./build listing7-3
// $ ./listing7-3
// Calling Listing 7-3:
// ((x > y) && (z < t)) || (aa != bb)
//  x  y  z  t aa bb Result
// -- -- -- -- -- -- ------
// -1 -1 -1  0  0 -1      1
//  0 -1  0  0  0  0      0
//  1 -1  1  0  0  1      1
// -1  0 -1  1 -1 -1      0
//  0  0  0  1 -1  0      1
//  1  0  1  1 -1  1      1
// -1  1 -1 -1  1 -1      1
//  0  1  0 -1  1  0      1
//  1  1  1 -1  1  1      0
//  1  0  0  1  1  1      1
// Listing 7-3 terminated.
// ```

#include "include.S"

// array size
size = 10

.code

.global _getTitle
.global _asmMain

.pool

title:
	.asciz "Listing 7-3"

fmt1:
	.ascii "((x > y) && (z < t)) || (aa != bb)\n"
	.ascii " x  y  z  t aa bb Result\n"
	.asciz "-- -- -- -- -- -- ------\n"

fmt2:
	.asciz "%2d %2d %2d %2d %2d %2d     %2d\n"

.align 4

_getTitle:
	adrl x0, title
	ret

// void _asmMain(void);
//
// Loops through the array elements and prints their values along with the result of
// the expression: ((x > y) && (z < t)) || (aa != bb).

#define x x19
#define y x20
#define z x21
#define t x22
#define aa x23
#define bb x24
#define i x25

_asmMain:
	stp   x19, x20, [sp, #-0x10]!
	stp   x21, x22, [sp, #-0x10]!
	stp   x23, x24, [sp, #-0x10]!
	stp   x25, x26, [sp, #-0x10]!
	enter 0x40

	// initialize the array pointers
	adrl x, x_array
	adrl y, y_array
	adrl z, z_array
	adrl t, t_array
	adrl aa, a_array
	adrl bb, b_array

	// print the header
	adrl x0, fmt1
	bl   _printf

	// loop through the array elements and print their values along
	// with the result of ((x > y) && (z < t)) || (aa != bb)
	mov i, #0

0:
	// load the array elements
	ldr w1, [x, i, lsl #2]  // w1 = x[i]
	ldr w2, [y, i, lsl #2]  // w2 = y[i]
	ldr w3, [z, i, lsl #2]  // w3 = z[i]
	ldr w4, [t, i, lsl #2]  // w4 = t[i]
	ldr w5, [aa, i, lsl #2] // w5 = aa[i]
	ldr w6, [bb, i, lsl #2] // w6 = bb[i]

	// w7 = ((w1 > w2) && (w3 < w4)) || (w5 != w6)
	cmp  w1, w2
	ccmp w3, w4, #ccnlt, gt
	ccmp w5, w6, #ccne, nlt
	cset w7, ne

	// print the result
	adrl x0, fmt2
	str  w1, [sp]
	str  w2, [sp, #0x08]
	str  w3, [sp, #0x10]
	str  w4, [sp, #0x18]
	str  w5, [sp, #0x20]
	str  w6, [sp, #0x28]
	str  w7, [sp, #0x30]
	bl   _printf

	// increment the loop counter and check the exit condition
	add i, i, #1
	cmp i, #size
	blo 0b

	leave
	ldp x25, x26, [sp], #0x10
	ldp x23, x24, [sp], #0x10
	ldp x21, x22, [sp], #0x10
	ldp x19, x20, [sp], #0x10
	ret

.data
.balign 8

x_array:
	.word -1, 0, 1, -1, 0, 1, -1, 0, 1, 1

y_array:
	.word -1, -1, -1, 0, 0, 0, 1, 1, 1, 0

z_array:
	.word -1, 0, 1, -1, 0, 1, -1, 0, 1, 0

t_array:
	.word 0, 0, 0, 1, 1, 1, -1, -1, -1, 1

a_array:
	.word 0, 0, 0, -1, -1, -1, 1, 1, 1, 1

b_array:
	.word -1, 0, 1, -1, 0, 1, -1, 0, 1, 1
