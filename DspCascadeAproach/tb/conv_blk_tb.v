`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2020 01:55:49 PM
// Design Name: 
// Module Name: conv_blk_tb
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


module conv_blk_tb #(
  parameter KERNEL_SIZE = 1,
  parameter FM_SIZE = 4,
  parameter PADDING = 0,
  parameter STRIDE = 1,
  parameter MAXPOOL = 1,
  localparam OUT_SIZE = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
  )();

  reg i_clk, i_rst, i_go;
  wire w_o_en;
  wire signed [48-1:0] w_o_conv_blk;
  wire signed [48*(OUT_SIZE / 2)-1:0] ouput_maxp;

  // à medida que o_en=1 vou escrevendo na bram e incrementando o addr
  always @(posedge i_clk) begin
    
  end

  
  conv_blk #(
    .KERNEL_SIZE(KERNEL_SIZE),
    .FM_SIZE(FM_SIZE),
    .PADDING(PADDING),
    .STRIDE(STRIDE),
    .MAXPOOL(MAXPOOL)
  )convolutional_block(
    .i_clk(i_clk), 
    .i_rst(i_rst), 
    .i_go(i_go),
    
    .o_en(w_o_en),
    .o_conv_result(w_o_conv_blk)
  );

  /*bram #(
    .ADDR_WIDTH($clog2(OUT_SIZE**2)),
    .RAM_WIDTH(48),
    .RAM_DEPTH(FM_SIZE**2),
    .RAM_PORTS(1)
  )outfeaturemap(
    .i_clk(i_clk), 
    .i_r_addrs(0), 
    .i_w_addrs(i_w_addrs),
    .i_wr_en(i_wr_fm_en),
    .i_data(i_fm),

    .o_data(o_fm_bram)
  );*/

  /*bram #(
    .ADDR_WIDTH($clog2(FM_SIZE**2)),
    .RAM_WIDTH(48),
    .RAM_DEPTH(FM_SIZE**2),
    .RAM_PORTS(1)
  )featuremap(
    .i_clk(i_clk), 
    .i_r_addrs(o_read_fm_bram), 
    .i_w_addrs(i_w_addrs),
    .i_wr_en(i_wr_fm_en),
    .i_data(i_fm),

    .o_data(o_fm_bram)
  );

  bram #(
    .ADDR_WIDTH($clog2(KERNEL_SIZE**2)),
    .RAM_WIDTH(48),
    .RAM_DEPTH(KERNEL_SIZE**2),
    .RAM_PORTS(1)
  )weights(
    .i_clk(i_clk), 
    .i_r_addrs(o_read_weight_bram), 
    .i_w_addrs(i_w_addrs),
    .i_wr_en(i_wr_weight_en),
    .i_data(i_weight),

    .o_data(o_weight)
  );*/


  always #5 i_clk = ~i_clk;
  
  initial begin
    i_clk = 0;
    i_rst = 1;
    i_go = 0;

    #150
    i_rst = 0;
    i_go = 1;
   
    #100 
    $finish;
  end

endmodule
