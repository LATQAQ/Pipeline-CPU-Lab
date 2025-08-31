`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 15:07:54
// Design Name: 
// Module Name: Imem
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


module Imem(
    input clk,
    input rst,

    input [31:0] addr,
    output  [31:0] idata
    );

    (* rom_style = "block" *)
    (* ram_style = "block" *)
    reg [31:0] imem [0:255];

    // Code
    initial begin
        $readmemh("D:/Code/CPU_Pipeline/code.txt", imem);
    end

    // wire [7:0] addr_ = addr[7:0];
    // assign idata = {imem[addr_ + 3], imem[addr_ + 2], imem[addr_ + 1], imem[addr_]};

    assign idata = imem[addr[9:2]]; // word-aligned addressing

endmodule
