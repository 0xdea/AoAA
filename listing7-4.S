// listing7-4.S - A simple state machine example
//
// ```
// $ ./build listing7-4
// $ ./listing7-4.out
// Calling Listing 7-4:
// Calling StateMachine, state=0, W20=5, W21=6
// Back from StateMachine, state=1, W20=11
// Calling StateMachine, state=1, W20=50, W21=60
// Back from StateMachine, state=2, W20=-10
// Calling StateMachine, state=2, W20=10, W21=20
// Back from StateMachine, state=3, W20=200
// Calling StateMachine, state=3, W20=50, W21=5
// Back from StateMachine, state=0, W20=10
// Calling StateMachine, state=0, W20=1, W21=2
// Back from StateMachine, state=1, W20=3
// Listing 7-4 terminated.
// ```

#include "include.S"

// state variable
#define state x19

.code

.global _getTitle
.global _asmMain

.pool

title:
	.asciz "Listing 7-4"

fmt0:
	.ascii "Calling StateMachine, "
	.asciz "state=%d, W20=5, W21=6\n"

fmt0b:
	.ascii "Calling StateMachine, "
	.asciz "state=%d, W20=1, W21=2\n"

fmtx:
	.ascii "Back from StateMachine, "
	.asciz "state=%d, W20=%d\n"

fmt1:
	.ascii "Calling StateMachine, "
	.asciz "state=%d, W20=50, W21=60\n"

fmt2:
	.ascii "Calling StateMachine, "
	.asciz "state=%d, W20=10, W21=20\n"

fmt3:
	.ascii "Calling StateMachine, "
	.asciz "state=%d, W20=50, W21=5\n"

.align 4

_getTitle:
	adrl x0, title
	ret

// void StateMachine(void);
//
// Leaf procedure, no need to save LR on the stack. Likewise, we do not preserve
// X19 and X20 even though they are technically non-volatile registers.
StateMachine:
	cmp state, #0
	bne trystate1

	// state 0: add W21 to W20 and switch to state 1
	add  w20, w20, w21
	add  state, state, #1
	b.al exit

trystate1:
	cmp state, #1
	bne trystate2

	// state 1: subtract W21 from W20 and switch to state 2
	sub  w20, w20, w21
	add  state, state, #1
	b.al exit

trystate2:
	cmp state, #2
	bne mustbestate3

	// state 2: multiply W20 by W21 and switch to state 3
	mul  w20, w20, w21
	add  state, state, #1
	b.al exit

mustbestate3:
	// state 3: divide W20 by W21 and switch back to state 0
	sdiv w20, w20, w21
	mov  state, #0

exit:
	ret

// void _asmMain(void);
_asmMain:
	stp   x19, x20, [sp, #-0x10]!
	stp   x21, x22, [sp, #-0x10]!
	enter 0x40

	// initialize the state machine
	mov state, #0

	// demonstrate state 0
	adrl x0, fmt0
	mov  x1, state
	str  x1, [sp]
	bl   _printf

	mov w20, #5
	mov w21, #6
	bl  StateMachine

	adrl x0, fmtx
	mov  x1, state
	str  x1, [sp]
	str  w20, [sp, #8]
	bl   _printf

	// demonstrate state 1
	adrl x0, fmt1
	mov  x1, state
	str  x1, [sp]
	bl   _printf

	mov w20, #50
	mov w21, #60
	bl  StateMachine

	adrl x0, fmtx
	mov  x1, state
	str  x1, [sp]
	str  w20, [sp, #8]
	bl   _printf

	// demonstrate state 2
	adrl x0, fmt2
	mov  x1, state
	str  x1, [sp]
	bl   _printf

	mov w20, #10
	mov w21, #20
	bl  StateMachine

	adrl x0, fmtx
	mov  x1, state
	str  x1, [sp]
	str  w20, [sp, #8]
	bl   _printf

	// demonstrate state 3
	adrl x0, fmt3
	mov  x1, state
	str  x1, [sp]
	bl   _printf

	mov w20, #50
	mov w21, #5
	bl  StateMachine

	adrl x0, fmtx
	mov  x1, state
	str  x1, [sp]
	str  w20, [sp, #8]
	bl   _printf

	// demonstrate back to state 0
	adrl x0, fmt0b
	mov  x1, state
	str  x1, [sp]
	bl   _printf

	mov w20, #1
	mov w21, #2
	bl  StateMachine

	adrl x0, fmtx
	mov  x1, state
	str  x1, [sp]
	str  w20, [sp, #8]
	bl   _printf

	leave
	ldp x21, x22, [sp], #0x10
	ldp x19, x20, [sp], #0x10
	ret
