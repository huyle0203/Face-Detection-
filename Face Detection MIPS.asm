#=================================================================
# Copyright 2023 Georgia Tech.  All rights reserved.
# The materials provided by the instructor in this course are for
# the use of the students currently enrolled in the course.
# Copyrighted course materials may not be further disseminated.
# This file must not be made publicly available anywhere.
# =================================================================
# P2-2
# Student Name: Huy Le
# Date:Oct 20th 2023
#
# Find George Variably Scaled
#
# This routine finds an exact match of George's face which may be
# scaled in a crowd of faces.
#
#===========================================================================
# CHANGE LOG: brief description of changes made from P1-2-shell.asm
# to this version of code.
# Date  Modification
# 10/2 Attempted to translate C to MIPS
# 10/3 Fixed the Loop that searches for red as the logic is different in MIPS
# 10/4 Fixed infinite loop errors
# 10/12 Fix iteration to check for Green clothes to reduce DI (i+=5) & change calculation of index
# 10/15 Attempted to fix mem[] read before defined errors 
# 10/15 Reduce Static instruction by simplifying lines 
# 10/19 Fix iteration to check for Red brim hat to reduce DI (i+=11) & change calculation of index
# 10/19 Change approach to count scale by going up the hat instead of counting total pixels of brim hat
# 10/19 Calculate offset of TopLeft with correct math
# 10/19 Reduce more DI by changing from 4096 to 3648 and end at 256 instead of 0 (where first red brim hat pixel would be)
# 10/19 Reduce registers by recycling old ones 
# 10/20 Fixed mem[] read before defined errors by insert slt to check out of range for white check
#===========================================================================
#The baseline numbers for this project are static code size: 90 instructions, dynamic instruction length: 2400 instructions (avg.), storage required: 17 words 
.data
Array:  .alloc	1024

.text

FindGeorge:	addi	$1, $0, Array		# point to array base
		swi	592			# generate crowd

	        # your code goes here
	  addi $28, $0, 3648   #4096 - 64*7 = 3648 (we dont have to start from 4096th pixel so this reduce DI a lot)

Loop: addi $28, $28, -11   #going from 3648 -> 256 (we dont need to iterate anymore once we reach end of brim hat pixel of the final face)
      slti $27, $28, 256   #is i < 256? -> $27 = 1 or 0
	  addi $3, $0, 2       #$3 holds red color to check hat
	  bne  $27, $0, End    #if i = 256 -> End loop else continue

	  lb   $27, Array($28) #load current i into Crowd[i] to know where it is on the map
	  bne  $27, $3, Loop   #if Crowd[i] != 2 -> keep looping till red is found
	  add  $26, $0, $28    #store index at that position 
	  add  $24, $0, $0      #scale = 0

Across: lb $25, Array($26)    #load index into current Crowd[i]
      bne  $25, $3, FinAcross #end loop if no more red pixel is found 
	  addi $26, $26, 1        #iterate through every red pixel till reach end of red brim hat
	  j Across                #loop back to keep checking Across 

FinAcross: addi $26, $26, -1  #move back to red pixel
		   add  $27, $0, $26  #store location of last red pixel
 
Up:   lb   $25, Array($26)  #load index into current Crowd[i]
      bne  $25, $3, White   #end loop if no more red pixel is found -> now we can start check each detail
	  addi $24, $24, 1        #scale++
	  addi $26, $26, -64    #iterate upwards of red pixel (to find scale)
	  j Up                  #loop back to keep checking Up

White: addi $3, $0, 1       #$3 holds white color to check upper dot
       addi $26, $0, -197   #offset by -64*3-5 = -197
	   mult $26, $24         #-197 * scale
	   mflo $26             #store value into $26
	   add  $26, $27, $26   #i + -197*scale 

	   slt  $25, $26, $0    #is i+-197*scale < 0? (check out of range)
	   bne  $25, $0, Loop   #as long as it's still less than 0 -> Loop

	   lb   $2, Array($26)  #load i + -197*scale into $2
	   bne  $2, $3, Loop    #if Crowd[i + -197*scale] =! white -> Back to Loop else continue 

Eye:  addi $3, $0, 3        #$3 holds blue color to check right eye
       addi $26, $0, 60     #offset by 64-4 = 60
	   mult $26, $24         #60 * scale
	   mflo $26             #store value into $26
	   add  $26, $27, $26   #i + 60*scale 

	   lb   $2, Array($26)  #load i + 60*scale into $2
	   bne  $2, $3, Loop    #if Crowd[i + 60*scale] =! blue -> Back to Loop else continue

       addi $3, $0, 5       #$3 holds yellow color to check between eye
	   sub $26, $26, $24     #Current i of blue eye location - scale 

	   lb   $2, Array($26)  #load i + 60*scale - scale into $2
	   bne  $2, $3, Loop    #if Crowd[i + 60*scale - scale] =! yellow -> Back to Loop else continue

Smile: addi $3, $0, 8       #$3 holds black color to check smile
       addi $26, $0, 189    #offset by 64*3-3 = 189
	   mult $26, $24         #189 * scale
	   mflo $26             #store value into $26
	   add  $26, $27, $26   #i + 189*scale 

	   lb   $2, Array($26)  #load i + 189*scale into $2
	   bne  $2, $3, Loop    #if Crowd[i + 189*scale] =! black -> Back to Loop else continue

Shirt: addi $3, $0, 7       #$3 holds green color to check shirt
       addi $26, $0, 445    #offset by 64*7-3 = 445
	   mult $26, $24         #445 * scale
	   mflo $26             #store value into $26
	   add  $26, $27, $26   #i + 445*scale 

	   lb   $2, Array($26)  #load i + 445*scale into $2
	   bne  $2, $3, Loop    #if Crowd[i + 445*scale] =! green -> Back to Loop else continue



Answer: addi $26, $0, -266  #offset by -64*4-10 = -266
        mult $26, $24        #-266 * scale         
		mflo $26            #store value into $26
		add  $26, $26, $27  #i + -266 * scale

		addi $3, $0, -65    #$3 = -65
		mult $24, $3         #-65 * scale
		mflo $3             #store value into $3
		addi $3, $3, 65     #-65 * scale + 65
		add  $26, $26, $3   #i + -266 * scale + (-65*scale + 65)
		sll  $26, $26, 16   #move TopLeft in upper 16 bits

		addi $3, $0, 449    #offset by 64*7+1 = 449
		mult $3, $24         #449 * scale
		mflo $3             #store value into $3
		add  $3, $3, $27    #i + 449*scale
		or   $2, $26, $3    #merge BottomRight as lower 16 bits

End:	swi	593			# submit answer and check
		jr	$31			# return to caller


