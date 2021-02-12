`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2021 11:24:40
// Design Name: 
// Module Name: layer_blk
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


module layer_blk#(
    parameter  KERNEL_SIZE = `KERNEL_SIZE,
    parameter  FM_SIZE     = `FM_SIZE,
    parameter  PADDING     = `PADDING,
    parameter  STRIDE      = `STRIDE,
    parameter  MAXPOOL     = `MAXPOOL,
    parameter  IN_FM_CH    = `IN_FM_CH,
    parameter  OUT_FM_CH   = `OUT_FM_CH,
    parameter  DSP_AVAILABLE      = `DSP_AVAILABLE,

  localparam NUM_PE = (DSP_AVAILABLE/(KERNEL_SIZE**2))/OUT_FM_CH,
  localparam real FM_size = FM_SIZE,
  localparam real KERNEL_size = KERNEL_SIZE,
  localparam real stride = STRIDE,
  localparam integer OUT_SIZE = (MAXPOOL == 1) ? (((FM_size - KERNEL_size + 2 * PADDING) / stride) + 1)/2:((FM_size - KERNEL_size + 2 * PADDING) / stride) + 1,             //calculo do tamanho do FM de saída
  localparam integer ROW_NUM1 = (NUM_PE == 1) ? (FM_SIZE + (NUM_PE-1))/NUM_PE:(FM_SIZE + (NUM_PE-1))/NUM_PE + (KERNEL_SIZE-STRIDE),                //Número de linhas a processar por cada PE (exclusão do último)
  localparam integer ROW_NUM2 = (NUM_PE ==1 ) ? ROW_NUM1:(STRIDE < KERNEL_SIZE) ? 
                               (((KERNEL_SIZE%2 == 0 && ROW_NUM1%2 == 0) ||  (KERNEL_SIZE%2 != 0 && ROW_NUM1%2 != 0) ) ? ROW_NUM1: ROW_NUM1 + 1) 
                               :(ROW_NUM1%KERNEL_SIZE > 0) ? ROW_NUM1 + (KERNEL_SIZE - (ROW_NUM1%KERNEL_SIZE)):ROW_NUM1,  
  localparam integer ROW_NUM = (MAXPOOL == 1 && ROW_NUM2%2 != 0) ? ROW_NUM2 + 1:ROW_NUM2,
  localparam integer PE_NUM = $ceil((FM_size/(ROW_NUM-(KERNEL_size-stride)))),                      //Número de PEs possiveis no FM de entrada
  localparam integer BRAM_SIZE = (MAXPOOL == 1) ? ((NUM_PE ==1 ) ? 
                                 ((ROW_NUM-(KERNEL_size-stride)+2*PADDING)/stride)/2:((ROW_NUM-(KERNEL_size-stride)+PADDING)/stride)/2) 
                                 :((NUM_PE == 1 ) ? 
                                 ((ROW_NUM-(KERNEL_size-stride)+2*PADDING)/stride):(ROW_NUM-(KERNEL_size-stride)+PADDING)/stride),                             //Tamanho BRAMs dos PEs (exclusão do último)
                                 
  localparam integer MID_BRAM_SIZE = (PADDING > 0 && NUM_PE > 2) ? (ROW_NUM-(KERNEL_size-stride))/stride:BRAM_SIZE,
  localparam integer IN_BRAM_SIZE = (NUM_PE == 1) ? FM_SIZE:ROW_NUM-(KERNEL_size-stride),
  localparam integer LAST_PE_ROW_NUM1 = FM_SIZE - (PE_NUM-1)*(ROW_NUM-((KERNEL_SIZE-STRIDE))),       //Número de linhas a processar pelo último PE
  localparam integer PE_TO_USE = (LAST_PE_ROW_NUM1 < KERNEL_SIZE) ? PE_NUM - 1: PE_NUM,              //Número de PEs realmente em uso pelo bloco (tendo em conta restrições definidas)
  localparam integer LAST_PE_ROW_NUM = FM_SIZE - (PE_TO_USE-1)*(ROW_NUM-((KERNEL_SIZE-STRIDE))),       /* alterado CARALHO*/
  localparam integer LAST_IN_BRAM_SIZE = (PE_TO_USE == 1) ? FM_SIZE: (LAST_PE_ROW_NUM == ROW_NUM) ?
                        ROW_NUM:ROW_NUM-(KERNEL_size-stride),
  localparam integer LAST_BRAM_SIZE = (MAXPOOL == 1) ? ((LAST_PE_ROW_NUM-(KERNEL_size-stride)+PADDING)/stride)/2:(LAST_PE_ROW_NUM-(KERNEL_size-stride)+PADDING)/stride,                 //Tamanho BRAM do último PE 
  localparam integer BRAM_NUM = (LAST_PE_ROW_NUM == ROW_NUM) ? PE_TO_USE + 1:PE_TO_USE  
)(
    input wire i_clk,
    input wire i_rst,
    input wire signed [(`B_DSP_WIDTH*OUT_FM_CH)-1:0]            i_weight_data,
    input wire signed [(`A_DSP_WIDTH*BRAM_NUM*IN_FM_CH)-1:0]   i_fm_data,
    input wire signed [(`DW*PE_TO_USE*OUT_FM_CH)-1:0]  i_outfm_data,
    
  
    output reg signed [(`DW*PE_TO_USE*OUT_FM_CH)-1:0]  o_conv_result,  //saida para a bram
    output reg [$clog2(IN_BRAM_SIZE*FM_SIZE) -1:0]     o_fm_bram_r_addr,
    output reg                                         o_output_bram_w_en,
    output reg [$clog2(OUT_SIZE**2):0]                 o_output_bram_w_addr,
    output reg [$clog2(OUT_SIZE**2):0]                 o_output_bram_r_addr,
    output reg                                         o_output_last_bram_w_en,
    output reg [$clog2(KERNEL_SIZE**2):0]              o_weight_bram_r_addr,
    output reg o_done
    
);


    wire [(`DW*PE_TO_USE*OUT_FM_CH)-1:0] w_o_conv_blk;
    reg [(`DW*PE_TO_USE*OUT_FM_CH)-1:0]  r_conv_blk;
    
    wire [OUT_FM_CH-1:0] w_o_en;
    reg [OUT_FM_CH-1:0] r_en;
    
    integer out_cnt, fm_bram;
    
    reg r_send_fm, r_weight_en, r_go, r_mux_sel, r_mux_sel1, r_restore_conv;
    
    reg [$clog2(IN_FM_CH):0]    r_fm_to_process;
    wire [(`A_DSP_WIDTH*PE_TO_USE)-1:0] w_fm_data;
    wire [(`A_DSP_WIDTH*BRAM_NUM)-1:0] w_fm_bram_data;
    
    localparam [1:0]    s_idle                  = 2'b00,
                        s_weights_load          = 2'b01,
                        s_fm_load_bram_store    = 2'b10,
                        s_fm_done_process       = 2'b11;
                        
    reg [1:0] r_next_state;    
    
    
    wire signed [(`A_DSP_WIDTH*PE_TO_USE*IN_FM_CH)-1:0]   w_test_bram;
    
    integer out_FM, out_PE;
                    
    always @(posedge i_clk) begin
        if(i_rst) begin
            r_next_state <= s_idle;
            
        end
        else begin
        case(r_next_state)
            s_idle: begin
                if(r_fm_to_process < IN_FM_CH) begin
                    r_next_state <= s_weights_load;
                end
                else begin
                    r_next_state <= s_idle;
                end
            
            end
        
            s_weights_load: begin
                if(o_weight_bram_r_addr == KERNEL_SIZE**2) begin
                    r_next_state <= s_fm_load_bram_store;
                end
                else begin 
                    r_next_state <= s_weights_load;
                end
            
            end
            
            s_fm_load_bram_store: begin
                if(out_cnt >=  BRAM_SIZE*OUT_SIZE - 1) begin
                    r_next_state <= s_fm_done_process;
                end
                else begin
                    r_next_state <= s_fm_load_bram_store;
                end
            end
            
            s_fm_done_process: begin
                r_next_state <= s_idle;
            
            end
        endcase
        end
    end
    
    generate
    genvar i;
        for(i=0;i<OUT_FM_CH;i=i+1) begin
            conv_blk #(
                .KERNEL_SIZE(KERNEL_SIZE),
                .FM_SIZE(FM_SIZE),
                .PADDING(PADDING),
                .STRIDE(STRIDE),
                .MAXPOOL(MAXPOOL),
                .NUM_PE(PE_TO_USE),
                .ROW_NUM(ROW_NUM),
                .LAST_PE_ROW_NUM(LAST_PE_ROW_NUM)
              )convolutional_block1(
                .i_clk(i_clk), 
                .i_rst(r_restore_conv), 
                .i_go(r_go),
                .i_fm_data(w_fm_data),
//                .i_fm_data(w_test_bram),
                .i_weight_en(r_weight_en),
                .i_weight_data(i_weight_data[i*`B_DSP_WIDTH + (`B_DSP_WIDTH-1):i*`B_DSP_WIDTH]),
                .o_en(w_o_en[i]),
                .o_conv_result(w_o_conv_blk[i*`DW*PE_TO_USE + (`DW*PE_TO_USE-1):i*`DW*PE_TO_USE])
            );
        end
    endgenerate
    
    always @(posedge i_clk) begin
        if(i_rst) begin
            r_restore_conv <= 1;
        end
        else if(r_next_state == s_idle) begin
            r_restore_conv <= 1;    
        end
        else begin
            r_restore_conv <= 0;    
        end
        
    end
    
     always @(posedge i_clk) begin
        if(i_rst) begin
            o_conv_result <= 0;
        end
        else if(r_next_state == s_fm_load_bram_store) begin
            for(out_FM = 0; out_FM < OUT_FM_CH; out_FM = out_FM + 1) begin
                for(out_PE = 0; out_PE < PE_TO_USE; out_PE = out_PE + 1) begin
                    if(PE_TO_USE > 1 && out_PE == PE_TO_USE - 1 && o_output_bram_r_addr > LAST_BRAM_SIZE*OUT_SIZE) begin
                        o_conv_result[(out_FM*PE_TO_USE+out_PE)*`DW+:`DW] <= r_conv_blk[(out_FM*PE_TO_USE+out_PE)*`DW+:`DW] + 0;    
                    end
                    else begin
                        o_conv_result[(out_FM*PE_TO_USE+out_PE)*`DW+:`DW] <= r_conv_blk[(out_FM*PE_TO_USE+out_PE)*`DW+:`DW] + i_outfm_data[(out_FM*PE_TO_USE+out_PE)*`DW+:`DW];
                    end
                end
            end
        end

     end
     always @(posedge i_clk) begin
     
         if(r_next_state == s_idle) begin
    
            o_output_bram_r_addr <= 0;
            r_conv_blk <= 0;
            r_en <= 0;
            
        end
        else if(r_next_state == s_fm_load_bram_store) begin
            if(w_o_en[0]) begin
                o_output_bram_r_addr <= o_output_bram_r_addr + 1;
                
            end    
        end
        
        r_conv_blk <= w_o_conv_blk;
        r_en       <= w_o_en;
     end
     
     
      always @(posedge i_clk) begin
        if(i_rst) begin
            o_done <= 0;
            r_fm_to_process <= 0;
        end
        else if(r_next_state == s_idle) begin
            o_done <= 0;
        end
        else if(r_next_state == s_fm_done_process) begin
            if(r_fm_to_process == IN_FM_CH - 1) begin
                o_done <= 1; 
            end
            r_fm_to_process <= r_fm_to_process + 1;    
        end
    
     end   


  /***************************************************
  Escrita no ficheiro e na bram do ouput do conv_blk
  ***************************************************/
  always@(posedge i_clk) begin
    if(r_next_state == s_idle) begin
        out_cnt <= 0;
        o_output_bram_w_en <= 0;
        o_output_last_bram_w_en <= 0;
        o_output_bram_w_addr <= -1;
        
    end
    else if(r_next_state == s_fm_load_bram_store) begin   
        if(r_en[0]) begin
                out_cnt <= out_cnt + 1;
        
                o_output_bram_w_addr <= o_output_bram_w_addr + 1;//comeca a -1 por causa do delay
