// Total boot code

// Set code alignment
.code16

.section .text              # Here comes the text section! Here's where the magic begins~
.equ KERNEL_ADDR,    0x1000 # Kernel will be load at 0x1000
.equ KERNEL_SECTORS, 16     # 16 * 512 = 8KB

.globl _start # Boot entry
_start:
    cli
    // ==========
    // Initialize registers
    // (how many meanings in the world does the word 'register' have!!! I'm near going insane while multi-processing multiple projects but having the same word around me all the time...)
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7C00, %sp # Set up stack pointer~
    sti

    movb %dl, drive

    // Tells user the pc is booting up
    movw $boot_msg_author, %si
    call blprint
    movw $boot_msg_welcome, %si
    call blprint
    movw $boot_msg_boot, %si
    call blprint

    movw $KERNEL_ADDR, %ax # Move the starter address to KERNEL_ADDR (0x1000)
    movw %ax, %es
    xorw %bx, %bx
    movb $0x00, %ch
    movb $0x00, %dh
    movb $0x02, %cl

    movb $KERNEL_SECTORS, %al # Announce kernel sector count
    movb $0x02, %ah
    movb drive, %dl
    int $0x13
    jc err_disk

    movw $boot_msg_drive_found, %si
    call blprint

    // Here is the real start of magic
    // Using lgdt to switch to 32bits
    lgdt gdt_descriptor # I bet 'ldgt', 'cr0' will only be used once... (hopefully)
    movl %cr0, %eax
    orl $0x01, %eax
    movl %eax, %cr0
    ljmp $0x08, $blstart

.code32 # 32-bits
blstart: # Boot loader entry. Here, the kernel is going to be booted
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    movl $0x90000, %esp # Stack pointer
    movl $0x10000, %eax # Kernel starter
    jmp *%eax

    call blhalt # After kernel ends

.code16 # Switch back to 16-bits
blprint: # Boot loader print
    lodsb
    testb %al, %al
    jz .blret
    movb $0x0E, %ah
    movw $0x07, %bx
    int $0x10
    jmp blprint
.blret: ret

blhalt: # Kill the boot
    cli
    hlt
    jmp blhalt

// Errors
// ==========
err_disk:
    movw $boot_error_disk_error, %si
    call blprint
    call blhalt
// ==========

// .section .data # The data section. Holds all the constants
boot_msg_author: .asciz "FlamedOS by Fom477"
boot_msg_boot: .asciz "Booting up FlamedOS..."
boot_msg_drive_found: .asciz "Successfully found valid boot drive. Booting..."
boot_msg_welcome: .asciz "Welcome to use FlamedOS!"

boot_error_disk_error: .asciz "Disk error: unable to load disk, boot failed"

drive: .byte 0

.align 8 # Define gdt alignment: 8
gdt_header:
    // Magic
    // The only thing to know about
    // these 3 numbers is that they
    // lead to the 32-bit limit
    .quad 0x0000000000000000
    .quad 0x00CF9A000000FFFF
    .quad 0x00CF92000000FFFF
gdt_bottom: # gun mu

gdt_descriptor:
    .word gdt_bottom - gdt_header - 1 # Size
    .long gdt_header

// .section .text
.org 510 # I leave 2 bytes left for the 0xAA55 signature
.word 0xAA55 # Boot signature