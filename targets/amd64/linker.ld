
ENTRY(_BOOT_ENTRY_AMD64)

SECTIONS
{
    . = 0x00100000;

    .boot BLOCK(4K) : ALIGN(4K)
    {
        KEEP(*(.multiboot2))
    }

    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.text)
    }
}