//                o_output_bram_r_addr <= o_output_bram_r_addr + 1;
    
                if(ROW_NUM >= LAST_PE_ROW_NUM) begin
                
                    if(out_cnt <  BRAM_SIZE*OUT_SIZE) begin
                        if(out_cnt <= LAST_BRAM_SIZE*OUT_SIZE) begin
                            o_output_last_bram_w_en <= 1;
//                            o_output_last_bram_w_en <= 2**r_fm_to_process;
                        end
                        else begin
                            o_output_last_bram_w_en <= 0;
                        end
                        
//                        o_output_bram_w_en <= 2**r_fm_to_process;
                            o_output_bram_w_en <= 1;    
                 
                    end  
                        
                 end
                 else begin 
                    if(out_cnt >=  LAST_BRAM_SIZE*OUT_SIZE) begin
                        o_output_bram_w_en <= 0;    
                        o_output_last_bram_w_en <= 0;
                    end 
                    else begin
//                        o_output_bram_w_en <= 2**r_fm_to_process;
                        o_output_bram_w_en <= 1;   
//                        o_output_last_bram_w_en <= 2**r_fm_to_process;
                        o_output_last_bram_w_en <= 1;
                    end
                 end
                 
            end
            else begin
              o_output_bram_w_en <= 0;
              o_output_last_bram_w_en <= 0; /*  alterado */
            end
           end

  end

  /***************************************************
  Envio dos pesos e feature map das brams para o conv_blk
  ***************************************************/
  always@(posedge i_clk) begin
    if(r_next_state == s_idle) begin
        o_weight_bram_r_addr <= 0;
        r_weight_en <= 0;
        r_send_fm <= 0;
        
    end
    else if(r_next_state == s_weights_load) begin
        if(o_weight_bram_r_addr < KERNEL_SIZE**2)begin
          o_weight_bram_r_addr <= o_weight_bram_r_addr + 1;
          r_weight_en <= 1;
    
        end
        else begin
          //o_weight_bram_r_addr <= 0;
          r_weight_en <= 0;
          r_send_fm <= 1;
        end
   end
  end
    
  always@(posedge i_clk) begin
  
    if(r_next_state == s_idle) begin
        
        o_fm_bram_r_addr <= 0;
        r_mux_sel <= 0;
        r_mux_sel1 <= 0;
        r_go <= 0;
    end
    else if(r_next_state == s_fm_load_bram_store) begin
        if(r_send_fm && (o_fm_bram_r_addr < (IN_BRAM_SIZE*FM_SIZE-1)))begin
          o_fm_bram_r_addr <= o_fm_bram_r_addr + 1;
          r_go <= 1;
        end
        else begin
            if(o_fm_bram_r_addr == (IN_BRAM_SIZE*FM_SIZE -1)) begin
                r_mux_sel1 <= 1;
            end      
            
          o_fm_bram_r_addr <= 0;
    
        end
        
        if(r_mux_sel1 == 1) begin
            r_mux_sel <= 1;
        end
   end
  end
  
  
    generate 
    genvar PE_num;
    
    for(PE_num = 0; PE_num < PE_TO_USE; PE_num = PE_num + 1) begin
     
        mux #( 
            .WIDTH(30)
        )mux_PE(
            
            .a_in(w_fm_bram_data[PE_num*30 + (30-1):PE_num*30]),
            .b_in(((PE_num == PE_TO_USE - 1) && (PE_TO_USE == BRAM_NUM)) ? 30'd0 : w_fm_bram_data[(PE_num+1)*30 + (30-1):(PE_num+1)*30]),
            .sel(r_mux_sel),
            .out(w_fm_data[PE_num*30 + (30-1):PE_num*30])
        );

    end
    endgenerate
    
    selector #( 
        .WIDTH(30),
        .IN_CH(IN_FM_CH),
        .PE_NUM(BRAM_NUM)
    )selector_FM(
        .i_data(i_fm_data),
        .i_ch_sel(r_fm_to_process),
        .out(w_fm_bram_data)
    );
    
    blk_mem_gen_0 #()BRAM0(
        .addra(o_fm_bram_r_addr),
        .clka(i_clk),
        .dina(0),
        .douta(w_test_bram),
        .ena(1),
        .wea(0)
    );
    
endmodule
