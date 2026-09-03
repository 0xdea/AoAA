// listing7-1.S - Demonstrates initializing 8-byte values with the addresses of statement labels
//
// ```
// $ ./build listing7-1
// Illegal text-relocations:
//   text-relocation in 'data_in_code'+0x8 (/private/var/folders/dd/_kx5dv0x0yxfv529cmy6ynp00000gn/T/listing7-1-13c5aa.o) to 'global_label2'
//   text-relocation in 'data_in_code' (/private/var/folders/dd/_kx5dv0x0yxfv529cmy6ynp00000gn/T/listing7-1-13c5aa.o) to 'global_label1'
// ld: Found illegal text-relocations
// clang++: error: linker command failed with exit code 1 (use -v to see invocation)
// ```

#include "include.S"

.code

.global _getTitle
.global _asmMain

.pool
.balign 8

// Storing the addresses of global_label1/global_label2 here means this .dword pair still
// lives in .text (no .data directive follows .code above), so the linker must patch two
// absolute addresses into the code segment at load time. On arm64 macOS, __TEXT is always
// read-only/non-relocatable under PIE, so this fails to link with "Illegal text-relocations".
// Compare with labels_in_proc below, which stores the very same two label addresses but in
// .data, where such relocations are allowed.
data_in_code:
	.dword global_label1, global_label2

title:
	.asciz "Listing 7-1"

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
