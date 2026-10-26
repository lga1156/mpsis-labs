module CYBERcobra (
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic [15:0]  sw_i,
  output logic [31:0]  out_o
);
  
  logic [31:0] program_counter; // Адрес инструкции в памяти инструкций
  logic [31:0] modified_pc; // РС следующей операции (+4)
  logic [31:0] read_data1, read_data2;
  logic [31:0] write_data; // Данные записываемые в регистровую память 
                           // (константа/результат вычислений)
  logic [31:0] second_term;
  logic [31:0] alu_result;
  logic [31:0] instruction;
  logic        flag;
  logic        transition_condition;
  
  // Код инструкции
  logic       branch;
  logic       jump;
  logic [1:0] write_source;
  logic [4:0] alu_op;
  logic [4:0] write_addr;
  logic [4:0] read_addr1, read_addr2;
  logic [7:0] offset_const;
  logic [22:0] rf_const;
  
  assign jump = instruction[31];
  assign branch = instruction[30];
  assign write_source = instruction[29:28];
  assign alu_op = instruction[27:23];
  assign read_addr1 = instruction[22:18];
  assign read_addr2 = instruction[17:13];
  assign offset_const = instruction[12:5];
  assign write_addr = instruction[4:0];
  assign rf_const = instruction[27:5];
  
  instr_mem imem (
    .read_addr_i(program_counter),
    .read_data_o(instruction)
  );
  
  fulladder32 f32 (
    .a_i(program_counter),
    .b_i(second_term),
    .carry_i(1'b0),
    .sum_o(modified_pc)
  );
  
  register_file rfile (
    .clk_i(clk_i),
    .write_enable_i(~(branch | jump)),
    
    .write_data_i(write_data),
    .read_addr1_i(read_addr1),
    .read_addr2_i(read_addr2),
    .write_addr_i(write_addr),
    
    .read_data1_o(read_data1),
    .read_data2_o(read_data2)
  );
  
  alu alu(
    .a_i(read_data1),
    .b_i(read_data2),
    .alu_op_i(alu_op),
    .flag_o(flag),
    .result_o(alu_result)
  );
  
  always_comb begin
    case(write_source)
      2'b00: write_data = {{9{instruction[27]}}, rf_const}; // Знакорасширенная константа
      2'b01: write_data = alu_result;
      2'b10: write_data = {{16{sw_i[15]}}, sw_i};
      
      default: write_data = 32'b0;
    endcase
  end
  
  assign transition_condition = (branch && flag) | jump;
  
  always_comb begin
    if(transition_condition)
      second_term = {{22{instruction[12]}}, offset_const, 2'b0};
    else
      second_term = 32'b100;
  end
  
  always_ff @(posedge clk_i) begin
    if(rst_i) begin
      program_counter <= 32'b0;
    end else begin
      program_counter <= modified_pc;
    end
  end
  
  assign out_o = read_data1;
  
endmodule