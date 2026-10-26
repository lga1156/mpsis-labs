module shift_right_logic(
    input logic [31:0] a_i,
    input logic [4:0] shamt_i,
    
    output logic [31:0] result_o
);
  
  logic [31:0] stage0, stage1, stage2, stage3, stage4;
  
  // if-else внутри одного always_comb блока
  always_comb begin
    if(shamt_i[0])
      stage0 = {1'b0, a_i[31:1]};
    else
      stage0 = a_i;
  
    if(shamt_i[1])
      stage1 = {2'b0, stage0[31:2]};
    else
      stage1 = stage0;
  end
  
  assign stage2 = shamt_i[2] ? {4'b0, stage1[31:4]} : stage1;
  
  assign stage3 = shamt_i[3] ? {8'b0, stage2[31:8]} : stage2;
  
  assign stage4 = shamt_i[4] ? {16'b0, stage3[31:16]} : stage3;
  
  assign result_o = stage4;
endmodule