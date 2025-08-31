`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 17:12:43
// Design Name: 
// Module Name: BrUnit
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

module BrUnit (
    input  wire [31:0] pc,         
    input  wire [31:0] rs_val,     
    input  wire [31:0] rt_val,     
    input  wire [15:0] imm,        
    input  wire [25:0] jaddr,      
    input  wire [5:0]  opcode,     
    output reg  [31:0] next_pc,    
    output reg         take_branch,
    output reg  [31:0] link_addr,  
    output reg         link_en     
);

    wire [31:0] pc_plus4 = pc + 4;
    wire [31:0] branch_target = pc_plus4 + {{14{imm[15]}}, imm, 2'b00};
    wire [31:0] jump_target = {pc_plus4[31:28],jaddr,2'b00};

    always @(*) begin
        take_branch = 1'b0;
        next_pc = pc_plus4;
        link_en = 1'b0;
        link_addr = 32'b0;

        case (opcode)
            6'b000100: begin // BEQ
                if (rs_val == rt_val) begin
                    take_branch = 1'b1;
                    next_pc = branch_target;
                end
            end
            6'b000101: begin // BNE
                if (rs_val != rt_val) begin
                    take_branch = 1'b1;
                    next_pc = branch_target;
                end
            end
            6'b000010: begin // J
                next_pc = jump_target;
                take_branch = 1'b1;
            end
            6'b000011: begin // JAL
                next_pc = jump_target;
                take_branch = 1'b1;
                link_en = 1'b1;
                link_addr = pc_plus4;
            end
            6'b001000: begin // JR
                next_pc = rs_val;
                take_branch = 1'b1;
            end
            6'b001001: begin // JALR
                next_pc = rs_val;
                take_branch = 1'b1;
                link_en = 1'b1;
                link_addr = pc_plus4;
            end
            default: begin
                next_pc = pc_plus4;
            end
        endcase
    end 
    

endmodule
