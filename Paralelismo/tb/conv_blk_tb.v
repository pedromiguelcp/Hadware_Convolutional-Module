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
  parameter KERNEL_SIZE = 3,
  parameter FM_SIZE = 252,
  parameter PADDING = 0,
  parameter STRIDE = 1,
  parameter MAXPOOL = 0,
  localparam OUT_SIZE = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
  )();

  reg i_clk, i_rst, i_go, weight_en;
  wire w_o_en;
  wire signed [48-1:0] w_o_conv_blk;
  wire signed [48*(OUT_SIZE / 2)-1:0] ouput_maxp;

  reg signed [30-1:0] i_fm_data;
  reg signed [18-1:0] i_weight_data;
  
  reg signed [30-1:0] FM_data [0:(FM_SIZE*FM_SIZE)-1];
  reg signed [18-1:0] KERNEL_data [0:(KERNEL_SIZE*KERNEL_SIZE)-1];
  
  integer i, j, out_data, out_cnt;
  
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
    .i_fm_data(i_fm_data),
    .i_weight_en(weight_en),
    .i_weight_data(i_weight_data),
    
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
  
  always @(posedge i_clk) begin
    if(i_go == 1 && (i < FM_SIZE*FM_SIZE)) begin
//        i_fm_data<= i_fm_data + 1;
      i_fm_data <= FM_data[i+1];
      i <= i+1;
    end
  end
  
  always@(posedge i_clk) begin
    if(w_o_en) begin
      $fwrite(out_data,"%0d\n", (w_o_conv_blk));  
      $display("%0d\n", w_o_conv_blk); 
      out_cnt <= out_cnt + 1; 
    end 
  end
 
 
  initial begin
    $readmemh("FM_data.txt", FM_data);
    $readmemh("Kernel_data.txt", KERNEL_data);
    out_data = $fopen("OUT_data.txt","w");
    
    #20
    i_clk <= 0;
    i_rst <= 1;
    i_go <= 0;
    weight_en <= 0;
//    i_fm_data <= 1;
    i_fm_data <= FM_data[0];
    i <= 0;
    out_cnt <= 0;


    
    #150
    i_rst <= 0;
    weight_en <= 1;
    for(j = 0; j<KERNEL_SIZE**2; j=j+1)begin
      i_weight_data[18-1:0] <= KERNEL_data[j];
      #10;
    end

    #20;
    weight_en <= 0;
    i_go <= 1;   

//    while(!(((out_cnt == OUT_SIZE**2 -1) && (MAXPOOL == 0)) || ((out_cnt == (OUT_SIZE / 2)**2 -1) && (MAXPOOL == 1))))begin 
//      #10;
//    end
    
//    #690000  
    
//    $fclose(out_data);
    $finish; 
  end

endmodule
