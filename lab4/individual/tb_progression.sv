`timescale 1ns/1ps
module tb_progression;
  logic clk = 0;
  logic rst = 1;
  logic [15:0] sw = 0;
  logic [31:0] out;
  integer tests = 0;
  integer d, n, k;
  logic [31:0] random_state = 32'h1248abcd;
  logic signed [31:0] first_term;

  CYBERcobra DUT(.clk_i(clk), .rst_i(rst), .sw_i(sw), .out_o(out));
  always #5 clk = ~clk;

  task automatic check_case(input integer delta, input integer number);
    integer cycles;
    logic [31:0] expected;
    begin
      // Drive inputs away from the positive edge. Reset only PC, like the board.
      @(negedge clk);
      rst = 1;
      sw = {8'(delta), 8'(number)};
      @(negedge clk);
      rst = 0;
      cycles = 0;
      while (DUT.program_counter !== 32'd52 && cycles < 1100) begin
        @(negedge clk);
        cycles++;
        // Both byte extraction instructions have completed on reaching PC=28.
        if (DUT.program_counter === 32'd28) begin
          if (DUT.rfile.rf_mem[4] !== 32'(number) ||
              DUT.rfile.rf_mem[6] !== 32'(delta))
            $fatal(1, "Byte extraction failed: sw=%h n=%h d=%h", sw,
                   DUT.rfile.rf_mem[4], DUT.rfile.rf_mem[6]);
        end
      end
      expected = first_term + (number - 1) * delta;
      if (DUT.program_counter !== 32'd52 || out !== expected)
        $fatal(1, "FAIL: a=%0d d=%0d n=%0d OUT=%h expected=%h PC=%0d",
               first_term, delta, number, out, expected, DUT.program_counter);
      repeat (3) begin
        @(negedge clk);
        if (out !== expected || DUT.program_counter !== 32'd52)
          $fatal(1, "Final output/PC did not remain stable");
      end
      tests++;
      if (tests <= 7)
        $display("PASS: a=%0d d=%0d n=%0d OUT=%0d (%h), PC=52, cycles=%0d",
                 first_term, delta, number, $signed(out), out, cycles);
    end
  endtask

  initial begin
    #1;
    // Read the configured LI constant, sign-extended independently of the CPU.
    first_term = {{9{DUT.imem.ROM[0][27]}}, DUT.imem.ROM[0][27:5]};
    check_case(2, 3);     // Assignment example: for a=1, OUT=5.
    check_case(2, 1);     // First member, no addition.
    check_case(0, 255);   // Zero step.
    check_case(128, 3);   // Signed switch input must not make d negative.
    check_case(255, 255); // Largest d and n.
    check_case(2, 0);     // Explicit extension: a0=a-d.
    check_case(255, 0);
    for (d = 0; d <= 255; d += 255)
      for (n = 0; n <= 255; n++)
        check_case(d, n);
    for (k = 0; k < 64; k++) begin
      random_state = random_state ^ (random_state << 13);
      random_state = random_state ^ (random_state >> 17);
      random_state = random_state ^ (random_state << 5);
      check_case(int'(random_state[15:8]), int'(random_state[7:0]));
    end
    $display("PASS: arithmetic progression, %0d cases, a=%0d", tests, first_term);
    $finish;
  end
endmodule
