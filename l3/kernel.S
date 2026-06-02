.syntax unified
.cpu cortex-m4
.thumb

.global __kernel_reset__
.type __kernel_reset__, %function

.section .data
output_buf: .space 16
msg_kernel: .asciz "Kernel started!\n"
msg_test1: .asciz "Test 1 Result: "
msg_test2: .asciz "Test 2 Result: "
msg_test3: .asciz "Test 3 Result: "
msg_newline: .asciz "\n"

.section .text
__kernel_reset__:
	ldr r0, =msg_kernel
	bl print_str

	// test set 1
	ldr r0, =msg_test1
	bl print_str
	mov r0, #3 // A
	mov r1, #7 // B
	mov r2, #2 // C
	bl start_prog
	mov r0, r4			// перенесення результатів обчислення із регістра r4 до регістра r0
	bl print_num		// друк результатів обчислення

	// test set 2
	ldr r0, =msg_test2
	bl print_str
	mov r0, #2 // A
	mov r1, #5 // B
	mov r2, #31 // C
	bl start_prog
	mov r0, r4			// перенесення результатів обчислення із регістра r4 до регістра r0
	bl print_num		// друк результатів обчислення

	// test set 3
	ldr r0, =msg_test3
	bl print_str
	mov r0, #8 // A
	mov r1, #1 // B
	mov r2, #5 // C
	bl start_prog
	mov r0, r4			// перенесення результатів обчислення із регістра r4 до регістра r0
	bl print_num		// друк результатів обчислення

_kernel_loop:
	b _kernel_loop

// Вивід рядка через Semihosting: адреса рядка передається у r0
print_str:
	push {lr}
	mov r1, r0
	mov r0, #0x04
	bkpt #0xAB
	pop {pc}

// Перетворення додатного числа з r0 у ASCII-рядок та вивід у консоль
print_num:
	push {r0-r7, lr}		// Зберігаємо початковий стан регістрів та адресу повернення
	ldr r1, =output_buf		// r1 зберігає адресу буфера, куди буде записано ASCII-рядок
	mov r2, #0				// r2 лічильник кількості цифр у числі
	mov r3, #10				// поділивши число на 10 зможемо отримати чергову його цифру

	cmp r0, #0				// якщо передане число 0, його можна відразу перевести у ASCII-рядок
	bne .num_loop			// Якщо число не 0, переходимо до основного циклу розбиття
	mov r4, #'0'			// ASCII-символ нуль
	strb r4, [r1], #1		// Записуємо отриманий '0' в буфер та зміщуємо вказівник на +1 байт
	mov r4, #0				// нуль-термінатор (\0) для кінця рядка
	strb r4, [r1]			// Завершуємо рядок символом \0
	ldr r0, =output_buf		// Передаємо отриманий "нуль-рядок" у функцію виводу
	bl print_str
	// Вставлення нового рядка у виводі
	ldr r0, =msg_newline	
	bl print_str
	pop {r0-r7, pc}			// Відновлюємо регістри та виходимо з функції (PC = LR)

.num_loop:
	cmp r0, #0				// Перевіряємо, чи повністю розібрали число (після останнього ділення на 10 в остачі залишиться 0)
	beq .num_pop
	udiv r4, r0, r3			// r4 = r0 / 10 (ціла частина від ділення)
	mls r5, r4, r3, r0		// r5 = r0 - (r4 * 10) (залишок від ділення це остання цифра)
	push {r5}				// Зберігаємо чергову цифру у стек
	add r2, r2, #1			// Інкремент лічильника кількості цифр
	mov r0, r4				// Оновлюємо робоче число цілою частиною для наступного кроку
	b .num_loop				

.num_pop:
	ldr r1, =output_buf		// r1 зберігає адресу буфера, куди буде записано ASCII-рядок
.pop_loop:
	cmp r2, #0				// Перевірка чи всі цифри додано до ASCII-буфера
	beq .num_print			// Якщо всі цифри опрацьовано, переходимо до друку
	pop {r4}				// Беремо чергову цифру зі стеку
	// через використання стеку, цифри зі старших розрядів йтимуть першими, тому додаткових перетворень не потрібно
	add r4, r4, #'0'		// Перетворюємо число (0-9) на ASCII-код символу ('0'-'9')
	strb r4, [r1], #1		// Записуємо символьну форму цифри у буфер і зміщуємо вказівник на 1 байт
	sub r2, r2, #1			// Зменшуємо лічильник залишкових цифр
	b .pop_loop

.num_print:
	mov r4, #0				// нуль-термінатор (\0) для кінця рядка
	strb r4, [r1]			// Додаємо нуль-термінатор у кінець сформованого у буфері рядка
	ldr r0, =output_buf		// Передаємо отримане рядкове число у функцію виводу
	bl print_str
	// Вставлення нового рядка у виводі
	ldr r0, =msg_newline
	bl print_str
	pop {r0-r7, pc}

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
	mov r4, r3
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

