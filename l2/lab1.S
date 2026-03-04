.global lab1
.syntax unified

lab1:
	push { lr }
	
	// test set 1
	test1:
		mov r0, #3 // A
		mov r1, #7 // B
		mov r2, #2 // C
		bl start_prog
	
	// test set 2
	test2:
		mov r0, #2 // A
		mov r1, #5 // B
		mov r2, #31 // C
		bl start_prog

	// test set 3
	test3:
		mov r0, #8 // A
		mov r1, #1 // B
		mov r2, #5 // C
		bl start_prog

	// after test 3 leaving
	pop { pc }

// program start point
start_prog:
	push { r0-r3, lr }
	
	// checking the first conditional block (a*b ?<=? 16)
	mul r3, r0, r1	// r3 = a * b
	cmp r3, #16	// comparing r3 and 16
	bgt else_case	// if (a * b) > 16 going to the first "not" branch on the scheme
	
	// checking the second conditional block (a ?>? b)
	cmp r0, r1	// comparing r0 (A) and r1 (B)
	ble else_inner	// if ( A <= B) going to the second "not" branch on the scheme
	
	// here handler for (a > b) branch
	mov r6, r2	// copying value of C (r2) to r6 as factorial calculator input register
	bl factorial	// calculating factorial(c)
	add r3, r0, r1	// (a + b)
	lsl r3, r3, #2	// << 2
	sub r4, r6, r3	// c! - ((a + b) << 2)
	b end_prog

// the second "not" branch on the scheme
else_inner:
	and r3, r0, r1	// (a & b)
	orr r6, r0, r2	// (a | c)
	eor r4, r3, r6	// (a & b) xor (a | c)
	b end_prog

// the first "not" branch on the scheme
else_case:
	add r3, r0, r1	// (a + b)
	sub r3, r3, r2	// (a + b) - c
	lsl r3, r3, #5	// << 5
	b end_prog

end_prog:
	pop { r0-r3, pc }


factorial:
	push { r5, lr }
	// factorial of what to calculate will be stored in r6
	mov r5, #1 // temporaty result of factorial is stored in r5

	.fact_calcul:
		mul r5, r6 // multiplying two numbers
		subs r6, #1 // substract 1 and update flags
		bne .fact_calcul // while the last multiplier not 0 we should continue multiplication

	// final result will be stored in r6
	mov r6, r5

	pop { r5, pc }
