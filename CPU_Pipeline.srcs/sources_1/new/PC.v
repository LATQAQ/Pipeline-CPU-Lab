`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 15:40:47
// Design Name: 
// Module Name: PC
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


module PC(
    input clk,
    input rst,

    input [31:0] _pc,
    output [31:0] pc
    );

    reg [31:0] pc_reg;
    assign pc = pc_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 32'b0;
        end else begin
            pc_reg <= _pc;
        end
    end
endmodule
