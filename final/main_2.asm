	.data
main_msg:	.asciiz "Welcome to Caesar's cipher!\nCaesar's cipher is an ecnryption system that relies on a key value(n) to shift a message by n positions.\nThis is a slightly modified version were instead of a key value we use a key character, this key  character will have a specific value based on its position (A or a = 0,B or b = 1, ..., Z or z = 25).\nOnce both the text message and the key value are available we rotate the message by the applying the value of the key character, thus obtaining the encrypted or decrypted text!\n"
txt_phrs_len:	.asciiz "How long do you think will your text be?\nEnter a value:"
txt_en_or_dec:	.asciiz "Please enter (1):for the encryption function or (2):for the decryption function or  (0):to end the program.\n"
txt_to_ciph:	.asciiz "Enter a message you want to encrypt:"
txt_key:	.asciiz "Enter a key:"
txt_ciphered:	.asciiz "Encription:"
txt_deciph:	.asciiz "Decription:"

	.text
#	.globl main
main:
	#main message
	la $a0, main_msg
	li $v0, 4
	syscall
	
	#txt len from user?
	la $a0, txt_phrs_len
	syscall
	
	la $a0, txt_en_or_dec
	syscall
	
	#phrase length
	li $v0, 5
	syscall
	move $s0, $v0
	
	li $v0, 4
	la $a0, txt_to_ciph
	syscall
	
	move $a1, $s0
	jal string_generator#s1 = v0 = base address of the new string
	move $s1, $v0
	
	
	li $v0, 4
	la $a0, txt_key
	syscall
	
	li $a1, 3#3 bytes for key char + \0 + \n
	jal string_generator#s2 = v0 = base address of key value
	move $s2, $v0
	
	#extract key_value from key_character
	
	#caesar_cipher(a0 = &string_to_de/encrypt,a1 = &key_char) --> &de/encrypted_string,len(*(&de/encrypted_string)) ,int(key_char)
	move $a0, $s1
	move $a1, $s2
	jal cipher
	move $s3, $v0
	#move $s4, $v1
	
	la $a0, txt_ciphered
	li $v0, 4
	syscall
	move $a0, $s3
	syscall
	#move $a0, $v0
	#li $v0, 4
	#syscall
		
	li $v0, 10
	syscall	
#######################
#string_generator is used to store in the heap a user input string without using memory in .data 
#Input:
#a1 = maximum size of the string
#Output:
#v0 = base address of the user input string
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
	
	
###############################################
#cipher takes a string and modifies it using a key letter
#Input:
#a0 = base address of text to encrypt/decrypt
#a1 = key_letter
#Output:
#v0 = base address of ciphered/deciphered text
#v1 = key_value_of_letter_used	
	.text
	#.globl cipher
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
	
	#extracts key_value from key_letter(a1) #####SPOSTALO FUORI LA FUNZIONE
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
	addi $s5, $s5, 10
	#generates len(text to decrypt)+10buffer bytes space in heap for the de/encrypted text
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
	
	
	move $v0, $s3#&base addr. of encrypted/decrypted string
	move $v1, $s2#key_value######################################################<----- FIND A WAY TO RETURN three arguments
	#move $v1, $s5#len of main string
	
	
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
	
#############################################################################
#char_val
#INPUT:
#a1 = letter(byte)
#OUTPUT:
# v1 = new_value; v1 = -1 if not a letter
# v0 = 0:Lowercase; v0 = 1: Uppercase; v0 = -1: not a letter
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

#########################################
#is_upper
# takes a0 byte(letter) and sets v0 = 1 if the byte maps to an upper_case letter on the ASCII TABLE or v0 = 0 if the byte maps to a lower_case letter on the ASCII TABLE v0 = -999
#Input:
#	a0 : letter
#Output:
#	v0 = 0 (lowercase); v0 = 1(uppercase); v0=-1 (not_a_char)
	.text

is_upper:
	#saving registers
	add $sp, $sp, -8
	sw $ra 0($sp)
	sw $fp 4($sp)
	addi $fp, $sp, 4
	
	li $v0, -1
	

	#checks if upper
	# if (a0 >= 65 && lett <= 90)
	#checks if a0 >= 65 if not then its not a letter
	li $t0, 65
	bne $a0, $t0, mightB_grtr# a0 == 65? 
	j is_up
	mightB_grtr:
	slt $t1, $t0, $a0##  a0 > 65?
	bne $t1, 1, end# if v0 != 1 then  not_letter
	

	#checks if lett <= 90 if not; then-->lower_case or not_letter
	li $t0, 90
	bne $a0, $t0, mightB_lesser
	j is_up
	mightB_lesser:
	slt $t1, $a0, $t0 #if lett<90	 -- v0 = 1
	beq $t1, 1, is_up
	


	#checks if lower
	# if (a0 >= 97 && lett <= 122)
	#checks if a0 >= 97 if not then its not a letter
	li $t0, 97
	bne $a0, $t0, mightB_grtr2# a0 == 97? 
	j is_low
	mightB_grtr2:
	slt $t1, $t0, $a0##  a0 > 97?
	bne $t1, 1, end# if v0 != 1 then  not_letter
	

	#checks if lett <= 122 if not; then-->lower_case or not_letter
	li $t0, 122
	bne $a0, $t0, mightB_lesser2
	j is_low
	mightB_lesser2:
	slt $t1, $a0, $t0 #if lett<90 then is_low
	beq $t1, 1, is_low


	end:
	#restoring registers
	lw $ra  0($sp)
	lw $fp 4($sp)
	addi $sp, $sp, 8	
		
	jr $ra
	

	is_up:
	li $v0, 1
	j end

	is_low:
	li $v0, 0
	j end


