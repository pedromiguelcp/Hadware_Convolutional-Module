`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.01.2021 09:59:33
// Design Name: 
// Module Name: layer_blk_tb
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


module layer_blk_tb #(
  parameter KERNEL_SIZE     = 3,
  parameter FM_SIZE         = 252,
  parameter PADDING         = 0,
  parameter STRIDE          = 1,
  parameter MAXPOOL         = 0,
  parameter DSP_AVAILABLE   = 100,
  parameter IN_FM_CH        = 1,
  parameter OUT_FM_CH       = 2,
  
  /* localparam real usados para arredondamentos dos valores nas eqs. abaixo */
  
  localparam NUM_PE = (DSP_AVAILABLE/(KERNEL_SIZE**2))/OUT_FM_CH,
  localparam real FM_size = FM_SIZE,
  localparam real KERNEL_size = KERNEL_SIZE,
  localparam real stride = STRIDE,
  localparam integer OUT_SIZE   = (MAXPOOL == 1) ? (((FM_size - KERNEL_size + 2 * PADDING) / stride) + 1)/2:((FM_size - KERNEL_size + 2 * PADDING) / stride) + 1,             //calculo do tamanho do FM de saída
  localparam integer ROW_NUM1 = (NUM_PE == 1) ? (FM_SIZE + (NUM_PE-1))/NUM_PE:(FM_SIZE + (NUM_PE-1))/NUM_PE + (KERNEL_SIZE-STRIDE),                //Número de linhas a processar por cada PE (exclusão do último)
  localparam integer ROW_NUM2 = (NUM_PE ==1 ) ? ROW_NUM1:(STRIDE < KERNEL_SIZE) ? 
                               (((KERNEL_SIZE%2 == 0 && ROW_NUM1%2 == 0) ||  (KERNEL_SIZE%2 != 0 && ROW_NUM1%2 != 0) ) ? ROW_NUM1: ROW_NUM1 + 1) 
                               :(ROW_NUM1%KERNEL_SIZE > 0) ? ROW_NUM1 + (KERNEL_SIZE - (ROW_NUM1%KERNEL_SIZE)):ROW_NUM1,  
  localparam integer ROW_NUM = (MAXPOOL == 1 && ROW_NUM2%2 != 0) ? ROW_NUM2 + 1:ROW_NUM2,
  localparam integer PE_NUM = $ceil((FM_size/(ROW_NUM-(KERNEL_size-stride)))),                      //Número de PEs possiveis no FM de entrada
  localparam integer BRAM_SIZE = (MAXPOOL == 1) ? ((ROW_NUM-(KERNEL_size-stride))/stride)/2:(ROW_NUM-(KERNEL_size-stride))/stride,                             //Tamanho BRAMs dos PEs (exclusão do último)
  localparam integer IN_BRAM_SIZE = (NUM_PE == 1) ? FM_SIZE:ROW_NUM-(KERNEL_size-stride),
  localparam integer LAST_PE_ROW_NUM = FM_SIZE - (PE_NUM-1)*(ROW_NUM-((KERNEL_SIZE-STRIDE))),       //Número de linhas a processar pelo último PE
  localparam integer PE_TO_USE = (LAST_PE_ROW_NUM < KERNEL_SIZE) ? PE_NUM - 1: PE_NUM,              //Número de PEs realmente em uso pelo bloco (tendo em conta restrições definidas)
  localparam integer LAST_BRAM_SIZE = (MAXPOOL == 1) ? ((LAST_PE_ROW_NUM-(KERNEL_size-stride))/stride)/2:(LAST_PE_ROW_NUM-(KERNEL_size-stride))/stride                 //Tamanho BRAM do último PE 

  )();

    
    
  reg i_clk, i_rst, i_go, weight_en, send_weights, send_fm;
  wire w_o_en;
  wire signed [(48*PE_TO_USE*OUT_FM_CH)-1:0] w_o_conv_blk;

  /*Dados lidos dos ficheiros*/
  reg signed [30-1:0] FM_data [0:(FM_SIZE**2)-1];
  reg signed [18-1:0] KERNEL_data [0:(KERNEL_SIZE**2*OUT_FM_CH)-1];
  
  /*Controlo escrita nas brams*/
    /*weight bram*/
  reg [$clog2(KERNEL_SIZE**2):0] weight_bram_w_addr, weight_bram_addr_cnt;
  reg [$clog2(KERNEL_SIZE**2):0] weight_bram_r_addr;
  reg signed [(18*OUT_FM_CH)-1:0] weight_bram_i_data;
  wire signed [(18*OUT_FM_CH)-1:0] weight_bram_o_data;
  reg weight_bram_w_en;

    /*input feature map bram*/
  reg [$clog2(IN_BRAM_SIZE*FM_SIZE):0] fm_bram_w_addr, fm_bram_addr_cnt;
  reg [$clog2(IN_BRAM_SIZE*FM_SIZE) -1:0] fm_bram_r_addr;
  reg signed [(30*PE_TO_USE)-1:0] fm_bram_i_data;
  wire signed [(30*PE_TO_USE)-1:0] fm_bram_o_data;
  reg fm_bram_w_en;

    /*output feature map bram*/
  reg [$clog2(OUT_SIZE**2):0] output_bram_w_addr;
  reg [$clog2(OUT_SIZE**2):0] output_bram_r_addr;
  reg signed [(48*PE_TO_USE*OUT_FM_CH)-1:0] output_bram_i_data;
  wire signed [(48*PE_TO_USE*OUT_FM_CH)-1:0] output_bram_o_data;
  reg output_bram_w_en;
  reg output_last_bram_w_en;
  
  
    /* output MUX */
  wire signed [(30*PE_TO_USE)-1:0] fm_mux_o_data;
  
  reg r_mux_sel;  
  reg r_mux_sel1; 
  
  integer i, j, out_data, out_data1, out_data2, out_cnt, clks;
  
  always #5 i_clk = ~i_clk;
  integer out_file;
  
  integer out_PE, in_PE;
  
  integer weight_bram, fm_bram;
  
  
  reg write_file;
  
  /***************************************************
  Escrita no ficheiro e na bram do ouput do conv_blk
  ***************************************************/
  always@(posedge i_clk) begin
    if(w_o_en) begin
//        for(out_PE = 0; out_PE < NUM_PE; out_PE = out_PE + 1) begin    
//            OUT_fm[out_cnt + out_PE] <= w_o_conv_blk[out_PE*48 +: 48];

//        end
        out_cnt <= out_cnt + 1;

        output_bram_w_addr <= output_bram_w_addr + 1;//comeca a -1 por causa do delay
        
        for(fm_bram = 0; fm_bram < OUT_FM_CH; fm_bram = fm_bram +1) begin
            output_bram_i_data[fm_bram*PE_TO_USE*48+:48*PE_TO_USE] <= w_o_conv_blk[fm_bram*PE_TO_USE*48+:48*PE_TO_USE];
        end
        
        if(ROW_NUM >= LAST_PE_ROW_NUM) begin
            if(out_cnt >=  BRAM_SIZE*OUT_SIZE) begin
                output_bram_w_en <= 0;   
                output_last_bram_w_en <= 0;
                 
            end
            else begin
                if(out_cnt <= LAST_BRAM_SIZE*OUT_SIZE) begin
                    output_last_bram_w_en <= 1;
                end
                else begin
                    output_last_bram_w_en <= 0;
                end
                
                output_bram_w_en <= 1; 
                
            end  
                
         end
         else begin 
            if(out_cnt >=  LAST_BRAM_SIZE*OUT_SIZE) begin
                output_bram_w_en <= 0;    
                output_last_bram_w_en <= 0;
            end 
            else begin
                output_bram_w_en <= 1; 
                output_last_bram_w_en <= 1;
            end
         end
         
    end
    else
      output_bram_w_en <= 0;
  end


  /***************************************************
  Escrita do filtro e fmp nas brams
  ***************************************************/
  always@(posedge i_clk) begin
    if(weight_bram_addr_cnt < KERNEL_SIZE**2)begin
      if(weight_bram_w_en)//delay por causa do addr de escrita
        weight_bram_w_addr <= weight_bram_w_addr + 1;
      else
        weight_bram_w_addr <= 0;
        
      for(weight_bram = 0; weight_bram < OUT_FM_CH; weight_bram = weight_bram +1) begin  
        weight_bram_i_data[weight_bram*18 +:18] <= KERNEL_data[weight_bram*KERNEL_SIZE**2 + weight_bram_addr_cnt];   
      end
      
      weight_bram_addr_cnt <= weight_bram_addr_cnt + 1;
      weight_bram_w_en <= 1;
    end
    else
      weight_bram_w_en <= 0;
  end

  always@(posedge i_clk) begin
    if(fm_bram_addr_cnt < IN_BRAM_SIZE*FM_SIZE)begin
      if(fm_bram_w_en)
        fm_bram_w_addr <= fm_bram_w_addr + 1;
      else
        fm_bram_w_addr <= 0;
      
      for(in_PE = 0; in_PE < PE_TO_USE; in_PE = in_PE +1) begin
          fm_bram_i_data[in_PE*30 +:30] <= FM_data[fm_bram_addr_cnt + IN_BRAM_SIZE*FM_SIZE*in_PE];
      end

      
      fm_bram_addr_cnt <= fm_bram_addr_cnt + 1;
      fm_bram_w_en <= 1;
    end
    else
      fm_bram_w_en <= 0;
  end


  /***************************************************
  Envio dos pesos e feature map das brams para o conv_blk
  ***************************************************/
  always@(posedge i_clk) begin
    if(send_weights && (weight_bram_r_addr < KERNEL_SIZE**2))begin
      weight_bram_r_addr <= weight_bram_r_addr + 1;
      weight_en <= 1;
    end
    else begin
      weight_bram_r_addr <= 0;
      weight_en <= 0;
    end
  end

  always@(posedge i_clk) begin
    if(send_fm && (fm_bram_r_addr < (IN_BRAM_SIZE*FM_SIZE-1)))begin
      fm_bram_r_addr <= fm_bram_r_addr + 1;
      i_go <= 1;
    end
    else begin
        if(fm_bram_r_addr == (IN_BRAM_SIZE*FM_SIZE -1)) begin
            r_mux_sel1 <= 1;
        end      
        
      fm_bram_r_addr <= 0;

    end
    
    if(r_mux_sel1 == 1) begin
        r_mux_sel <= 1;
    end
  end
 

 
  initial begin
    $readmemh("FM_data.txt", FM_data);
    $readmemh("Kernel_data.txt", KERNEL_data);
    out_data = $fopen("OUT_data.txt","w");
    out_data1 = $fopen("OUT_data1.txt","w");
    out_data2 = $fopen("OUT_data2.txt","w");
    
    i_clk = 0;
    clks = 0;
    i_rst = 1;
    i_go = 0;
    weight_en = 0;

    i = 0;
    out_cnt = 0;
    send_weights = 0;

//    test = int'(((252/11) + (3-1)));
    weight_bram_i_data = 0;
    weight_bram_addr_cnt = 0;
    weight_bram_w_en = 0;
    weight_bram_w_addr = 0;
    weight_bram_r_addr = 0;

    fm_bram_i_data = 0;
    fm_bram_addr_cnt = 0;
    fm_bram_w_en = 0;
    fm_bram_w_addr = 0;
    fm_bram_r_addr = 0;

    output_bram_i_data = 0;
    output_bram_w_en = 0;
    output_bram_w_addr = -1;
    output_bram_r_addr = 0;

    r_mux_sel <= 0;
    r_mux_sel1 <= 0;
    
    out_file=0;
    
    write_file <= 0;
    #150
    i_rst = 0;
    send_weights = 1;
    
    while (weight_bram_r_addr < KERNEL_SIZE**2) begin
      #10;
    end
    send_weights = 0;
    #10 //desligar enable dos pesos e começar a enviar feature map
    
    
    send_fm = 1;   
    
    if(ROW_NUM >= LAST_PE_ROW_NUM) begin
        while(out_cnt <  BRAM_SIZE*OUT_SIZE)begin 
           
          clks <= clks + 1;
          #10;
        end
    end
    else begin
        while(out_cnt <=  LAST_BRAM_SIZE*OUT_SIZE)begin 
           
          clks <= clks + 1;
          #10;
        end   
    end
    
    write_file <= 1;

  end
  
    always @(posedge i_clk) begin
        if(write_file) begin
        
            if(out_file < PE_TO_USE - 1 || out_file == 0) begin
                if(output_bram_r_addr < (BRAM_SIZE*OUT_SIZE)+1) begin
                   if(output_bram_r_addr > 0) begin
                        $fwrite(out_data,"%0d\n", output_bram_o_data[out_file*48 + 48*PE_TO_USE*0 +: 48]);    // 0..47, 48..95
                        $fwrite(out_data1,"%0d\n", output_bram_o_data[out_file*48 + 48*PE_TO_USE*1 +: 48]);   //96..143,144..191
                        $fwrite(out_data2,"%0d\n", output_bram_o_data[out_file*48 + 48*PE_TO_USE*2 +: 48]);   //192..240,241..288
                   end
                    output_bram_r_addr <= output_bram_r_addr + 1;
                end
                else begin
                    output_bram_r_addr <= 0;
                    out_file <= out_file + 1;
                end
                
                
            end
            else if ((out_file == PE_TO_USE - 1) && output_bram_r_addr < (LAST_BRAM_SIZE*OUT_SIZE)+1) begin
                   if(output_bram_r_addr > 0) begin
                        $fwrite(out_data,"%0d\n", output_bram_o_data[out_file*48 + 48*PE_TO_USE*0 +: 48]);    // 0..47, 48..95
                        $fwrite(out_data1,"%0d\n", output_bram_o_data[out_file*48 + 48*PE_TO_USE*1 +: 48]);   //96..143,144..191
                        $fwrite(out_data2,"%0d\n", output_bram_o_data[out_file*48 + 48*PE_TO_USE*2 +: 48]);   //192..240,241..288
                   end
                   output_bram_r_addr <= output_bram_r_addr + 1;   
            end
            else begin
                    output_bram_r_addr <= 0;
                    out_file <= out_file + 1;
            end
            
        end
        
        if(out_file == PE_TO_USE)
            $finish;
        
    end
    

    layer_blk #(
        .KERNEL_SIZE(KERNEL_SIZE),
        .FM_SIZE(FM_SIZE),
        .PADDING(PADDING),
        .STRIDE(STRIDE),
        .MAXPOOL(MAXPOOL),
        .IN_FM_CH(IN_FM_CH),
        .OUT_FM_CH(OUT_FM_CH),
        .NUM_PE(PE_TO_USE)
    ) TOP_layer (
        .i_clk(i_clk), 
        .i_rst(i_rst), 
        .i_go(i_go),
        .i_weight_en(weight_en),
        .i_weight_data(weight_bram_o_data),
        .i_fm_data(fm_mux_o_data),
        
        .o_en(w_o_en),
        .o_conv_result(w_o_conv_blk)
    );

    
    generate 
    genvar PE_num;
    
    for(PE_num = 0; PE_num < PE_TO_USE; PE_num = PE_num + 1) begin
          bram #(
            .ADDR_WIDTH($clog2(IN_BRAM_SIZE*FM_SIZE)),
            .RAM_WIDTH(30),
            .RAM_DEPTH(IN_BRAM_SIZE*FM_SIZE),
            .RAM_PORTS(1)
          )featuremap(
            .i_clk(i_clk), 
            .i_r_addrs(fm_bram_r_addr), 
//            .i_r_addrs(fm_bram_r_addr[PE_num*(BRAM_SIZE**2) + BRAM_SIZE*FM_SIZE:PE_num*BRAM_SIZE*FM_SIZE]), 
            .i_w_addrs(fm_bram_w_addr),
            .i_wr_en(fm_bram_w_en),
            .i_data(fm_bram_i_data[PE_num*30 + (30-1):PE_num*30]),
        
            .o_data(fm_bram_o_data[PE_num*30 + (30-1):PE_num*30])
          );    
          
          
        mux #( 
            .WIDTH(30)
        )mux_PE(
            
            .a_in(fm_bram_o_data[PE_num*30 + (30-1):PE_num*30]),
            .b_in((PE_num == PE_TO_USE - 1) ? 0 : fm_bram_o_data[(PE_num+1)*30 + (30-1):(PE_num+1)*30]),
            .sel(r_mux_sel),
            .out(fm_mux_o_data[PE_num*30 + (30-1):PE_num*30])
        );
//    [$clog2(BRAM_SIZE*FM_SIZE)*2 -1:0] fm_bram_r_addr;
    end
    
    endgenerate   
    
    generate 
    genvar out_BRAM, out_FM;
        for(out_FM = 0; out_FM < OUT_FM_CH; out_FM = out_FM + 1) begin
            for(out_BRAM = 0; out_BRAM < PE_TO_USE; out_BRAM = out_BRAM +1) begin      
                if(out_BRAM < PE_TO_USE - 1 || out_BRAM == 0) begin
                     bram #(
                    .ADDR_WIDTH($clog2(BRAM_SIZE*OUT_SIZE)),
                    .RAM_WIDTH(48),
                    .RAM_DEPTH(BRAM_SIZE*OUT_SIZE),
                    .RAM_PORTS(1)
                    )outfeaturemap(
                    .i_clk(i_clk), 
                    .i_r_addrs(output_bram_r_addr), 
                    .i_w_addrs(output_bram_w_addr),
                    .i_wr_en(output_bram_w_en),
                    .i_data(output_bram_i_data[(out_BRAM+out_FM*PE_TO_USE)*48+47:(out_BRAM+out_FM*PE_TO_USE)*48]),
                    
                    .o_data(output_bram_o_data[(out_BRAM+out_FM*PE_TO_USE)*48+47:(out_BRAM+out_FM*PE_TO_USE)*48])
                    );
                
                end
                else begin
                    bram #(
                    .ADDR_WIDTH($clog2(LAST_BRAM_SIZE*OUT_SIZE)),
                    .RAM_WIDTH(48),
                    .RAM_DEPTH(LAST_BRAM_SIZE*OUT_SIZE),
                    .RAM_PORTS(1)
                    )outfeaturemap(
                    .i_clk(i_clk), 
                    .i_r_addrs(output_bram_r_addr), 
                    .i_w_addrs(output_bram_w_addr),
                    .i_wr_en(output_last_bram_w_en),
                    .i_data(output_bram_i_data[(out_BRAM+out_FM*PE_TO_USE)*48+47:(out_BRAM+out_FM*PE_TO_USE)*48]),
                    
                    .o_data(output_bram_o_data[(out_BRAM+out_FM*PE_TO_USE)*48+47:(out_BRAM+out_FM*PE_TO_USE)*48])
                    );
                
                end
            
            end
            
              bram #(
                .ADDR_WIDTH($clog2(KERNEL_SIZE**2) + 1),
                .RAM_WIDTH(18),
                .RAM_DEPTH(KERNEL_SIZE**2),
                .RAM_PORTS(1)
              )weights(
                .i_clk(i_clk), 
                .i_r_addrs(weight_bram_r_addr), 
                .i_w_addrs(weight_bram_w_addr),
                .i_wr_en(weight_bram_w_en),
                .i_data(weight_bram_i_data[out_FM*18+17:out_FM*18]),
            
                .o_data(weight_bram_o_data[out_FM*18+17:out_FM*18])
              );
        end    
    endgenerate




endmodule


