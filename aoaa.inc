// aoaa.inc
//
//  "Magic" header file for "The Art of ARM Assembly"
// that smooths over the differences between Linux
// and macOS.
//
// Assertions:
//
//  Either isMacOS, isLinux, or isLinuxPIE has been
// defined in the source file (using #define) prior
// to including this source file. This source file
// must be included using <<#include "aoaa.inc">>
// NOT using the gas <<.include>> directive.

#ifndef aoaa_inc
#define aoaa_inc 0

    // Makefiles define the symbols Darwin (for macOS)
    // and Linux (for Linux) rather than isMacOS and
    // isLinux. Deal with that here:
    
    #ifdef Darwin
        #define isMacOS (1)
        #undef isLinux
        #undef Darwin
    #endif
    #ifdef Linux
        #define isLinux (1)
        #undef isMacOS
        #undef Linux
    #endif
    

    // Make sure all OS symbols are
    // defined and only one of them
    // is set to 1:
    
    #ifndef isMacOS
        #define isMacOS (0)
    #else
        #undef isMacOS
        #define isMacOS (1)
    #endif

    #ifndef isLinux
        #define isLinux (0)
    #else
        #undef isLinux
        #define isLinux (1)
    #endif

    // Make sure exactly one of the OS symbols is set to 1:
    
    #if (isMacOS+isLinux) != 1
        #error "Exactly one of isMacOS or isLinux must be 1"
    #endif

    // Do macOS-specific stuff here:
    
    #if isMacOS 

        // Change all the C global function
        // names to include a leading underscore
        // character, as required by macOS (these
        // definitions allow use to use all the
        // same names in example programs in
        // macOS and Linux_). This list includes
        // all the C Stdlib functions used by
        // AoAA example code. 
        
        #define asmMain  _asmMain
        #define acos     _acos
        #define asin     _asin
        #define atan     _atan
        #define cos      _cos
        #define exp      _exp
        #define exp2     _exp2
        #define getTitle _getTitle
        #define free     _free
        #define log      _log
        #define log2     _log2
        #define log10    _log10
        #define malloc   _malloc
        #define memchr   _memchr
        #define memcmp   _memcmp
        #define memcpy   _memcpy
        #define memmove  _memmove
        #define memset   _memset
        
        #define pow      _pow
        #define printf   _printf
        #define readLine _readLine
        #define sin      _sin
        #define sqrt     _sqrt
        #define strcat   _strcat
        #define strncat  _strncat
        #define strchr   _strchr
        #define strcmp   _strcmp
        #define strcmpi  _strcasecmp
        #define strcasecmp _strcasecmp
        #define strncmp  _strncmp
        #define strcpy   _strcpy
        #define strncpy  _strncpy
        #define strcspn  _strcspn
        #define strerror _strerror
        #define strlen   _strlen
        #define strncat  _strncat
        #define strpbrk  _strpbrk
        #define strrchr  _strrchr
        #define strspn   _strspn
        #define strstr   _strstr
        #define strcasestr  _strcasestr
        #define strnstr  _strnstr
        #define strtok   _strtok
        #define strtol   _strtol
        #define tan      _tan
        #define write    _write
        
        #define __errno_location ___error
        
        // Under macOS, the system call number
        // goes into X16:
        
        #define svcReg x16
        #define OSint 0x80

    
            
        // LEA (Load Effective Address) macro.
        // Correctly loads the address of
        // a memory object into a register, even
        // on machines that use position independent
        // executables (PIE).
        
        .macro  lea reg, mem
            adrp    \reg,\mem@PAGE
            add     \reg, \reg, \mem@PAGEOFF        
        .endm
        
        // mstr- assembles to an str instruction under macOS
        // mstrb
        // mstrh
        
        .macro      mstr operands:vararg
        str         \operands
        .endm
        
        .macro      mstrb operands:vararg
        strb        \operands
        .endm
        
        .macro      mstrh operands:vararg
        strh        \operands
        .endm
        
        // macOS's assembler doesn't have .dword,
        // define it here:
        
        .macro  .dword value:vararg
            .quad   \value
        .endm
        
        // Macros to load parameters 2..8 onto
        // the stack for macOS when calling
        // a variadic (variable parameter list)
        // function, such as printf().
        //
        // Note that parameter 1 still goes into X0.
        
        .macro  vparm2 mem
        lea     x1, \mem
        ldr     x1, [x1]
        str     x1, [sp]
        .endm
        
        .macro  vparm3 mem
        lea     x2, \mem
        ldr     x2, [x2]
        str     x2, [sp, #8]
        .endm
        
        .macro  vparm4 mem
        lea     x3, \mem
        ldr     x3, [x3]
        str     x3, [sp, #16]
        .endm
        
        .macro  vparm5 mem
        lea     x4, \mem
        ldr     x4, [x4]
        str     x4, [sp, #24]
        .endm
        
        .macro  vparm6 mem
        lea     x5, \mem
        ldr     x5, [x5]
        str     x5, [sp, #32]
        .endm
        
        .macro  vparm7 mem
        lea     x6, \mem
        ldr     x6, [x6]
        str     x6, [sp, #40]
        .endm
        
        .macro  vparm8 mem
        lea     x7, \mem
        ldr     x7, [x7]
        str     x7, [sp, #48]
        .endm
        


    #elif isLinux

        // Do Linux (no-pie)-specific stuff here:

        .macro  lea reg, mem
            adrp    \reg,\mem
            add     \reg, \reg, :lo12:\mem      
        .endm

        // mstr- assembles to nothing under Linux
        // mstrb
        // mstrh
        
        .macro      mstr operands:vararg
        .endm
        
        .macro      mstrb operands:vararg
        .endm
        
        .macro      mstrh operands:vararg
        .endm
        
        // Under Linux, the system call number
        // is passed in X8:
        
        #define svcReg x8
        #define OSint 0
        
        
    #endif
    
    #if isLinux == 1 
    
        .macro  vparm2 mem
        lea     x1, \mem
        ldr     x1, [x1]
        .endm
        
        .macro  vparm3 mem
        lea     x2, \mem
        ldr     x2, [x2]
        .endm
        
        .macro  vparm4 mem
        lea     x3, \mem
        ldr     x3, [x3]
        .endm
        
        .macro  vparm5 mem
        lea     x4, \mem
        ldr     x4, [x4]
        .endm
        
        .macro  vparm6 mem
        lea     x5, \mem
        ldr     x5, [x5]
        .endm
        
        .macro  vparm7 mem
        lea     x6, \mem
        ldr     x6, [x6]
        .endm
        
        .macro  vparm8 mem
        lea     x7, \mem
        ldr     x7, [x7]
        .endm

    #endif  


    // Global declarations:
    
    .global asmMain
    .global getTitle
    .global readLine
    .global printf

        
    // Generic code for all OSes:

    
    // Gas doesn't have a .qword
    // directive. Map .qword to .octa:
    
    .macro  .qword value:vararg
        .octa   \value
    .endm
    
    
    
    // Macros for structure definitions
    
__inStruct          = 0
__inArgs            = 0
__inLocals          = 0
__dir               = 1

                    .macro  struct name initialOffset=0
__inStruct          = 1
__inLocals          = 0
__inArgs            = 0
__struct_offset     = \initialOffset
\name\().base       = \initialOffset
__dir               = 1
                    .if     \initialOffset > 0
                    .err    
                    .err    struct offset must be negative or 0
                    .endif          
                    .endm
                    
                    .macro  args, name initialOffset=16
__inStruct          = 0
__inLocals          = 0
__inArgs            = 1
__struct_offset     = \initialOffset
\name\().base       = \initialOffset
__dir               = 1
                    .endm
                    

                    .macro  locals name
__inStruct          = 0
__inLocals          = 1
__inArgs            = 0
__struct_offset     = 0
__dir               = -1
                    .endm
                    
                    
                    .macro  salign size
__salign            = 0xFFFFFFFFFFFFFFFF - ((1 << \size)-1)
__struct_offset     = (__struct_offset + (1 << \size)-1) & __salign
                    .endm
                    
                    .macro  byte name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + \elements
                    .else
__struct_offset     =       __struct_offset + \elements
\name               =       -__struct_offset
                    .endif
                    .endm
        
                    .macro  hword name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*2)
                    .else
__struct_offset     =       __struct_offset + ((\elements)*2)
\name               =       -__struct_offset
                    .endif
                    .endm
        
                    .macro  word name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*4)
                    .else
__struct_offset     =       __struct_offset + ((\elements)*4)
\name               =       -__struct_offset
                    .endif
                    .endm
        
                    .macro  dword name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*8)
                    .else
__struct_offset     =       __struct_offset + ((\elements)*8)
\name               =       -__struct_offset
                    .endif
                    .endm
        
                    .macro  qword name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*16)
                    .else
__struct_offset      =       __struct_offset + ((\elements)*16)
\name               =       -__struct_offset
                    .endif
                    .endm
        
                    .macro  oword name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*32)
                    .else
__struct_offset     = __struct_offset + ((\elements)*32)
\name               = -__struct_offset
                    .endif
                    .endm
                
                    .macro  single name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*4)
                    .else
