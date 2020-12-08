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
  parameter KERNEL_SIZE = 3,
  parameter FM_SIZE = 4,
  parameter PADDING = 0,
  parameter STRIDE = 1
  )();

  reg i_clk, i_rst, i_go;
  wire o_done;
  wire signed [47:0] ouput_conv;
  
  //depois talvez se passe para o modulo o address de onde estao
  //pesos e o feature map e ele so vai ler
  conv_blk #(
    .KERNEL_SIZE(KERNEL_SIZE),
    .FM_SIZE(FM_SIZE),
    .PADDING(PADDING),
    .STRIDE(STRIDE)
  )convolutional_block(
    .i_clk(i_clk), 
    .i_rst(i_rst), 
    .i_go(i_go),

    .o_done(o_done),
    .o_conv_result(ouput_conv)
  );

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
