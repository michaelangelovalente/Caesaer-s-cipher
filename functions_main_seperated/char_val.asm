#char_val
#INPUT:
#a1 = letter(byte)
#OUTPUT:
# v1 = new_value; v1 = -1 if not a letter
# v0 = 0:Lowercase; v0 = 1: Uppercase; v0 = -1: not a letter
	.globl char_val
	
char_val:
	addi $sp, $sp, -12
	sw $ra 0($sp)
	sw $s1 4($sp)
	sw $fp 8($sp)
	addi $fp, $sp, 8
	
	
	move $s1, $a1
		
	move $a0 $s1 #a1 = s1 = letter[0]
	

	#generating char_value
	jal is_upper# is_upper returns v0 = 0: Lowercase; v0 = 1: UpperCase; v0 = -1 if not a letter
	#if uppercase 65 - char_value
	beq $v0, -1, invalid_char #if v0 == -1 --> v1 == v0 =-1
	
	#UPPERCASE
	bne $v0, 1, is_lower# v0 != 1 -->  v0 == 0 --> s1 is !UPPERCASE
	addi $s1, $s1, -65 #  s1 - 65(A)  = char_position_value
	move $v1, $s1
	j char_found
	
	#LOWERCASE v1 != 1 && v1 != -1 --> v0 == 0 --> s1 is lowercase
	is_lower:
	addi $s1, $s1, -97 #  s1 - (a)97  = char_position_value
	move $v1, $s1
	j char_found
	
	invalid_char:
	move $v1, $v0
	
	char_found:
	#restores modified registers
	lw $ra 0($sp)
	lw $s1 4($sp)
	lw $fp 8($sp)
	addi $sp, $sp, 12
	
	
	jr $ra
