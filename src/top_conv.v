`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2020 14:32:11
// Design Name: 
// Module Name: top_conv
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


module top_conv#(
        parameter  BIT_LEN =  `BIT_LEN,
        parameter  M_LEN =    `M_LEN,
        parameter  CONV_LEN = 20,
        localparam M_ARRAY =  BIT_LEN*M_LEN
    )(
    
        input wire i_start,
        input wire i_clk,
        input wire i_rst,
        input wire [8-1:0] i_data_I,
        input wire [8-1:0] i_data_K,
        input wire [5:0] i_addrw_I,
        input wire [5:0] i_addrw_K,
        input wire i_addrw_r,
        output reg [CONV_LEN-1:0] o_data
        
    );
    
    wire w_selectK_I;
    wire [23:0] w_bramdata0, w_bramdata1;
    wire [17:0] w_addr0, w_addr1;
    wire w_selec_K, w_selec_I;
    wire [CONV_LEN-1:0] w_data;
    
    always @(*) begin
        o_data = w_data;
    end
    
    controller ct(
        .i_clk(i_clk), 
        .i_rst(i_rst),
        .i_start(i_start),
        .o_addr0(w_addr0), 
        .o_addr1(w_addr1), 
        .o_selec_K(w_selec_K),
        .o_selec_I(w_selec_I)
    );
    

    convolution conv(
        .i_clk(i_clk),
        .i_reset(i_rst),
        .i_selec_K(w_selec_K), 
        .i_selec_I(w_selec_I), 
        .i_data_img(w_bramdata0),
        .i_data_kernel(w_bramdata1),
        .o_data(w_data)
    );
    
    bram bram_FM(
        .i_clk(i_clk),
        .i_r_addrs(w_addr0),
        .i_w_addrs(i_addrw_I),   
        .i_wr_en(i_addrw_r),
        .i_data(i_data_I),
        .o_data(w_bramdata0)
    );
    
     bram bram_Kernel(
        .i_clk(i_clk),
        .i_r_addrs(w_addr1),
        .i_w_addrs(i_addrw_K),   
        .i_wr_en(i_addrw_r),
        .i_data(i_data_K),
        .o_data(w_bramdata1)
    );
    

    
endmodule
