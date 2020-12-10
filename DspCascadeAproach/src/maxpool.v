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


module maxpool#(
    parameter KERNEL_SIZE = 3,
    parameter FM_SIZE = 4,
    parameter PADDING = 0,
    parameter STRIDE = 1
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
