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


module controller
(
    input wire i_clk, i_rst,
    input wire i_start,
    output reg [17:0] o_addr0, o_addr1,// o_addr2,
    //output wire o_bram2_wr,
    output wire o_selec_K, o_selec_I
);

localparam [2:0]    s_idle          = 3'b000,
                    s_loadFM_K      = 3'b001,
                    s_compute_conv  = 3'b010,
                    s_store_out     = 3'b011,
                    s_inc_addr      = 3'b100;

reg [2:0] r_next_state;
reg [17:0] r_img_addr,  r_kernel_addr;
reg [5:0] r_addrImg0, r_addrImg1, r_addrImg2;
reg [5:0] r_addrK0, r_addrK1, r_addrK2;

always @(posedge i_clk) begin
        if(i_rst) begin
            r_next_state <= s_idle;
            r_addrImg0 <= 0;
            r_addrImg1 <= 1;
            r_addrImg2 <= 2;
            r_addrK0 <= 0;
            r_addrK1 <= 1;
            r_addrK2 <= 2;
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
                    r_next_state <= s_compute_conv;
                    
                    
             end
        
             s_compute_conv: begin
                    r_next_state <= s_store_out;
              end
        
             s_store_out: begin
                    if(r_addrImg0 < 15) begin

                        r_addrImg0 <= r_addrImg0 + 3;
                        r_addrImg1 <= r_addrImg1 + 3;
                        r_addrImg2 <= r_addrImg2 + 3;
                        r_addrK0 <= r_addrK0 + 3;
                        r_addrK1 <= r_addrK1 + 3;
                        r_addrK2 <= r_addrK2 + 3;

                        r_next_state <= s_inc_addr;
                    end
                    else begin
                        r_next_state <= s_idle;
                    end
              end
        
              s_inc_addr: begin
                    r_next_state <= s_loadFM_K;
              end
                    
              default: begin
                    r_next_state <= s_idle;
               end
                            
        endcase
        
        end
        

end

always @(*) begin
        r_img_addr = {r_addrImg2, r_addrImg1, r_addrImg1};
        r_kernel_addr = {r_addrK2, r_addrK1, r_addrK0};
        case(r_next_state)
            s_idle: begin
                o_addr0 = 0;
                o_addr1 = 0;
//                o_addr2 = 0;
            end

            s_loadFM_K: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_kernel_addr;
//                o_addr2 = r_out_addr;
            end

            s_compute_conv: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_kernel_addr;
//                o_addr2 = r_out_addr;
            end

            s_store_out: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_kernel_addr;
//                o_addr2 = r_out_addr;
            end

            s_inc_addr: begin
                o_addr0 = r_img_addr;
                o_addr1 = r_kernel_addr;
//                o_addr2 = r_out_addr;
            end
            
            default: begin
                o_addr0 = 0;
                o_addr1 = 0;
//                o_addr2 = 0;

            end
            
        endcase
 end               

assign o_selec_K = (r_next_state == s_loadFM_K && r_addrK0 <= 6) ? 1:0;
assign o_selec_I = (r_next_state == s_loadFM_K) ? 1:0;
assign o_compute_conv = (r_next_state == s_compute_conv) ? 1:0;

//assign o_bram2_wr = (r_next_state == s_store_out) ? 1:0;

endmodule
