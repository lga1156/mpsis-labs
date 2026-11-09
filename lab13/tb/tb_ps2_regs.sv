`timescale 1ns/1ps
module tb_ps2_regs;
logic clk=0,rst=1,kc=1,kd=1,req=0,we=0,ret=0,irq;
logic [31:0] addr=0,wd=0,rd;
always #50 clk=~clk;
ps2_sb_ctrl dut(.clk_i(clk),.rst_i(rst),.kclk_i(kc),.kdata_i(kd),.req_i(req),.write_enable_i(we),.interrupt_return_i(ret),.addr_i(addr),.write_data_i(wd),.read_data_o(rd),.interrupt_request_o(irq));
task send(input logic [7:0] code);
 logic [10:0] frame;frame={1'b1,~^code,code,1'b0};
 for(int i=0;i<11;i++) begin kd=frame[i];#15000;kc=0;#15000;kc=1;end
 kd=1;#10000;
endtask
task read_reg(input logic [31:0] a,d);
 @(negedge clk);addr=a;req=1;we=0;
 @(posedge clk);#1;if(rd!==d) $fatal(1,"PS2 register mismatch");
 @(negedge clk);req=0;
endtask
initial begin
 #1000;rst=0;#10000;
 send('h1c);if(!irq) $fatal(1,"missing IRQ");
 read_reg(4,1);if(!irq) $fatal(1,"status read cleared IRQ");
 read_reg(0,'h1c);if(irq) $fatal(1,"data read did not clear IRQ");
 send('h32);@(negedge clk);ret=1;@(negedge clk);ret=0;
 if(irq) $fatal(1,"return did not clear IRQ");
 send('h21);@(negedge clk);addr='h24;wd=1;req=1;we=1;
 @(negedge clk);req=0;we=0;
 read_reg(4,0);read_reg(0,0);
 $display("PASS: PS2 status, read-to-clear, interrupt return and software reset");$finish;
end
endmodule
