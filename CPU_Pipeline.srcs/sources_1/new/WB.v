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

        // pipeline control
        input mem_wb_valid,
        output wb_allow_in,

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
    wire wb_reg_we;
    assign wb_id_bus = {wb_reg_we, wb_waddr, wb_final_result};

    // pipeline control
    reg wb_valid;
    wire wb_ready_go;

    assign wb_ready_go = 1'b1;
    assign wb_allow_in = ~wb_valid | wb_ready_go;

    always @(posedge clk) begin
        if (rst) begin
            wb_valid <= 1'b0;
        end
        else if (wb_allow_in) begin
            wb_valid <= mem_wb_valid;
        end
    end

    always @(posedge clk) begin
        if (wb_allow_in & mem_wb_valid) begin
            wb_reg <= mem_wb_bus;
        end
    end

    assign wb_reg_we = wb_valid & wb_reg_write;

endmodule
