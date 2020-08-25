# generates an space inside the heap
#Input:
# a0 = number of elements inside the array
# a1 = dimensions of each element
# Output:
# v0 = Base address of the new array
#generate_array, generates an array of dimension a0*a1 bytes
	.globl generate_array
generate_array:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $fp, 4($sp)

	#malloc(a0*a1)	
	mul $a0, $a0, $a1
	li $v0, 9
	syscall
	
	
	lw $ra, 0 ($sp)
	lw $fp, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
	
