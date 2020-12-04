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
    parameter FM_SIZE = 3
    )();

    reg i_clk;
    reg [8:0] OPMODE;
    reg [4:0] INMODE;
    
    reg signed [29:0] i_DataFM;
    reg i_en;
    reg signed [KERNEL_SIZE*KERNEL_SIZE*18-1:0] i_Weight;

    wire o_en;
    wire signed [47:0] o_P;
    
    PE #(
      .KERNEL_SIZE(KERNEL_SIZE),
      .FM_SIZE(FM_SIZE)
      )uut(
      .i_clk(i_clk), 
      .INMODE(INMODE),
      .OPMODE(OPMODE), 
      .i_DataFM(i_DataFM), 
      .i_Weight(i_Weight),
      .i_en(i_en),

      .o_en(o_en),
      .o_P(o_P)
    );
      
    always #5 i_clk = ~i_clk;
    
    initial begin
      i_clk = 0;
      i_en = 0;
      OPMODE = 9'b110101;//somar o C M(resultado da multiplicao)
      INMODE = 5'b100;

      i_DataFM = 30'b0;
      //i_Weight = {18'b1}; //1*1
      //i_Weight = {18'b1, 18'b1, 18'b1, 18'b1}; //2*2
      i_Weight = {18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1}; //3*3
      //i_Weight = {18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1}; //4*4

      #150
      i_en = 1;//iniciar envio de valores    
      i_DataFM = 30'b1;

      #10    
      i_DataFM = 30'b10;
    
      #10    
      i_DataFM = 30'b11;

      #10    
      i_DataFM = 30'b100;

      #10    
      i_DataFM = 30'b101;

      #10    
      i_DataFM = 30'b110;

      #10    
      i_DataFM = 30'b111;

      #10   
      i_DataFM = 30'b1000;

      #10    
      i_DataFM = 30'b1001;
      
      #10    
      i_DataFM = 30'b1010;

      #10    
      i_DataFM = 30'b1011;

      #10    
      i_DataFM = 30'b1100;

      #10    
      i_DataFM = 30'b1101;

      #10    
      i_DataFM = 30'b1110;

      #10   
      i_DataFM = 30'b1111;

      #10    
      i_DataFM = 30'b10000;

      $finish;
    end
    
endmodule
