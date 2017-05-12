# Lucas Lopilato
# CS154 Lab3
# Library consisting of methods for 
# Floating Point Addition, 
# Multiplication, and Subtraction

.data # TODO
.ascii "12.5"
TwelvePointFive: .word 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.ascii "3.5"
ThreePointFive:  .word 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.ascii "AddResult"
AdditionResult:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

.ascii "2.5"
TwoPointFive:    .word 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

.ascii "4.75"
FourPointSevenFive: .word 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

.ascii "SubResult"
SubtractionResult:  .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

.text
.globl main

# Test each Function
main: 
    addi $sp, $sp, -12

    # Load 12.5
    la $a0, TwelvePointFive
    jal DataToParts
    sw $s0, 0($sp)
    sw $v0, 4($sp)
    sw $v1, 8($sp)

    # Load 3.5
    la $a0, ThreePointFive
    jal DataToParts
    add $s1, $v0, $zero
    add $s2, $v1, $zero  

    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp)

    # 12.5 + 3.5
    # jal FADD 

    # Save Results To Array
    la $a0, AdditionResult
    add $a1, $s0, $zero
    add $a2, $s1, $zero
    add $a3, $s2, $zero
    jal PartsToData

    # Load 2.5
    la $a0, TwoPointFive
    jal DataToParts
    sw $s0, 0($sp)
    sw $v0, 4($sp)
    sw $v1, 8($sp)

    # Load 4.75
    la $a0, FourPointSevenFive
    jal DataToParts
    add $s1, $v0, $zero
    add $s2, $v1, $zero

    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp)

    # 4.75 - 2.5
    jal FSUB

    # Save Results To Array
    la $a0, SubtractionResult
    add $a1, $s0, $zero
    add $a2, $s1, $zero
    add $a3, $s2, $zero
    jal PartsToData


    # Reset 
    addi $sp, $sp, 12

    li $v0, 10  # Exit
    syscall



# Subtraction Function
# A is the item being subtracted 
# $s0 contains A sign
# $s1 contains A exponent
# $s2 contains A fraction
# $a0 contains B sign
# $a1 contains B exponent
# $a2 contains B fraction
# result in s registers
FSUB:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    beq $s0, $zero, FSUBAPOS
    add $s0, $zero, $zero
    j FSUBCALL

FSUBAPOS:
    addi $s0, $zero, 1

FSUBCALL:
    jal FADD

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra    



# on input 
# $v0 has sign
# $v1 has fraction
# Output in same spot
ComplimentIfNecessary:
    addi $t0, $zero, 1
    bne $v0, $t0, ComplimentIfNecessaryEnd

    # set sign = 0
    addi $v0, $zero, 0

    # Get negation
    addi $t0, $zero, -1
    mult $v1, $t0
    mflo $v1


ComplimentIfNecessaryEnd:
    jr $ra
    


# Undo 2's Compliment 
# $v0 has sign
# $v1 has fraction 
UndoComplimentIfNecessary:
    bge $v1, $zero, UCINExit

    # Check if sign is positive
    bne $v0, $zero, UCINSignNeg
    # Check if float is negative
    slt $t0, $v1, $zero
    bne $t0, $zero, UCINSignPosFloatNeg

    # Nothing to do
    j UCINExit

UCINSignPosFloatNeg:
    addi $v0, $zero, 1
    addi $t0, $zero, -1
    mult $v1, $t0
    mflo $v1

    j UCINExit

UCINSignNeg:
    # Sign Negative Float positive
    beq $t0, $zero, UCINExit

    # Otherwise Both Sign and Float Negative
    addi $v0, $zero, 0
    addi $t0, $zero, -1
    mult $v1, $t0
    mflo $v1

    # set sign

UCINExit:
    jr $ra   
    
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
    # Shift Lesser Function Until Exponents Equal
    # $t0 tracks the number of shifts needed
    #sub $t0, $a1, $s1
    #sllv $s2, $s2, $t0
    # Check for 2's Compliment
    add $v0, $s0, $zero
    add $v1, $s2, $zero
    jal ComplimentIfNecessary
    add $s0, $v0, $zero
    add $s2, $v1, $zero

    add $v0, $a0, $zero
    add $v1, $a2, $zero
    jal ComplimentIfNecessary
    add $a0, $v0, $zero
    add $a2, $v1, $zero

    sub $t0, $a1, $s1
    srlv $s2, $s2, $t0

    # Update Exponent
    move $s1, $a1

    # Perform Addition
    add $s2, $s2, $a2

    add $v0, $s0, $zero
    add $v1, $s2, $zero
    jal UndoComplimentIfNecessary
    add $s0, $v0, $zero
    add $s2, $v1, $zero

    # Normalize Results
    jal Normalize

#return
FADDExit:
lw $ra, 0($sp) 
addi $sp, $sp, 4
jr $ra



# Normalizes 3 part representation to be in proper form
# Also handles underflow and overflow
# $s0 contains sign bit of number
# $s1 contains exponent
# $s2 contains fraction
# Result returned in same registers
Normalize:

# $t0 holds wanted index
addi $t0, $zero, 1
sll $t0, $t0, 22

NormalizeLessThanLoop:
    # Check if the fraction needs left shift
    bge $s2, $t0, NormalizeLessThanLoopEnd
    sll $s2, $s2, 1
    addi $s1, $s1, -1

    # Check if underflow occurred
    blt $s1, $zero, NormalizeUnderflow
    j NormalizeLessThanLoop

NormalizeLessThanLoopEnd:
    # Check if fraction needs right shift
    sll $t1, $t0, 1
    blt $s2, $t1, NormalizeGreaterThanLoopEnd

    # Shift Right
    srl $s2, $s2, 1
    addi $s1, $s1, 1

    # Check for overflow
    addi $t1, $zero, 127
    bgt $s1, $t1, NormalizeOverflow

    j NormalizeLessThanLoopEnd

NormalizeGreaterThanLoopEnd:
    jr $ra

NormalizeUnderflow:
    jr $ra

NormalizeOverflow:
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

# Add the implicit 1 into the representation
addi $t0, $zero, 1
sll $t0, $t0, 23
or $v1, $v1, $t0 

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
