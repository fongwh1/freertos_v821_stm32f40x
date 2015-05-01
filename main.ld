/* Linker Script for STM32F405*/

MEMORY
{
    FLASH(rx) : ORIGIN = 0x08000000, LENGTH = 1024K
    RAM(rwx)  : ORIGIN = 0x20000000, LENGTH = 128K
}

ENTRY(main)

SECTIONS
{

    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        _sidata = .;
    } > FLASH

    .data : AT (_sidata)
    {
        _sdata = .;
        *(.data*)
        _edata = .;
    } > RAM

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        _ebss = .;
    } > RAM

    _estack = ORIGIN(RAM) + LENGTH(RAM);

}
