`timescale 1ns / 1ps
`include "CPU_Pipeline_Header.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/01 15:55:58
// Design Name:
// Module Name: WB
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


module WB(
        input wire clk,
        input wire rst,

        // bus from MEM
        input  [`MEM_WB_BUS_WIDTH-1:0] mem_wb_bus,
        // bus to ID
        output [`WB_ID_BUS_WIDTH-1:0] wb_id_bus
    );

    // pipeline registers
    reg [`MEM_WB_BUS_WIDTH-1:0] wb_reg;
    wire [31:0] wb_pc;
    wire [31:0] wb_final_result;
    wire [4:0] wb_waddr;
    wire wb_reg_write;
    assign {wb_pc, wb_final_result, wb_waddr, wb_reg_write} = wb_reg;

    // output wb_id_bus
    assign wb_id_bus = {wb_reg_write, wb_waddr, wb_final_result};

    always @(posedge clk) begin
        begin
            wb_reg <= mem_wb_bus;
        end
    end

endmodule
