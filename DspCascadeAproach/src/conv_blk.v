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
  parameter KERNEL_SIZE = `KERNEL_SIZE,
  parameter FM_SIZE = `FM_SIZE,
  parameter PADDING = `PADDING,
  parameter STRIDE = `STRIDE,
  parameter MAXPOOL = `MAXPOOL,
  localparam OUT_SIZE = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
)(
    input wire i_clk,
    input wire i_rst,
    input wire i_go, 

    output reg o_done,
    output reg o_en,
    output reg signed [`DW-1:0] o_conv_result//saida para a bram
    );

    reg signed [`A_DSP_WIDTH-1:0] r_fm_data;    
    reg signed [KERNEL_SIZE*KERNEL_SIZE*18-1:0] r_weight_data;

    reg signed [`DW-1:0] r_relu_result [OUT_SIZE / 2 - 1:0];//registo para os resultados que saiem do bloco ReLU e entrar no bloco maxpool
    reg [$clog2(OUT_SIZE**2)+1:0] r_o_PE_cnt, r_o_ReLU_cnt, r_index_clean;
    reg r_mp_en [OUT_SIZE / 2 - 1:0];
    reg r_en_PE, r_clean_maxp, r_mp_out_rdy;

    wire signed [`DW-1:0] r_maxpool_result [OUT_SIZE / 2 - 1:0];
    reg signed [`DW-1:0] r_maxp_result [OUT_SIZE / 2 - 1:0];
    wire signed [`DW-1:0] w_o_data_PE, w_o_data_ReLU;
    wire w_o_PE, w_o_ReLU;
    
    integer i, j, k, int_maxpool_cnt;


    /***************************************************
    Controlo sobre os pesos e valores do feature map que 
    sao enviados para o PE
    ***************************************************/
    always @(posedge i_clk) begin
        if(i_rst)begin
            r_fm_data <= 0;
            r_en_PE <= 0;
            o_done <= 0;
            
            //pesos com valor = 1 para facilitar validacoes
            for(j = 0; j < KERNEL_SIZE*KERNEL_SIZE; j = j + 1) begin
                r_weight_data[j*18 +: 18] <= 1;
            end
            
        end
        else if(i_go && !o_done && (r_fm_data < FM_SIZE**2)) begin
            //feature map com valores incrementais
            r_fm_data <= r_fm_data + 1;
            //novo dado para o PE
            r_en_PE <= 1;
        end
        else begin
            //mais nenhum valor vai ser enviado para o PE
            o_done <= 1;
        end
    end


    /***************************************************
    Monitorizacao de quantos valores sairam do PE
    ***************************************************/
    always @(posedge i_clk) begin
        if(i_rst)
            r_o_PE_cnt <= 0;
        else if(w_o_PE)
            r_o_PE_cnt <= r_o_PE_cnt + 1;
    end

    
    /***************************************************
    Monitorizacao da saida do bloco ReLU
    ***************************************************/
    always @(posedge i_clk) begin
        if(i_rst) begin
            r_o_ReLU_cnt <= 0;
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
        if(i_rst) begin
            r_clean_maxp <= 0;
            r_mp_out_rdy <= 0;
            int_maxpool_cnt <= 0;
            
            //Inicializacao dos arrays de entrada e saida do bloco maxpool
            for(i = 0; i < OUT_SIZE/2; i = i + 1)begin
                r_relu_result[i] <= 0;
                r_mp_en[i] <= 0;
            end
        end
        else if(MAXPOOL && (int_maxpool_cnt  < (OUT_SIZE/2)**2)) begin
            //posicoes do array sao preenchidas com valores que saiem do bloco ReLU e vao para os blocos maxpool
            r_relu_result[(r_o_ReLU_cnt/2) - ((r_o_ReLU_cnt / OUT_SIZE) * (OUT_SIZE / 2))] <= w_o_data_ReLU;

            //de duas em duas linhas de saida do bloco ReLU, sao lidas as saidas dos blocos maxpool
            if((r_o_ReLU_cnt % (2*OUT_SIZE)) == 0 && r_o_ReLU_cnt > 0) begin
                
                //ler a saida dos blocos maxpool
                for(i = 0; i < (OUT_SIZE/2); i = i +1) begin

                    //guardar valores
                    int_maxpool_cnt <= int_maxpool_cnt + OUT_SIZE/2;
                    r_maxp_result[i] <= r_maxpool_result[i];

                    //limpar o array que alimenta o bloco maxpool com dados vindos do bloco ReLU
                    //para que os blocos maxpool nao consumam valores antigos e ja processados
                    if(i>0)
                        //a primeira posicao ja foi preenchida com um novo valor, as restantes sao limpas
                        r_relu_result[i] <= 0;
                end
                r_mp_out_rdy <= 1;
                //sinal para os blocos maxpool limparam o registo dos maiores valores recebidos anteriormente
                r_clean_maxp <= 1;

                //primeiro bloco maxpool ja esta a receber um novo valor
                r_mp_en[0] <= 1;
            end
            else begin
                r_mp_en[0] <= 0;
                r_clean_maxp <= 0;
                r_mp_out_rdy <= 0;
            end
        end
        else begin
            r_mp_en[0] <= 0;
            r_clean_maxp <= 0;
            r_mp_out_rdy <= 0;
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
        else if(r_mp_out_rdy) begin
            //sinal para começar a enviar os resultados do maxpool para a saida
            k <= 0;
        end
        else if(k < OUT_SIZE / 2) begin
            //se houver maxpool, k = 0, e inicia-se o envio dos resultados um a um
            o_en <= 1;
            k <= k + 1;
            o_conv_result <= r_maxp_result[k];
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
        if(MAXPOOL)
            for(m = 0; m < (((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1) / 2); m = m +1) begin
                maxpool maxpool_inst (
                    .i_clk(i_clk),
                    .i_rst(i_rst),
                    .i_clean(r_clean_maxp),//para limpar o maior valor das outras operacoes e poder reutilizar os modulos
                    .i_en_mp(r_mp_en[m]),//serve para guardar entrada e ao mesmo tempo limpar o max
                    .i_data(r_relu_result[m]),

                    .o_data(r_maxpool_result[m])
                );
            end 
    endgenerate
endmodule
