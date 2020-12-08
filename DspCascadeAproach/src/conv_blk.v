`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2020 06:23:24 PM
// Design Name: 
// Module Name: conv_blk
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


module conv_blk#(
  parameter KERNEL_SIZE = 3,
  parameter FM_SIZE = 4,
  parameter PADDING = 0,
  parameter STRIDE = 1
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_go, 

    output reg o_done,
    output reg signed [47:0] o_conv_result//so serve para ver na sim pos implementacao
    );

    reg signed [29:0] i_DataFM;
    reg i_en;
    reg signed [KERNEL_SIZE*KERNEL_SIZE*18-1:0] i_Weight;
    /*tamanho da saida
    W2 = (W1 - F + 2P) / S + 1
    H2 = (H1 - F + 2P) / S + 1
    */
    reg signed [48-1:0] r_conv_result [((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2-1:0];//onde fica guardado o resultado da convoluçao
    reg [$clog2(((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2)+1:0] r_conv_result_cnt, r_rect_result_cnt, r_index_clean;
    reg [$clog2(KERNEL_SIZE*KERNEL_SIZE)+1:0] j;//posso usar isto no ciclo for?
    wire o_en, o_en_result;
    wire signed [47:0] o_P, o_data;

    /*Mandar sinal para terminar a convolução (i_en = 0)*/
    always @(posedge i_clk) begin
        if(i_rst)begin
            i_DataFM <= 0;
            i_en <= 0;
            o_done <= 0;
            
            for(j = 0; j < KERNEL_SIZE*KERNEL_SIZE; j = j + 1) begin//pesos todos com valor 1
                i_Weight[j*18 +: 18] <= 1;
            end
        end
        else if(i_go) begin
            if(r_conv_result_cnt == ((FM_SIZE-KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2) begin//já saíram todos os resultados válidos da convolucao
                i_en <= 0;
                o_done <= 1;
            end
            else if(!o_done) begin
                i_DataFM <= i_DataFM + 1;//feature map com valores incrementais
                i_en <= 1;
            end
        end
    end


    /*Guardar os resultados das convolucoes*/
    always @(posedge i_clk) begin
        if(i_rst)
            r_conv_result_cnt <= 0;
        else if(o_en)
            r_conv_result_cnt <= r_conv_result_cnt + 1;
    end

    always @(posedge i_clk) begin
        if(i_rst) begin
            r_rect_result_cnt <= 0;
            o_conv_result <= 0;

            for(r_index_clean = 0; r_index_clean < ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1)**2; r_index_clean = r_index_clean + 1)begin
                r_conv_result[r_index_clean] <= 0;
            end
        end  
        else if(o_en_result) begin
            r_rect_result_cnt <= r_rect_result_cnt + 1;
            r_conv_result[r_rect_result_cnt] <= o_data;//dados que vem do bloco ReLU
            o_conv_result <= o_data;  
        end
    end


    PE #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .FM_SIZE(FM_SIZE),
        .PADDING(PADDING),
        .STRIDE(STRIDE)
    )uut(
        .i_clk(i_clk), 
        .i_DataFM(i_DataFM), 
        .i_Weight(i_Weight),
        .i_en(i_en),

        .o_en(o_en),
        .o_P(o_P)
    );

    relu uut1(
        .i_clk(i_clk), 
        .i_data(o_P),
        .i_en(o_en), 

        .o_en(o_en_result),
        .o_data(o_data)
    );


    /*bram #(
        .ADDR_WIDTH($clog2(FM_SIZE**2)),
        .RAM_WIDTH(48),
        .RAM_DEPTH(FM_SIZE**2),
        .RAM_PORTS(1)
    )featuremap(
        .i_clk(i_clk), 
        .i_r_addrs(i_r_addrs), 
        .i_w_addrs(i_w_addrs),
        .i_wr_en(i_wr_en),
        .i_data(i_data),

        .o_data(o_data)
    );

    bram #(
        .ADDR_WIDTH($clog2(KERNEL_SIZE**2)),
        .RAM_WIDTH(48),
        .RAM_DEPTH(KERNEL_SIZE**2),
        .RAM_PORTS(1)
    )weights(
        .i_clk(i_clk), 
        .i_r_addrs(i_r_addrs), 
        .i_w_addrs(i_w_addrs),
        .i_wr_en(i_wr_en),
        .i_data(i_data),

        .o_data(o_data)
    );*/

endmodule
