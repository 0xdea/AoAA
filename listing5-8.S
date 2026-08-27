// listing5-8.S - Demonstrates passing a local variable by reference as a parameter to a function
//
// ```
// $ ./build listing5-8
// $ ./listing5-8
// Calling Listing 5-8:
// address=0x16d87f09c, value=42
// Listing 5-8 terminated.
// $ lldb listing5-8
// (lldb) b main
// Breakpoint 1: where = listing5-8`main, address = 0x00000001000005e8
// (lldb) r
// ...
// (lldb) reg read sp
//       sp = 0x000000016fdfef20
// (lldb) c
// Process 63174 resuming
// Calling Listing 5-8:
// address=0x16fdfeecc, value=42
// Listing 5-8 terminated.
// Process 63174 exited with status = 0 (0x00000000)
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

// void somefunc(void);
//
// Calls anotherfunc() passing a local variable by reference.
//
// Local variables:
// - value: a word at offset -4 from the frame pointer.

#define value -4

somefunc:
	enter 8

	// value = 42
	mov w0, #42
	str w0, [fp, #value]

	// anotherfunc(&value);
	add x0, fp, #value
	bl  anotherfunc

	leave
	ret

// void anotherfunc(word *x0);
//
// Prints the address of x0 and the value at that address.
//
// Arguments:
// - x0: The address of the word to print.
anotherfunc:
	enter 16

	// printf("address=%p, value=%d\n", x0, *x0);
	ldr  x1, [x0]
	str  x1, [sp, #8]
	str  x0, [sp]
	adrl x0, fmt
	bl   _printf

	leave
	ret

// void _asmMain(void);
_asmMain:
	enter 0

	// somefunc();
	bl somefunc

	leave
	ret

.data

fmt:
	.asciz "address=%p, value=%d\n"

title:
	.asciz "Listing 5-8"
