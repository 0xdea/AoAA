// listing1-1.S - A simple standalone gas program
//
// ```
// $ g++ listing1-1.S -o listing1-1
// $ objdump --disassemble-all listing1-1
//
// listing1-1:	file format mach-o arm64
//
// Disassembly of section __TEXT,__text:
//
// 0000000100000310 <_main>:
// 100000310: d65f03c0    	ret
// $ sudo dtruss ./listing1-1
// dtrace: system integrity protection is on, some features will not be available
//
// SYSCALL(args) 		 = return
// ```

.text

.global _main
.align  2

_main:
	ret
