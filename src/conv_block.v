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
    
    output reg  [0:(point_width*(data_width - kernel_size + 1)*(data_height - kernel_size + 1))-1] data_out,//smaller than input data if no padding
    output reg  convolution_done
);

wire  [0:point_width*kernel_size*kernel_size-1] filter;
wire  [0:point_width*kernel_size*kernel_size-1] window;
wire  [0:point_width-1] conv_result;
reg   en_read_mem, conv_done, window_rdy, window_gen_end, conv_result_count, slide = 0;
reg  [0:((data_width - kernel_size + 1)*(data_height - kernel_size + 1))-1] conv_result;

always @(posedge clock) begin//send signal to linebuffer to read memory and create window for convolution
    if(start)begin
        en_read_mem <= 1;
        conv_result_count <= 0;
    end
    else
        en_read_mem <= 0;
end

always @(posedge clock) begin//get each matrix multiplication result and concatenate on the convolution result variable
    if(conv_done)begin
        data_out <= (data_out << point_width) + conv_result;
        if(conv_result_count == (data_width - kernel_size + 1)*(data_height - kernel_size + 1) - 1) begin//end of convolution, send signal
            convolution_done <= 1;
            slide <= 0;
        else begin
            conv_result_count <= conv_result_count + 1;
            slide <= 1;//keep sliding the window through the input data
            convolution_done <= 0;
        end
    end
end

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
    .slide(slide),
    .data(data),
    .weights(weights),

    .window(window),
    .window_rdy(window_rdy),
    .window_gen_end(window_gen_end),
    .weights(filter)
);

PE #
(     
    .kernel_size(kernel_size),
    .data_width(data_width),
    .data_height(data_height),     
    .point_width(point_width)
    
) PE1 (
    .clock(clock),
    .reset(reset),
    .enable_read(window_rdy),
    .window(window),
    .weights(filter),

    .conv_result(conv_result),
    .conv_done(conv_done)
);
endmodule
