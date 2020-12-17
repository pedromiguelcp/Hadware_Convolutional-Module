`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2020 03:48:04 PM
// Design Name: 
// Module Name: maxpool
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
`include "global.v"

module maxpool#(
  parameter KERNEL_SIZE = `KERNEL_SIZE,
  parameter FM_SIZE = `FM_SIZE,
  parameter PADDING = `PADDING,
  parameter STRIDE = `STRIDE
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_clean,
    input wire i_en_mp,
    input wire signed [48-1:0] i_data,

    output reg signed [48-1:0] o_data
    );

    always @(*) begin
        o_data = (i_rst || (i_clean && !i_en_mp)) ? 0:
                            ((i_data > o_data) || (i_clean && i_en_mp)) ? i_data:o_data;
    end
endmodule
