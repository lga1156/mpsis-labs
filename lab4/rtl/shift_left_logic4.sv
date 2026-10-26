module shift_left_logic(
    input logic [31:0] a_i,
    input logic [4:0] shamt_i,
    
    output logic [31:0] result_o
);
  
  logic [31:0] stage0, stage1, stage2, stage3, stage4;
  
  always_comb begin
    if(shamt_i[0])
      stage0 = {a_i[30:0], 1'b0};
    else
      stage0 = a_i;
  end
  
  // if-else
  always_comb begin
    if(shamt_i[1])
      stage1 = {stage0[29:0], 2'b0};
    else
      stage1 = stage0;
  end
  
  always_comb begin
    if(shamt_i[2])
      stage2 = {stage1[27:0], 4'b0};
    else
      stage2 = stage1;
  end
  
  // Потренировался в использовании тернарных операторов
  assign stage3 = shamt_i[3] ? {stage2[23:0], 8'b0} : stage2;
  
  assign stage4 = shamt_i[4] ? {stage3[15:0], 16'b0} : stage3;
  
  assign result_o = stage4;
endmodule
