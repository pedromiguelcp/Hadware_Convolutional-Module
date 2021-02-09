`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.02.2021 14:41:45
// Design Name: 
// Module Name: selector
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


module selector #( 
    parameter WIDTH = 30,
    parameter IN_CH = 3,
    parameter PE_NUM = 2
)(
    input [(IN_CH*PE_NUM*WIDTH)-1:0] i_data,
    input [$clog2(IN_CH):0] i_ch_sel,
    output [(WIDTH*PE_NUM)-1:0] out
    );

    assign out = i_data[PE_NUM*i_ch_sel*WIDTH+:PE_NUM*WIDTH];

endmodule
