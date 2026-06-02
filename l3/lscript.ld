/* linker script for stm32f4 */
MEMORY
{
    FLASH ( rx ) : ORIGIN = 0x08000000, LENGTH = 1M
    RAM ( rxw ) : ORIGIN = 0x20000000, LENGTH = 128K
}

__stack_start = ORIGIN(RAM) + LENGTH(RAM);
_ram_start = ORIGIN(RAM);

SECTIONS
{
    .text :
    {
        KEEP(*(.interrupt_vector))
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
    } > FLASH

    .data :
    {
        *(.data)
        *(.data*)
    } > RAM AT > FLASH

    .bss :
    {
        *(.bss)
        *(.bss*)
    } > RAM
}

