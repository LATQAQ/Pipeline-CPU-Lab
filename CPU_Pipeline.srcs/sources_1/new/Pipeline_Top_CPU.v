`timescale 1ns / 1ps
`include "CPU_Pipeline_Header.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/01 16:42:23
// Design Name:
// Module Name: Pipeline_Top_CPU
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


module Pipeline_Top_CPU(
        input clk,
        input rst
    );

    // IF stage
    wire [`IF_ID_BUS_WIDTH-1:0] if_id_bus;
    wire inst_mem_ena;
    wire [9:0] inst_mem_addra;
    wire [31:0] inst_mem_douta;

    wire if_id_valid;
    wire id_allow_in;

    IF if_stage(
           .clk(clk),
           .rst(rst),
           .id_allow_in(id_allow_in),
           .if_id_valid(if_id_valid),
           .id_if_bus(id_if_bus),
           .if_id_bus(if_id_bus),
           .inst_mem_ena(inst_mem_ena),
           .inst_mem_addra(inst_mem_addra),
           .inst_mem_douta(inst_mem_douta)
       );

    inst_mem imem(
                 .clka(clk),
                 .ena(inst_mem_ena),
                 .addra(inst_mem_addra),
                 .douta(inst_mem_douta)
             );

    // ID stage
    wire [`ID_IF_BUS_WIDTH-1:0] id_if_bus;
    wire [`ID_EX_BUS_WIDTH-1:0] id_ex_bus;

    wire ex_allow_in;
    wire id_ex_valid;


    ID id_stage(
           .clk(clk),
           .rst(rst),
           .if_id_valid(if_id_valid),
           .ex_allow_in(ex_allow_in),
           .id_allow_in(id_allow_in),
           .id_ex_valid(id_ex_valid),
           .if_id_bus(if_id_bus),
           .wb_id_bus(wb_id_bus),
           .id_if_bus(id_if_bus),
           .id_ex_bus(id_ex_bus)
       );

    // EX stage
    wire [`EX_MEM_BUS_WIDTH-1:0] ex_mem_bus;

    wire mem_allow_in;
    wire ex_mem_valid;

    EX ex_stage(
           .clk(clk),
           .rst(rst),
           .id_ex_valid(id_ex_valid),
           .mem_allow_in(mem_allow_in),
           .ex_allow_in(ex_allow_in),
           .ex_mem_valid(ex_mem_valid),
           .id_ex_bus(id_ex_bus),
           .ex_mem_bus(ex_mem_bus)
       );

    // MEM stage
    wire [`MEM_WB_BUS_WIDTH-1:0] mem_wb_bus;
    wire data_mem_ena;
    wire [9:0] data_mem_addra;
    wire data_mem_wea;
    wire [31:0] data_mem_dina;
    wire [31:0] data_mem_douta;

    wire mem_wb_valid;
    wire wb_allow_in;

    MEM mem_stage(
            .clk(clk),
            .rst(rst),
            .ex_mem_valid(ex_mem_valid),
            .wb_allow_in(wb_allow_in),
            .mem_allow_in(mem_allow_in),
            .mem_wb_valid(mem_wb_valid),
            .ex_mem_bus(ex_mem_bus),
            .mem_wb_bus(mem_wb_bus),
            .data_mem_ena(data_mem_ena),
            .data_mem_addra(data_mem_addra),
            .data_mem_wea(data_mem_wea),
            .data_mem_dina(data_mem_dina),
            .data_mem_douta(data_mem_douta)
        );

    data_mem dmem(
                 .clka(clk),
                 .ena(data_mem_ena),
                 .wea(data_mem_wea),
                 .addra(data_mem_addra),
                 .dina(data_mem_dina),
                 .douta(data_mem_douta)
             );

    // WB stage
    wire [`WB_ID_BUS_WIDTH-1:0] wb_id_bus;

    WB wb_stage(
           .clk(clk),
           .rst(rst),
           .mem_wb_valid(mem_wb_valid),
           .wb_allow_in(wb_allow_in),
           .mem_wb_bus(mem_wb_bus),
           .wb_id_bus(wb_id_bus)
       );

endmodule
