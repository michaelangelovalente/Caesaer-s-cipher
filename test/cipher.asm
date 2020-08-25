#cipher takes a string and modifies it using a key letter
#Input:
#a0 = base address of text to encrypt/decrypt
#a1 = key_letter
#Output:
#v0 = base address of ciphered/deciphered text
#v1 = key_value_of_letter_used

# s0, s1, s2, s3, s4, s5, s6
	
	.text
	.globl cipher
cipher:

	addi $sp, $sp, -36
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $fp 32($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	#extracts key_value from key_letter(a1)
	lb $t1 0($a1)
	move $a1, $t1
	jal char_val
	
	move $s2, $v1## s2 = key value
	
	
	li $t0, 0
	#counts the # of letters in main text
	cntr:
	add $t1, $t0, $s0#&a0
	lb  $t2 0($t1)
	addi $t0, $t0, 1 
	bne $t2, 10, cntr #keeps counting until \n
	move $s5, $t0# s5 = number of bytes used by main text
	#generates len(text to decrypt)+10 byte space in heap for the de/encrypted text
	li $v0, 9
	move $a0, $t0
	syscall
	move $s3, $v0# s3= &newAddr(encrypted/decrypted text)
	
	
	
	################################################
	#encryption/decryption part
	#formulas: 
	# cipher(x) = (x + key)%26 or decipher(x) = (x - key)%26
	li $t7, 0# i == 0 ; i< lent(text) == t0; i++
	li $t3, 26
	addi $s5, $s5, -1# we won't consider \0 when decrypting/encrypting this means len(main_text) --> len(main_text)-1  
	#############################################REMEMBER TO ADD \n on the main implementation
	encr_loop:
	add $t6, $s0, $t7
	lb $a1 0($t6)#a1 = text[i=0...i=(n-1)]
	jal char_val# extracts character's abs position. A/a = 0, B/b = 1 ... Z/z = 25 --> v1 = abs. position or  if special char {v1 = -1} and retruns v0 = 0:if char is lowercase or v0 = 1: if char is Uppercase
	#if v== -1 then skip and store the special character
	move $s4, $a1
	beq $v1, -1, final_value
	
	
	move $s6, $v0
	
	
	#s4 = decrypted/encrypted_text = (char_val(text[i]) + key_value)%26
	add $s4, $v1, $s2#char_val(text[i]) + key_value
	div $s4, $t3
	mfhi $s4
	
	
	
	#note : (in some cases) MIPS calculates a negative mod of a given number instead of the mod itself
	#e.g.: (-4)MOD(26) == -4, should be 22.
	#solution: -MOD + 26 == +MOD  (the example above would be -4 + 26 == 22)
	
	# s4>=0 ? then{not_negative}else{-MOD + 26 == +MOD}
	beq $s4, $zero, not_negative
	slt $t2 ,$zero, $s4 
	beq $t2, 1, not_negative
	add $s4, $s4, $t3

	not_negative:
	
	#repositioning abs value of char on the ascii_table 
	beq $s6, 0, l_case #if s6 ==0 -->lowercase --> s4 = s4 + 97 else  #s6 == 1 --> uppercase --> s4 = s4 + 65
	addi $s4, $s4, 65
	j final_value
	l_case:
	addi $s4, $s4, 97
	
	final_value:
	#stores encrypted char in new address
	add $t2, $s3, $t7
	sb $s4, 0($t2)
	addi $t7, $t7, 1
	bne $t7, $s5, encr_loop
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $fp 32($sp)
	add $sp, $sp, 36
	jr $ra