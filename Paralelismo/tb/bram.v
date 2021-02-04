`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2020 09:21:48 PM
// Design Name: 
// Module Name: bram
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

module bram #(
    parameter ADDR_WIDTH = $clog2((252**2)*2), 
    parameter RAM_WIDTH = 8, 
    parameter RAM_DEPTH = (252**2)*2,
    parameter RAM_PORTS = 2
)(
    input wire i_clk,
    input wire [ADDR_WIDTH * RAM_PORTS-1:0] i_r_addrs,
    input wire [ADDR_WIDTH-1:0] i_w_addrs,   
    input wire i_wr_en,
    input wire [RAM_WIDTH-1:0] i_data,

    output reg [RAM_WIDTH * RAM_PORTS-1:0] o_data
);
    integer j;

    reg [RAM_WIDTH-1:0] memory_array [0:RAM_DEPTH-1];

    /*Reset memory*/
    initial begin
        for(j=0; j < RAM_DEPTH; j=j+1) begin
            memory_array[j] = 0;
        end
    end
    
    /*Write data in bram*/
    always @ (posedge i_clk) begin
        if(i_wr_en) begin
            memory_array[i_w_addrs] <= i_data;
        end
    end
    
    generate
        genvar i;
        
        for(i = 0; i < RAM_PORTS; i = i + 1) begin
            always @ (posedge i_clk) begin
                o_data[RAM_WIDTH * i + (RAM_WIDTH - 1): RAM_WIDTH*i] <= 
                    memory_array[i_r_addrs[ADDR_WIDTH * i + (ADDR_WIDTH - 1): ADDR_WIDTH*i]];
            end
        end
    
    endgenerate
    
endmodule
