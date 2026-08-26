// listing5-2.S - Demonstrates what happens when a procedure without a ret instruction is called
//
// ```
// $ ./build listing5-2
// $ ./listing5-2
// Calling Listing 5-2:
// followingProc was called
// Listing 5-2 terminated.
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

noRet:

followingProc:
	enter 64

	adrl x0, msg
	bl   _printf

	leave
	ret

// void _asmMain(void);
_asmMain:
	enter 64

	bl noRet

	leave
	ret

.data

msg:
	.asciz "followingProc was called\n"

title:
	.asciz "Listing 5-2"
