module fulladder4(
  input  logic [3:0] a_i,
  input  logic [3:0] b_i,
  input  logic       carry_i,
  output logic [3:0] sum_o,
  output logic       carry_o
);
    
    logic [2:0] name; 
    
    fulladder f0(
        .a_i (a_i[0]),
        .b_i (b_i[0]),
        .sum_o (sum_o[0]),
        .carry_i (carry_i),
        .carry_o (name[0])
    );
    
    fulladder f1(
        .a_i (a_i[1]),
        .b_i (b_i[1]),
        .sum_o (sum_o[1]),
        .carry_i (name[0]),
        .carry_o (name[1])
    );
    
    fulladder f2(
        .a_i (a_i[2]),
        .b_i (b_i[2]),
        .sum_o (sum_o[2]),
        .carry_i (name[1]),
        .carry_o (name[2])
    );
    
    fulladder f3(
        .a_i (a_i[3]),
        .b_i (b_i[3]),
        .sum_o (sum_o[3]),
        .carry_i (name[2]),
        .carry_o (carry_o)
    );

endmodule;