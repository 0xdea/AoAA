// include.S - Macro definitions for macOS based on the original aoaa.inc

// aligns code to a 4-byte boundary
.macro  .code
.text
.balign 4
.endm

// function prologue
.macro enter locals.size
stp    fp, lr, [sp, #-16]!
mov    fp, sp
.if    \locals.size > 0
sub    sp, sp, #((\locals.size)+15) & 0xFFFFFFFFFFFFFFF0
.endif
.endm

// function epilogue
.macro leave
mov    sp, fp
ldp    fp, lr, [sp], #16
.endm

// loads the address of a symbol into a register
.macro adrl reg, mem
adrp   \reg, \mem@PAGE
add    \reg, \reg, \mem@PAGEOFF
.endm

// loads variadic function parameters onto the stack
.macro vparm2 mem
adrl   x1, \mem
ldr    x1, [x1]
str    x1, [sp]
.endm

.macro vparm3 mem
adrl   x2, \mem
ldr    x2, [x2]
str    x2, [sp, #8]
.endm

.macro vparm4 mem
adrl   x3, \mem
ldr    x3, [x3]
str    x3, [sp, #16]
.endm

.macro vparm5 mem
adrl   x4, \mem
ldr    x4, [x4]
str    x4, [sp, #24]
.endm
