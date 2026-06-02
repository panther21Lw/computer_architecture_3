MEMORY
{
    RAM ( rxw ) : ORIGIN = 0x20000000, LENGTH = 128K
}

__stack_start = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    . = ORIGIN(RAM);
    .text :
    {
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
    } > RAM

    .data :
    {
        *(.data)
        *(.data*)
    } > RAM

    .bss :
    {
        *(.bss)
        *(.bss*)
    } > RAM
}

