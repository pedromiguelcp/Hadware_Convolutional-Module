`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2020 04:54:41 PM
// Design Name: 
// Module Name: linebuffer
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


module linebuffer #
(
    parameter integer   
        kernel_size = 2,
        data_width  = 4,
        data_height = 4,
        point_width = 8
)
(
    input wire clock,
    input wire reset,
    input wire en_read,
    input wire slide,
    input wire [0:point_width*data_width*data_height-1]  data,
    input wire [0:point_width*kernel_size*kernel_size-1] weights,
    
    output wire [0:point_width*kernel_size*kernel_size-1] window,
    output reg window_rdy,
    output reg window_gen_end,
    output wire [0:point_width*kernel_size*kernel_size-1] filter
);

reg [0:5] shift = 0, shift_align = 0, column_filter = 0, initial_data = 0;//counter to shift

reg  [0:point_width*data_width*data_height-1]  data_in;//save all input data
assign window = {data_in [0:point_width*kernel_size-1], data_in [point_width*data_width:point_width*data_width+point_width*kernel_size-1]}//static window ref
assign filter = weights;

always @(posedge clock) begin
    window_rdy    <= 0;

    if(en_read & !initial_data) begin//set initial window
        data_in    <= data;
        window_rdy <= 1;
        initial_data  <= 1;
    end

    if(slide) begin
        data_in <= (data_in << point_width*shift_align) + 0;//shift with 0s to
    
        if(column_filter == data_width - kernel_size) begin//end of row, need to jump to the next row (slide the kernel_size positions)
            shift <= shift + kernel_size;
            column_filter <= 0;
        end
        else begin//slide only one position
            shift <= shift + 1;
            column_filter <= column_filter +1;
        end

        window_rdy <= 1;
    end
end

always @(posedge clock) begin
    if(shift == data_width*data_height-kernel_size-data_width)//end of window generator
        window_gen_end <= 1;
    else
        window_gen_end <= 0;
end
    
endmodule