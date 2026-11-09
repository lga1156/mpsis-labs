`timescale 1ns/1ps
module tb_vga_bus;
logic clk=0, clk100=0, rst=1, req=0, we=0;
logic [3:0] be=0;
logic [31:0] addr=0, wd=0, rd;
always #50 clk=~clk;
always #5 clk100=~clk100;
vga_sb_ctrl dut(.clk_i(clk),.rst_i(rst),.clk100m_i(clk100),.req_i(req),.write_enable_i(we),.mem_be_i(be),.addr_i(addr),.write_data_i(wd),.read_data_o(rd));
task write_word(input logic [31:0] a,d,input logic [3:0] b,input logic selected);
 @(negedge clk); addr=a;wd=d;be=b;we=1;req=selected;
 @(negedge clk); we=0;req=0;
endtask
task check_word(input logic [31:0] a,d);
 @(negedge clk);addr=a;req=1;we=0;
 @(posedge clk);#1;
 if(rd !== d) $fatal(1,"VGA read %h expected %h got %h",a,d,rd);
 @(negedge clk);req=0;
endtask
initial begin
 #1000;rst=0;
 write_word(0,32'h12345678,15,1);
 write_word(0,32'hffffffff,15,0);
 check_word(0,32'h12345678);
 write_word(0,32'h00ab0000,4,1);
 check_word(0,32'h12ab5678);
 write_word('h1000,32'hf0e0d0c0,15,1);
 check_word('h1000,32'hf0e0d0c0);
 write_word('h2ff0,32'h11223344,15,1);
 write_word('h2ffc,32'haabbccdd,15,1);
 check_word('h2ff0,32'h11223344);
 check_word('h2ffc,32'haabbccdd);
 check_word(0,32'h12ab5678);
 $display("PASS: VGA selection, byte mask, synchronous reads, color and font including character 255");$finish;
end
endmodule
