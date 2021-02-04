`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2021 11:24:40
// Design Name: 
// Module Name: layer_blk
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


module layer_blk#(
    parameter  KERNEL_SIZE = `KERNEL_SIZE,
    parameter  FM_SIZE     = `FM_SIZE,
    parameter  PADDING     = `PADDING,
    parameter  STRIDE      = `STRIDE,
    parameter  MAXPOOL     = `MAXPOOL,
    parameter  IN_FM_CH    = `IN_FM_CH,
    parameter  OUT_FM_CH   = `OUT_FM_CH,
    parameter  NUM_PE      = `NUM_PE
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_go,
    input wire i_weight_en, 
    input wire signed [(`B_DSP_WIDTH*OUT_FM_CH)-1:0]   i_weight_data,
    input wire signed [(`A_DSP_WIDTH*NUM_PE)-1:0]      i_fm_data,

    output wire o_en,
    output reg signed [(`DW*NUM_PE*OUT_FM_CH)-1:0]    o_conv_result//saida para a bram
);


    wire [(`DW*NUM_PE*OUT_FM_CH)-1:0] w_o_conv_blk;
    
    
    
    generate
    genvar i;
        for(i=0;i<OUT_FM_CH;i=i+1) begin
            conv_blk #(
                .KERNEL_SIZE(KERNEL_SIZE),
                .FM_SIZE(FM_SIZE),
                .PADDING(PADDING),
                .STRIDE(STRIDE),
                .MAXPOOL(MAXPOOL),
                .NUM_PE(NUM_PE)
              )convolutional_block1(
                .i_clk(i_clk), 
                .i_rst(i_rst), 
                .i_go(i_go),
                .i_fm_data(i_fm_data),
                .i_weight_en(i_weight_en),
                .i_weight_data(i_weight_data[i*`B_DSP_WIDTH + (`B_DSP_WIDTH-1):i*`B_DSP_WIDTH]),
                .o_en(o_en),
                .o_conv_result(w_o_conv_blk[i*`DW*NUM_PE + (`DW*NUM_PE-1):i*`DW*NUM_PE])
            );
        end
    endgenerate
    
     always @(*) begin
        o_conv_result = w_o_conv_blk;
     end
    


endmodule
