`timescale 1ns/1ps
module tb_ps2_vga;
logic clk=0, resetn=0, kc=1, kd=1;
bit test_done=0;
initial begin
 while (!test_done) begin #5; clk=~clk; end
end
riscv_unit dut(.clk_i(clk),.resetn_i(resetn),.sw_i(16'b0),.kclk_i(kc),.kdata_i(kd),.rx_i(1'b1));
time last_hs=0, last_vs=0;
int hs_periods=0, vs_periods=0;
always @(negedge dut.vga_hs_o) if (!dut.rst) begin
 if (last_hs && ($time-last_hs)!=32000) $fatal(1,"HS period");
 last_hs=$time; hs_periods++;
end
always @(negedge dut.vga_vs_o) if (!dut.rst) begin
 if (last_vs && ($time-last_vs)!=16800000) $fatal(1,"VS period");
 last_vs=$time; vs_periods++;
end
int traps=0, returns=0, reads=0, writes=0;
logic [31:0] saved_pc;
always @(posedge dut.sysclk) if (!dut.rst) begin
 if (dut.core.irq) begin
   traps++;
   saved_pc=dut.core.pc;
   $display("TRAP pc=%h mtvec=%h",saved_pc,dut.core.mtvec);
 end
 if (dut.ps2_req && !dut.lsu_mem_we) reads++;
 if (dut.vga_req && dut.lsu_mem_we) begin
   writes++;
   $display("VGA addr=%h data=%h be=%b",dut.lsu_mem_addr,dut.lsu_mem_wd,dut.lsu_mem_be);
 end
 if (!dut.vga_req && (|dut.vga.we)) $fatal(1,"VGA write without selection");
 if (dut.irq_ret) begin
   returns++;
   if (dut.core.mepc !== saved_pc) $fatal(1,"mepc mismatch");
   $display("MRET mepc=%h",dut.core.mepc);
 end
end
task send(input logic [7:0] code);
 logic [10:0] frame;
 frame={1'b1,~^code,code,1'b0};
 for(int i=0;i<11;i++) begin
   kd=frame[i]; #15000; kc=0; #15000; kc=1;
 end
 kd=1; #20000;
endtask
initial begin
 if ($test$plusargs("trace")) begin $dumpfile("wave.vcd"); $dumpvars(0,tb_ps2_vga); end
 #1000; resetn=1; #20000;
 if (dut.core.pc !== 'h20 || dut.core.mie !== 'h10000) $fatal(1,"startup failed");
 send('h1c); send('h32); send('h21);
 #10000;
 if (dut.vga.vga.ch_map.mem[0][23:0] !== 24'h636261) $fatal(1,"expected abc, got %h",dut.vga.vga.ch_map.mem[0]);
 if (traps!=3 || returns!=3 || writes!=6 || reads<3) $fatal(1,"bad counts");
 if (dut.irq_req || dut.core.pc !== 'h20) $fatal(1,"did not return to idle");
 send('hf0); send('h1c);
 if (traps!=5 || returns!=5 || writes!=10) $fatal(1,"break sequence counts");
 if (dut.vga.vga.ch_map.mem[0][31:24] !== 8'h00 || dut.vga.vga.ch_map.mem[1][7:0] !== 8'h61) $fatal(1,"break behavior");
 #34000000;
 if (hs_periods<1000 || vs_periods<2) $fatal(1,"VGA timing not exercised");
 $display("PASS: PS2 break sequence F0,1C produces NUL,a as official firmware specifies; VGA HS=32us VS=16.8ms");
 $display("PASS: abc in VGA RAM; 3 traps, PS2 reads, VGA store instructions (6 bus cycles) and mret; IRQ cleared");
 test_done=1;
 $finish;
end
initial begin #40000000; if (!test_done) $fatal(1,"timeout"); end
endmodule
