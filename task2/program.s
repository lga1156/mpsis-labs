# RV32I. Separate instruction/data memories, both addressed from 0.
# RAM byte addresses: 0=a, 4=packed d:n, 8=result.
# Initial values are in mem/data.mem, loaded BEFORE execution.
# No pseudoinstructions, multiplication, syscalls or stack.
.text
.globl main
main:
    lw   x6, 0(x0)          # a; running result
    lw   x7, 4(x0)          # packed input
    andi x28, x7, 255       # n
    srli x29, x7, 8
    andi x29, x29, 255      # d
    beq  x28, x0, zero_n
    addi x28, x28, -1
loop:
    beq  x28, x0, store_result
    add  x6, x6, x29
    addi x28, x28, -1
    jal  x0, loop
zero_n:
    sub  x6, x6, x29        # convention: a_0 = a-d
store_result:
    sw   x6, 8(x0)
done:
    jal  x0, done
