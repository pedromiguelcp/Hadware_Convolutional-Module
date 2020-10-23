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
    reg selec_K;
    reg selec_I;
    reg signed [BIT_LEN*M_LEN-1:0]data_img;
    reg signed [BIT_LEN*M_LEN-1:0]data_kernel;
    wire [CONV_LEN-1:0] out_data;



    always #5 clk = ~clk;


    initial begin
        clk      = 1'b0;
        data_img    = 24'b0; 
        data_kernel = 24'b0; 
        reset    = 1'b1; 
        selec_K  = 1'b0;
        selec_I  = 1'b0;

        #100 reset	 = 1'b0;

        /*Load kernel*/
        data_kernel    = {8'b00000001, 8'b00000001, 8'b00000001};
        data_img    = {8'b00000001, 8'b00000001, 8'b00000001};
        #10 selec_K = 1'b1;
        selec_I = 1'b1; 

        #10 data_kernel    = {8'b00000010, 8'b00000010, 8'b00000010};
        data_img    = {8'b00000010, 8'b00000010, 8'b00000010};

        #10 data_kernel    = {8'b00000011, 8'b00000011, 8'b00000011};
        data_img      = {8'b00000011, 8'b00000011, 8'b00000011};

        
        #10 selec_K = 1'b0;//stop consuming input data
        selec_I = 1'b0;


        /*First image slide*/
        data_img      = {8'b00000100, 8'b00000100, 8'b00000100};
        #10 selec_I = 1'b1;

        #10 data_img      = {8'b00000101, 8'b00000101, 8'b00000101};

        #10 selec_I = 1'b0;
        #10 $finish;
    end

    convolution
    conv(
        .i_clk(clk), 
        .i_reset(reset), 
        .i_selec_K(selec_K), 
        .i_selec_I(selec_I), 
        .i_data_img(data_img), 
        .i_data_kernel(data_kernel),
        .o_data(out_data)
    );

endmodule
