	.data
txt_phrs_len:	.asciiz "How long do you think will your text be?\n"
txt_to_ciph:	.asciiz "Enter a message you want to encrypt:"
txt_key:	.asciiz "Enter a key:"
txt_ciphered:	.asciiz "Encription:"
txt_deciph:	.asciiz "Decription:"

	.text
	.globl main
main:

	#txt len from user?
	la $a0, txt_phrs_len
	li $v0, 4
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
	
	
	
