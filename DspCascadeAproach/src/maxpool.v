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

module maxpool(
  input wire i_clk,
  input wire i_rst,
  input wire i_clean,
  input wire i_read_clean,//usado quando é preciso limpar o maior valor e ao mesmo tempo ler entrada
  input wire signed [`DW-1:0] i_data,

  output reg signed [`DW-1:0] o_data
);

  always @(posedge i_clk) begin
    if(i_rst || (i_clean && i_read_clean)) begin
      o_data <= 0;
    end
    else if((i_data > o_data) || (i_clean && !i_read_clean)) begin
      o_data <= i_data;
    end
  end

endmodule

/*module maxpool(
  input wire i_clk,
  input wire i_rst,
  input wire signed [`DW-1:0] i_data,

  output reg signed [`DW-1:0] o_data
);

  always @(posedge i_clk) begin
    if(i_rst) begin
      o_data <= 0;
    end
    else if(i_data > o_data) begin
      o_data <= i_data;
    end
  end

endmodule*/
