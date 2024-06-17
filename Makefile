
AS := nasm

ASM_SOURCE_FILES := $(shell find boot/amd64 -name *.asm)
ASM_OBJECT_FILES := $(patsubst boot/amd64/%.asm, build/amd64/boot/%.o, $(ASM_SOURCE_FILES))

$(ASM_OBJECT_FILES): build/amd64/boot%.o : boot/amd64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/amd64/boot/%.o, boot/amd64/%.asm, $@) -i include -o $@ 

.PHONY: build-amd64
build-amd64: $(ASM_OBJECT_FILES)
	mkdir -p release/amd64 && \
	amd64-elf-ld -n -o release/amd64/calypso-amd64.bin -T targets/amd64/linker.ld $(ASM_OBJECT_FILES) && \
	cp release/amd64/calypso-amd64.bin targets/amd64/iso/boot/calypso-amd64.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o release/amd64/calypso-amd64.iso targets/amd64/iso
