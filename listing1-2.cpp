// listing1-2.cpp - A simple C++ program that calls an assembly function
//
// ```
// $ g++ listing1-2.cpp listing1-3.S -o listing1-2
// $ objdump --disassemble listing1-2
//
// listing1-2:	file format mach-o arm64
//
// Disassembly of section __TEXT,__text:
//
// 0000000100000498 <_main>:
// 100000498: d10083ff    	sub	sp, sp, #0x20
// 10000049c: a9017bfd    	stp	x29, x30, [sp, #0x10]
// 1000004a0: 910043fd    	add	x29, sp, #0x10
// 1000004a4: 52800008    	mov	w8, #0x0                ; =0
// 1000004a8: b9000be8    	str	w8, [sp, #0x8]
// 1000004ac: b81fc3bf    	stur	wzr, [x29, #-0x4]
// 1000004b0: 90000000    	adrp	x0, 0x100000000 <_printf+0x100000000>
// 1000004b4: 9113b000    	add	x0, x0, #0x4ec
// 1000004b8: 9400000a    	bl	0x1000004e0 <_printf+0x1000004e0>
// 1000004bc: 94000008    	bl	0x1000004dc <_asmMain>
// 1000004c0: 90000000    	adrp	x0, 0x100000000 <_printf+0x100000000>
// 1000004c4: 91140000    	add	x0, x0, #0x500
// 1000004c8: 94000006    	bl	0x1000004e0 <_printf+0x1000004e0>
// 1000004cc: b9400be0    	ldr	w0, [sp, #0x8]
// 1000004d0: a9417bfd    	ldp	x29, x30, [sp, #0x10]
// 1000004d4: 910083ff    	add	sp, sp, #0x20
// 1000004d8: d65f03c0    	ret
//
// 00000001000004dc <_asmMain>:
// 1000004dc: d65f03c0    	ret
//
// ...
// $ sudo dtruss ./listing1-2
// dtrace: system integrity protection is on, some features will not be available
//
// SYSCALL(args) 		 = return
// Calling asmMain():
// Returned from asmMain().
// ```

#include <stdio.h>

extern "C" {
void asmMain(void);
}

int main(void)
{
	printf("Calling asmMain():\n");
	asmMain();
	printf("Returned from asmMain().\n");
	return 0;
}
