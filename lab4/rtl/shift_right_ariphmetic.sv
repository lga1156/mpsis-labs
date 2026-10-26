module shift_right_ariphmetic(
    input logic [31:0] a_i,
    input logic [4:0] shamt_i, //shift amount input
    
    output logic [31:0] result_o
);

  logic [31:0] stage0, stage1, stage2, stage3, stage4;
  logic sign_bit;
  assign sign_bit = a_i[31];
  
  assign stage0 = shamt_i[0] ? {sign_bit, a_i[31:1]} : a_i;
  
  assign stage1 = shamt_i[1] ? {{2{sign_bit}}, stage0[31:2]} : stage0;
  
  assign stage2 = shamt_i[2] ? {{4{sign_bit}}, stage1[31:4]} : stage1;
 
  assign stage3 = shamt_i[3] ? {{8{sign_bit}}, stage2[31:8]} : stage2;
  
  assign stage4 = shamt_i[4] ? {{16{sign_bit}}, stage3[31:16]} : stage3;
  
  assign result_o = stage4;
  
endmodule 