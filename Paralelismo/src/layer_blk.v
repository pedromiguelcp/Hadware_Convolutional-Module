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
`include "global.v"

module layer_blk#(
    parameter  kernel_size = `KERNEL_SIZE,
    parameter  fm_size     = `FM_SIZE,
    parameter  padding     = `PADDING,
    parameter  stride      = `STRIDE,
    parameter  maxpool     = `MAXPOOL,
    parameter  in_fm_ch    = `IN_FM_CH,
    parameter  out_fm_ch   = `OUT_FM_CH,
    parameter  dsp_available    = `DSP_AVAILABLE,
    parameter  bram_available = `BRAM_AVAILABLE,

  /* localparam real usados para arredondamentos dos valores nas eqs. abaixo */
  parameter real fm_size1 = fm_size,
  parameter real kernel_size1 = kernel_size,
  parameter real stride1 = stride,
  parameter real out_fm_ch1 = out_fm_ch,
  parameter integer out_size = (maxpool == 1) ? (((fm_size1 - kernel_size1 + 2 * padding) / stride1) + 1)/2:((fm_size1 - kernel_size1 + 2 * padding) / stride1) + 1,             //calculo do tamanho do FM de saída
  parameter integer memory_available = bram_available*`BRAM_MEMORY_BIT,
  parameter integer memory_each_filter = out_size**2*`DW,
  parameter integer num_parallel_filter = (memory_available/memory_each_filter > out_fm_ch) ? out_fm_ch:memory_available/memory_each_filter,
  parameter integer num_pe = dsp_available/(num_parallel_filter*kernel_size**2),
  parameter integer num_iterations = $ceil(out_fm_ch1/num_parallel_filter),
  parameter integer num_filter_last_it = (out_fm_ch - (num_iterations-1)*num_parallel_filter),
  parameter integer row_num1 = (num_pe == 1) ? (fm_size + (num_pe-1))/num_pe:(fm_size + (num_pe-1))/num_pe + (kernel_size-stride),                //Número de linhas a processar por cada PE (exclusão do último)
  parameter integer row_num2 = (num_pe ==1 ) ? row_num1:(stride < kernel_size) ? 
                               (((kernel_size%2 == 0 && row_num1%2 == 0) ||  (kernel_size%2 != 0 && row_num1%2 != 0) ) ? row_num1: row_num1 + 1) 
                               :(row_num1%kernel_size > 0) ? row_num1 + (kernel_size - (row_num1%kernel_size)):row_num1,  
  parameter integer row_num = (maxpool == 1 && row_num2%2 != 0) ? row_num2 + 1:row_num2,
  parameter integer pe_num = $ceil((fm_size1/(row_num-(kernel_size1-stride1)))),                      //Número de PEs possiveis no FM de entrada
  parameter integer bram_size = (maxpool == 1) ? ((num_pe ==1 ) ? 
                                 ((row_num-(kernel_size1-stride1)+2*padding)/stride1)/2:((row_num-(kernel_size1-stride1)+padding)/stride1)/2) 
                                 :((num_pe == 1 ) ? 
                                 ((row_num-(kernel_size1-stride1)+2*padding)/stride1):(row_num-(kernel_size1-stride1)+padding)/stride1),                             //Tamanho BRAMs dos PEs (exclusão do último)                                 
  parameter integer mid_bram_size = (padding > 0 && num_pe > 2) ? (row_num-(kernel_size1-stride1))/stride1:bram_size,
  parameter integer in_bram_size = (num_pe == 1) ? fm_size:row_num-(kernel_size1-stride1),
  parameter integer last_pe_row_num1 = fm_size - (pe_num-1)*(row_num-((kernel_size-stride))),       //Número de linhas a processar pelo último PE
  parameter integer pe_to_use = (last_pe_row_num1 < kernel_size) ? pe_num - 1: pe_num,              //Número de PEs realmente em uso pelo bloco (tendo em conta restrições definidas)
  parameter integer last_pe_row_num = fm_size - (pe_to_use-1)*(row_num-((kernel_size-stride))),       /* alterado CARALHO*/
  
  parameter integer last_in_bram_size = (pe_to_use == 1) ? fm_size: (last_pe_row_num == row_num) ?
                        (kernel_size1-stride1):row_num-(kernel_size1-stride1),
  parameter integer last_bram_size = (maxpool == 1) ? ((last_pe_row_num-(kernel_size1-stride1)+padding)/stride1)/2:(last_pe_row_num-(kernel_size1-stride1)+padding)/stride1,                //Tamanho BRAM do último PE 
  parameter integer bram_num = (pe_to_use == 1) ? pe_to_use: (last_pe_row_num == row_num) ? pe_to_use + 1:pe_to_use



)(
    input wire i_clk,
    input wire i_rst,
    input wire i_ready_read,
    input wire signed [(18*out_fm_ch)-1:0]            i_weight_data,
    input wire signed [(30*bram_num*in_fm_ch)-1:0]   i_fm_data,
    input wire signed [(48*pe_to_use*num_parallel_filter)-1:0]  i_outfm_data,

    
  
    output reg signed [(48*pe_to_use*num_parallel_filter)-1:0]  o_conv_result,  //saida para a bram
    output reg [$clog2(in_bram_size*fm_size)-1:0]     o_fm_bram_r_addr,
    output reg [num_iterations-1:0]                    o_output_bram_w_en,
    output reg [$clog2(out_size**2)-1:0]                 o_output_bram_w_addr,
    output reg [$clog2(out_size**2)-1:0]                 o_output_bram_r_addr,
    output reg [num_iterations-1:0]                    o_output_last_bram_w_en,
    output reg [$clog2(kernel_size**2*in_fm_ch*num_parallel_filter)-1:0]     o_weight_bram_r_addr,
    output reg o_done,
    output reg o_load_fm
    
);


    wire [(`DW*pe_to_use*num_parallel_filter)-1:0] w_o_conv_blk; 
    reg [(`DW*pe_to_use*num_parallel_filter)-1:0]  r_conv_blk;
    
    wire [num_parallel_filter-1:0] w_o_en;
    reg [num_parallel_filter-1:0] r_en;
    
    integer out_cnt, fm_bram;
    
    reg r_send_fm, r_weight_en, r_go, r_mux_sel, r_mux_sel1, r_restore_conv;
    
    reg [$clog2(in_fm_ch):0]       r_fm_to_process;
    reg [$clog2(out_fm_ch):0]      r_weight_to_process;
    
    wire [(`A_DSP_WIDTH*pe_to_use)-1:0] w_fm_data;
    wire [(`A_DSP_WIDTH*bram_num)-1:0] w_fm_bram_data;
    wire signed [(`B_DSP_WIDTH*num_parallel_filter)-1:0] w_weight_data;
    wire signed [(`DW*pe_to_use*num_parallel_filter)-1:0]  w_outfm_data;
    
    localparam [1:0]    s_idle                  = 2'b00,
                        s_weights_load          = 2'b01,
                        s_fm_load_bram_store    = 2'b10,
                        s_fm_done_process       = 2'b11;
                        
    reg [1:0] r_next_state;  
    
    wire signed [(`A_DSP_WIDTH*pe_to_use*in_fm_ch)-1:0]   w_test_bram;
    
    integer out_FM, out_PE;
    
  /***************************************************
                    State machine
  ***************************************************/                
    always @(posedge i_clk) begin
        if(i_rst) begin
            r_next_state <= s_idle;
            
        end
        else begin
        case(r_next_state)
            s_idle: begin
                if(r_weight_to_process < num_iterations && o_done == 0) begin
                    r_next_state <= s_weights_load;
                end
                else begin
                    r_next_state <= s_idle;
                end
            
            end
        
            s_weights_load: begin
                if(o_weight_bram_r_addr == kernel_size**2*(r_fm_to_process+1)) begin
                    r_next_state <= s_fm_load_bram_store;
                end
                else begin 
                    r_next_state <= s_weights_load;
                end
            
            end
            
            s_fm_load_bram_store: begin
                if(out_cnt >=  bram_size*out_size - 1) begin
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
   
   
  /***************************************************
     Restore conv_block state, reset all param
  ***************************************************/ 
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
    
  /***************************************************
     Send conv_block values to output brams
  ***************************************************/    
     always @(posedge i_clk) begin
        if(i_rst) begin
            o_conv_result <= 0;
        end
        else if(r_next_state == s_fm_load_bram_store) begin
            for(out_FM = 0; out_FM < num_parallel_filter; out_FM = out_FM + 1) begin
                for(out_PE = 0; out_PE < pe_to_use; out_PE = out_PE + 1) begin
                    if(r_fm_to_process == 0 || in_fm_ch == 1 || (pe_to_use > 1 && out_PE == pe_to_use - 1 && o_output_bram_r_addr > last_bram_size*out_size)) begin
                        o_conv_result[(out_FM*pe_to_use+out_PE)*`DW+:`DW] <= r_conv_blk[(out_FM*pe_to_use+out_PE)*`DW+:`DW] + 0;    
                    end
                    else begin
                        o_conv_result[(out_FM*pe_to_use+out_PE)*`DW+:`DW] <= r_conv_blk[(out_FM*pe_to_use+out_PE)*`DW+:`DW] + w_outfm_data[(out_FM*pe_to_use+out_PE)*`DW+:`DW];
                    end
                end
            end
        end

     end
    
   /***************************************************
     Read from output brams to sum previous output values
        increment bram_addr
  ***************************************************/  
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
     
   /***************************************************
     Update num of processed filters, in_FM, 
     check if maximum is reached
  ***************************************************/   
      always @(posedge i_clk) begin
        if(i_rst) begin
            o_done <= 0;
            r_fm_to_process <= 0;
            r_weight_to_process <= 0;
            o_load_fm <= 0;
        end
        else if(r_next_state == s_idle) begin   
            o_load_fm <= 0; 
            if(i_ready_read == 1) begin
                o_done <= 0;   
            end
        end
        else if(r_next_state == s_fm_done_process) begin
//            if((r_fm_to_process == in_fm_ch - 1) && (r_weight_to_process == num_iterations - 1)) begin
////                o_done <= 1; 
//            end
            o_load_fm <= 1;
            if(r_fm_to_process < in_fm_ch - 1) begin
                r_fm_to_process <= r_fm_to_process + 1; 
                
            end
            else begin
//            else if(r_weight_to_process < num_iterations - 1)begin
                r_weight_to_process <= r_weight_to_process + 1; 
                o_done <= 1; 
                r_fm_to_process <= 0;  
            end          
        end
    
     end   


  /***************************************************
    update output bram_addr to save conv_block values
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
    
                if(row_num >= last_pe_row_num) begin
                
                    if(out_cnt <  bram_size*out_size) begin
                        if(out_cnt <= last_bram_size*out_size) begin
                            o_output_last_bram_w_en <= 1;
//                            o_output_last_bram_w_en <= 2**r_weight_to_process;
                        end
                        else begin
                            o_output_last_bram_w_en <= 0;
                        end
                        
//                        o_output_bram_w_en <= 2**r_weight_to_process;
                            o_output_bram_w_en <= 1;    
                 
                    end  
                        
                 end
                 else begin 
                    if(out_cnt >=  last_bram_size*out_size) begin
                        o_output_bram_w_en <= 0;    
                        o_output_last_bram_w_en <= 0;
                    end 
                    else begin
//                        o_output_bram_w_en <= 2**r_weight_to_process;
                        o_output_bram_w_en <= 1;   
//                        o_output_last_bram_w_en <= 2**r_weight_to_process;
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
    update read bram_addr from weight and in_FM brams
  ***************************************************/
  always@(posedge i_clk) begin
    if(r_next_state == s_idle) begin
        o_weight_bram_r_addr <= kernel_size**2*r_fm_to_process;
        r_weight_en <= 0;
        r_send_fm <= 0;
        
    end
    else if(r_next_state == s_weights_load) begin
        if(o_weight_bram_r_addr < kernel_size**2*(r_fm_to_process+1))begin
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
        if(r_send_fm && (o_fm_bram_r_addr < (in_bram_size*fm_size-1)))begin
          o_fm_bram_r_addr <= o_fm_bram_r_addr + 1;
          r_go <= 1;
        end
        else begin
            if(o_fm_bram_r_addr == (in_bram_size*fm_size -1)) begin
                r_mux_sel1 <= 1;
            end      
            
          o_fm_bram_r_addr <= 0;
    
        end
        
        if(r_mux_sel1 == 1) begin
            r_mux_sel <= 1;
        end
   end
  end
  
   /***************************************************
    Generate "num_parallel_filter" conv_block
  ***************************************************/    
    generate
    genvar i;
        for(i=0;i<num_parallel_filter;i=i+1) begin
            conv_blk #(
                .KERNEL_SIZE(kernel_size),
                .FM_SIZE(fm_size),
                .PADDING(padding),
                .STRIDE(stride),
                .MAXPOOL(maxpool),
                .NUM_PE(pe_to_use),
                .ROW_NUM(row_num),
                .LAST_PE_ROW_NUM(last_pe_row_num)
              )convolutional_block1(
                .i_clk(i_clk), 
                .i_rst(r_restore_conv), 
                .i_go(r_go),
                .i_fm_data(w_fm_data),
//                .i_fm_data(w_test_bram),
                .i_weight_en(r_weight_en),
                .i_weight_data(w_weight_data[i*`B_DSP_WIDTH + (`B_DSP_WIDTH-1):i*`B_DSP_WIDTH]),
                .o_en(w_o_en[i]),
                .o_conv_result(w_o_conv_blk[i*`DW*pe_to_use + (`DW*pe_to_use-1):i*`DW*pe_to_use])
            );
        end
    endgenerate
     
  /***************************************************
    Generate 1 Mux block per each two in_FM brams
  ***************************************************/  
    generate 
    genvar PE_num;
    
    for(PE_num = 0; PE_num < pe_to_use; PE_num = PE_num + 1) begin
     
        mux #( 
            .WIDTH(30)
        )mux_PE(
            
            .a_in(w_fm_bram_data[PE_num*30 + (30-1):PE_num*30]),
            .b_in(((PE_num == pe_to_use - 1) && (pe_to_use == bram_num)) ? 30'd0 : w_fm_bram_data[(PE_num+1)*30 + (30-1):(PE_num+1)*30]),
            .sel(r_mux_sel),
            .out(w_fm_data[PE_num*30 + (30-1):PE_num*30])
        );

    end
    endgenerate
    
   /***************************************************
    selectors block for controling acces to in_FM,
    weights and out_FM brams
  ***************************************************/  
    selector #( 
        .WIDTH(`A_DSP_WIDTH),
        .IN_CH(in_fm_ch),
        .OUT_NUM(bram_num)
    )selector_FM(
        .i_data(i_fm_data),
        .i_ch_sel(r_fm_to_process),
        .out(w_fm_bram_data)
    );
    
    selector #( 
        .WIDTH(`B_DSP_WIDTH),
        .IN_CH(out_fm_ch),
        .OUT_NUM(num_parallel_filter)
    )selector_FILTER(
        .i_data(i_weight_data),
        .i_ch_sel(r_weight_to_process),
        .out(w_weight_data)
    );
    
    selector #( 
        .WIDTH(`DW),
        .IN_CH(1),
        .OUT_NUM(num_parallel_filter*pe_to_use)
    )selector_OUT_FM(
        .i_data(i_outfm_data),
        .i_ch_sel(0),
        .out(w_outfm_data)
    );

   
    
endmodule
