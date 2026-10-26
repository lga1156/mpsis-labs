# Лаба 5: декодер RISC-V

## Запуск в Vivado

Перенеси всю папку `lab5` на компьютер, где запускается Vivado.
Открой `Nikolai.xpr`, затем Run Simulation → Run Behavioral Simulation.
В Design Sources верхний модуль — `decoder`, в Simulation Sources —
`lab_05_tb_decoder`. Нажми Run All, если моделирование не дошло до конца.

Альтернативный запуск: открой Vivado без проекта и выполни в Tcl Console:

```tcl
source /home/ТВОЙ_ЛОГИН/lab5/scripts/simulate.tcl
```

Замени путь на путь на компьютере с Vivado. Скрипт создаёт служебный проект
в `lab5/build_sim`; исходники в эту папку не клади.

Успешный результат в консоли:

```text
Test has been finished
Number of errors:           0
```

Плата, программа в `program.mem` и ограничения XDC для этой работы не нужны.
Для просмотра сигналов выбери Scope → lab_05_tb_decoder → DUT → Add to Wave Window,
затем Restart и Run All. Наблюдай `fetched_instr_i`, `opcode`, `func3`, `func7`,
выбор операндов, `alu_op_o`, разрешения записи, признаки переходов и
`illegal_instr_o`. Входную инструкцию удобно смотреть в Hex.

## Состав проекта

- `rtl/decoder.sv` — найденный декодер, адаптированный под интерфейс задания.
- `rtl/alu_opcodes_pkg.sv`, `csr_pkg.sv`, `decoder_pkg.sv` — константы APS.
- `tb/lab_05.tb_decoder.sv` — официальный тест без изменений.
- `scripts/simulate.tcl` — создание проекта и запуск в Vivado.
- `scripts/check.sh` — проверка через Verilator и Z3 (`./scripts/check.sh`).

Порядок компиляции: `alu_opcodes_pkg`, `csr_pkg`, `decoder_pkg`, `decoder`, тест.

Официальный тестбенч сохранён без изменений. В декодере проверка MRET
выполняется по полному слову `32'h30200073`.

## Источник

Файлы пакетов и тест взяты из
[MPSU/APS, Labs/05. Main decoder](https://github.com/MPSU/APS/tree/4cac36212b98dc1d1fb2f8e408828c956f733696/Labs/05.%20Main%20decoder),
ветка `russian_version`, commit `4cac36212b98dc1d1fb2f8e408828c956f733696`.
Задание также есть в соседнем каталоге `APS/Labs/05. Main decoder/README.md`.

Декодер — комбинационная схема: превращает инструкцию в управляющие сигналы.
У него нет тактового входа и собственной памяти. Тактовый сигнал в тесте нужен
для последовательной подачи и проверки инструкций. Сборка процессора из этого
и остальных блоков выполняется в лабораторной №7.

## Проверка сборки

27 октября 2026 новый декодер прошёл полный официальный тест APS без изменений
тестбенча: `Number of errors: 0`. Запуск выполнен в Verilator 5.052 с assertions
и решателем Z3. Проверка RTL через
`--lint-only` прошла без предупреждений. Vivado на этом Mac отсутствует;
проверку XSim следует запускать на компьютере с Vivado по инструкции выше.
