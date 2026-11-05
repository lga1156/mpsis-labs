`timescale 1ns/1ps
module tb_progression;
  logic clk = 0;
  logic rst = 1;
  always #5 clk = ~clk;
  riscv_unit dut (.clk_i(clk), .rst_i(rst));

  // Удобные сигналы для временной диаграммы: реальные ячейки ОЗУ.
  int case_id = 0;
  wire [31:0] a = dut.datamem.ram[0];
  wire [7:0] d = dut.datamem.ram[1][15:8];
  wire [7:0] n = dut.datamem.ram[1][7:0];
  wire [31:0] result = dut.datamem.ram[2];

  // Каждый пример занимает 400 нс: сброс, выполнение, пауза с ответом.
  task automatic demo(input int id, input int step_d,
                      input int number_n, input logic [31:0] expected);
    case_id = id;
    rst = 1;
    repeat (3) @(negedge clk);
    // Первый пример использует исходный data.mem без перезаписи.
    if (id != 1) begin
      dut.datamem.ram[0] = 32'd1;
      dut.datamem.ram[1] = (step_d << 8) | number_n;
      dut.datamem.ram[2] = 32'd0;
    end
    rst = 0;
    repeat (27) @(negedge clk);
    if (dut.IM_A !== 32'h34 || result !== expected)
      $fatal(1, "FAIL case=%0d result=%h expected=%h PC=%h",
             id, result, expected, dut.IM_A);
    $display("PASS: case=%0d a=%0d d=%0d n=%0d result=%0d PC=0x34",
             id, a, d, n, result);
    repeat (10) @(negedge clk);
    if (dut.IM_A !== 32'h34 || result !== expected)
      $fatal(1, "Result changed during final loop");
  endtask

  initial begin
    demo(1,   2, 3,   5);  // Пример из задания: 1, 3, 5.
    demo(2,   2, 1,   1);  // Первый член: цикл сложений пропускается.
    demo(3, 128, 3, 257);  // d беззнаковое: 1, 129, 257.
    $display("PASS: 3 demonstration cases");
    $finish;
  end
endmodule
