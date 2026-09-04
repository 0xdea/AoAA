// include.S - Macro definitions for macOS based on the original aoaa.inc

// aligns code to a 4-byte boundary
.macro  .code
.text
.balign 4
.endm

// function prologue
.macro enter locals.size
stp    fp, lr, [sp, #-0x10]!
mov    fp, sp
.if    \locals.size > 0
sub    sp, sp, #((\locals.size) + 0xf) & 0xFFFFFFFFFFFFFFF0
.endif
.endm

// function epilogue
.macro leave
mov    sp, fp
ldp    fp, lr, [sp], #0x10
.endm

// loads the address of a symbol into a register
.macro adrl reg, mem
adrp   \reg, \mem@PAGE
add    \reg, \reg, \mem@PAGEOFF
.endm

// gets the value of errno
.macro get_errno
bl     ___error
ldr    w0, [x0]
.endm

// loads variadic function parameters on the stack
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

.macro vparm6 mem
adrl   x5, \mem
ldr    x5, [x5]
str    x5, [sp, #0x20]
.endm

.macro vparm7 mem
adrl   x6, \mem
ldr    x6, [x6]
str    x6, [sp, #0x28]
.endm

.macro vparm8 mem
adrl   x7, \mem
ldr    x7, [x7]
str    x7, [sp, #0x30]
.endm

// opposite conditions for conditional instructions
#define nhi ls
#define nhs lo
#define nlo hs
#define nls hi
#define ngt le
#define nge lt
#define nlt ge
#define nle gt

// constants to use in the immediate field of ccmp (NZCV)
.equ cceq, 0b0100 // Z=1
.equ ccne, 0b0000 // Z=0

.equ cchi, 0b0010 // C=1
.equ cchs, 0b0110 // Z=1, C=1
.equ cclo, 0b0000 // Z=0, C=0
.equ ccls, 0b0100 // Z=1, C=0
.equ ccgt, 0b0000 // Z=0, N=V
.equ ccge, 0b0100 // Z=1, N=V
.equ cclt, 0b0001 // Z=0, N!=V
.equ ccle, 0b0101 // Z=1, N!=V

.equ ccnhi, 0b0100 // Not HI=LS, Z=1, C=0
.equ ccnhs, 0b0000 // Not HS=LO, Z=0, C=0
.equ ccnlo, 0b0110 // Not LO=HS, Z=1, C=1
.equ ccnls, 0b0100 // Not LS=HI, C=1
.equ ccngt, 0b0101 // Not GT=LE, Z=1, N!=V
.equ ccnge, 0b0001 // Not GE=LT, Z=0, N!=V
.equ ccnlt, 0b0100 // Not LT=GE, Z=1, N=V
.equ ccnle, 0b0000 // Not LE=GT, Z=0, N=V

.equ cccs, 0b0010 // C=1
.equ cccc, 0b0000 // C=0
.equ ccvs, 0b0001 // V=1
.equ ccvc, 0b0000 // V=0
.equ ccmi, 0b1000 // N=1
.equ ccpl, 0b0000 // N=0
