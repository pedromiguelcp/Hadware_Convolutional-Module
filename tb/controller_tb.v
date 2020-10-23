`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2020 14:29:17
// Design Name: 
// Module Name: controller_tb
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


module controller_tb();

//inputs
    reg i_clk, i_rst;
    reg i_start;
    reg i_ready2compute;
    reg i_conv_done;

//outputs
    wire o_compute_conv;
    wire [2:0] o_addr0, o_addr1, o_addr2;
    wire o_bram0_wr, o_bram1_wr, o_bram2_wr;
    
    controller uut(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(i_start),
        .i_ready2compute(i_ready2compute),
        .i_conv_done(i_conv_done),
        .o_compute_conv(o_compute_conv),
        .o_addr0(o_addr0), 
        .o_addr1(o_addr1), 
        .o_addr2(o_addr2),
        .o_bram0_wr(o_bram0_wr), 
        .o_bram1_wr(o_bram1_wr), 
        .o_bram2_wr(o_bram2_wr)
    
    );
    
    
    always #5 i_clk = ~i_clk;
    
    
   initial begin
   i_clk = 0;
   i_rst = 0;
   i_start = 0;
   i_ready2compute = 0;
   i_conv_done = 0;
   #2 i_rst = 1;
   #100 i_rst = 0;
   
   #15 i_start = 1;
   
   #15 i_start = 0; i_ready2compute = 1;
   
   
   #20 $finish;
   end
   
   always @(posedge i_clk) begin
        if(o_compute_conv) begin
            i_conv_done <= 1;
        end 
        else begin
            i_conv_done <= 0;
        end
   end
   
   



endmodule
