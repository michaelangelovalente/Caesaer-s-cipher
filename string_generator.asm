#string_generator is used to store in the heap a user input string without using memory in .data 
#Input:
#a1 = maximum size of the string
#Output:
#v0 = base address of the user input string
	.globl string_generator
string_generator:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $fp, 4($sp)
	sw $s0, 8($sp)
	
	move $s0, $a1
	
	li $v0, 9
	move $a0, $a1
	syscall
	
	
	move $a0, $v0
	move $a1, $s0
	li $v0, 8
	syscall
	
	move $v0, $a0
	
	lw $ra, 0($sp)
	lw $fp, 4($sp)
	lw $s0, 8($sp)	
	addi $sp, $sp, 12
	
	jr $ra
	
