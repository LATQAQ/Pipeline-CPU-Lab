`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zijian
// 
// Create Date: 2025/08/29 14:44:18
// Design Name: 
// Module Name: tb1
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


module tb1();

    reg clk;
    reg rst;

    TopCpu cpu (
        .clk(clk),
        .rst(rst)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #30;
        rst = 0;

        #500;

        $stop;
    end


endmodule
