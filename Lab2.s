.text
.global _start
.org 0x0000

# ---------- MAIN ! CALL SUBS HERE ! ---------------

_start:
main:
    movi sp, 0x7ffC
    movi r2, list1          # register 2 points to first element in list 1
    movi r3, list2          # register 3 points to first element in list 2
    ldw r4, n(r0)              # the length of the lists
    movi r5, param1
    movi r6, param2
    
    movi r12, pos_count(r0)
    
    call GenerateList
    call CountPosElements

    break

# 7, 8, 9, 10, 11

# SUB DECLARATION

# -----------------------------------------
#   r2 list pointer for list1, r3 list pointer for list2

GenerateList:
    # pushing the stack
    subi sp, sp, 20
    stw ra, 16(sp)
    stw r7, 12(sp)      # holds the length
    stw r8, 8(sp)       # sub pointer1
    stw r9, 4(sp)       # sub pointer2 
    stw r4, 0(sp)

    mov r8, r2          # the local pointers
    mov r9, r3

gl_loop:
gl_if:
    ldw r8, 0(r8) 
    ldw r9, 0(r8)
    
    call CalcValue
    
gl_endif:
    addi r8, r8, 4              # increment the pointers within the list
    addi r9, r9, 4
    subi r4, r4, 1              # decrement the counter
    bgt  r4, r0, gl_loop        # check if there are still elements 

    # popping the stack
    ldw ra, 16(sp)
    ldw r7, 12(sp)      # holds the length
    ldw r8, 8(sp)       # sub pointer
    ldw r9, 4(sp)
    ldw r4, 0(sp)

    addi sp, sp, 20
    ret

# ----------------------------------------------------------------------

CalcValue:
    mul r8, r8, r5
    add r8, r8, r6
    mov r9, r8
    
    ret

# ----------------------------------------------------------------------

CountPosElements:
    # pushing the stack
    subi sp, sp, 20
    stw ra, 16(sp)
    stw r7, 12(sp)      # holds the length
    stw r8, 8(sp)       # sub pointer
    stw r4, 4(sp)
    stw r11, 0(sp)      # counting variable

    mov r11, pos_count(r0)
    mov r8, r3

cpe_loop:
cpe_if:
    ldw r8, 0(r4)
    bgt r8, r0, cpe_then

cpe_then:
    add r11, r11, r8

cpe_endif:
    addi r8, r8, 4
    bgt r4, r0, cpe_loop

    addi sp, sp, 20
    ldw ra, 16(sp)
    ldw r7, 12(sp)      # holds the length
    ldw r8, 8(sp)       # sub pointer
    ldw r4, 4(sp)
    ldw r11, 0(sp)      # counting variable


.org 0x5000

# declaration
list1:      .word   1, 2, 3, 4, 5
n:          .word   5                   # n is the integer value of the list length
param1:     .word   2
param2:     .word   -7

list2:      .word   0, 0, 0, 0, 0
pos_count:  .skip   4

.end

