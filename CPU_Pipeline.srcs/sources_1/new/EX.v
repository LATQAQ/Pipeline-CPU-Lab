`timescale 1ns / 1ps
`include "CPU_Pipeline_Header.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/01 15:55:58
// Design Name:
// Module Name: EX
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


module EX(
        input wire clk,
        input wire rst,

        // pipeline control
        input id_ex_valid,
        input mem_allow_in,
        output ex_allow_in,
        output ex_mem_valid,

        // bus from ID
        input  [`ID_EX_BUS_WIDTH-1:0] id_ex_bus,
        // bus to MEM
        output [`EX_MEM_BUS_WIDTH-1:0] ex_mem_bus
    );

    // pipeline registers
    reg [`ID_EX_BUS_WIDTH-1:0] ex_reg;
    wire [31:0] ex_pc;
    wire [4:0] ex_alu_control;
    wire [1:0] ex_alu_src;
    wire ex_reg_dst;
    wire ex_reg31;
    wire ex_link_en;
    wire [31:0] ex_link_addr;
    wire ex_mem_to_reg;
    wire ex_reg_write;
    wire ex_mem_write;
    wire [31:0] ex_rd1;
    wire [31:0] ex_rd2;
    wire [31:0] ex_imm;
    wire [4:0] ex_rs;
    wire [4:0] ex_rt;
    wire [4:0] ex_rd;
    assign {ex_pc, ex_alu_control, ex_alu_src, ex_reg_dst, ex_reg31,
            ex_link_en, ex_link_addr, ex_mem_to_reg, ex_reg_write, ex_mem_write,
            ex_rd1, ex_rd2, ex_imm, ex_rs, ex_rt, ex_rd} = ex_reg;

    // output ex_mem_bus
    wire [31:0] ex_alu_result;
    wire [31:0] ex_wdata;
    wire [4:0] ex_waddr;
    assign ex_mem_bus = {ex_pc, ex_alu_result, ex_wdata, ex_waddr,
                         ex_mem_to_reg, ex_reg_write, ex_mem_write};

    // pipeline control
    reg ex_valid;
    wire ex_ready_go;

    assign ex_ready_go = 1'b1;
    assign ex_allow_in = ~ex_valid | (ex_ready_go & mem_allow_in);
    assign ex_mem_valid = ex_valid & ex_ready_go;

    always @(posedge clk) begin
        if (rst) begin
            ex_valid <= 1'b0;
        end
        else if (ex_allow_in) begin
            ex_valid <= id_ex_valid;
        end
    end

    always @(posedge clk) begin
        if (ex_allow_in & id_ex_valid) begin
            ex_reg <= id_ex_bus;
        end
    end

    // internal signals
    wire [31:0] ex_alu_src2;

    // EX stage
    function [31:0] getALUInput;
        input [1:0] alu_src;
        input [31:0] rd;
        input [31:0] imm;
        begin
            case (alu_src)
                2'b00:
                    getALUInput = rd;
                2'b01:
                    getALUInput = imm;
                2'b10:
                    getALUInput = 32'h0000_0004;
                default:
                    getALUInput = rd;
            endcase
        end
    endfunction
    assign ex_alu_src2 = getALUInput(ex_alu_src, ex_rd2, ex_imm);

    ALU alu(
            .ALUCtrl(ex_alu_control),
            .SrcA(ex_rd1),
            .SrcB(ex_alu_src2),
            .ALUResult(ex_alu_result)
        );
    assign ex_wdata = ex_rd2;
    assign ex_waddr = ex_reg31 ? 5'b11111 : (ex_reg_dst ? ex_rd : ex_rt);

endmodule
