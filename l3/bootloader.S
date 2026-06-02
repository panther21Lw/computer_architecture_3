.syntax unified
.cpu cortex-m4
.thumb

.global vtable
.global __hard_reset__

.type vtable, %object
.type __hard_reset__, %function

.section .interrupt_vector
vtable:
	.word __stack_start
	.word __hard_reset__+1
	.size vtable, .-vtable

.section .rodata
image: .incbin "kernel.bin"
end_of_image:

msg_boot: .asciz "Bootloader started. Copying kernel to RAM...\n"
msg_done: .asciz "Loading complete. Jumping to kernel...\n"

.section .text
__hard_reset__:
	// Вивід повідомлення про старт завантажувача
	mov r0, #0x04
	ldr r1, =msg_boot
	bkpt #0xAB

	ldr r0, =image			// Початок kernel.bin у Flash
	ldr r1, =end_of_image		// Кінець kernel.bin у Flash
	ldr r2, =_ram_start		// Початок RAM, куди копіюється kernel.bin

	sub r3, r1, r0			// r3 зберігає розмір kernel.bin у байтах
	add r2, r2, r3			// для декременту починаємо з кінця області RAM
	mov r4, #4				// зсув 4 байти

copy_loop:
	cmp r3, #0
	ble boot_kernel

	sub r3, r3, r4			// декремент регістру адресного зсуву на 4 байти
	sub r2, r2, r4			// декремент адреси RAM на 4 байти
	ldr r5, [r0, r3]		// LDR з регістровим зсувом: адреса = r0 + r3
	str r5, [r2]			// STR за поточною декрементованою адресою RAM
	b copy_loop

boot_kernel:
	// Вивід повідомлення про завершення копіювання
	mov r0, #0x04
	ldr r1, =msg_done
	bkpt #0xAB

	ldr r0, =_ram_start
	add r0, r0, #1			// Thumb-bit для переходу до Thumb-коду
	bx r0

