
global _BOOT_ENTRY_AMD64

    section .text
_BOOT_ENTRY_AMD64:
    mov al, 'O'
    mov ah, 0x0F

    mov [0xB8000], ax

    mov al, 'K'
    mov ah, 0x0F

    mov [0xB8002], ax

    hlt
