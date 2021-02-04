`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2020 10:08:14 AM
// Design Name: 
// Module Name: relu
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


module relu(
    input i_clk,
    input wire signed [47:0] i_data,
    input wire i_en,

    output reg o_en,
    output reg signed [47:0] o_data
    );

    always @(posedge i_clk) begin
        if(i_en) begin
            if(i_data[47]) begin//num negativo
                o_data <= 0;
            end
            else begin
                o_data <= i_data;
            end
            o_en <= 1;
        end
        else begin
            o_en <= 0;
            o_data <= 0;
        end
    end
endmodule
