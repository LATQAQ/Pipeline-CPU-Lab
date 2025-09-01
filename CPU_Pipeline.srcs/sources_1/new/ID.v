`timescale 1ns / 1ps
`include "CPU_Pipeline_Header.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/01 15:55:58
// Design Name:
// Module Name: ID
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ID(
        input wire clk,
        input wire rst,

        // bus from IF
        input  [`IF_ID_BUS_WIDTH-1:0] if_id_bus,
        // bus from WB
        input [`WB_ID_BUS_WIDTH-1:0] wb_id_bus
        // bus to IF
        output [`ID_IF_BUS_WIDTH-1:0] id_if_bus,
        // bus to EX
        output [`ID_EX_BUS_WIDTH-1:0] id_ex_bus
    );

    // pipeline registers
    reg [`IF_ID_BUS_WIDTH-1:0] id_reg;
    wire [31:0] id_pc;
    wire [31:0] id_inst;
    assign {id_pc, id_inst} = id_reg;

    // decode wb_id_bus
    wire wb_reg_write;
    wire [4:0] wb_waddr;
    wire [31:0] wb_final_result;
    assign {wb_reg_write, wb_waddr, wb_final_result} = wb_id_bus;

    // output id_ex_bus
    wire id_alu_control;
    wire [1:0] id_alu_src;
    wire id_reg_dst;
    wire id_reg31;
    wire id_link_en;
    wire [31:0] id_link_addr;
    wire id_mem_to_reg;
    wire id_reg_write;
    wire id_mem_write;
    wire id_sign_ext;
    wire [31:0] id_rd1;
    wire [31:0] id_rd2;
    wire [31:0] id_imm;
    wire [4:0] id_rs;
    wire [4:0] id_rt;
    wire [4:0] id_rd;
    assign id_ex_bus = {
               id_pc,
               id_alu_control,
               id_alu_src,
               id_reg_dst,
               id_reg31,
               id_link_en,
               id_link_addr,
               id_mem_to_reg,
               id_reg_write,
               id_mem_write,
               id_rd1,
               id_rd2,
               id_imm,
               id_rs,
               id_rt,
               id_rd
           };

    // output id_if_bus
    wire id_br_taken;
    wire [31:0] id_br_target;
    assign id_if_bus = {id_br_taken, id_br_target};

    always @(posedge clk) begin
        begin
            id_reg <= if_id_bus;
        end
    end

    // internal signals
    wire [31:0] id_pc_plus4;
    wire [5:0] id_opcode;
    wire [5:0] id_funct;
    wire [4:0] id_shamt;
    wire [15:0] id_imm16;
    wire [25:0] id_addr26;
    wire [31:0] id_br_offset;
    wire [31:0] id_jump_addr;

    wire inst_rtype;
    wire inst_lw;
    wire inst_sw;
    wire inst_beq;
    wire inst_bne;
    wire inst_addi;
    wire inst_ori;
    wire inst_lui;
    wire inst_j;
    wire inst_jal;
    wire inst_jr;
    wire inst_jalr;

    wire inst_add;
    wire inst_addu;
    wire inst_sub;
    wire inst_subu;
    wire inst_and;
    wire inst_or;
    wire inst_slt;
    wire inst_sll;

    // ID stage
    assign id_pc_plus4 = id_pc + 32'h0000_0004;
    assign id_opcode = id_inst[31:26];
    assign id_funct = id_inst[5:0];
    assign id_shamt = id_inst[10:6];
    assign id_imm16 = id_inst[15:0];
    assign id_addr26 = id_inst[25:0];
    assign id_rs = id_inst[25:21];
    assign id_rt = id_inst[20:16];
    assign id_rd = id_inst[15:11];
    assign id_br_offset = {{14{id_imm16[15]}}, id_imm16, 2'b00};
    assign id_jump_addr = {id_pc_plus4[31:28], id_addr26, 2'b00};

    // instruction type decoding
    assign inst_rtype = (id_opcode == 6'b000000);
    assign inst_lw = (id_opcode == 6'b100011);
    assign inst_sw = (id_opcode == 6'b101011);
    assign inst_beq = (id_opcode == 6'b000100);
    assign inst_bne = (id_opcode == 6'b000101);
    assign inst_addi = (id_opcode == 6'b001000);
    assign inst_ori = (id_opcode == 6'b001101);
    assign inst_lui = (id_opcode == 6'b001111);
    assign inst_j = (id_opcode == 6'b000010);
    assign inst_jal = (id_opcode == 6'b000011);
    assign inst_jr = (inst_rtype & (id_funct == 6'b001000));
    assign inst_jalr = (inst_rtype & (id_funct == 6'b001001));

    assign inst_add = (inst_rtype & (id_funct == 6'b100000));
    assign inst_addu = (inst_rtype & (id_funct == 6'b100001));
    assign inst_sub = (inst_rtype & (id_funct == 6'b100010));
    assign inst_subu = (inst_rtype & (id_funct == 6'b100011));
    assign inst_and = (inst_rtype & (id_funct == 6'b100100));
    assign inst_or = (inst_rtype & (id_funct == 6'b100101));
    assign inst_slt = (inst_rtype & (id_funct == 6'b101010));
    assign inst_sll = (inst_rtype & (id_funct == 6'b000000));

    // control signal
    assign id_reg_dst = inst_rtype;
    assign id_reg31 = inst_jal | inst_jalr;
    assign id_mem_to_reg = inst_lw;
    assign id_reg_write = inst_rtype | inst_lw | inst_addi | inst_ori | inst_lui | inst_jal | inst_jalr;
    assign id_mem_write = inst_sw;
    assign id_sign_ext = inst_lw | inst_sw | inst_addi | inst_beq | inst_bne;
    assign id_imm = id_sign_ext ? {{16{id_imm16[15]}}, id_imm16} : {16'b0, id_imm16};

    function [1:0] getALUSrc;
        input inst_lw, inst_sw, inst_addi, inst_ori, inst_lui, inst_rtype;
        input [5:0] funct;
        begin
            if (inst_lw | inst_sw | inst_addi | inst_ori | inst_lui) begin
                getALUSrc = 2'b01; // immediate
            end
            else if (inst_rtype) begin
                if (funct == 6'b000000) begin
                    getALUSrc = 2'b10; // shamt
                end
                else begin
                    getALUSrc = 2'b00; // register
                end
            end
            else begin
                getALUSrc = 2'b00; // default
            end
        end
    endfunction
    assign id_alu_src = getALUSrc(inst_lw, inst_sw, inst_addi, inst_ori, inst_lui, inst_rtype, id_funct);

    function [4:0] getALUCtrl;
        input [5:0] funct;
        input inst_lw, inst_sw, inst_addi, inst_ori, inst_lui, inst_beq, inst_bne, inst_rtype;
        begin
            if (inst_rtype) begin
                case (funct)
                    6'b100000:
                        getALUCtrl = 5'b00010; // ADD
                    6'b100001:
                        getALUCtrl = 5'b00010; // ADDU
                    6'b100010:
                        getALUCtrl = 5'b00110; // SUB
                    6'b100011:
                        getALUCtrl = 5'b00110; // SUBU
                    6'b100100:
                        getALUCtrl = 5'b00000; // AND
                    6'b100101:
                        getALUCtrl = 5'b00001; // OR
                    6'b101010:
                        getALUCtrl = 5'b00111; // SLT
                    6'b000000:
                        getALUCtrl = 5'b00011; // SLL
                    default:
                        getALUCtrl = 5'bxxxxx; // default
                endcase
            end
            else if (inst_lw | inst_sw | inst_addi) begin
                getALUCtrl = 5'b00010; // ADD
            end
            else if (inst_ori) begin
                getALUCtrl = 5'b00001; // OR
            end
            else if (inst_lui) begin
                getALUCtrl = 5'b01000; // LUI
            end
            else if (inst_beq | inst_bne) begin
                getALUCtrl = 5'b00110; // SUB
            end
            else begin
                getALUCtrl = 5'bxxxxx; // default
            end
        end
    endfunction
    assign id_alu_control = getALUCtrl(id_funct, inst_lw, inst_sw, inst_addi, inst_ori, inst_lui, inst_beq, inst_bne, inst_rtype);

    // Register File
    wire [31:0] id_rd1, id_rd2;
    Regfile regfile(
                .clk(clk),
                .rst(rst),
                .we(wb_reg_write),
                .ra1(id_rs),
                .ra2(id_rt),
                .wa(wb_waddr),
                .wd(wb_final_result),
                .rd1(id_rd1),
                .rd2(id_rd2)
            );

    // Branch Decision
    assign id_br_taken = (inst_beq & (id_rd1 == id_rd2)) |
           (inst_bne & (id_rd1 != id_rd2)) |
           inst_j | inst_jal | inst_jr | inst_jalr;

    assign id_br_target = (inst_beq | inst_bne) ? (id_pc_plus4 + id_br_offset) :
           (inst_j | inst_jal) ? id_jump_addr :
           (inst_jr | inst_jalr) ? id_rd1 :
           32'b0;

    assign id_link_en = inst_jal | inst_jalr;
    assign id_link_addr = id_pc_plus4;

endmodule
