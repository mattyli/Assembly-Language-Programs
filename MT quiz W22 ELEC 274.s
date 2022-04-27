# Pseudocode goes here
#ArrayCreation(final, in1, in2, len, m, b):
#    for i=0 to len-1:
#        if in[2] > m:
#        final[i] = in1[i]

# ----------------------------------------------------------------------
# Program starts here

    .text
    .global     _start
    .org        0x0000

_start:
    movi        sp, 0x7FFFC      # intializng the stack pointer
    movia       r2, SRC_ARR1     # list pointer SRC_ARR1, ADDRESS OF
    movia       r3, SRC_ARR2     # list pointer SRC_ARR2, ADDRESS OF
    movia       r11, DEST_ARR    # pointer to the destination array ADDRESS OF

    ldw         r4, N(r0)               # loop counter
    ldw         r5, MEM_PARAM(r0)       # M parameter
    ldw         r6, SECOND_PARAM(r0)    # the constant 6

    call        ArrayCreation
    stw         r2, NEG_COUNT(r0)

_end:
    break       # stop the program from running

# ----------------------------------------------------------------------
# Subroutine

ArrrayCreation:
    subi        sp, sp, 28
    stw         r4, 24(sp)       # local counter
    stw         r5, 20(sp)       # first parameter (m)
    stw         r6, 16(sp)       # second parameter (b)
    stw         r7, 12(sp)       # first element of SRC_ARR1
    stw         r8, 8(sp)        # first element of SRC_ARR2
    stw         r9, 4(sp)        # will store the negative count
    stw         r10, 0(sp)      

ac_loop:
ac_if:

    ldw         r12, 0(r11)         # first element of the empty array
    ldw         r7, 0(r2)           # x[i]
    ldw         r8, 0(r3)           # same as y[i]
    ble         r8, r5, ac_else     # y[i] <= m

ac_then:
    sub        r10, r7, r6
    mul        r12, r10, r5
    blt        r12, r0, ac_LT_Z
    bge        r12, r0, ac_endif

ac_else:
    add        r12, r8, r5
    blt        r12, r0, ac_LT_Z
    bge        r12, r0, ac_endif

ac_LT_Z:
    addi        r9, r9, 1           # incrementing the negative element counter

ac_endif:
    blt         r12, r0, ac_LT_Z
    addi        r2, r2, 4           # incrementing array ptrs
    addi        r3, r3, 4
    addi        r11, r11, 4

    subi         r4, r4, 1           # decrementing loop counter   

    bgt         r4, r0, ac_loop

    mov         r2, r9              # return neg_count

    ldw         r4, 24(sp)       # local counter
    ldw         r5, 20(sp)       # first parameter (m)
    ldw         r6, 16(sp)       # second parameter (b)
    ldw         r7, 12(sp)       # first element of SRC_ARR1
    ldw         r8, 8(sp)        # first element of SRC_ARR2
    ldw         r9, 4(sp)        # will store the negative count
    ldw         r10, 0(sp) 
    subi        sp, sp, 28
    ret                         # return to calling program

# ----------------------------------------------------------------------
# Data directives

    .org        0x1000

N:          .word   5
MEM_PARAM:  .word   2
DEST_ARR:   .skip   20          # five words 
SRC_ARR1:   .word   9,4,2,4,3
SRC_ARR2:   .word   -3,7,1,-1,6
NEG_COUNT:  .skip   4
SECOND_PARAM:   .word   6       # the constant second parameter

# ----------------------------------------------------------------------
