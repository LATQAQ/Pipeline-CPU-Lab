`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 15:07:54
// Design Name: 
// Module Name: Dmem
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


module Dmem(
    input clk,
    input rst,
    input we,

    input [31:0] addr,
    input [31:0] wdata,

    output [31:0] rdata
    );
    
    (* rom_style = "block" *)
    (* ram_style = "block" *)
    reg [31:0] memory [0:255];

    initial begin
        $readmemb("D:/Code/CPU_Pipeline/data.txt", memory);
    end

    assign rdata = memory[addr[9:2]];
    
    always @(posedge clk) begin
        if (we) begin
            memory[addr[9:2]] <= wdata;
        end
    end

endmodule
