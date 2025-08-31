`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 14:44:07
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [4:0] ALUCtrl,
    input [31:0] SrcA,
    input [31:0] SrcB,

    output reg [31:0] ALUResult
    );


    always @(*) begin
        case (ALUCtrl)
            5'b00000: ALUResult <= SrcA & SrcB; // AND
            5'b00001: ALUResult <= SrcA | SrcB; // OR
            5'b00010: ALUResult <= SrcA + SrcB; // ADD
            5'b00110: ALUResult <= SrcA - SrcB; // SUB
            5'b00111: ALUResult <= (SrcA < SrcB) ? 32'b1 : 32'b0; // SLT
            5'b00011: ALUResult <= SrcA << SrcB[4:0]; // SLL
            5'b01000: ALUResult <= SrcB << 16; // LUI
            default: ALUResult <= 32'b0;
        endcase
    end

endmodule
