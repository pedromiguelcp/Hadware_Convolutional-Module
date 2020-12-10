`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2020 04:49:54 PM
// Design Name: 
// Module Name: PE
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

module PE #(
  parameter KERNEL_SIZE = 4,
  parameter FM_SIZE = 5,
  parameter PADDING = 0,
  parameter STRIDE = 1
)(
    input wire i_clk,
    input wire signed [`A_DSP_WIDTH-1:0] i_DataFM, 
    input wire signed [(KERNEL_SIZE*KERNEL_SIZE*`B_DSP_WIDTH)-1:0] i_Weight,
    input wire i_en, 

    output reg o_en, //sinal para dizer quando tem saída válida
    output reg signed [`OUTPUT_DSP_WIDTH-1:0] o_P
    );
    
    /*tamanho da saída
        W2 = (W1 - F + 2P) / S + 1
        H2 = (H1 - F + 2P) / S + 1
    */
    reg [$clog2(KERNEL_SIZE*FM_SIZE) +1:0] r_out_cnt;//contar até KERNEL_SIZE*FM_SIZE + 1b para o sinal  
    reg r_cnt;
    
    //saída de cada DSP
    wire [(KERNEL_SIZE*KERNEL_SIZE*48) - 1:0] w_outDSP;

    //saída das shift rams -> quantidade = tamanho kernel
    wire [(KERNEL_SIZE*48) - 1:0] w_outRAM;
     

    /*Saida = ultima posicao do w_outRAM 
    a menos que KERNEL_SIZE == FM_SIZE pois nao sao usadas shiftrams*/
    always @(*) begin
        o_P = (KERNEL_SIZE != FM_SIZE) ?  
                        w_outRAM[(KERNEL_SIZE*48) - 1:(KERNEL_SIZE*48) - 48] :
                        w_outDSP[(KERNEL_SIZE*KERNEL_SIZE*48) - 1:(KERNEL_SIZE*KERNEL_SIZE*48) - 48];
    end

    /*Controlo para enviar sinal para fora quando houver resultados validos da convolucao*/
    always @(posedge i_clk) begin
        if(i_en) begin
            r_out_cnt <= r_out_cnt + 1;
            /* verifica se foi dado o 1reset do count */
            if(r_cnt == 0) begin
                if(r_out_cnt + 2 == (KERNEL_SIZE*FM_SIZE) + 2) begin
                    r_out_cnt <= 0;
                    r_cnt <= 1;//No proximo clock comeca a sair resultados da convolucao
                end
            end 
            else if((r_out_cnt[$clog2(KERNEL_SIZE*FM_SIZE) +1] != 1)) begin//enquanto r_out_cnt < 0 os resultados sao invalidos (intervalos), portanto sinal o_en mantem-se 0
                if((r_out_cnt  < ((FM_SIZE-KERNEL_SIZE) + 1)) || ((KERNEL_SIZE == 1) && (STRIDE == 1))) begin//se KERNEL_SIZE=1 ou enquanto saem os resultados de uma linha, valores sao sempre validos
                    if(r_out_cnt % STRIDE == 0) begin//rejeitar valores intermédios de acordo com o stride
                        o_en <= 1;
                    end
                    else
                        o_en <= 0;
                end
                else begin
                    r_out_cnt <= 2 - KERNEL_SIZE - (STRIDE-1)*FM_SIZE;//Intervalo entre valores validos
                    o_en <= 0;
                end
            end
                
        end
        else begin
            r_cnt <= 0;
            o_en <= 0;
            r_out_cnt <= 0;
        end  
    end

    /*Número de shift rams = tamanho do kernel*/
    generate 
    genvar j;
    if(KERNEL_SIZE != FM_SIZE) begin
        for(j=0;j<KERNEL_SIZE*KERNEL_SIZE;j=j+KERNEL_SIZE) begin
            shift_bram #(
                .RAM_WIDTH(`OUTPUT_DSP_WIDTH),
                .RAM_DEPTH(FM_SIZE-KERNEL_SIZE)
            )ram(
                .i_clk(i_clk),
                .i_data(w_outDSP[(`OUTPUT_DSP_WIDTH*j)+((KERNEL_SIZE*`OUTPUT_DSP_WIDTH)-1):`OUTPUT_DSP_WIDTH*j+(KERNEL_SIZE-1)*`OUTPUT_DSP_WIDTH]),
                .o_data(w_outRAM[(`OUTPUT_DSP_WIDTH*(j/KERNEL_SIZE))+(`OUTPUT_DSP_WIDTH-1):`OUTPUT_DSP_WIDTH*(j/KERNEL_SIZE)])
            );
        end
    end
    endgenerate 

    /*Numero de DSPs = tamanho de pesos num filtro*/
    generate
    genvar i;
        if(KERNEL_SIZE == FM_SIZE) begin
            for(i=0;i<KERNEL_SIZE*KERNEL_SIZE;i=i+1) begin
            DSP48E2#(
                .AMULTSEL("AD"), 
                .A_INPUT("DIRECT"),  
                .BMULTSEL("B"),   
                .USE_MULT("MULTIPLY"),
                .PREADDINSEL("A"),   
                .RND(48'h000000000000), 
                .USE_SIMD("ONE48"), 
                .USE_WIDEXOR("FALSE"), 
                .XORSIMD("XOR24_48_96"), 
                .AUTORESET_PATDET("NO_RESET"),
                .AUTORESET_PRIORITY("RESET"), 
                .MASK(48'h000000000fff),  // INITIAL VALUE : 48'h3fffffffffff
                .PATTERN(48'h000000000000),
                .SEL_MASK("MASK"), 
                .SEL_PATTERN("PATTERN"),
                .USE_PATTERN_DETECT("PATDET"), 
                .IS_ALUMODE_INVERTED(4'b0000), 
                .IS_CARRYIN_INVERTED(1'b0), 
                .IS_CLK_INVERTED(1'b0), 
                .IS_INMODE_INVERTED(5'b00000), 
                .IS_OPMODE_INVERTED(9'b000000000), 
                .IS_RSTALLCARRYIN_INVERTED(1'b0), 
                .IS_RSTALUMODE_INVERTED(1'b0),
                .IS_RSTA_INVERTED(1'b0), 
                .IS_RSTB_INVERTED(1'b0), 
                .IS_RSTCTRL_INVERTED(1'b0), 
                .IS_RSTC_INVERTED(1'b0), 
                .IS_RSTD_INVERTED(1'b0), 
                .IS_RSTINMODE_INVERTED(1'b0), 
                .IS_RSTM_INVERTED(1'b0), 
                .IS_RSTP_INVERTED(1'b0),  
                .ACASCREG(1), 
                .ADREG(1), 
                .ALUMODEREG(0), 
                .AREG(1),
                .BCASCREG(1), 
                .BREG(1), 
                .CARRYINREG(1),
                .CARRYINSELREG(1), 
                .CREG(0), 
                .DREG(1), 
                .INMODEREG(1), 
                .MREG(0), 
                .OPMODEREG(1), 
                .PREG(1)
            ) 
            DSP48E2_inst (
                //.ACOUT(ACOUT), 
                //.BCOUT(BCOUT), 
                //.CARRYCASCOUT(CARRYCASCOUT), 
                //.MULTSIGNOUT(MULTSIGNOUT), 
                //.PCOUT(PCOUT), 
                //.OVERFLOW(OVERFLOW), 
                //.PATTERNBDETECT(PATTERNBDETECT), 
                //.PATTERNDETECT(PATTERNDETECT), 
                //.UNDERFLOW(UNDERFLOW), 
                //.CARRYOUT(CARRYOUT), 
                .P(w_outDSP[(`OUTPUT_DSP_WIDTH*i)+(`OUTPUT_DSP_WIDTH-1):`OUTPUT_DSP_WIDTH*i]), 
                //.XOROUT(XOROUT), 
                //.ACIN(ACIN), 
                //.BCIN(BCIN), 
                //.CARRYCASCIN(CARRYCASCIN), 
                //.MULTSIGNIN(MULTSIGNIN), 
                .PCIN(0),  
                .ALUMODE(4'd0), 
                .CARRYINSEL(3'd0), 
                .CLK(i_clk), 
                .INMODE(5'd0), // A * B
                .OPMODE(9'b000110101), // (A * B) + C
                //.RSTINMODE(RSTINMODE), 
                .A(i_DataFM), 
                .B(i_Weight[(`B_DSP_WIDTH*i)+(`B_DSP_WIDTH-1):`B_DSP_WIDTH*i]),
                .C((i>0) ? w_outDSP[(`OUTPUT_DSP_WIDTH*i)-1:(`OUTPUT_DSP_WIDTH*i)-`OUTPUT_DSP_WIDTH]: 0),  
                .CARRYIN(1'd0), 
                //.D(D),
                .CEA1(1), 
                .CEA2(1),
                .CEAD(1), 
                .CEALUMODE(1), 
                .CEB1(1), 
                .CEB2(1), 
                .CEC(1), 
                //.CECARRYIN(CECARRYIN), 
                .CECTRL(1), 
                //.CED(CED), 
                .CEINMODE(1), 
                .CEM(1), 
                .CEP(1), 
                .RSTA(0), 
                //.RSTALLCARRYIN(RSTALLCARRYIN), 
                .RSTALUMODE(0), 
                .RSTB(0), 
                .RSTC(0), 
                .RSTCTRL(0), 
                //.RSTD(RSTD), 
                .RSTM(0), 
                .RSTP(0) 
            );
        end
        end
        else for(i=0;i<KERNEL_SIZE*KERNEL_SIZE;i=i+1) begin
            DSP48E2#(
                .AMULTSEL("AD"), 
                .A_INPUT("DIRECT"),  
                .BMULTSEL("B"),   
                .USE_MULT("MULTIPLY"),
                .PREADDINSEL("A"),   
                .RND(48'h000000000000), 
                .USE_SIMD("ONE48"), 
                .USE_WIDEXOR("FALSE"), 
                .XORSIMD("XOR24_48_96"), 
                .AUTORESET_PATDET("NO_RESET"),
                .AUTORESET_PRIORITY("RESET"), 
                .MASK(48'h000000000fff),  // INITIAL VALUE : 48'h3fffffffffff
                .PATTERN(48'h000000000000),
                .SEL_MASK("MASK"), 
                .SEL_PATTERN("PATTERN"),
                .USE_PATTERN_DETECT("PATDET"), 
                .IS_ALUMODE_INVERTED(4'b0000), 
                .IS_CARRYIN_INVERTED(1'b0), 
                .IS_CLK_INVERTED(1'b0), 
                .IS_INMODE_INVERTED(5'b00000), 
                .IS_OPMODE_INVERTED(9'b000000000), 
                .IS_RSTALLCARRYIN_INVERTED(1'b0), 
                .IS_RSTALUMODE_INVERTED(1'b0),
                .IS_RSTA_INVERTED(1'b0), 
                .IS_RSTB_INVERTED(1'b0), 
                .IS_RSTCTRL_INVERTED(1'b0), 
                .IS_RSTC_INVERTED(1'b0), 
                .IS_RSTD_INVERTED(1'b0), 
                .IS_RSTINMODE_INVERTED(1'b0), 
                .IS_RSTM_INVERTED(1'b0), 
                .IS_RSTP_INVERTED(1'b0),  
                .ACASCREG(1), 
                .ADREG(1), 
                .ALUMODEREG(0), 
                .AREG(1),
                .BCASCREG(1), 
                .BREG(1), 
                .CARRYINREG(1),
                .CARRYINSELREG(1), 
                .CREG(0), 
                .DREG(1), 
                .INMODEREG(1), 
                .MREG(0), 
                .OPMODEREG(1), 
                .PREG(1)
            ) 
            DSP48E2_inst (
                //.ACOUT(ACOUT), 
                //.BCOUT(BCOUT), 
                //.CARRYCASCOUT(CARRYCASCOUT), 
                //.MULTSIGNOUT(MULTSIGNOUT), 
                //.PCOUT(PCOUT), 
                //.OVERFLOW(OVERFLOW), 
                //.PATTERNBDETECT(PATTERNBDETECT), 
                //.PATTERNDETECT(PATTERNDETECT), 
                //.UNDERFLOW(UNDERFLOW), 
                //.CARRYOUT(CARRYOUT), 
                .P(w_outDSP[(`OUTPUT_DSP_WIDTH*i)+(`OUTPUT_DSP_WIDTH-1):`OUTPUT_DSP_WIDTH*i]), 
                //.XOROUT(XOROUT), 
                //.ACIN(ACIN), 
                //.BCIN(BCIN), 
                //.CARRYCASCIN(CARRYCASCIN), 
                //.MULTSIGNIN(MULTSIGNIN), 
                .PCIN(0),  
                .ALUMODE(4'd0), 
                .CARRYINSEL(3'd0), 
                .CLK(i_clk), 
                .INMODE(5'd0), 
                .OPMODE(9'b000110101), 
                //.RSTINMODE(RSTINMODE), 
                .A(i_DataFM), 
                .B(i_Weight[(`B_DSP_WIDTH*i)+(`B_DSP_WIDTH-1):`B_DSP_WIDTH*i]),
                .C((i>0 & i%KERNEL_SIZE!=0) ? w_outDSP[(`OUTPUT_DSP_WIDTH*i)-1:(`OUTPUT_DSP_WIDTH*i)-`OUTPUT_DSP_WIDTH]:  (i!=0) ? 
                                              w_outRAM[`OUTPUT_DSP_WIDTH*(i/KERNEL_SIZE)-1:`OUTPUT_DSP_WIDTH*(i/KERNEL_SIZE)-`OUTPUT_DSP_WIDTH] :   0),  
                .CARRYIN(1'd0), 
                //.D(D),
                .CEA1(1), 
                .CEA2(1),
                .CEAD(1), 
                .CEALUMODE(1), 
                .CEB1(1), 
                .CEB2(1), 
                .CEC(1), 
                //.CECARRYIN(CECARRYIN), 
                .CECTRL(1), 
                //.CED(CED), 
                .CEINMODE(1), 
                .CEM(1), 
                .CEP(1), 
                .RSTA(0), 
                //.RSTALLCARRYIN(RSTALLCARRYIN), 
                .RSTALUMODE(0), 
                .RSTB(0), 
                .RSTC(0), 
                .RSTCTRL(0), 
                //.RSTD(RSTD), 
                .RSTM(0), 
                .RSTP(0) 
            );
        end
    endgenerate
    
 
endmodule
