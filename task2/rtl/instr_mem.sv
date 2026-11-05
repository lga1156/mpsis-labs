module instr_mem (
  input logic [31:0] addr_i,
  output logic [31:0] read_data_o
);
  import memory_pkg::*;
  logic [31:0] rom [0:INSTR_MEM_SIZE_WORDS-1];
  initial $readmemh("program.mem", rom);
  assign read_data_o = rom[addr_i[$clog2(INSTR_MEM_SIZE_BYTES)-1:2]];
endmodule
