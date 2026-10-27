module fulladder(
    input logic a_i,
    input logic b_i,
    input logic carry_i,
    output logic sum_o,
    output logic carry_o
);
    
    logic AxorB;
    assign AxorB = a_i ^ b_i;
    
    logic AxorBxorCarry, AandB;
    logic AandCarry;
    logic AandBorAandCarry;
    logic BandCarry;
    logic AandBorAandCarryorBandCarry;
    
    always_comb begin
        AxorBxorCarry = AxorB ^ carry_i;
        AandB = a_i & b_i;
        AandCarry = a_i & carry_i;
        AandBorAandCarry = AandCarry | AandB;
        BandCarry = b_i & carry_i;
        AandBorAandCarryorBandCarry = AandBorAandCarry | BandCarry;
    end
    
    assign sum_o = AxorBxorCarry;
    assign carry_o = AandBorAandCarryorBandCarry;
    
endmodule