`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2020 03:22:30 PM
// Design Name: 
// Module Name: bram_tb
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

`define ADDR_WIDTH 6//32d
`define RAM_WIDTH  8
`define RAM_PORTS  3//read 3 values each time

module bram_tb#(
    parameter ADDR_WIDTH = `ADDR_WIDTH, 
    parameter RAM_WIDTH = `RAM_WIDTH, 
    parameter RAM_PORTS = `RAM_PORTS
    )();

    
    reg clk;
    reg wr_en;
	reg[ADDR_WIDTH-1:0] w_addrs;
	reg[ADDR_WIDTH*RAM_PORTS-1:0] r_addrs;
    reg [RAM_WIDTH-1:0] data_in;
    wire[RAM_WIDTH*RAM_PORTS-1:0] data_out;

    reg[RAM_WIDTH*9-1:0] matrix;
    always #5 clk = ~clk;

    initial begin
        clk     = 1'b0;
        w_addrs = 6'd0;
        r_addrs = 18'd0;
        wr_en   = 1'b0;
        data_in = 8'd0;
        matrix  = 81'b0;

        /*start write every clock, 9 bytes written*/
        #10 wr_en   = 1'b1;
        data_in = 8'd1;

        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd2;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd3;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd4;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd5;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd6;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd7;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd8;
        #10 w_addrs = w_addrs + 1'd1;
        data_in = 8'd9;

        #10 wr_en   = 1'b0;
        w_addrs     = 6'd0;//clean write address

        /*Start reading from bram, 3 bytes at once (done optionaly), 9 bytes read*/
        #10 r_addrs = {6'd2, 6'd1, 6'd0};
        #10 matrix[RAM_WIDTH*3-1:0] = {data_out[RAM_WIDTH*3-1:RAM_WIDTH*2], data_out[RAM_WIDTH*2-1:RAM_WIDTH], data_out[RAM_WIDTH-1:0]};

        #10 r_addrs = {6'd5, 6'd4, 6'd3};
        #10 matrix[RAM_WIDTH*6-1:RAM_WIDTH*3] = {data_out[RAM_WIDTH*3-1:RAM_WIDTH*2], data_out[RAM_WIDTH*2-1:RAM_WIDTH], data_out[RAM_WIDTH-1:0]};

        #10 r_addrs = {6'd8, 6'd7, 6'd6};
        #10 matrix[RAM_WIDTH*9-1:RAM_WIDTH*6] = {data_out[RAM_WIDTH*3-1:RAM_WIDTH*2], data_out[RAM_WIDTH*2-1:RAM_WIDTH], data_out[RAM_WIDTH-1:0]};

        #10 $finish;
    end


    bram
    blkram(
        .i_clk(clk), 
        .i_r_addrs(r_addrs), 
        .i_w_addrs(w_addrs), 
        .i_wr_en(wr_en), 
        .i_data(data_in),
        .o_data(data_out)
    );
endmodule
