`timescale 1ns / 1ps
`include "CPU_Pipeline_Header.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/01 15:55:58
// Design Name:
// Module Name: MEM
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


module MEM(
        input wire clk,
        input wire rst,

        // pipeline control
        input ex_mem_valid,
        input wb_allow_in,
        output mem_allow_in,
        output mem_wb_valid,

        // RAW hazard
        input [`MEM_ID_BUS_WIDTH-1:0] mem_id_bus,

        // bus from EX
        input  [`EX_MEM_BUS_WIDTH-1:0] ex_mem_bus,
        // bus to WB
        output [`MEM_WB_BUS_WIDTH-1:0] mem_wb_bus,

        // data_mem interface
        input  [31:0] data_mem_douta
    );

    // pipeline registers
    reg [`EX_MEM_BUS_WIDTH-1:0] mem_reg;
    wire [31:0] mem_pc;
    wire [31:0] mem_alu_result;
    wire [4:0] mem_waddr;
    wire mem_mem_to_reg;
    wire mem_reg_write;
    wire mem_mem_write;
    assign {mem_pc, mem_alu_result, mem_waddr,
            mem_mem_to_reg, mem_reg_write, mem_mem_write} = mem_reg;

    // output mem_wb_bus
    wire [31:0] mem_rdata;
    wire [31:0] mem_final_result;
    assign mem_wb_bus = {mem_pc, mem_final_result, mem_waddr,mem_reg_write};

    // pipeline control
    reg mem_valid;
    wire mem_ready_go;

    assign mem_ready_go = 1'b1;
    assign mem_allow_in = ~mem_valid | (mem_ready_go & wb_allow_in);
    assign mem_wb_valid = mem_valid & mem_ready_go;

    // output mem_id_bus
    assign mem_id_bus = {mem_reg_write, mem_waddr, mem_valid, mem_final_result};

    always @(posedge clk) begin
        if (rst) begin
            mem_valid <= 1'b0;
        end
        else if (mem_allow_in) begin
            mem_valid <= ex_mem_valid;
        end
    end

    always @(posedge clk) begin
        if (mem_allow_in & ex_mem_valid) begin
            mem_reg <= ex_mem_bus;
        end
    end

    // MEM stage
    assign mem_rdata = data_mem_douta;
    assign mem_final_result = mem_mem_to_reg ? mem_rdata : mem_alu_result;

endmodule
