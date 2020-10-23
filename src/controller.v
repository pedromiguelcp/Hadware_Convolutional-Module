`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2020 14:27:41
// Design Name: 
// Module Name: controller
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


module controller #(
    parameter IN_MATRIX_WITDH = 5
)
(
    input wire i_clk, i_rst,
    input wire i_start,
    input wire i_ready2compute,
    input wire i_conv_done,
    output wire o_compute_conv,
    output reg [2:0] o_addr0, o_addr1, o_addr2,
    output wire o_bram0_wr, o_bram1_wr, o_bram2_wr
);

localparam [2:0]    s_idle          = 3'b000,
                    s_loadFM_K      = 3'b001,
                    s_compute_conv  = 3'b010,
                    s_store_out     = 3'b011,
                    s_inc_addr      = 3'b100;

reg [2:0] r_next_state;
reg [2:0] r_img_addr,  r_out_addr;


always @(posedge i_clk) begin
        if(i_rst) begin
            r_next_state <= s_idle;
            r_img_addr <= 0;
            r_out_addr <= 0;
        end
        else begin
        case(r_next_state)
            s_idle: begin
                    if(i_start == 1'b1) begin
                        r_next_state <= s_loadFM_K;
                    end
                    else begin
                        r_next_state <= s_idle;
                    end 
            end
        
            s_loadFM_K: begin

                    if(i_ready2compute == 1'b1) begin
                        r_next_state <= s_compute_conv;
                    end
                    else begin
                        r_next_state <= s_loadFM_K;
                    end 
             end
        
             s_compute_conv: begin
    
                    if(i_conv_done == 1'b1) begin
                        r_next_state <= s_store_out;
                    end
                    else begin
                        r_next_state <= s_compute_conv;
                    end
              end
        
             s_store_out: begin
                    r_next_state <= s_inc_addr;
                    if(r_img_addr < IN_MATRIX_WITDH) begin
                        r_next_state <= s_inc_addr;
                    end
                    else begin
                        r_next_state <= s_idle;
                    end
              end
        
              s_inc_addr: begin
                    r_img_addr <= r_img_addr + 1;
                    r_out_addr <= r_out_addr + 1;
                    r_next_state <= s_loadFM_K;
              end
                    
              default: begin
                    r_next_state <= s_idle;
               end
                            
        endcase
        
        end
        

end

always @(*) begin
        case(r_next_state)
            s_idle: begin
                o_addr0 = 0;
                o_addr1 = 0;
                o_addr2 = 0;
            end

            s_loadFM_K: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_img_addr;
                o_addr2 = r_out_addr;
            end

            s_compute_conv: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_img_addr;
                o_addr2 = r_out_addr;
            end

            s_store_out: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_img_addr;
                o_addr2 = r_out_addr;
            end

            s_inc_addr: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_img_addr;
                o_addr2 = r_out_addr;
            end
            
            default: begin
                o_addr0 = 0;
                o_addr1 = 0;
                o_addr2 = 0;

            end
            
        endcase
 end               

assign o_compute_conv = (r_next_state == s_compute_conv) ? 1:0;
assign o_bram0_wr = 0;
assign o_bram1_wr = 0;
assign o_bram2_wr = (r_next_state == s_store_out) ? 1:0;

endmodule
