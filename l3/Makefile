SDK_PREFIX ?= arm-none-eabi-
CC = $(SDK_PREFIX)gcc
OBJCOPY = $(SDK_PREFIX)objcopy
QEMU = qemu-system-gnuarmeclipse
BOARD ?= STM32F4-Discovery
MCU = STM32F407VG
TARGET = firmware
CPU_CC = cortex-m4
TCP_ADDR = 1234

all: kernel.bin bootloader

kernel.bin: kernel.S kernel.ld
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall kernel.S -o kernel.o
	$(CC) kernel.o -mcpu=$(CPU_CC) -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./kernel.ld -o kernel.elf
	$(OBJCOPY) -O binary kernel.elf kernel.bin

bootloader: bootloader.S kernel.bin lscript.ld
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall bootloader.S -o bootloader.o
	$(CC) bootloader.o -mcpu=$(CPU_CC) -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

qemu: all
	$(QEMU) --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -gdb tcp::$(TCP_ADDR) -S

run: all
	$(QEMU) --verbose --board $(BOARD) --mcu $(MCU) --image $(TARGET).bin --semihosting-config enable=on,target=native

.PHONY: all bootloader qemu run clean
clean:
	-rm -f *.o *.elf *.bin

