`timescale 1ns/1ps
module tb_progression_demo;
  logic clk = 0;
  logic rst = 1;
  logic [15:0] sw = 16'h0203; // d=2, n=3
  logic [31:0] out;
  logic signed [31:0] first_term;
  integer cycles = 0;
  CYBERcobra DUT(.clk_i(clk), .rst_i(rst), .sw_i(sw), .out_o(out));
  always #5 clk = ~clk;
  initial begin
    $dumpfile("progression_demo.vcd");
    $dumpvars(0, tb_progression_demo);
    #1;
    first_term = {{9{DUT.imem.ROM[0][27]}}, DUT.imem.ROM[0][27:5]};
    @(negedge clk);
    rst = 0;
    $display("TRACE: cycle PC instruction r1 r4 out (decimal except instruction)");
    while (DUT.program_counter !== 32'd52 && cycles < 30) begin
      @(negedge clk);
      cycles++;
      $display("TRACE: %0d %0d %08h %0d %0d %0d", cycles,
               DUT.program_counter, DUT.instruction, $signed(DUT.rfile.rf_mem[1]),
               DUT.rfile.rf_mem[4], $signed(out));
    end
    if (cycles != 18 || DUT.program_counter !== 32'd52 || out !== (first_term + 32'd4))
      $fatal(1, "FAIL: OUT=%h PC=%0d cycles=%0d", out, DUT.program_counter, cycles);
    repeat (3) begin
      @(negedge clk);
      if (DUT.program_counter !== 32'd52 || out !== (first_term + 32'd4))
        $fatal(1, "FAIL: final output is unstable");
    end
    $display("PASS: d=2 n=3 OUT=%0d PC=52", $signed(out));
    $finish;
  end
endmodule
