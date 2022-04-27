    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF


    .text
    .global _start
    .org    0x0000
_start:

	movia sp,0x007FFFFC

	movia r2, ELEC274
	call PrintString

	movia r2, NAMES
	call PrintString


	movia r7, LIST
	movia r3, N
	call ShowMemContents
_end:
	break
	br _end


ShowMemContents:

	subi sp,sp, 28
	stw ra,24(sp)
	stw r7,20(sp) #list ptr
	stw r3,16(sp) # num ptr
	stw r4,12(sp) # c_count
	stw r5,8(sp) # index ptr
	stw	r6,4(sp) # hold the constant
	stw r8,0(sp) # contents
	
	ldw r3, 0(r3)
	movi r4, 0  		# set c_count = 0
	movi r6, 0x1000		# the checking variable
	
smc_loop:
smc_if:

	ldw r5,0(r7)				# loading the first element of LIST into r5
	bge	r5, r6, smc_else		# if the element is greater than r6, branch to the end
smc_then:
	movia r2, CODE
	call PrintString
	addi r4, r4, 1		# incrementing c_count
	br		smc_endif
	
smc_else:
	movia r2, DATA
	call PrintString
smc_endif:
	
	movia r2, LOCATION
	call	PrintString
	
	mov r2, r5
	call PrintHexWord
	
	movia r2, CONTAINS
	call PrintString
	
	ldw r8,0(r5)
	mov r2, r8
	call PrintHexWord
	
	movi r2, '\n'
	call PrintChar
	
	

smc_endfor:
	subi	r3, r3, 1
	addi	r7, r7, 4
	bgt		r3, r0, smc_loop
	
	# out of the for loop
	
	# printhexword
	mov	r2, r4				
	call PrintHexWord
	# printstring
	
	movia r2, WCL			# moving the address of WCL
	call PrintString
	
	

	
	
	ldw ra,24(sp)
	ldw r7,20(sp) #list ptr
	ldw r3,16(sp) # num ptr
	ldw r4,12(sp) # c_count
	ldw r5,8(sp) # index ptr
	ldw	r6,4(sp) # hold the constant
	ldw r8,0(sp) # contents
	addi sp,sp, 28
	
	ret
	
	
	
	
	

# ------------------------------------------------------------

PrintString:
    subi    sp, sp, 12                  # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    mov     r4, r2                      # move string pointer to r4

ps_loop:
    ldb		r2, 0(r4)                   # read byte into r2 from the pointer r4
    beq     r2, r0, ps_end_loop         # if ch is 0, loop past end
    call    PrintChar                   # otherwise, call printChar subroutine with r2 as input
    addi    r4, r4, 1                   # increment string pointer (1 byte at a time!)
    beq     r0, r0, ps_loop             # unconditional loop (while loop)

ps_end_loop:
    ldw     ra, 8(sp)                   # restore reg values
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret

# ------------------------------------------------------------
PrintChar:
    subi    sp, sp, 12                   # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    movia   r3, JTAG_UART_BASE          # move pointer to the JTAG UART location in memory using movia (large address)

# start polling loop
pc_loop:
    ldwio   r4, STATUS_OFFSET(r3)       # load word from control reg of JTAG UART (+4 from base addr)
    andhi   r4, r4, WSPACE_MASK         # and top 16 bits of the control reg w/ FFFF 
    beq     r4, r0, pc_loop             # if top 16 bits is 0, no space for char to be read, repeat polling loop
    
    stwio   r2, DATA_OFFSET(r3)         # store the character in the "data" area of the JTAG UART to be read (+0 from base addr)

    ldw     ra, 8(sp)                   # restore reg values
    ldw     r3, 4(sp)                   
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret
    
#----------------------------------------------------------------------------------------------------------------------

PrintHexWord: #32 bits
	subi sp, sp, 12
	stw ra, 8(sp)
	stw r2, 4(sp)
	stw r3, 0(sp)

	mov r3, r2   #make a copy of r2
	srli r2, r3, 24 #shift right logical immediate by 24 bits. Put into r2, r3 is preserved
	call PrintHexByte #byte 1
	srli r2, r3, 16
	andi r2, r2, 0xFF #to get rid of byte 1
	call PrintHexByte #byte 2
	srli r2, r3, 8
	andi r2, r2, 0xFF
	call PrintHexByte #byte 3
	andi r2, r3, 0xFF
	call PrintHexByte #byte 4

	ldw ra, 8(sp)
	ldw r2, 4(sp)
	ldw r3, 0(sp)
	addi sp, sp, 12

	ret
#-----------------------------------------------------------------------------------------------------------------------

#PrintHexByte - call PrintHexDigit twice to get first four bits then next four bits - number between 0 and 255
#Shift right by 4 then do printhexdigit for high. mask with 0xF for low thne do printhexdigit.
PrintHexByte:
	subi sp, sp, 12 #IF A REGISTER IS MODIFIED SAVE ITS VALUE
	stw ra, 8(sp)
	stw r2, 4(sp) #r2 is being used to save and restore and won't be returned so we save
	stw r3, 0(sp) #orginal value of n

	mov r3, r2 #copy r2 to r3

	srli r2, r2, 4 #shift right by 4 bits
	call PrintHexDigit

	andi r2, r3, 0xF #and with 0xF
	call PrintHexDigit

	ldw ra, 8(sp)
	ldw r2, 4(sp) #r2 is being used to save and restore and won't be returned so we save
	ldw r3, 0(sp) #orginal value of n
	addi sp, sp, 12

	ret

#----------------------------------------------------------------------------------------------------------------------

#PrintHexDigit - print an ascii character 0-9 or A-F for an input value n and priunt it to screen
PrintHexDigit:
	subi sp, sp, 12
	stw ra, 8(sp) #return address
	stw r2, 4(sp) #original n
	stw r3, 0(sp) #constant to compare - 9

	movi r3, 9 #to compare
phd_if:
	bgt r2, r3, phd_else #will skip number
phd_then:
	addi r2, r2, '0' #add constant '0' to r2
	br phd_end_if
phd_else:
	subi r2, r2, 10 #subtract 10 from n
	addi r2, r2, 'A' #add character A. Will make n a value between A and F
phd_end_if:
	call PrintChar #argument is ready in r2

	ldw ra, 8(sp)
	ldw r2, 4(sp)
	ldw r3, 0(sp)
	addi sp, sp, 12

	ret

#-------------------------------------------------------------------------------------------------------------------


N: .word	5
LIST: .word 0x0, 0x4, 0x8, 0x1000, 0x1004
NAMES: .asciz "Brandon, Carter, Matthew\n"
LOCATION: .asciz "location "
CONTAINS: .asciz " contains "
WCL: .asciz " were code locations\n"
ELEC274: .asciz "ELEC274 L4 by\n"
CODE: .asciz "[code] "
DATA: .asciz "[data] "