__struct_offset     =       __struct_offset + ((\elements)*4)
\name               =       -__struct_offset
                    .endif
                    .endm
        
                    .macro  double name, elements=1
                    .if     __dir > 0
\name               =       __struct_offset
__struct_offset     =       __struct_offset + ((\elements)*8)
                    .else
__struct_offset     =       __struct_offset + ((\elements)*8)
\name               =       -__struct_offset
                    .endif
                    .endm

// Generate name.size and name.offset constants
// specifying total structure size and the offset
// just beyond the last field.
//
// Also create a macro to be used to declare
// structure variables.

                    .macro ends name
                    .ifb    \name
                    .err    "Expected structure name as argument"
                    .endif
                    
__inStruct          =       0
\name\().size       =       __struct_offset-\name\().base
\name\().offset     =       __struct_offset
                    .macro  \name varName
                    .if     \name\().base < 0
                    .space  __struct_offset-(\name\().base)
                    .endif
\varName:
                    .if     __struct_offset > 0
                    .fill   __struct_offset
                    .endif

                    .endm 
                    .endm
                    

                    .macro  enda name
                    .ifb    \name
                    .err    "Expected args name as argument"
                    .endif
_inArgs             =       0
\name\().size       =       __struct_offset-\name\().base
                    .endm
                    


                    .macro  endl name
                    .ifb    \name
                    .err    "Expected locals name as argument"
                    .endif
