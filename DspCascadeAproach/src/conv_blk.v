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
`include "global.v"

module conv_blk#(
    parameter  KERNEL_SIZE = `KERNEL_SIZE,
    parameter  FM_SIZE     = `FM_SIZE,
    parameter  PADDING     = `PADDING,
    parameter  STRIDE      = `STRIDE,
    parameter  MAXPOOL     = `MAXPOOL,
    parameter  IN_FM_CH    = `IN_FM_CH,
    parameter  OUT_FM_CH   = `OUT_FM_CH,
    localparam OUT_SIZE    = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_go,
    input wire i_weight_en, 
    input wire signed [18-1:0] i_weight_data,
    input wire signed [`A_DSP_WIDTH-1:0] i_fm_data,

    output reg o_en,
    output reg signed [`DW-1:0] o_conv_result//saida para a bram
);

    reg signed [`A_DSP_WIDTH-1:0] r_fm_data;   
    reg signed [`A_DSP_WIDTH-1:0] r_fm_data_save [(FM_SIZE + 2*PADDING)*PADDING*3 - 1:0];    
    reg signed [KERNEL_SIZE**2*18-1:0] r_weight_data;
    reg signed [`DW-1:0] r_relu_result [(OUT_SIZE / 2) - 1:0];//registo para os resultados que saiem do bloco ReLU e entrar no bloco maxpool
    reg signed [`DW-1:0] r_maxp_result [(OUT_SIZE / 2) - 1:0];
    reg r_en_PE, r_clean_maxp, r_mp_out_rdy;

    wire signed [`DW-1:0] r_maxpool_result [(OUT_SIZE / 2) - 1:0];
    wire signed [`DW-1:0] w_o_data_PE, w_o_data_ReLU;
    wire w_o_PE, w_o_ReLU;
    
    integer i, ii, j, k, r_in_fm_cnt, r_o_ReLU_cnt, r_fm_row, r_fm_column, r_fm_read_addr, r_fm_write_addr;


    /***************************************************
    Controlo sobre os pesos e valores do feature map que 
    sao enviados para o PE
    ***************************************************/
    always @(posedge i_clk) begin
        if(i_rst)begin
            r_fm_data <= 0;
            r_en_PE <= 0;
            ii <= 0;
            r_fm_row <= 0;
            r_fm_column <= 0;
            r_fm_read_addr <= 0;
            r_fm_write_addr <= 0;
        end
        else if(i_weight_en)begin
            r_weight_data[ii*18 +: 18] <= i_weight_data;
            ii <= ii + 1;
        end
        else if(i_go && (r_fm_row < (FM_SIZE + PADDING*2))) begin
            
            if(r_fm_column < (FM_SIZE + PADDING*2 - 1))
                r_fm_column <= r_fm_column + 1;
            else begin
                r_fm_column <= 0;
                r_fm_row <= r_fm_row + 1;
            end

            //havendo padding aqui tera de haver o controlo para mandar os 0s para o PE
            //certamente aqui estara o controlo do addr de leitura da memoria onde estarao os dados de entrada
            //por isso em certos momento em vez de ler o feature map, manda-se 0 para o PE
            if(PADDING > 0) begin
                r_fm_data_save[r_fm_write_addr] <= i_fm_data;
                if(r_fm_write_addr < (FM_SIZE + 2*PADDING)*PADDING*3 - 1)
                    r_fm_write_addr <= r_fm_write_addr + 1;
                else
                    r_fm_write_addr <= 0;

                if((r_fm_row < PADDING || r_fm_row > (FM_SIZE + PADDING*2 - 1 - PADDING) || r_fm_column < PADDING || r_fm_column > (FM_SIZE + PADDING*2 - 1 - PADDING)))begin
                    r_fm_data <= 0;                     
                end
                else begin
                    r_fm_data <= r_fm_data_save[r_fm_read_addr];
                    if(r_fm_read_addr < (FM_SIZE + 2*PADDING)*PADDING*3 - 1)
                        r_fm_read_addr <= r_fm_read_addr + 1;
                    else
                        r_fm_read_addr <= 0;
                end
            end
            else begin
                //feature map que vem do ficheiro
                r_fm_data <= i_fm_data;
            end
            
            //novo dado para o PE
            r_en_PE <= 1;
        end
    end

    
    /***************************************************
    Monitorizacao da saida do bloco ReLU
    ***************************************************/
    always @(posedge i_clk) begin
        if(i_rst) begin
            r_o_ReLU_cnt <= 1;
        end  
        else if(w_o_ReLU) begin
            r_o_ReLU_cnt <= r_o_ReLU_cnt + 1;         
        end
    end


    /***************************************************
    Monitorizacao e armazenamento da saida do bloco ReLU
    para o bloco maxpool
    ***************************************************/
    always @(posedge i_clk) begin
        r_mp_out_rdy <= 0;
        r_clean_maxp <= 0;
        if(i_rst) begin
            //Inicializacao dos arrays de entrada do bloco maxpool
            for(i = 0; i < (OUT_SIZE / 2); i = i + 1)begin
                r_relu_result[i] <= 0;
            end
        end
        else if(w_o_ReLU && MAXPOOL) begin

            r_relu_result[((r_o_ReLU_cnt-1)/2) 
                        - (((r_o_ReLU_cnt-1) / OUT_SIZE) * (OUT_SIZE / 2))] <= w_o_data_ReLU;

            if((r_o_ReLU_cnt % (2*OUT_SIZE)) == 0 && !r_mp_out_rdy)begin
                r_mp_out_rdy <= 1;
            end
            if(((r_o_ReLU_cnt-1) % (2*OUT_SIZE)) == 0 && !r_clean_maxp && ((r_o_ReLU_cnt-1) > 0))begin
                r_clean_maxp <= 1;

                //limpar o array exceto a primeira posição que esta a ser escrita
                for(i = 1; i < (OUT_SIZE / 2); i = i + 1)
                    r_relu_result[i] <= 0;
            end
        end
    end


    /***************************************************
    Envio para a saida do resultados do bloco ReLU / MAXPOOL
    ***************************************************/
    always @(posedge i_clk) begin
        if(i_rst) begin
            o_en <= 0;
            o_conv_result <= 0;
            //quantidade de resultados que saem dos blocos maxpool
            k <= OUT_SIZE / 2;
        end
        else if(w_o_ReLU && (MAXPOOL == 0)) begin
            //se nao houver maxpool, saida = saida do bloco ReLU
            o_en <= 1;
            o_conv_result <= w_o_data_ReLU;
        end
        else if(k < (OUT_SIZE / 2)) begin
            //se houver maxpool, k = 0, e inicia-se o envio dos resultados um a um
            o_en <= 1;
            k <= k + 1;
            
            o_conv_result <= r_maxp_result[k];

            //load para um array auxiliar na primeira iteração pois o array principal
            //é usado consecutivamente para armazenar novos valores que sai do maxpool
            if(k == 0) begin
                for(j = 0; j < (OUT_SIZE / 2); j = j + 1)
                    r_maxp_result[j] <= r_maxpool_result[j];
                o_conv_result <= r_maxpool_result[0];
            end
        end
        else if(r_mp_out_rdy) begin
            //sinal para começar a enviar os resultados do maxpool para a saida
            k <= 0;
        end
        else
            o_en <= 0;
    end


    PE #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .FM_SIZE(FM_SIZE),
        .PADDING(PADDING),
        .STRIDE(STRIDE)
    )uut(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_DataFM(r_fm_data), 
        .i_Weight(r_weight_data),
        .i_en(r_en_PE),

        .o_en(w_o_PE),
        .o_P(w_o_data_PE)
    );

    relu uut1(
        .i_clk(i_clk), 
        .i_data(w_o_data_PE),
        .i_en(w_o_PE), 

        .o_en(w_o_ReLU),
        .o_data(w_o_data_ReLU)
    );

    generate 
    genvar m;
        if(MAXPOOL == 1)
            for(m = 0; m < ((OUT_SIZE / 2)); m = m +1) begin
                maxpool maxpool_inst (
                    .i_clk(i_clk),
                    .i_rst(i_rst),
                    .i_clean(r_clean_maxp),
                    .i_read_clean(m == 0 ? 0 : 1),
                    .i_data(r_relu_result[m]),

                    .o_data(r_maxpool_result[m])
                );
            end 
    endgenerate
endmodule
