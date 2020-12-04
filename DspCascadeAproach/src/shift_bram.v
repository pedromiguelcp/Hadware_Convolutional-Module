`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2020 10:50:42 AM
// Design Name: 
// Module Name: shift_bram
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
module shift_bram #(
    parameter RAM_WIDTH = 48, 
    parameter RAM_DEPTH = 1
)(
    input wire i_clk,
    input wire [RAM_WIDTH-1:0] i_data,

    output wire [RAM_WIDTH-1:0] o_data
);
    integer index, j;

    reg [RAM_WIDTH-1:0] memory_array [0:RAM_DEPTH-1];
    assign o_data = memory_array[RAM_DEPTH-1];

    /*Reset memory*/
    initial begin
        for(j=0; j < RAM_DEPTH; j=j+1) begin
            memory_array[j] = 0;
        end
    end
    
    /*Write data in bram*/
    always @ (posedge i_clk) begin
        memory_array [0] <= i_data;
    end
    
    /*Shift all positions*/
    generate
        genvar i;
        
        for(i = 0; i < RAM_DEPTH - 1; i = i + 1) begin
            always @ (posedge i_clk) begin
                memory_array [i + 1] <= memory_array[i];
            end
        end
    
    endgenerate
    
endmodule
