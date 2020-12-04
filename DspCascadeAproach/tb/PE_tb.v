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


module PE_tb();

    reg i_clk;
    reg [8:0] OPMODE;
    reg [4:0] INMODE;
    
    reg signed [29:0] i_DataFM;
    reg signed [26:0] i_D;
    reg signed [71:0] i_Weight;
    wire signed [47:0] o_P;
    
    PE #(
      .KERNEL_SIZE(4)
      )uut(
      .i_clk(i_clk), 
      .INMODE(INMODE),
      .OPMODE(OPMODE), 
      .i_DataFM(i_DataFM), 
      .i_Weight(i_Weight),
      .i_D(i_D),
      .o_P(o_P)
    );
      
    always #5 i_clk = ~i_clk;
    
    initial begin
      i_clk = 0;
      OPMODE = 9'b000110101;//somar o C M(resultado da multiplica��o)

      INMODE = 5'b00100;
      i_D = 27'b000000000000000000000000000;

      i_DataFM = 30'b000000000000000000000000000000;
      i_Weight = 72'b000000000000000010_000000000000000001_000000000000000010_000000000000000001; 

      #150    
      i_DataFM = 30'b000000000000000000000000000001;

      #10    
      i_DataFM = 30'b000000000000000000000000000010;
    
      #10    
      i_DataFM = 30'b000000000000000000000000000011;

      #10    
      i_DataFM = 30'b000000000000000000000000000100;

      #10    
      i_DataFM = 30'b000000000000000000000000000101;

      #10    
      i_DataFM = 30'b000000000000000000000000000110;

      #10    
      i_DataFM = 30'b000000000000000000000000000111;

      #10   
      i_DataFM = 30'b000000000000000000000000001000;

      #10    
      i_DataFM = 30'b000000000000000000000000001001;
      
      #10    
      i_DataFM = 30'b000000000000000000000000001010;

      #10    
      i_DataFM = 30'b000000000000000000000000001011;

      #10    
      i_DataFM = 30'b000000000000000000000000001100;

      #10    
      i_DataFM = 30'b000000000000000000000000001101;

      #10    
      i_DataFM = 30'b000000000000000000000000001110;

      #10   
      i_DataFM = 30'b000000000000000000000000001111;

      #10    
      i_DataFM = 30'b000000000000000000000000010000;

      $finish;
    end
    
endmodule
