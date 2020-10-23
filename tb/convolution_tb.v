`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2020 05:24:04 PM
// Design Name: 
// Module Name: convolution_tb
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

`define BIT_LEN  8
`define M_LEN    3
`define CONV_LEN 20

module convolution_tb#(
    parameter  BIT_LEN =  `BIT_LEN,
    parameter  M_LEN =    `M_LEN,
    parameter  CONV_LEN = `CONV_LEN,
    localparam M_ARRAY =  BIT_LEN*M_LEN
    )();

    
    reg clk;
    reg reset;
    reg valid;
    reg selecK_I;
    reg signed [BIT_LEN-1:0]data0;
    reg signed [BIT_LEN-1:0]data1;
    reg signed [BIT_LEN-1:0]data2;
    wire [CONV_LEN-1:0] out_data;



    always #5 clk = ~clk;


    initial begin
        clk      = 1'b0;
        data0    = 8'b00000000; 
        data1    = 8'b00000000; 
        data2    = 8'b00000000; 
        reset    = 1'b1; 
        valid    = 1'b0;
        selecK_I = 1'b0;//kernel

        #100 reset	 = 1'b0;

        /*Load kernel*/
        data0    = 8'b00000001; 
        data1    = 8'b00000001; 
        data2    = 8'b00000001;
        #10 valid = 1'b1; 

        #10 valid = 1'b0;

        data0    = 8'b00000010; 
        data1    = 8'b00000010; 
        data2    = 8'b00000010;
        #10 valid = 1'b1;

        #10 valid = 1'b0;

        data0    = 8'b00000011; 
        data1    = 8'b00000011; 
        data2    = 8'b00000011;
        #10 valid = 1'b1;

        /*Load Image*/
        #10 valid = 1'b0;
        selecK_I = 1'b1;//image

        data0    = 8'b00000001; 
        data1    = 8'b00000001; 
        data2    = 8'b00000001;
        #10 valid = 1'b1; 

        #10 valid = 1'b0;

        data0    = 8'b00000010; 
        data1    = 8'b00000010; 
        data2    = 8'b00000010;
        #10 valid = 1'b1;

        #10 valid = 1'b0;

        data0    = 8'b00000011; 
        data1    = 8'b00000011; 
        data2    = 8'b00000011;
        #10 valid = 1'b1;

        #10 valid = 1'b0;

        /*First image slide*/
        data0    = 8'b00000100; 
        data1    = 8'b00000100; 
        data2    = 8'b00000100;
        #10 valid = 1'b1;

        #10 valid = 1'b0;

        data0    = 8'b00000101; 
        data1    = 8'b00000101; 
        data2    = 8'b00000101;
        #10 valid = 1'b1;

        #10 valid = 1'b0;

        data0    = 8'b00000110; 
        data1    = 8'b00000110; 
        data2    = 8'b00000110;
        #10 valid = 1'b1;

        #10 valid = 1'b0;
        #10 $finish;
    end

    convolution
    conv(
        .i_clk(clk), 
        .i_reset(reset), 
        .i_valid(valid), 
        .i_selecK_I(selecK_I), 
        .i_data0(data0), 
        .i_data1(data1),
        .i_data2(data2),
        .o_data(out_data)
    );

endmodule
