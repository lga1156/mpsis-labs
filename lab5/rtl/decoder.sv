module decoder (
  input  logic [31:0]  fetched_instr_i,
  output logic [1:0]   a_sel_o,
  output logic [2:0]   b_sel_o,
  output logic [4:0]   alu_op_o,
  output logic [2:0]   csr_op_o,
  output logic         csr_we_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [2:0]   mem_size_o,
  output logic         gpr_we_o,
  output logic [1:0]   wb_sel_o,
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o
);
  import decoder_pkg::*;
  
  logic [4:0] opcode;
  logic [2:0] func3;
  logic [6:0] func7;
  logic [1:0] opcode_lob;

  assign func3 = fetched_instr_i[14:12];
  assign func7 = fetched_instr_i[31:25];
  assign opcode = fetched_instr_i[6:2];
  assign opcode_lob = fetched_instr_i[1:0];

  always_comb begin
    a_sel_o = OP_A_RS1;
    b_sel_o = OP_B_RS2;
    alu_op_o = ALU_ADD;
    csr_op_o = CSR_RW;
    csr_we_o = 1'b0;
    mem_req_o = 1'b0;
    mem_we_o = 1'b0;
    mem_size_o = LDST_W;
    wb_sel_o = WB_EX_RESULT;
    gpr_we_o = 1'b0;
    branch_o = 1'b0;
    jal_o = 1'b0;
    jalr_o = 1'b0;
    mret_o = 1'b0;
    illegal_instr_o = 1'b0;    

    if (opcode_lob == 2'b11) begin
      case (opcode)
        // R-type
        OP_OPCODE: begin
          gpr_we_o = 1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_RS2;
          wb_sel_o = WB_EX_RESULT;

          case (func7)
            7'd00: begin 
              case (func3)
                3'b000: alu_op_o = ALU_ADD;  // add
                3'b001: alu_op_o = ALU_SLL;  // sll
                3'b010: alu_op_o = ALU_SLTS; // slt
                3'b011: alu_op_o = ALU_SLTU; // sltu
                3'b100: alu_op_o = ALU_XOR;  // xor
                3'b101: alu_op_o = ALU_SRL;  // srl
                3'b110: alu_op_o = ALU_OR;   // or
                3'b111: alu_op_o = ALU_AND;  // and
              endcase    
            end 
            
            7'd32: begin
              case (func3)
                3'b000: alu_op_o = ALU_SUB;  // sub
                3'b101: alu_op_o = ALU_SRA;  // sra
                
                default: begin
                  gpr_we_o = 1'b0;
                  illegal_instr_o = 1'b1;
                end
              endcase
            end

            default: begin
              gpr_we_o = 1'b0;
              illegal_instr_o = 1'b1;
            end
          endcase
        end
        
        OP_IMM_OPCODE: begin
          gpr_we_o = 1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_IMM_I;
          wb_sel_o = WB_EX_RESULT;
          
          case (func3)
            3'b000: alu_op_o = ALU_ADD; // addi
            3'b001: begin 
              case (func7)
                7'd00: alu_op_o = ALU_SLL; // slli
                
                default: begin
                  gpr_we_o = 1'b0;
                  illegal_instr_o = 1'b1;
                end
              endcase
            end
            
            3'b010: alu_op_o = ALU_SLTS; // slti
            3'b011: alu_op_o = ALU_SLTU; // sltiu
            3'b100: alu_op_o = ALU_XOR; // xori
            
            3'b101: begin
              case (func7)
                7'd00: alu_op_o = ALU_SRL; // srli
                7'd32: alu_op_o = ALU_SRA; // srai
                
                default: begin
                  gpr_we_o = 1'b0;
                  illegal_instr_o = 1'b1;
                end
              endcase
            end
            
            3'b110: alu_op_o = ALU_OR; // ori
            3'b111: alu_op_o = ALU_AND;  // andi

            default: begin
              gpr_we_o = 1'b0;
              illegal_instr_o = 1'b1;
            end
          endcase
        end
         
        // I-type
        LOAD_OPCODE: begin
          gpr_we_o = 1'b1; 
          mem_req_o = 1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_IMM_I;
          alu_op_o = ALU_ADD;
          wb_sel_o = WB_LSU_DATA;

          case (func3)
            3'b000: mem_size_o = LDST_B; // lb
            3'b001: mem_size_o = LDST_H; // lh
            3'b010: mem_size_o = LDST_W; // lw
            3'b100: mem_size_o = LDST_BU; // lbu
            3'b101: mem_size_o = LDST_HU; // lhu

            default: begin
              gpr_we_o = 1'b0; 
              mem_req_o = 1'b0;
              illegal_instr_o = 1'b1;
            end
          endcase
        end

        // S-type
        STORE_OPCODE: begin
          mem_req_o = 1'b1;
          mem_we_o = 1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_IMM_S;
          alu_op_o = ALU_ADD;

          case (func3)
            3'b000: mem_size_o = LDST_B; // sb
            3'b001: mem_size_o = LDST_H; // sh
            3'b010: mem_size_o = LDST_W; // sw

            default: begin
              mem_req_o = 1'b0;
              mem_we_o = 1'b0;
              illegal_instr_o = 1'b1;
            end
          endcase
        end

        // B-type
        BRANCH_OPCODE: begin
          branch_o = 1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_RS2;
          
          case (func3)
            3'b000: alu_op_o = ALU_EQ;  // beq
            3'b001: alu_op_o = ALU_NE;  // bne
            3'b100: alu_op_o = ALU_LTS; // blt
            3'b101: alu_op_o = ALU_GES; // bge
            3'b110: alu_op_o = ALU_LTU; // bltu
            3'b111: alu_op_o = ALU_GEU; // bgeu

            default: begin
              branch_o = 1'b0;
              illegal_instr_o = 1'b1;
            end
          endcase
        end

        // J-type (jal instruction)
        JAL_OPCODE: begin
          jal_o = 1'b1;
          gpr_we_o = 1'b1;

          a_sel_o = OP_A_CURR_PC;
          b_sel_o = OP_B_INCR;
          alu_op_o = ALU_ADD;
          wb_sel_o = WB_EX_RESULT;
        end

        // I-type (jalr instruction)
        JALR_OPCODE: begin
          case (func3)
            3'b000: begin
              jalr_o = 1'b1;
              gpr_we_o = 1'b1;

              a_sel_o = OP_A_CURR_PC;
              b_sel_o = OP_B_INCR;
              alu_op_o = ALU_ADD;
              wb_sel_o = WB_EX_RESULT;
            end
            
            default: illegal_instr_o = 1'b1;
          endcase
        end

        // U-type (lui instruction)
        LUI_OPCODE: begin
          gpr_we_o = 1'b1;
          a_sel_o = OP_A_ZERO;
          b_sel_o = OP_B_IMM_U;
          alu_op_o = ALU_ADD;
          wb_sel_o = WB_EX_RESULT;
        end

        // U-type (auipc instruction)
        AUIPC_OPCODE: begin
          gpr_we_o = 1'b1;
          a_sel_o = OP_A_CURR_PC;
          b_sel_o = OP_B_IMM_U;
          alu_op_o = ALU_ADD;
          wb_sel_o = WB_EX_RESULT;
        end
        
        // fence instruction
        MISC_MEM_OPCODE: begin
          case (func3)
            3'b000: illegal_instr_o = 1'b0;
            
            default: illegal_instr_o = 1'b1;
          endcase
        end

        SYSTEM_OPCODE: begin
          case (fetched_instr_i)
            32'h00000073: illegal_instr_o = 1'b1; // ecall
            32'h00100073: illegal_instr_o = 1'b1; // ebreak
            32'h30200073: mret_o = 1'b1;          // mret

            default: begin
              csr_we_o = 1'b1;
              gpr_we_o = 1'b1;
              wb_sel_o = WB_CSR_DATA;

              case (func3)
                3'b001: csr_op_o = CSR_RW;  // csrrw
                3'b010: csr_op_o = CSR_RS;  // csrrs
                3'b011: csr_op_o = CSR_RC;  // csrrc
                3'b101: csr_op_o = CSR_RWI; // csrrwi
                3'b110: csr_op_o = CSR_RSI; // csrrsi
                3'b111: csr_op_o = CSR_RCI; // csrrci

                default: begin
                  csr_we_o = 1'b0;
                  gpr_we_o = 1'b0;
                  illegal_instr_o = 1'b1;
                end
              endcase 
            end
          endcase
        end

        default: illegal_instr_o = 1'b1;
      endcase
    end else begin
      csr_we_o = 1'b0;
      mem_req_o = 1'b0;
      mem_we_o = 1'b0;
      gpr_we_o = 1'b0;
      branch_o = 1'b0;
      jal_o = 1'b0;
      jalr_o = 1'b0;
      mret_o = 1'b0;
      illegal_instr_o = 1'b1;
    end
  end
endmodule
