;@============================================================================
;@
;@ Student Name 1: Greyson Wang
;@ Student 1 #: 301249759
;@ Student 1 greysonw@sfu.ca
;@
;@ Student Name 2: Ricardo Dupouy
;@ Student 2 #: 301259470
;@ Student 2 rdupouy@sfu.ca
;@
;@ Helpers: lab TA's
;@
;@ Also, reference resources beyond the course textbooks and the course pages on Canvas
;@ that you used in making your submission.
;@
;@ Resources:  none
;@
;@% Instructions:
;@ * Put your name(s), student number(s), userid(s) in the above section.
;@ * Edit the "Helpers" line and "Resources" line.
;@ * Your group name should be "<userid1>_<userid2>" (eg. stu1_stu2)
;@ * Form groups as described at:  https://courses.cs.sfu.ca/docs/students
;@ * Submit your file to courses.cs.sfu.ca
;@
;@ Name        : fib-full.s
;@ Description : Submission for Assignment 1.
;@============================================================================

.text; @ Store in ROM

Reset_Handler:
 .global Reset_Handler; @ The entry point on reset
; @ The main program

main:
 ldr sp, =#0x40004000; @ Initialize SP just past the end of RAM
 mov r4, #3; @ Some value I care about.
 
 mov r5, #0;	@ the test number
 mov r11, #0;	@ number of tests passed
 ldr r6, =test_n;	@ load address where input n is to be loaded from
 
run_testCase:

 ldr r0, [r6, r5]; @ Load value of N into first argument
 
 bl sub_fib; @ Find Nth value of the Fibonacci sequence

 
 test_returned_n:
  push {r6, r7, r8, r9}
  ldr r6, =ans_n;	@ load address of n from test table
  ldr r7, [r6, r5];	@ load value of n from test table
  ldr r8, =var_n;	@ load address of subroutine's return value of n 
  ldr r9, [r8];		@ load subroutine's return value of n
  subs r7, r7, r9
  pop {r6, r7, r8, r9}
  BNE increment_counter
  
  test_overflow:
  push {r6, r7, r8, r9}  
  ldr r6, =ans_of; @ load address of of from test table
  ldr r7, [r6, r5]; @ load value of of from test table
  ldr r8, =of;
  ldr r9, [r8];
  subs r9, r7;		
  pop {r6, r7, r8, r9}
  BNE increment_counter
  
  test_msw:
  push {r4, r6, r7, r8, r9, r10, r11}  
  mov r4, #4
  ldr r10, =num_words;
  ldr r11, [r10];
  sub r11, #1;
  mul r11, r4, r11;		@ calculate offset of msw
  ldr r6, =ans_msw; @ load address of msw from test table
  ldr r7, [r6, r5]; @ load value of msw from test table
  ldr r8, =var_b;		@ load address of b
  ldr r9, [r8, r11];	@ load value of msw of b
  subs r9, r7;
  pop {r4, r6, r7, r8, r9, r10, r11}
  BNE increment_counter

  test_lsw:
  push {r6, r7, r8, r9}  
  ldr r6, =ans_lsw; @ load address of msw from test table
  ldr r7, [r6, r5]; @ load value of lsw from test table
  ldr r8, =var_b;		@ load address of b
  ldr r9, [r8];		@ load value of lsw of b
  subs r9, r7;
  pop {r6, r7, r8, r9}
  BNE increment_counter

add r11, #1;	
CMP r5, #24
BEQ end
	
	;@ increment the counter and loop back to the start of the test to run the next testcase
increment_counter:
 add r5, #4
 b run_testCase

 
end:
 b end;
 
 
sub_fib:
 ;@ Store register(s) and LR to stack
 ;@ initialize variables 
 
	push {r4, r6, r8, r10, r11, lr};
			
	ldr r1, =var_n;
	ldr r2, =var_a;
	ldr r3, =var_b;
	ldr r6, =of;
	ldr r10, =num_words; ;@ Number of words
	
	initialize_byte:
	;@ initialize a and b to 0
	push {r4, r5}
	mov r4, #0;		@ const of 0
	mov r5, #0;		@ the word number	
	init_loop:	
	str r4, [r2, r5];
	str r4, [r3, r5];
	add r5, #4
	CMP r5, #508
	BNE init_loop
	pop {r4, r5}
	
	
	;@ initialize the number of words to 1
	mov r8, #1;
	str r8, [r10];
	
	mov r4, #0;
	str r4, [r1];	@ initialize n
	str r4, [r6];	@ initialize overflow
	
;	@ initialize both variables to 1
	mov r11, #1;	@ Constant used for initializing the variables	
	str r11, [r2];
	str r11, [r3];	
	
	;@ Check if N = 0, 1 or 2 and update var_n accordingly
	cmp r0, #0;
	BEQ zero;
	
	add r4, #1
	str r4, [r1]
	cmp r0, #1;
	BEQ stop;
	
	add r4, #1
	str r4, [r1]
	cmp r0, #2;
	BEQ stop;
	
	;@ first fib calculated is f3
	sub r0, #2
	
	bl loop;
	
	stop:
	;@<Restore registers, and load LR into PC>
	pop {r4, r6, r8, r10, r11, lr};
	mov pc, lr;

