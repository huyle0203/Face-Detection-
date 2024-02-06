//=================================================================
// Copyright 2023 Georgia Tech.  All rights reserved.
// The materials provided by the instructor in this course are for
// the use of the students currently enrolled in the course.
// Copyrighted course materials may not be further disseminated.
// This file must not be made publicly available anywhere.
//=================================================================

/*
Please fill in the following
 Student Name: Huy Le
 Date: 24/9/2023

ECE 2035 Project 1-2

This is the only file that should be modified for the C implementation
of Project 1.

Do not include any additional libraries.
-----------------------------------------------
     Find George Variably Scaled

This routine finds an exact match of George's face which may be
scaled in a crowd of faces.
*/

#include <stdio.h>
#include <stdlib.h>

#define DEBUG 0 // RESET THIS TO 0 BEFORE SUBMITTING YOUR CODE

int Load_Mem(char *, int *);

int main(int argc, char *argv[]) {
   int	             CrowdInts[1024];
   // This allows you to access the pixels (individual bytes)
   // as byte array accesses (e.g., Crowd[25] gives pixel 25):
   char *Crowd = (char *)CrowdInts;
   int	             NumInts, TopLeft, BottomRight;

   if (argc != 2) {
     printf("usage: ./P1-1 valuefile\n");
     exit(1);
   }
   NumInts = Load_Mem(argv[1], CrowdInts);
   if (NumInts != 1024) {
      printf("valuefiles must contain 1024 entries\n");
      exit(1);
      
   }
   if (DEBUG){
     printf("Crowd[0] is Pixel 0: 0x%02x\n", Crowd[0]);
     printf("Crowd[107] is Pixel 107: 0x%02x\n", Crowd[107]);

     printf("CrowdInts[211] packs 4 Pixels: 0x%08x\n", CrowdInts[211]);
     printf("Crowd[211*4] is Pixel 844: 0x%02x\n", Crowd[844]);
     printf("Crowd[211*4+1] is Pixel 845: 0x%02x\n", Crowd[845]);
     printf("Crowd[211*4+2] is Pixel 846: 0x%02x\n", Crowd[846]);
     printf("Crowd[211*4+3] is Pixel 847: 0x%02x\n", Crowd[847]);
   }

   /* your code goes here. */
   int redCt;        //counting red pxls to calculate scale
   int scale = 0;    //make scale variable and use it for math so no need another for loop for scale (inefficent)
   BottomRight = 0;  //initialize BottomRight so it wont give warning "uninitialized" warning
   int RightBottom = BottomRight; //a dummy node to store BottomRight because somehow it's the variable that gives me segmentation error
   for (int i = 0; i < 4096; i++) {  //traversing through each pixels on the whole 64 x 64 map
    if (Crowd[i] == 2) { redCt++; }  //once it approaches the top red pixel of the hat --> Count red pixel as long as the index is stil red
    else {
        scale = redCt/3;             //if it is not red pixel anymore -> take total count of red pixel divide for 3 (3 red pixel for scale 1, 6 for scale 2, 9 for scale 3, 12 for scale 4, 15 for scale 5)
        redCt = 0; //now my i is the grey box next to the right side of the red hat pixel (i will be the base location to identify spots on George's face)
        if (Crowd[i- (2*scale) + (64*scale)] == 1) {  //spot white dot on hat --> eliminate face with unmatched stripe 
            if (Crowd[i- (2*scale) + (64*5*scale)] == 5 && Crowd[i - (1*scale) + (64*5*scale)] == 3) { //spot yellow dot between 2 blue eyes  --> eliminate glasses face and non blue eyes
                if (Crowd[i + (64*7*scale)] == 8) {  //spot black dot of the smile --> eliminate non-smiling face
                        if (Crowd[(i + (64*11*scale))] == 7) {    //spot green "shoes" --> eliminate non green shoes
                            TopLeft = i - (7*scale);              //spot index of top left spot
                            RightBottom = i + (4*scale) + (64*11*scale) + (65*(scale-1)); //spot index of bottom right spot
                            break;  //break out the loop 
                        }
                    
                }
            }
        }
    }
   }
   BottomRight = RightBottom; //put values back into BottomRight

   printf("George is located at: top left pixel %4d, bottom right pixel %4d.\n", TopLeft, BottomRight);
   exit(0);
}

/* This routine loads in up to 1024 newline delimited integers from
a named file in the local directory. The values are placed in the
passed integer array. The number of input integers is returned. */

int Load_Mem(char *InputFileName, int IntArray[]) {
   int	N, Addr, Value, NumVals;
   FILE	*FP;

   FP = fopen(InputFileName, "r");
   if (FP == NULL) {
      printf("%s could not be opened; check the filename\n", InputFileName);
      return 0;
   } else {
      for (N=0; N < 1024; N++) {
         NumVals = fscanf(FP, "%d: %d", &Addr, &Value);
         if (NumVals == 2)
            IntArray[N] = Value;
         else
            break;
      }
      fclose(FP);
      return N;
   }
}
