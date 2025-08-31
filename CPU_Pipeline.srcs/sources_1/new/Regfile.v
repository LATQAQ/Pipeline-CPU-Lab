`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 16:25:33
// Design Name: 
// Module Name: Regfile
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


module Regfile(
    input clk,
    input rst,

    input we,
    input [4:0] ra1,
    input [4:0] ra2,
    input [4:0] wa,
    input [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
    );

    reg [31:0] regs [0:31];

    assign rd1 = (we && (wa != 0) && (ra1 == wa)) ? wd : regs[ra1];
    assign rd2 = (we && (wa != 0) && (ra2 == wa)) ? wd : regs[ra2];
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end else if (we && (wa != 5'b0)) begin
            regs[wa] <= wd;
        end
    end
endmodule
