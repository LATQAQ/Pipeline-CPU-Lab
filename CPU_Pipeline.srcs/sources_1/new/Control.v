`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/28 15:40:47
// Design Name: 
// Module Name: Control
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


module Control(
    input [5:0] opcode,
    input [5:0] funct,

    output mem_to_reg,
    output mem_write,
    output [4:0] alu_control,
    output [1:0] alu_src,
    output signext,
    output reg_dst,
    output reg31,
    output reg_write  
    );

    wire Rtype = (opcode == 6'b000000);
    wire lw = (opcode == 6'b100011);
    wire sw = (opcode == 6'b101011);
    wire beq = (opcode == 6'b000100);
    wire bne = (opcode == 6'b000101);
    wire addi = (opcode == 6'b001000);
    wire ori = (opcode == 6'b001101);
    wire lui = (opcode == 6'b001111);
    wire j = (opcode == 6'b000010);
    wire jal = (opcode == 6'b000011);
    wire jr = (Rtype & (funct == 6'b001000));
    wire jalr = (Rtype & (funct == 6'b001001));

    function [1:0] getALUSrc;
        input lw, sw, addi, ori, lui, Rtype;
        input [5:0] funct;
        begin
            if (lw | sw | addi | ori | lui) begin
                getALUSrc = 2'b01; // immediate
            end else if (Rtype) begin
                if (funct == 6'b000000) begin
                    getALUSrc = 2'b10; // shamt
                end else begin
                    getALUSrc = 2'b00; // register
                end
            end else begin
                getALUSrc = 2'b00; // default
            end
        end
    endfunction

    assign alu_src = getALUSrc(lw, sw, addi, ori, lui, Rtype, funct);
    
    function [4:0] getALUCtrl;
        input [5:0] funct;
        input lw, sw, addi, ori, lui, beq, bne, Rtype;
        begin
            if (Rtype) begin
                case (funct)
                    6'b100000: getALUCtrl = 5'b00010; // ADD
                    6'b100001: getALUCtrl = 5'b00010; // ADDU
                    6'b100010: getALUCtrl = 5'b00110; // SUB
                    6'b100011: getALUCtrl = 5'b00110; // SUBU
                    6'b100100: getALUCtrl = 5'b00000; // AND
                    6'b100101: getALUCtrl = 5'b00001; // OR
                    6'b101010: getALUCtrl = 5'b00111; // SLT
                    6'b000000: getALUCtrl = 5'b00011; // SLL
                    default: getALUCtrl = 5'bxxxxx; // undefined
                endcase
            end else if (lw | sw | addi) begin
                getALUCtrl = 5'b00010; 
            end else if (ori) begin
                getALUCtrl = 5'b00001; 
            end else if (lui) begin
                getALUCtrl = 5'b01000; 
            end else if (beq | bne) begin
                getALUCtrl = 5'b00110;
            end else begin
                getALUCtrl = 5'bxxxxx; // undefined
            end
        end
    endfunction

    assign alu_control = getALUCtrl(funct, lw, sw, addi, ori, lui, beq, bne, Rtype);

    assign mem_to_reg = lw;
    assign mem_write = sw;
    assign signext = lw | sw | addi | beq | bne;
    assign reg_dst = Rtype | jalr;
    assign reg31 = jal;
    assign reg_write = Rtype | lw | addi | ori | lui | jal | jalr;


endmodule
