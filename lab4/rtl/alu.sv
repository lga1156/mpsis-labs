module alu (
  input  logic [31:0]  a_i,
  input  logic [31:0]  b_i,
  input  logic [4:0]   alu_op_i,
  output logic         flag_o,
  output logic [31:0]  result_o
);

  import alu_opcodes_pkg::*;
  
  logic [31:0] sum_o;
  logic [31:0] sub_o;
  logic [31:0] sll_o, srl_o, sra_o; 
  logic [31:0] AxorB, AorB, AandB;
  logic [31:0] srl_or_sra;
  logic [31:0] sum_or_sub;
  logic [31:0] slts_o, sltu_o;
  logic eq_o, ne_o, lts_o, ltu_o, ges_o, geu_o;
  
  assign slts_o = $signed(a_i) < $signed(b_i) ? 32'b1 : 32'b0;
  assign sltu_o = a_i < b_i ? 32'b1 : 32'b0;
  assign AxorB = a_i ^ b_i;
  assign AorB = a_i | b_i;
  assign AandB = a_i & b_i;
  assign sub_o = a_i - b_i;
  
  fulladder32 f32(
    .a_i (a_i),
    .b_i (b_i),
    .sum_o (sum_o),
    .carry_i (1'b0)
  );
  
  shift_left_logic sll(
    .a_i (a_i),
    .shamt_i (b_i[4:0]),
    .result_o (sll_o)
  );
  
  shift_right_logic srl(
    .a_i (a_i),
    .shamt_i (b_i[4:0]),
    .result_o (srl_o)
  );
  
  shift_right_ariphmetic sra(
    .a_i (a_i),
    .shamt_i (b_i[4:0]),
    .result_o (sra_o)
  );
  
  always_comb begin
    eq_o = a_i == b_i;
    ne_o = a_i != b_i;
    lts_o = $signed(a_i) < $signed(b_i);
    ltu_o = a_i < b_i;
    ges_o = $signed(a_i) >= $signed(b_i);
    geu_o = a_i >= b_i;
  
    case(alu_op_i)
      ALU_ADD: result_o = sum_o;
      ALU_SUB: result_o = sub_o;
      ALU_SLL: result_o = sll_o;
      ALU_SRL: result_o = srl_o;
      ALU_SRA: result_o = sra_o;
      ALU_XOR: result_o = AxorB;
      ALU_OR: result_o = AorB;
      ALU_AND: result_o = AandB;
      ALU_SLTS: result_o = slts_o;
      ALU_SLTU: result_o = sltu_o;
      
      default: result_o = 32'b0;
    endcase   
    
    case(alu_op_i)
      ALU_LTS: flag_o = lts_o;
      ALU_LTU: flag_o = ltu_o;
      ALU_GES: flag_o = ges_o;
      ALU_GEU: flag_o = geu_o;
      ALU_EQ: flag_o = eq_o;
      ALU_NE: flag_o = ne_o;
      
      default: flag_o = 1'b0;
    endcase
  end

endmodule