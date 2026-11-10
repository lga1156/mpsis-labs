#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PREFIX=${RISCV_PREFIX:-riscv-none-elf-}
mkdir -p "$ROOT/build/firmware"
cd "$ROOT/build/firmware"
FLAGS='-march=rv32i_zicsr -mabi=ilp32 -Os -ffreestanding -fno-builtin -ffunction-sections -fdata-sections -msmall-data-limit=0'
"${PREFIX}gcc" $FLAGS -Wall -Wextra -Werror -c "$ROOT/firmware/main.c" -o main.o
"${PREFIX}gcc" $FLAGS -c "$ROOT/firmware/startup.S" -o startup.o
"${PREFIX}gcc" $FLAGS -nostdlib -Wl,--gc-sections,-Map=result.map -T "$ROOT/firmware/linker_script.ld" startup.o main.o -lgcc -o result.elf
"${PREFIX}objcopy" -O verilog --verilog-data-width=4 -j .text result.elf "$ROOT/mem/init_instr.mem"
"${PREFIX}objcopy" -O verilog --verilog-data-width=4 -j .data result.elf init_data.raw
# The ELF data load address is artificial; RAM starts at word zero.
sed '1s/^@.*/@00000000/' init_data.raw > "$ROOT/mem/init_data.mem"
"${PREFIX}objdump" -d result.elf > "$ROOT/firmware/disassembly.txt"
"${PREFIX}size" result.elf
