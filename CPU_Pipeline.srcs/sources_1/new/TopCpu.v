`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 15:36:37
// Design Name: 
// Module Name: TopCpu
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


module TopCpu(
    input clk,
    input rst
    );

    // PC
    wire [31:0] pc, _pc, pc_plus4, branch_addr, jump_addr;
    PC pc_reg(
        .clk(clk),
        .rst(rst),
        ._pc(_pc),
        .pc(pc)
    );
    assign pc_plus4 = pc + 4;
    
    // Instruction Memory
    wire [31:0] instr;
    Imem imem(
        .clk(clk),
        .rst(rst),
        .addr(pc),
        .idata(instr)
    );
    
    // Control Unit
    wire reg_dst, mem_to_reg, reg_write, mem_write, reg31, signext;
    wire [4:0] alu_control;
    wire [1:0] alu_src;
    Control control(
        .opcode(instr[31:26]),
        .funct(instr[5:0]),
        .reg_dst(reg_dst),
        .reg31(reg31),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_control(alu_control),
        .signext(signext)
    );

    // Immediate Extension
    wire [15:0] imm;
    wire [31:0] imm_ext;
    assign imm = instr[15:0];
    assign imm_ext = signext ? {{16{imm[15]}}, imm} : {16'b0, imm};

    // Register File
    wire [4:0] rs, rt, rd, write_reg;
    wire [31:0] read_data1, read_data2, write_data;
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    assign write_reg = reg31 ? 5'b11111 : (reg_dst ? rd : rt);

    Regfile regfile(
        .clk(clk),
        .rst(rst),
        .we(reg_write),
        .ra1(rs),
        .ra2(rt),
        .wa(write_reg),
        .wd(write_data),
        .rd1(read_data1),
        .rd2(read_data2)
    );

    // ALU
    wire [31:0] alu_src2;
    wire [31:0] alu_result;
    wire [4:0] shamt = instr[10:6];

    function [31:0] getALUSrc2;
        input alu_src;
        input [31:0] read_data2;
        input [31:0] imm_ext;
        input [4:0] shamt;
        begin
            case (alu_src)
                2'b00: getALUSrc2 = read_data2; // register
                2'b01: getALUSrc2 = imm_ext;    // immediate
                2'b10: getALUSrc2 = {27'b0, shamt}; // shamt
                default: getALUSrc2 = read_data2; // default
            endcase
        end
    endfunction
    assign alu_src2 = getALUSrc2(alu_src, read_data2, imm_ext, shamt);

    ALU alu(
        .ALUCtrl(alu_control),
        .SrcA(read_data1),
        .SrcB(alu_src2),
        .ALUResult(alu_result)
    );

    // Data Memory
    wire [31:0] mem_read_data;
    Dmem dmem(
        .clk(clk),
        .rst(rst),
        .we(mem_write),
        .addr(alu_result),
        .wdata(read_data2),
        .rdata(mem_read_data)
    );
    
    // Branch Unit
    wire take_branch, link_en;
    wire [31:0] link_addr;
    BrUnit br_unit(
        .pc(pc),
        .rs_val(read_data1),
        .rt_val(read_data2),
        .imm(imm),
        .jaddr(instr[25:0]),
        .opcode(instr[31:26]),
        .next_pc(_pc),
        .take_branch(take_branch),
        .link_addr(link_addr),
        .link_en(link_en)
    );

    // Write Back
    assign write_data = (link_en) ? link_addr : (mem_to_reg ? mem_read_data : alu_result);

endmodule
