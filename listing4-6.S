// listing4-6.S - A simple bubble sort example
//
// ```
// $ ./build listing4-6
// $ ./listing4-6
// Calling Listing 4-6:
// sortme[0] = 1
// sortme[1] = 2
// sortme[2] = 3
// sortme[3] = 4
// sortme[4] = 5
// sortme[5] = 6
// sortme[6] = 7
// sortme[7] = 8
// sortme[8] = 9
// sortme[9] = 10
// sortme[10] = 11
// sortme[11] = 12
// sortme[12] = 13
// sortme[13] = 14
// sortme[14] = 15
// sortme[15] = 16
// Listing 4-6 terminated.
// ```

// enter - function prologue
.macro enter locals.size
stp    fp, lr, [sp, #-0x10]!
mov    fp, sp
.if    \locals.size > 0
sub    sp, sp, #((\locals.size)+15) & 0xFFFFFFFFFFFFFFF0
.endif
.endm

// leave - function epilogue
.macro leave
mov    sp, fp
ldp    fp, lr, [sp], #0x10
.endm

// adrl - load the address of a symbol into a register
.macro adrl reg, mem
adrp   \reg, \mem@PAGE
add    \reg, \reg, \mem@PAGEOFF
.endm

// vparm - load variadic function parameters
.macro vparm2 mem
adrl   x1, \mem
ldr    x1, [x1]
str    x1, [sp]
.endm

.macro vparm3 mem
adrl   x2, \mem
ldr    x2, [x2]
str    x2, [sp, #0x08]
.endm

.macro vparm4 mem
adrl   x3, \mem
ldr    x3, [x3]
str    x3, [sp, #0x10]
.endm

.macro vparm5 mem
adrl   x4, \mem
ldr    x4, [x4]
str    x4, [sp, #0x18]
.endm

// constants
maxlen = 0x100
true   = 1
false  = 0

.text
.balign 4

.global _getTitle
.global _asmMain

// void sort(4byte *array, 8byte count)
//
// Sorts the array of integers in ascending order using bubble sort.
//
// Parameters:
//   array - Pointer to the array of integers to be sorted.
//   count - Number of elements in the array.
//
// Local variables:
//   X2 - didswap boolean flag
//   X3 - i loop index
//
// Note:
//   This is not an external C function and it doesn't call any external functions,
//   so it will dispense with some of the stuff mandated by the calling conventions.

#define array x0
#define count x1
#define didswap x2
#define i x3

sort:
	// count = (count - 1) * 4;
	sub count, count, #1
	lsl count, count, #2

outer:
	// didswap = false; i = 0;
	mov didswap, #false
	mov i, #0

inner:
	// while (i < count) ...
	cmp i, count
	bhs exit_inner

	// w6 = array[i]; w7 = array[i + 1];
	add x5, array, i
	ldr w6, [x5]
	ldr w7, [x5, #4]

	// if (w6 > w7) swap
	cmp w6, w7
	bls dontswap

	// swap w6 and w7
	str w6, [x5, #4]
	str w7, [x5]
	mov didswap, #true

dontswap:
	// i += 4;
	add i, i, #4
	b   inner

exit_inner:
	cmp didswap, #true
	beq outer

	ret

// char *_getTitle(void)
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// void _asmMain(void)
//
// Sorts the array of integers in ascending order using bubble sort and prints the sorted array.
_asmMain:
	// preserve non-volatile registers x19 and x20
	stp x19, x20, [sp, #-0x10]!

	enter 0x40

	// sort(&sortme, sortsize);
	adrl x0, sortme
	mov  x1, #sortsize
	bl   sort

	// print the sorted array
	adrl x19, sortme
	mov  x20, xzr

loop:
	// value = array[index];
	ldr  w0, [x19, x20, lsl #2]
	adrl x1, value
	str  w0, [x1]
	adrl x1, index
	str  x20, [x1]

	// printf("sortme[%d] = %d\n", index, value);
	adrl   x0, fmt
	vparm2 index
	vparm3 value
	bl     _printf

	// index++;
	add x20, x20, #1
	mov x9, #sortsize
	cmp x20, x9
	blo loop

	leave

	// restore non-volatile registers x19 and x20
	ldp x19, x20, [sp], #0x10

	ret

.data

sortme:
	.4byte 1, 2, 16, 14, 3, 9, 4, 10
	.4byte 5, 7, 15, 12, 8, 6, 11, 13

	// number of 4-byte elements in sortme
	sortsize = (. - sortme) / 4

value:
	.4byte 0

index:
	.8byte 0

fmt:
	.asciz "sortme[%d] = %d\n"

title:
	.asciz "Listing 4-6"
