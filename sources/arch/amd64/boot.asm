
    ; This code will be running in Protected Mode (32-bit)
    [bits 32]

    ; Declaring TEXT section, where we will put our instructions
    section .text

    ; Making entry point of our bootloader available for linker
    ; This is the point where booting process will start executing
    global _bootloader_entry

; After that we can create our start label
; Where our code will begin executing
_bootloader_entry:
    ; Before we start, we have to bootstrap our stack
    ; By setting ESP register to the top of the stack
    mov esp, stack_top

    call _lm_bootloader.verify_multiboot2
    call _lm_bootloader.verify_cpuid
    call _lm_bootloader.verify_longmode

    mov ebx, STATUS_MESSAGE_SUCCESS

    call _print_message.begin

    call _setup_page_tables
    call _enable_paging

    extern GDT64_descriptor
    lgdt [GDT64_descriptor]

    extern _lm_bootloader_entry

    extern GDT64_start.GDT64_code
    jmp GDT64_start.GDT64_code:_lm_bootloader_entry

    ; This instruction halts our CPU
    ; To prevent executing undefined code
    hlt

%define MULTIBOOT2_MAGIC 0x36D76289

_lm_bootloader.verify_multiboot2:
    cmp eax, MULTIBOOT2_MAGIC
    jne _lm_bootloader.failed_multiboot2

    ret

_lm_bootloader.verify_cpuid:
    pushfd
    pushfd
    xor dword [esp], 1 << 21
    popfd
    pushfd
    pop eax
    xor eax, [esp]
    popfd 
    and eax, 1 << 21
    jz _lm_bootloader.failed_cpuid

    ret

_lm_bootloader.verify_longmode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001

    jb _lm_bootloader.failed_longmode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29

    jb _lm_bootloader.failed_longmode

    ret

ERROR_MESSAGE_MULTIBOOT2 db "ERROR: Unable to verify Multiboot2 signature!", 0
ERROR_MESSAGE_CPUID db "ERROR: CPU does not support CPUID instruction!", 0
ERROR_MESSAGE_LONGMODE db "ERROR: CPU does not support 64-bit mode!", 0

STATUS_MESSAGE_SUCCESS db "Successfully booted on x86_64!", 0

_lm_bootloader.failed_multiboot2:
    mov ebx, ERROR_MESSAGE_MULTIBOOT2
    jmp _print_message.begin

_lm_bootloader.failed_cpuid:
    mov ebx, ERROR_MESSAGE_CPUID
    jmp _print_message.begin

_lm_bootloader.failed_longmode:
    mov ebx, ERROR_MESSAGE_LONGMODE
    jmp _print_message.begin

%define VIDEO_MEMORY_ADDRESS 0xB8000

_print_message.begin:
    pusha
    mov edx, VIDEO_MEMORY_ADDRESS

    jmp _print_message.loop

_print_message.loop:
    mov al, [ebx]
    mov ah, 0x0F

    cmp al, 0
    je _print_message.end

    mov [edx], ax
    add ebx, 1
    add edx, 2 

    jmp _print_message.loop

_print_message.end:
    popa

    ret

_setup_page_tables:
    mov eax, _page_table_l3
    or eax, 0b11
    mov [_page_table_l4], eax

    mov eax, _page_table_l2
    or eax, 0b11
    mov [_page_table_l3], eax

    mov ecx, 0

_setup_page_tables.loop:
    mov eax, 0x200000
    mul ecx
    or eax, 0b10000011

    mov [_page_table_l2 + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne _setup_page_tables.loop

    ret

_enable_paging:
    mov eax, _page_table_l4
    mov cr3, eax

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

    ; Declaring BSS section for uninitialized data
    section .bss

    align 4096

_page_table_l4:
    resb 4096
_page_table_l3:
    resb 4096
_page_table_l2:
    resb 4096

    ; This code will be aligned on 16-byte boundary
    align 16

    ; Since the multiboot standart doesn't define the value of the ESP register
    ; We'll provide the stack for the kernel manually
    
; This label points to the bottom of the stack
stack_bottom:
    ; Here we'll reserve 16 KiB of memory
    resb 16384
; This label points to the top of the stack
stack_top: