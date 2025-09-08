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

        // pipeline control
        input id_allow_in,
        output if_id_valid,

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
    wire        id_br_taken;
    wire [31:0] id_br_target;
    wire        id_br_cancel;
    assign {id_br_taken, id_br_target, id_br_cancel} = id_if_bus;
    

    // output if_id_bus
    reg [31:0] if_pc;
    wire [31:0] if_inst;
    assign if_id_bus = {if_pc, if_inst};

    // pipeline control
    reg if_valid;
    wire pre_if_valid;
    wire if_allow_in;
    wire if_ready_go;

    always @(posedge clk) begin
        if (rst) begin
            if_valid <= 1'b0;
        end
        else if (id_br_cancel) begin
            if_valid <= 1'b0;
        end
        else if (if_allow_in) begin
            if_valid <= pre_if_valid;
        end
    end

    // internal signals
    wire [31:0] pc_plus4;
    wire [31:0] next_pc;

    // pre_if stage
    assign pc_plus4 = if_pc + 32'd4;
    assign pre_if_valid = ~rst;
    // assign next_pc = id_br_taken ? id_br_target : pc_plus4;

    // early decode
    wire [5:0] if_opcode = if_inst[31:26];
    wire [15:0] if_imm   = if_inst[15:0];
    wire [25:0] if_idx   = if_inst[25:0];

    wire is_beq  = (if_opcode == 6'b000100);
    wire is_bne  = (if_opcode == 6'b000101);
    wire is_j    = (if_opcode == 6'b000010);
    wire is_jal  = (if_opcode == 6'b000011);

    wire is_branch = is_beq | is_bne;
    wire is_jump   = is_j | is_jal;  

    wire [31:0] imm_se_sh = {{14{if_imm[15]}}, if_imm, 2'b00};

    wire [31:0] branch_target = if_pc + imm_se_sh;
    wire [31:0] jump_target   = {if_pc[31:28], if_idx, 2'b00};

    // BTFNT prediction
    wire is_backward = if_imm[15];
    wire predict_taken = (is_branch & is_backward) | is_jump;

    // predicted next_pc
    assign next_pc = id_br_cancel ? id_br_target :
                     predict_taken ? (is_branch ? branch_target : jump_target) :
                     pc_plus4;

    // IF stage
    assign if_ready_go = 1'b1;
    assign if_allow_in = ~if_valid | (if_ready_go & id_allow_in);
    assign if_id_valid = if_valid && if_ready_go && !predict_taken;

    always @(posedge clk) begin
        if (rst) begin
            if_pc <= 32'h0000_0000 - 32'd4;
        end
        else if (if_allow_in && pre_if_valid) begin
            if_pc <= next_pc;
        end
    end

    // inst_mem interface
    assign inst_mem_ena = pre_if_valid && if_allow_in;
    assign inst_mem_addra = predict_taken ? (next_pc[11:2]) : (if_pc[11:2]);
    assign if_inst = inst_mem_douta;
                     
endmodule
