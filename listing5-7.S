// listing5-7.S - Demonstrates passing a static variable by reference to a function
//
// ```
// $ ./build listing5-7
// $ ./listing5-7
// Calling Listing 5-7:
// address=0x1044dc000, value=42
// Listing 5-7 terminated.
// $ otool -l listing5-7 | grep -A 5 "sectname __data"
//   sectname __data
//    segname __DATA
//       addr 0x0000000100008000
//       size 0x0000000000000026
//     offset 32768
//      align 2^0 (1)
// $ lldb listing5-7
// (lldb) image dump sections listing5-7
// ...
//   0x0000000000000006 data                   [0x0000000100008000-0x0000000100008026)  rw-  0x00008000 0x00000026 0x00000000 listing5-7.__DATA.__data
// ...
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

// void somefunc(word *x0);
//
// Prints the address of x0 and the value at that address.
//
// Arguments:
// - x0: The address of the word to print.

somefunc:
	enter 16

	// printf("address=0x%p, value=%d\n", x0, *x0);
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

	// somefunc(&staticvar);
	adrl x0, staticvar
	bl   somefunc

	leave
	ret

.data

staticvar:
	.word 42

fmt:
	.asciz "address=%p, value=%d\n"

title:
	.asciz "Listing 5-7"