zero:
	mov r11, #0;
	str r11, [r3];
	b stop;

;@ Each run of loop calculates one term of the fib sequence
;@ Load the number of words currently needed to store the value of b into r8 (from address stored in r10)
loop:	
	push {r7, r8, r9, r11, lr};
	addloop:
	ldr r8, [r10];		@Number of times to preform add_by_byte
	mov r7, #0;			@Offset used for load_var and store_var
	mov r11, #0;		@Initialize r11 to 0
	adds r9, #0; 		@clear flags
	bl add_ab;			@Perform addition of a+b
				
	add r4, r4, #1;		@Increment r4, which stores the index of the current fib number calculated
	str r4, [r1];
	subs r0, r0, #1;	@ Decrement the loop counter		
	BNE addloop;			@ Have we reached the desired term yet?	
	
	pop {r7, r8, r9, r11, lr};
	mov pc, lr;

	
; @ Subroutine to add a+b from the variables into memory
add_ab:	

;	@ r8 is the number of words needed to store the current fib number
;	@ while r8 > 0, move on to the next 4 bytes of a and b and add them.
;	@ then decrement r8
;	@ if r8 = 1, we are on the rightmost word of a and b
;	@ if the carry flag is set from adding the last 4 bytes, increment r8 and the value stored in memory location r10
	
	push {lr}; 
	add_ab_2:
	;@save return address of this subroutine because LR will be used for the load_var and store_var subroutines		
	bl add_word			
	add r7, r7, #4;
	subs r8, r8, #1;
	BNE add_ab_2
	
	pop {lr};
	mov PC, lr;		@ Return from subroutine

;@ Add 1 word of a with 1 word of b
;@ Which word is added is determined by the offset stored in r7
;@ If the addition produces a carry, carry is stored in r11
add_word:
	push {r5, r6, lr};
	
	mov r5, r7;		@move the value of the offset used in load_var into r5
	bl load_var	
	adds r6, r6, r11;	@ Add any carry from previous words to r6
	mov r11, #0;		@Reset carry to 0 after it is added
	;@mov lr, pc
	blcs check_expand;
	adds r6, r6, r5;	@ Add word x, set status register
	mov lr, pc
	BCS check_expand;	@ Determine if another word is needed, True if there is overflow and we are on rightmost word (r8 = 1). Also store carry in r11
	mov r5, r7;
	bl store_var
	
	pop {r5, r6, lr};
	mov PC, lr;		@ Return from subroutine

; @ Subroutine to load two words from the variables into memory
load_var:

	ldr r6, [r2, r5];	@ Load the value of var_a
	ldr r5, [r3, r5];	@ Load the value of var_b
	mov pc, lr;			@ Return from subroutine

; @ Subroutine to shift move var_b into var_a and store
; @ the result of the add.
; @ Set F2 = F3, then store F4 = F2+F3 into F3
store_var:
	push {r11}
	ldr	r11,[r3, r5];   @ Move var_b into r11
	str	r11,[r2, r5];	@ store r11 into var_a
	str r6, [r3, r5];	@ Store the result of a+b into var_b
	pop {r11}
	mov pc, lr;		@ Return from subroutine

;@ Check if r8 = 1
;@ if r8 is 1, then addition needs to be expanded
check_expand:
	push {lr};
	
	mov r11, #1
	CMP r8, #1;
	BEQ check_overflow;
	
	pop {lr};
	mov pc, lr;
	
	check_overflow:
	CMP r1, #128
	mov lr, pc
	BNE expand_addition;
	
	pop {lr};
	mov pc, lr;

;@ increment r8 so that addition will be preformed on the next 4 bits as well
;@ also update the value in memory storing the number of words needed 
expand_addition:
	push {r4}; 
	add r8, r8, #1
	ldr r4, [r10];
	add r4, r4, #1;
	str r4, [r10];


	pop {r4};
	mov pc, lr;

 .data
of:    .space 4;   
var_n: .space 4;@ 1 word/32 bits – what Fib number ended up in var_b
var_a: .space 512;@ 128 words/4096 bits
var_b: .space 512;@ 128 words/4096 bits 
num_words: .space 4

;@ Test parameters format 2
    .equ    TestCount,    7
;@    test number            1            2            3          4          5       6            7 
test_n:   .word             4,          1,        130,          0,          2,         60,         72;    @ input n
ans_n:    .word             4,          1,        130,          0,          2,         60,         72;    @ output n
ans_of:   .word             0,          0,          0,          0,          0,          0,          0;    @ overflow
ans_msw:  .word    0x00000003, 0x00000001, 0x02212402, 0x00000000, 0x00000001, 0x00000168, 0x0001C557;    @ fib msw
ans_lsw:  .word    0x00000003, 0x00000001, 0xf98af5a7, 0x00000000, 0x00000001, 0x6C8312D0, 0x5E509F60;    @ fib lsw