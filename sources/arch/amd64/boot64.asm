
    ; This code will be running in Long Mode (64-bit)
    [bits 64]

    ; Declaring TEXT section, where we will put our instructions
    section .text

    global _lm_bootloader_entry

_lm_bootloader_entry:
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov al, "X"
    mov ah, 0x0F

    mov [0xB8000], ax

    hlt