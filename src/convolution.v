`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2020 10:14:08 AM
// Design Name: 
// Module Name: convolution
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

`define BIT_LEN  8
`define M_LEN    3
`define CONV_LEN 20//size of convolution 8b*8b*9

module convolution #(
    parameter  BIT_LEN =  `BIT_LEN,
    parameter  M_LEN =    `M_LEN,
    parameter  CONV_LEN = `CONV_LEN,
    localparam M_ARRAY =  BIT_LEN*M_LEN
    )(
    input  i_clk,
    input  i_reset,
    input  i_valid,
    input  i_selecK_I, //0 kernel   1 image
    input  [BIT_LEN-1:0] i_data0,
    input  [BIT_LEN-1:0] i_data1,
    input  [BIT_LEN-1:0] i_data2,
    output [CONV_LEN-1:0] o_data
    );
    reg signed [M_ARRAY-1:0]   r_kernel [0:M_LEN-1];
    reg signed [M_ARRAY-1:0]   r_image [0:M_LEN-1];
    
    reg signed [CONV_LEN-1:0]   r_partial;

    wire signed [CONV_LEN-1:0]   w_resultado;
    
    reg signed [(2*BIT_LEN)-1:0] r_array_mult [0:(M_LEN*M_LEN)-1];

    integer i, j, shift;

    assign w_resultado = r_partial;
    assign o_data = w_resultado;

    always @( posedge i_clk) begin
        /*reset image and kernel*/
        if(i_reset) begin
            for(shift=0; shift < M_LEN; shift = shift +1) begin
                r_image[shift]<={M_ARRAY{1'b0}};
                r_kernel[shift]<={M_ARRAY{1'b0}};
            end 
        end
        else if(i_valid)begin
            /*Load kernel or image*/
            case (i_selecK_I)
                1'b1: begin
                    for( shift = 0; shift < M_LEN-1; shift = shift +1)//shift of lines
                        r_image[shift]<=r_image[shift+1];
                    
                    r_image[M_LEN-1]<={i_data2,i_data1,i_data0};//store new values
                end
                1'b0: begin
                    for( shift = 0; shift < M_LEN-1; shift = shift +1)
                        r_kernel[shift]<=r_kernel[shift+1];

                    r_kernel[M_LEN-1]<={i_data2,i_data1,i_data0};
                end
            endcase
        end
    end

    /*matrix multiplication, each column of each line*/
    always@(posedge i_clk)
        for(i = 0 ; i < (M_LEN*M_LEN) ; i=i+1) begin
            r_array_mult[i] =
                r_kernel[i/3][((i%3)+1)*BIT_LEN-1 -: BIT_LEN]*
                r_image[i/3][((i%3)+1)*BIT_LEN-1 -: BIT_LEN];
        end

    /*sum of the matrix multiplication results*/
    always @(*) begin
        r_partial=0;
        for(j = 0 ; j < (M_LEN*M_LEN); j = j +1)begin
            r_partial = r_partial + r_array_mult[j];
        end
    end

endmodule
