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
    parameter  KERNEL_SIZE = `KERNEL_SIZE,
    parameter  FM_SIZE     = `FM_SIZE,
    parameter  PADDING     = `PADDING,
    parameter  STRIDE      = `STRIDE,
    parameter  MAXPOOL     = `MAXPOOL,
    parameter  IN_FM_CH    = `IN_FM_CH,
    parameter  OUT_FM_CH   = `OUT_FM_CH,
    localparam OUT_SIZE    = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
    )(
    input wire i_clk,
    input wire i_rst,
    input wire i_go,
    input wire i_fm_data,
    input wire i_weight_data, 

    output reg w_o_conv_blk,
    output reg o_done
    );
    
  /*reg signed [30-1:0] FM_data [0:(FM_SIZE*FM_SIZE)-1];
  reg signed [30-1:0] i_fm_data;
  reg signed [18-1:0] KERNEL_data [0:(KERNEL_SIZE*KERNEL_SIZE)-1];
  reg signed [(KERNEL_SIZE**2)*18-1:0] i_weight_data;*/

  //tb manda sinal para começar
  //este top.v está ligado a brams e lê os dados depois de receber o sinal anterior
  //a partir daí ele controla quando dá o go para o conv_blk


  /*conv_blk #(
    .KERNEL_SIZE(KERNEL_SIZE),
    .FM_SIZE(FM_SIZE),
    .PADDING(PADDING),
    .STRIDE(STRIDE),
    .MAXPOOL(MAXPOOL)
  )convolutional_block(
    .i_clk(i_clk), 
    .i_rst(i_rst), 
    .i_go(i_go),
    .i_fm_data(i_fm_data),
    .i_weight_data(i_weight_data),
    
    .o_en(w_o_en),
    .o_conv_result(w_o_conv_blk)
  );*/
    
endmodule
