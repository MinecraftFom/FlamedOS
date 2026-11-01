.section .data
msg: .asciz "Environment test 'S' finished\n"

.section .text
.globl run_s_test

run_s_test:
    movq $1, %rax
    movq $1, %rdi
    leaq msg(%rip), %rsi
    movq $30, %rdx
    syscall