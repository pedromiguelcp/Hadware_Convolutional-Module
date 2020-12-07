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
  parameter FM_SIZE = 2,
  parameter PADDING = 0,
  parameter STRIDE = 1
  )();

  reg i_clk;
  reg [8:0] OPMODE;
  reg [4:0] INMODE;
  
  reg signed [29:0] i_DataFM;
  reg i_en;
  reg signed [KERNEL_SIZE*KERNEL_SIZE*18-1:0] i_Weight;
  /*tamanho da saida
    W2 = (W1 - F + 2P) / S + 1
    H2 = (H1 - F + 2P) / S + 1
  */
  reg signed [48-1:0] r_conv_result [((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2-1:0] ;
  reg [$clog2(((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2)+1:0] r_conv_result_cnt, r_rect_result_cnt, r_index_clean;
  wire o_en, o_en_result;
  wire signed [47:0] o_P, o_data;
  
  PE #(
    .KERNEL_SIZE(KERNEL_SIZE),
    .FM_SIZE(FM_SIZE),
    .PADDING(PADDING),
    .STRIDE(STRIDE)
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

  relu u1ut(
    .i_clk(i_clk), 
    .i_data(o_P),
    .i_en(o_en), 

    .o_en(o_en_result),
    .o_data(o_data)
  );
    
  always #5 i_clk = ~i_clk;
  
  initial begin
    i_clk = 0;
    r_conv_result_cnt = 0;
    r_rect_result_cnt = 0;
    for(r_index_clean = 0; r_index_clean < ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2; r_index_clean = r_index_clean + 1)begin
      r_conv_result[r_index_clean] = 0;
    end
    i_en = 0;
    OPMODE = 9'b110101;//somar o C M(resultado da multiplicao)
    INMODE = 5'b100;

    i_DataFM = 30'b0;
    i_Weight = {18'b1}; //1*1
    //i_Weight = {18'b1, 18'b1, 18'b1, 18'b1}; //2*2
    //i_Weight = {18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1}; //3*3
    //i_Weight = {18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1}; //4*4
    //i_Weight = {18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1
    //                            , 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1, 18'b1}; //5*5

    #150
    i_en = 1;//iniciar envio de valores    
    i_DataFM = 30'b1;

    #10    
    i_DataFM = 30'b10;
  
    #10    
    i_DataFM = -10;//num negativo

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
    i_DataFM = 30'b10000;//16

    #10   
    i_DataFM = 30'b10001;

    #10    
    i_DataFM = 30'b10010;
    
    #10    
    i_DataFM = 30'b10011;

    #10    
    i_DataFM = 30'b10100;

    #10    
    i_DataFM = 30'b10101;

    #10    
    i_DataFM = 30'b10110;

    #10    
    i_DataFM = 30'b10111;

    #10   
    i_DataFM = 30'b11000;

    #10    
    i_DataFM = 30'b11001;//25

    #100 
    $finish;
  end

  /*Guardar os resultados das convolucoes*/
  always @(posedge i_clk) begin
    if(o_en) begin
      r_conv_result_cnt <= r_conv_result_cnt + 1;
      //r_conv_result[r_conv_result_cnt] <= o_P;
    end
  end

  always @(posedge i_clk) begin
    if(o_en_result) begin
      r_rect_result_cnt <= r_rect_result_cnt + 1;
      r_conv_result[r_rect_result_cnt] <= o_data;
    end
  end



  /*Mandar sinal para terminar a convolução (i_en = 0)
  se FM_SIZE == KERNEL_SIZE so vem um resultado*/
  always @(posedge i_clk) begin
    if(FM_SIZE == KERNEL_SIZE) begin
      if(r_conv_result_cnt == ((FM_SIZE-KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2)
        i_en <= 0;
    end
    else if(r_conv_result_cnt + 1 == ((FM_SIZE-KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2) begin
        i_en <= 0;
    end
  end
    
endmodule