__inLocal           =       0
\name\().size       =       __struct_offset
                    .endm
                    

// Macro to emit a string that is padded with bytes
// so that it consumes a multiple of 4 bytes in memory

                    .macro   wastr theStr
                    .asciz   "\theStr"
                    .p2align 2
                    .endm

// Macros for declaration procedures/functions

public      =               1
                    .macro  proc pName:req, isPublic=0
                    
// If "public" argument is present, emit
// global statement.

                    .if     \isPublic
                    .global _\pName
                    .global \pName
                    .endif

\pName\().isOpenProcDCL = 1
\pName:
_\pName:
                    .endm
                                    
                    .macro  endp pName:req
                    .ifndef \pName\().isOpenProcDCL
                    .err
                    .err   "Not an open procedure"
                    .else
                    .if     \pName\().isOpenProcDCL
                    .else
                    .err
                    .err   "endp name does not match last proc name"
                    .endif
                    .endif
\pName\().isOpenProcDCL = 0
                    .endm           


// Sanity for ARM code:

                    .macro  .code
                    .text
                    .align  2
                    .endm    
                    
// Assembly standard entry sequence:

                    .macro  enter localsSize
                    stp     fp, lr, [sp, #-16]!
                    mov     fp, sp
                    .if     \localsSize > 0
                    sub     sp, sp, #((\localsSize)+15) & 0xFFFFFFFFFFFFFFF0
                    .endif
                    .endm
                    
// Assembly standard exit sequence

                    .macro  leave
                    mov     sp, fp
                    ldp     fp, lr, [sp], #16
                    ret
                    .endm  


// goto-
//
//          Transfers control to the specified label
// anywhere in the 64-bit address space

                    .macro  goto destination
                    adr     x16, 0f
                    ldr     x17, 0f
                    add     x16, x16, x17
                    br      x16
0:
                    .dword  \destination-0b
                    .endm
                             
                             
    
// getErrno-
//
// Retrieve's C errno value and returns
// it in X0:
            
                    .extern __errno_location
                    .macro  getErrno
                    bl      __errno_location
                    ldr     w0, [x0]
                    .endm

// Constants to use in the immediate field of
// ccmp:

//                  NZCV
            .equ    ccne,   0b0000   //Z=0
            .equ    cceq,   0b0100   //Z=1
            .equ    cchi,   0b0010   //C=1
            .equ    cchs,   0b0110   //Z=1, C=1
            .equ    cclo,   0b0000   //Z=0, C=0
            .equ    ccls,   0b0100   //Z=1, C=0
            .equ    ccgt,   0b0000   //Z=0, N=V
            .equ    ccge,   0b0100   //Z=1, N=V
            .equ    cclt,   0b0001   //Z=0, N!=V
            .equ    ccle,   0b0101   //Z=1, N!=V

            .equ    cccs,   0b0010   //C=1
            .equ    cccc,   0b0000   //C=0
            .equ    ccvs,   0b0001   //V=1
            .equ    ccvc,   0b0000   //V=0
            .equ    ccmi,   0b1000   //N=1
            .equ    ccpl,   0b0000   //N=0

            .equ    ccnhi,  0b0100   //Not HI=LS, Z=1, C=0
            .equ    ccnhs,  0b0000   //Not HS=LO, Z=0, C=0
            .equ    ccnlo,  0b0110   //Not LO=HS, Z=1, C=1
            .equ    ccnls,  0b0100   //Not LS=HI, C=1

            .equ    ccngt,  0b0101   //Not GT=LE, Z=1, N!=V
            .equ    ccnge,  0b0001   //Not GE=LT, Z=0, N!=V
            .equ    ccnlt,  0b0100   //Not LT=GE, Z=1, N=V
            .equ    ccnle,  0b0000   //Not LE=GT, Z=0, N=V
                            
// Opposite conditions (useful with all conditional instructions

#define nhi ls
#define nhs lo
#define nlo hs
#define nls hi
#define ngt le
#define nge lt
#define nlt ge
#define nle gt


// Opposite branches

        .macro  bnlt dest
        bge     \dest
        .endm
        
        .macro  bnle dest
        bgt     \dest
        .endm
        
        .macro  bnge dest
        blt     \dest
        .endm
        
        .macro  bngt dest
        ble     \dest
        .endm

        .macro  bnlo dest
        bhs     \dest
        .endm
        
        .macro  bnls dest
        bhi     \dest
        .endm
        
        .macro  bnhs dest
        blo     \dest
        .endm
        
        .macro  bnhi dest
        bls     \dest
        .endm
                    

// Structure to hold the volatile registers saved by functions
// that call C stdlib funcs.
//
// Note: size of this structure must be a multiple of 16 bytes!

            struct  volatile_save
            qword   volatile_save.x0x1
            qword   volatile_save.x2x3
            qword   volatile_save.x4x5
            qword   volatile_save.x6x7
            qword   volatile_save.x8x9
            qword   volatile_save.x10x11
            qword   volatile_save.x12x13
            qword   volatile_save.x14x15
            qword   volatile_save.v0
            qword   volatile_save.v1
            qword   volatile_save.v2
            qword   volatile_save.v3
            qword   volatile_save.v4
            qword   volatile_save.v5
            qword   volatile_save.v6
            qword   volatile_save.v7
            qword   volatile_save.v8
            qword   volatile_save.v9
            qword   volatile_save.v10
            qword   volatile_save.v11
            qword   volatile_save.v12
            qword   volatile_save.v13
            qword   volatile_save.v14
            qword   volatile_save.v15
            ends    volatile_save

#endif //aoaa_inc
        
