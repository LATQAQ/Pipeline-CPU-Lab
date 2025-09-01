`timescale 1ns / 1ps
`include "CPU_Pipeline_Header.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/01 15:55:58
// Design Name:
// Module Name: IF
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


module IF(
        input wire clk,
        input wire rst,

        // bus from ID
        input  [`ID_IF_BUS_WIDTH-1:0] id_if_bus,
        // bus to ID
        output [`IF_ID_BUS_WIDTH-1:0] if_id_bus,

        // inst_mem interface
        output       inst_mem_ena,
        output [9:0] inst_mem_addra,
        input  [31:0] inst_mem_douta
    );

    // decode id_if_bus
    wire id_br_taken;
    wire [31:0] id_br_target;
    assign {id_br_taken, id_br_target} = id_if_bus;

    // output if_id_bus
    reg [31:0] if_pc;
    wire [31:0] if_inst;
    assign if_id_bus = {if_pc, if_inst};

    // internal signals
    wire [31:0] pc_plus4, next_pc;

    // IF stage

    assign pc_plus4 = if_pc + 32'h0000_0004;
    assign next_pc = id_br_taken ? id_br_target : pc_plus4;

    always @(posedge clk) begin
        if (rst) begin
            if_pc <= 32'h0000_0000;
        end
        else begin
            if_pc <= next_pc;
        end
    end

    // inst_mem interface
    assign inst_mem_ena = ~rst;
    assign inst_mem_addra = if_pc[11:2]; // word aligned
    assign if_inst = inst_mem_douta;

endmodule
