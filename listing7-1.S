// listing7-1.S - Demonstrates initializing 8-byte values with the addresses of statement labels
//
// ```
// $ ./build listing7-1
// $ ./listing7-1
// ```

#include "include.S"

.code

.global _getTitle
.global _asmMain

.pool
.balign 8

title:
	.asciz "Listing 7-1"

data_in_code:
	.dword global_label1, global_label2

_getTitle:
	adrl x0, title
	ret

// proc_with_labels
//
// Just a procedure containing private (lexically scoped) and global symbols.
proc_with_labels:
global_label1:
	b global_label2

global_label2:
	ret

_asmMain:
	enter 0x40

	leave
	ret

.data
.balign 8

labels_in_proc:
	.dword global_label1, global_label2
