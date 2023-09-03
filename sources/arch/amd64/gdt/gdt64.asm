
; Before entering Long Mode we should bootstrap GDT

; GDT is a data structure for Intel x86-family processors
; Which is used to define the characteristics
; Of the various memory areas used durning our kernel executing  

    ; Since we are not going to change our GDT
    ; We'll put it's code to a READ-ONLY SEGMENT
    section .rodata

    global GDT64_start
    global GDT64_start.GDT64_code

    global GDT64_descriptor

; Here is the beginning of our GDT64

; WARNING: DON'T REMOVE THIS LABEL
; THEY ARE USED TO CALCULATE VALUES FOR DESCRIPTOR
GDT64_start:
    ; First entry, our table should contain is a Null Descriptor
    dq 0x0000000000000000

    ; The next one is a CODE segment
.GDT64_code: equ $ - GDT64_start
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)

    ; And the last one for now is a DATA segment

; After that, we'll also create a label pointing to the end of our GDT

; WARNING: DON'T REMOVE THIS LABEL
; THEY ARE USED TO CALCULATE VALUES FOR DESCRIPTOR
GDT64_end:

; Finally, we should create GDT descriptor
; Which is required to load our GDT 

GDT64_descriptor:
    ; The first field of our descriptor is the size of our table
    dw GDT64_end - GDT64_start - 1

    ; And the second field is the address of location, where our GDT begins
    dd GDT64_start