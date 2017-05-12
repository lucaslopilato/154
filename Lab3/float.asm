# Lucas Lopilato
# CS154 Lab3
# Library consisting of methods for 
# Floating Point Addition, 
# Multiplication, and Subtraction

.data # TODO
TwelvePointFive: .word 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text
.globl main

# Test each Function
main: 
    la $a0, TwelvePointFive
    jal DataToParts
    add $s1, $v0, $zero
    add $s2, $v1, $zero

    add $a1, $s0, $zero
    add $a2, $s1, $zero
    add $a3, $s2, $zero
    jal PartsToData

    li $v0, 10  # Exit
    syscall



# Add Function
# A is item with smallest exponent
# $s0 contains A sign
# $s1 contains A exponent
# $s2 contains A fraction
# $a0 contains B sign
# $a1 contains B exponent
# $a2 contains B fraction

# Result stored as
# $s0 contains sign
# $s1 contains exponent
# $s2 containts fraction
FADD:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Check if A's exponent is less than B
    bge $a1, $s1, FADDInOrder
    # Perform swap if needed

    # Store Temporaries
    add $t0, $s0, $zero 
    add $t1, $s1, $zero 
    add $t2, $s2, $zero

    add $s0, $a0, $zero 
    add $s1, $a1, $zero 
    add $s2, $a2, $zero 

    add $a0, $t0, $zero 
    add $a1, $t1, $zero 
    add $a2, $t2, $zero 

    # Recall the Function
    jal FADD
    j FADDExit

FADDInOrder:
    # Shift Lesser Function Untill Exponents Equal
    # $t0 tracks the number of shifts needed
    sub $t0, $a1, $s1
    sllv $s2, $s2, $t0

    # Update Exponent
    move $s1, $a1

    # Perform Addition
    

#return
FADDExit:
lw $ra, 0($sp) 
addi $sp, $sp, 4
jr $ra




# Converts the data array representation # into 3 parts. Use inverse operation to 
# return representation back
# $a0 is address of array
# $s0 returns sign bit (as a word)
# $v0 returns exponent (as a word)
# $v1 returns fraction (as a word)
DataToParts:

addi $sp, $sp, -4
sw $ra, 0($sp)

# Initialize $v0 and $v1
li $v0, 0
li $v1, 0
#li $t4, 0

# Extract Sign bit
lw $s0 0($a0)
andi $s0, $s0, 1

#Extract Fraction
addi $a1, $zero, 9
addi $a2, $zero, 32
jal ParseArray
add $v1, $v0, $zero

# Extract Exponent
addi $a1, $zero, 1 # Start Index
addi $a2, $zero, 9 # End Index
jal ParseArray

# Return
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra



# Parses and consolidates array into a 
# register
# $a0 is array
# $a1 is start index
# $a2 is finish index
# $v0 is return value
ParseArray:
    # Move over indices
    add $t0, $a1, $zero
    add $t1, $a2, $zero
    add $v0, $zero, $zero
    add $t3, $zero, $t1

ParseArrayLoop:
    # Check if index is >= bit 9 
    bge $t0, $t1, ParseArrayLoopEnd

    # Otherwise extract each bit and add 
    # To the word to construct the 
    # exponent
    sll $t2, $t0, 2
    add $t2, $t2, $a0
    lw $t2, 0($t2)

    # Shift to fit the bit into the
    # Exponent word
    sub $t3, $a2, $t0
    addi $t3, $t3, -1
    sllv $t2, $t2, $t3

    # Add to exponent
    or $v0, $v0, $t2 

    # Increment Loop Index
    addi $t0, $t0, 1

    j ParseArrayLoop

ParseArrayLoopEnd:
# Return
jr $ra



# Converts three part representation back
# to word array representation.
# Result saved into array at $a0
# $a0 = array address
# $a1 = sign bit (as a word)
# $a2 = exponent (as a word)
# $a3 = fraction (as a word)
PartsToData:

addi $sp, $sp, -8
sw $ra, 0($sp)
sw $a3, 4($sp)

# $t0 holds current number
andi $t0, $a1, 1

# Record Sign Bit
sw $t0, 0($a0)

# Record Exponent
move $a3, $a2
li $a1, 30
li $a2, 23
jal ParseWord

# Record Fraction TODO
lw $a3, 4($sp)
li $a1, 22
li $a2, 0
jal ParseWord

# return
lw $ra, 0($sp)
addi $sp, $sp, 8
jr $ra



# Parses word form from smallest index to largest
# Index and stores in the array
# $a0 = array base address
# $a1 = highest bit index
# $a2 = lowest bit index
# $a3 = word to parse
ParseWord:
    # $t0 holds current bit index
    add $t0, $a1, $zero

    # $t1 holds current array index
    addi $t1, $a0, 128
    sll $t3, $t0, 2
    sub $t1, $t1, $t3
    addi $t1, $t1, -4
    add $s6, $zero, $t1

ParseWordLoop:
    blt $t0, $a2 ParseWordLoopEnd

    # $t2 holds value of the bit at position
    # $t3 holds the number of shifts needed
    li $t2, 1
    sub $t3, $t0, $a2 
    sllv $t2, $t2, $t3

    # Record the value
    and $t2, $t2, $a3

    # Isolate the bit
    srlv $t2, $t2, $t3

    # Record the bit
    sll $t3, $t1, 2

    sw $t2, 0($t1)

    addi $t1, $t1, 4
    addi $t0, $t0, -1

    j ParseWordLoop

ParseWordLoopEnd:
    jr $ra
