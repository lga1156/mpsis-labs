#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v verilator >/dev/null
command -v z3 >/dev/null
mkdir -p build_verilator
verilator --binary --timing --assert -Wno-fatal \
  --top-module lab_05_tb_decoder --Mdir build_verilator \
  rtl/alu_opcodes_pkg.sv rtl/csr_pkg.sv rtl/decoder_pkg.sv rtl/decoder.sv \
  tb/lab_05.tb_decoder.sv > build_verilator/compile.log 2>&1 || {
    cat build_verilator/compile.log
    exit 1
  }
./build_verilator/Vlab_05_tb_decoder "$@" | tee build_verilator/test.log
# The upstream test ends with $finish even when errors were recorded.
python3 - <<'PY'
from pathlib import Path
import re
text = Path('build_verilator/test.log').read_text()
match = re.search(r'Number of errors:\s*(\d+)', text)
if not match or int(match[1]) != 0:
    raise SystemExit('FAIL: official test did not finish with zero errors')
print('PASS: official APS decoder test, zero errors')
PY
