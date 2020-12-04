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


module PE #(
    parameter KERNEL_SIZE = 2
    )(
    input wire i_clk,
    input wire [8:0]INMODE, 
    input wire [4:0] OPMODE, 
    input wire signed [29:0] i_DataFM, 
    input wire signed [(KERNEL_SIZE*KERNEL_SIZE*18)-1:0] i_Weight,

    input wire signed [26:0] i_D, 
    output reg signed [47:0] o_P
    );
    
    
    wire [(KERNEL_SIZE*KERNEL_SIZE*48) - 1:0] w_outDSP;
    
    wire [(KERNEL_SIZE*48) - 1:0] w_outRAM;
     
    //last position of array
    always @(*) begin
        o_P = w_outRAM[(KERNEL_SIZE*48) - 1:(KERNEL_SIZE*48) - 1 - 47];
    end
    /*
    2*2 ->  [95:48]  [191:144]
            [47:0]   [95:48]
    
    3*3 ->  [143:96] [287:240]  [431:384]
            [47:0]   [95:48]    [143:96]
    */

    /*Número de shift rams é igual ao tamanho do kernel*/
    generate 
    genvar j;
    for(j=0;j<KERNEL_SIZE*KERNEL_SIZE;j=j+KERNEL_SIZE) begin
        shift_bram #(
            .RAM_WIDTH(48),
            .RAM_DEPTH(1)
        )ram(
            .i_clk(i_clk),
            .i_data(w_outDSP[(48*j)+((KERNEL_SIZE*48)-1):48*j+(KERNEL_SIZE-1)*48]),
            .o_data(w_outRAM[(48*(j/KERNEL_SIZE))+47:48*(j/KERNEL_SIZE)])
        );
    end
    endgenerate  

    generate
    genvar i;
        for(i=0;i<KERNEL_SIZE*KERNEL_SIZE; i = i + 1) begin

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
                .P(w_outDSP[(48*i)+47:48*i]), 
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
                .B(i_Weight[(18*i)+17:18*i]), 
                .C((i>0 & i%KERNEL_SIZE!=0) ? w_outDSP[(48*i)-1:(48*i)-48]:  (i!=0) ? w_outRAM[48*(i/KERNEL_SIZE)-1:48*(i/KERNEL_SIZE)-48] :   0),
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