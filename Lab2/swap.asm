# Lucas Lopilato
# CS154 Lab 2
# Question 1

    # Defines global function main
    .globl main 
    .data

    # Define the array of ints
    array:  .word 13, 17, 19, 23, 29

    .text       

main:
swap: 

# Load Array Address into $a0
      la $a0, array

# Load 3 into $a1
      li $a1, 3

# Stores the byte offset of an int array index k
# $t1 now holds 4 * k
      sll $t1, $a1, 2

# Adds the byte offset to v and stores the result in $t1
      add $t1, $a0, $t1

# Loads the value of array[k] into $t0
      lw $t0, 0($t1)

# Loads the value of array[k+1] into $t2
      lw $t2, 4($t1)

# Stores the value of array[k+1] into array[k]
      sw $t2, 0($t1)

# Stores the old value of array[k] into array[k+1]
      sw $t0, 4($t1)


    li $v0, 10 # Sets $v0 to "10" to select exit syscall
    syscall # Exit

