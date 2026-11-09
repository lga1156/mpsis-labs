main:
    lw   x6, 0(x0)          # x6 = a, текущий результат
    lw   x29, 4(x0)         # x29 = d
    lw   x28, 8(x0)         # x28 = n

    beq  x28, x0, zero_n
    addi x28, x28, -1       # Осталось n-1 сложений

loop:
    beq  x28, x0, store_result
    add  x6, x6, x29        # Результат += d
    addi x28, x28, -1       # Счётчик -= 1
    jal  x0, loop

zero_n:
    addi  x6, x0, -1        

store_result:
    sw   x6, 12(x0)         # Ответ в ОЗУ по адресу 12

done:
    jal  x0, done