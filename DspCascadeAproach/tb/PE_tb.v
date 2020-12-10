`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2020 05:09:00 PM
// Design Name: 
// Module Name: PE_tb
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


module PE_tb #(
  parameter KERNEL_SIZE = 1,
  parameter FM_SIZE = 4,
  parameter PADDING = 0,
  parameter STRIDE = 1,
  parameter MAXPOOL = 1,
  localparam OUT_SIZE = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
  )();

  reg i_clk, i_rst, i_go;
  wire o_done;
  wire signed [48-1:0] ouput_conv;
  wire signed [48*(OUT_SIZE / 2)-1:0] ouput_maxp;
  
  //depois talvez se passe para o modulo o address de onde estao
  //pesos e o feature map e ele so vai ler
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
    
    .o_done(o_done),
    .o_conv_result(ouput_conv),
    .o_maxp_result(ouput_maxp)
  );

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
