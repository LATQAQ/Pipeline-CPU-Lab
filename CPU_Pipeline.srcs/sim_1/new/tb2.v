`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Li Zijian
//
// Create Date: 2025/09/03 09:30:59
// Design Name:
// Module Name: tb2
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


module tb2();

    reg clk;
    reg rst;

    Pipeline_Top_CPU u_Pipeline_Top_CPU(
                         .clk 	(clk),
                         .rst 	(rst)
                     );


    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #20;
        rst = 0;

        #20000;

        $stop;
    end


endmodule
