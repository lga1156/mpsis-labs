# Вариант 28. a_n = a + (n - 1) * d.
# Входы и результат находятся в ОЗУ (.data).
# sw[15:8] = d, sw[7:0] = n; оба числа беззнаковые.
# Для n=0 принято a_0 = a-d, как в прежней программе.

.data
.align 2
a:      .word 1
sw:     .word 0x00000203
result: .word 0

.text
.globl main
main:
    la   t0, a
    lw   t1, 0(t0)          # t1 = a, затем текущий результат
    la   t0, sw
    lw   t2, 0(t0)          # t2 = упакованные входные данные из ОЗУ
    andi t3, t2, 255        # t3 = n
    srli t4, t2, 8
    andi t4, t4, 255        # t4 = d (0..255)

    beq  t3, zero, zero_n
    addi t3, t3, -1         # нужно выполнить n-1 сложений
loop:
    beq  t3, zero, store_result
    add  t1, t1, t4
    addi t3, t3, -1
    jal  zero, loop

zero_n:
    sub  t1, t1, t4         # отдельная обработка n=0

store_result:
    la   t0, result
    sw   t1, 0(t0)          # записать ответ в ОЗУ
done:
    jal  zero, done         # ответ сохранён; ожидание сброса
