`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2020 02:34:07 PM
// Design Name: 
// Module Name: top_blk
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

module top_blk#(
  parameter KERNEL_SIZE = `KERNEL_SIZE,
  parameter FM_SIZE = `FM_SIZE,
  parameter PADDING = `PADDING,
  parameter STRIDE = `STRIDE,
  parameter MAXPOOL = `MAXPOOL,
  localparam OUT_SIZE = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_go, 

    output reg o_done
    );
    
endmodule
