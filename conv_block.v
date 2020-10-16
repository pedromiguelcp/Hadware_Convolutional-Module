`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2020 05:18:16 PM
// Design Name: 
// Module Name: conv_block
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


module conv_block #
(
    parameter integer   
        kernel_size = 2,
        data_width  = 4,
        data_height = 4,
        point_width = 8
)
(
    input  wire  clock,
    input  wire  reset,
    input  wire  start,
    input  wire  [0:point_width*data_width*data_height-1]  data,
    input  wire  [0:point_width*kernel_size*kernel_size-1] weights,
    
    output wire  [0:((data_width - kernel_size + 1)*(data_height - kernel_size + 1))-1] data_out//smaller than input data if no padding
);

wire  [0:point_width*kernel_size*kernel_size-1] filter;
wire  [0:point_width*kernel_size*kernel_size-1] window;
wire  [0:point_width-1] conv_result;
reg   en_read_mem, en_read_buffer, conv_done;

PE #
(     
    .kernel_size(kernel_size),
    .data_width(data_width),
    .data_height(data_height),     
    .point_width(point_width)
    
) PE1 (
    .clock(clock),
    .reset(reset),
    .enable_read(en_read_buffer),
    .window(window),
    .weights(filter),

    .conv_result(conv_result),
    .conv_done(conv_done)
);

linebuffer #
(     
    .kernel_size(kernel_size),
    .data_width(data_width),
    .data_height(data_height),     
    .point_width(point_width)
    
) in_linebuffer (
    .clock(clock),
    .reset(reset),
    .en_read(en_read_mem),
    .data(data),
    .weights(weights),

    .window(window),
    .weights(filter)
);
endmodule
