
    [bits 64]

    section .text

    global _lm_bootloader_entry

_lm_bootloader_entry:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov al, "X"
    mov ah, 0x0F

    mov [0xB8000], ax

    hlt