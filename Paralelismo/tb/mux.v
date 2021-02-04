`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.01.2021 13:43:38
// Design Name: 
// Module Name: mux
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


module mux #( 
    parameter WIDTH = 30
    )(
    
    input [WIDTH-1:0] a_in,
    input [WIDTH-1:0] b_in,
    input sel,
    output [WIDTH-1:0] out
);
	
	assign out = sel ? b_in : a_in;
	
endmodule
