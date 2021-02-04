//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 04.01.2021 11:45:46
//// Design Name: 
//// Module Name: layer_tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module layer_tb #(
//  parameter KERNEL_SIZE = 3,
//  parameter FM_SIZE = 252,
//  parameter PADDING = 0,
//  parameter STRIDE = 1,
//  parameter MAXPOOL = 0,
//  localparam OUT_SIZE = ((FM_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE) + 1
//)();

//    reg i_clk;
//    reg i_rst;
//    reg i_go;
//    reg i_weight_en; 
//    reg signed [18-1:0] i_weight_data;
//    reg signed [30*84-1:0] i_fm_data;

//    wire o_en;
//    wire signed [48*84-1:0] o_conv_result;

      
//    reg signed [30-1:0] FM_data [0:(FM_SIZE*FM_SIZE)-1];
//    reg signed [18-1:0] KERNEL_data [0:(KERNEL_SIZE*KERNEL_SIZE)-1];
    
//    layer_blk#(
//        .KERNEL_SIZE(KERNEL_SIZE),
//        .FM_SIZE(FM_SIZE),
//        .PADDING(PADDING),
//        .STRIDE(STRIDE),
//        .MAXPOOL(MAXPOOL)
//    ) uut (
//        .i_clk(i_clk), 
//        .i_rst(i_rst), 
//        .i_go(i_go),
//        .i_weight_en(i_weight_en),
//        .i_weight_data(i_weight_data),
//        .i_fm_data(i_fm_data),
        
//        .o_en(o_en),
//        .o_conv_result(o_conv_result)
//    );
    
    
//    integer i, j, out_data;
    
//    integer PE0,    PE1,    PE2,    PE3,    PE4,    PE5,    PE6,    PE7,    PE8,    PE9,    PE10,   PE11,
//            PE12,   PE13,   PE14,   PE15,   PE16,   PE17,   PE18,   PE19,   PE20,   PE21,   PE22,   PE23,   
//            PE24,   PE25,   PE26,   PE27,   PE28,   PE29,   PE30,   PE31,   PE32,   PE33,   PE34,   PE35,   
//            PE36,   PE37,   PE38,   PE39,   PE40,   PE41,   PE42,   PE43,   PE44,   PE45,   PE46,   PE47,   
//            PE48,   PE49,   PE50,   PE51,   PE52,   PE53,   PE54,   PE55,   PE56,   PE57,   PE58,   PE59,   
//            PE60,   PE61,   PE62,   PE63,   PE64,   PE65,   PE66,   PE67,   PE68,   PE69,   PE70,   PE71,   
//            PE72,   PE73,   PE74,   PE75,   PE76,   PE77,   PE78,   PE79,   PE80,   PE81,   PE82,   PE83;
            
//    integer count;
//    always #5 i_clk = ~i_clk;
    
//    always @(posedge i_clk) begin
//        if(i_go == 1 && (i < FM_SIZE*FM_SIZE)) begin
////                i_fm_data <= {FM_data[i+60],FM_data[i+30],FM_data[i]};
////            i_fm_data <= {FM_data[i+36],FM_data[i]};
////            i_fm_data <= {
////                            FM_data[i+9600],FM_data[i+9300],FM_data[i+9000],
////                            FM_data[i+8700],FM_data[i+8400],FM_data[i+8100],
////                            FM_data[i+7800],FM_data[i+7500],FM_data[i+7200],
////                            FM_data[i+6900],FM_data[i+6600],FM_data[i+6300],   
////                            FM_data[i+6000],FM_data[i+5700],FM_data[i+5400],
////                            FM_data[i+5100],FM_data[i+4800],FM_data[i+4500],
////                            FM_data[i+4200],FM_data[i+3900],FM_data[i+3600],
////                            FM_data[i+3300],FM_data[i+3000],FM_data[i+2700],
////                            FM_data[i+2400],FM_data[i+2100],FM_data[i+1800],
////                            FM_data[i+1500],FM_data[i+1200],FM_data[i+900],
////                            FM_data[i+600],FM_data[i+300],FM_data[i]};
//            i_fm_data <= {  
//                            FM_data[i + 62748],FM_data[i + 61992],FM_data[i + 61236],  
//                            FM_data[i + 60480],FM_data[i + 59724],FM_data[i + 58968],
//                            FM_data[i + 58212],FM_data[i + 57456],FM_data[i + 56700],             
//                            FM_data[i + 55944],FM_data[i + 55188],FM_data[i + 54432],
//                            FM_data[i + 53676],FM_data[i + 52920],FM_data[i + 52164],
//                            FM_data[i + 51408],FM_data[i + 50652],FM_data[i + 49896],
//                            FM_data[i + 49140],FM_data[i + 48384],FM_data[i + 47628],
//                            FM_data[i + 46872],FM_data[i + 46116],FM_data[i + 45360],
//                            FM_data[i + 44604],FM_data[i + 43848],FM_data[i + 43092],
//                            FM_data[i + 42336],FM_data[i + 41580],FM_data[i + 40824],
//                            FM_data[i + 40068],FM_data[i + 39312],FM_data[i + 38556],  
//                            FM_data[i + 37800],FM_data[i + 37044],FM_data[i + 36288],
//                            FM_data[i + 35532],FM_data[i + 34776],FM_data[i + 34020],
//                            FM_data[i + 33264],FM_data[i + 32508],FM_data[i + 31752],
//                            FM_data[i + 30996],FM_data[i + 30240],FM_data[i + 29484],
//                            FM_data[i + 28728],FM_data[i + 27972],FM_data[i + 27216],
//                            FM_data[i + 26460],FM_data[i + 25704],FM_data[i + 24948],
//                            FM_data[i + 24191],FM_data[i + 23436],FM_data[i + 22680],
//                            FM_data[i + 21924],FM_data[i + 21168],FM_data[i + 20412],
//                            FM_data[i + 19656],FM_data[i + 18900],FM_data[i + 18144],
//                            FM_data[i + 17388],FM_data[i + 16632],FM_data[i + 15876],  
//                            FM_data[i + 15120],FM_data[i + 14364],FM_data[i + 13608],
//                            FM_data[i + 12852],FM_data[i + 12096],FM_data[i + 11340],
//                            FM_data[i + 10584],FM_data[i + 9828],FM_data[i + 9072],
//                            FM_data[i + 8316],FM_data[i + 7560],FM_data[i + 6804],
//                            FM_data[i + 6048],FM_data[i + 5292],FM_data[i + 4536],
//                            FM_data[i + 3780],FM_data[i + 3024],FM_data[i + 2268],
//                            FM_data[i + 1512],FM_data[i + 756],FM_data[i + 0]};
//            i <= i+1;
//        end
//    end
  
//    always@(posedge i_clk) begin
//        if(o_en && count < ((KERNEL_SIZE - STRIDE)+1)*(((FM_SIZE-KERNEL_SIZE)/STRIDE)+1)) begin
//        count = count + 1;
////            $fwrite(out_data,"%0d\n", o_conv_result);  
////            $display("PE0: %0d ,PE1: %0d,PE2: %0d, \n", o_conv_result[47:0],o_conv_result[95:48],o_conv_result[143:96]);
////            $display("PE3: %0d ,PE4: %0d,PE5: %0d, \n", o_conv_result[191:144],o_conv_result[239:192],o_conv_result[287:240]);
////            $display("PE6: %0d ,PE7: %0d,PE8: %0d, \n", o_conv_result[335:288],o_conv_result[383:336],o_conv_result[431:384]);
////            $display("PE9: %0d ,PE10: %0d,PE11: %0d, \n", o_conv_result[479:432],o_conv_result[527:480],o_conv_result[575:528]);
////            $display("PE12: %0d ,PE13: %0d,PE14: %0d, \n", o_conv_result[623:576],o_conv_result[671:624],o_conv_result[719:672]);
////            $display("PE15: %0d ,PE16: %0d,PE17: %0d, \n", o_conv_result[767:720],o_conv_result[815:768],o_conv_result[863:816]);
////            $display("PE18: %0d ,PE19: %0d,PE20: %0d, \n", o_conv_result[911:864],o_conv_result[959:912],o_conv_result[1007:960]);
////            $display("PE21: %0d ,PE22: %0d,PE23: %0d, \n", o_conv_result[1055:1008],o_conv_result[1103:1056],o_conv_result[1151:1104]);
////            $display("PE24: %0d ,PE25: %0d,PE26: %0d, \n", o_conv_result[1199:1152],o_conv_result[1247:1200],o_conv_result[1295:1248]);
////            $display("PE27: %0d ,PE28: %0d,PE29: %0d, \n", o_conv_result[1343:1296],o_conv_result[1391:1344],o_conv_result[1439:1392]);
////            $display("PE30: %0d ,PE31: %0d,PE32: %0d, \n", o_conv_result[1487:1440],o_conv_result[1535:1488],o_conv_result[1583:1536]);
////            $display("PE33: %0d ,PE34: %0d,PE35: %0d, \n", o_conv_result[1631:1584],o_conv_result[1679:1632],o_conv_result[1727:1680]);
////            $display("PE36: %0d ,PE37: %0d,PE38: %0d, \n", o_conv_result[1775:1728],o_conv_result[1823:1776],o_conv_result[1871:1824]);
////            $display("PE39: %0d ,PE40: %0d,PE41: %0d, \n", o_conv_result[1919:1872],o_conv_result[1967:1920],o_conv_result[2015:1968]);
////            $display("PE42: %0d ,PE43: %0d,PE44: %0d, \n", o_conv_result[2063:2016],o_conv_result[2111:2064],o_conv_result[2159:2112]);
////            $display("PE45: %0d ,PE46: %0d,PE47: %0d, \n", o_conv_result[2207:2160],o_conv_result[2255:2208],o_conv_result[2303:2256]);
////            $display("PE48: %0d ,PE49: %0d,PE50: %0d, \n", o_conv_result[2351:2304],o_conv_result[2399:2352],o_conv_result[2447:2400]);
////            $display("PE51: %0d ,PE52: %0d,PE53: %0d, \n", o_conv_result[2495:2448],o_conv_result[2543:2496],o_conv_result[2591:2544]);
////            $display("PE54: %0d ,PE55: %0d,PE56: %0d, \n", o_conv_result[2639:2592],o_conv_result[2687:2640],o_conv_result[2735:2688]);
////            $display("PE57: %0d ,PE58: %0d,PE59: %0d, \n", o_conv_result[2783:2736],o_conv_result[2831:2784],o_conv_result[2879:2832]);
////            $display("PE60: %0d ,PE61: %0d,PE62: %0d, \n", o_conv_result[2927:2880],o_conv_result[2975:2928],o_conv_result[3023:2976]);
////            $display("PE63: %0d ,PE64: %0d,PE65: %0d, \n", o_conv_result[3071:3024],o_conv_result[3119:3072],o_conv_result[3167:3120]);
////            $display("PE66: %0d ,PE67: %0d,PE68: %0d, \n", o_conv_result[3215:3168],o_conv_result[3263:3216],o_conv_result[3311:3264]);
////            $display("PE69: %0d ,PE70: %0d,PE71: %0d, \n", o_conv_result[3359:3312],o_conv_result[3407:3360],o_conv_result[3455:3408]);
////            $display("PE72: %0d ,PE73: %0d,PE74: %0d, \n", o_conv_result[3503:3456],o_conv_result[3551:3504],o_conv_result[3599:3552]);
////            $display("PE75: %0d ,PE76: %0d,PE77: %0d, \n", o_conv_result[3647:3600],o_conv_result[3695:3648],o_conv_result[3743:3696]);
////            $display("PE78: %0d ,PE79: %0d,PE80: %0d, \n", o_conv_result[3791:3744],o_conv_result[3839:3792],o_conv_result[3887:3840]);
////            $display("PE81: %0d ,PE82: %0d,PE83: %0d  \n", o_conv_result[3935:3888],o_conv_result[3983:3936], o_conv_result[4031:3984]);
            
//            $fwrite(PE0,"%0d\n", o_conv_result[47:0]);  
//            $fwrite(PE1,"%0d\n", o_conv_result[95:48]);  
//            $fwrite(PE2,"%0d\n", o_conv_result[143:96]);  
//            $fwrite(PE3,"%0d\n", o_conv_result[191:144]);  
//            $fwrite(PE4,"%0d\n", o_conv_result[239:192]);  
//            $fwrite(PE5,"%0d\n", o_conv_result[287:240]);  
//            $fwrite(PE6,"%0d\n", o_conv_result[335:288]);  
//            $fwrite(PE7,"%0d\n", o_conv_result[383:336]);  
//            $fwrite(PE8,"%0d\n", o_conv_result[431:384]);  
//            $fwrite(PE9,"%0d\n", o_conv_result[479:432]); 
//            $fwrite(PE10,"%0d\n", o_conv_result[527:480]);  
//            $fwrite(PE11,"%0d\n", o_conv_result[575:528]);  
//            $fwrite(PE12,"%0d\n", o_conv_result[623:576]);  
//            $fwrite(PE13,"%0d\n", o_conv_result[671:624]);  
//            $fwrite(PE14,"%0d\n", o_conv_result[719:672]);  
//            $fwrite(PE15,"%0d\n", o_conv_result[767:720]);  
//            $fwrite(PE16,"%0d\n", o_conv_result[815:768]);  
//            $fwrite(PE17,"%0d\n", o_conv_result[863:816]);  
//            $fwrite(PE18,"%0d\n", o_conv_result[911:864]);  
//            $fwrite(PE19,"%0d\n", o_conv_result[959:912]); 
//            $fwrite(PE20,"%0d\n", o_conv_result[1007:960]);  
//            $fwrite(PE21,"%0d\n", o_conv_result[1055:1008]);  
//            $fwrite(PE22,"%0d\n", o_conv_result[1103:1056]);  
//            $fwrite(PE23,"%0d\n", o_conv_result[1151:1104]);  
//            $fwrite(PE24,"%0d\n", o_conv_result[1199:1152]);  
//            $fwrite(PE25,"%0d\n", o_conv_result[1247:1200]);  
//            $fwrite(PE26,"%0d\n", o_conv_result[1295:1248]);  
//            $fwrite(PE27,"%0d\n", o_conv_result[1343:1296]);  
//            $fwrite(PE28,"%0d\n", o_conv_result[1391:1344]);  
//            $fwrite(PE29,"%0d\n", o_conv_result[1439:1392]); 
//            $fwrite(PE30,"%0d\n", o_conv_result[1487:1440]);  
//            $fwrite(PE31,"%0d\n", o_conv_result[1535:1488]);  
//            $fwrite(PE32,"%0d\n", o_conv_result[1583:1536]);  
//            $fwrite(PE33,"%0d\n", o_conv_result[1631:1584]);  
//            $fwrite(PE34,"%0d\n", o_conv_result[1679:1632]);  
//            $fwrite(PE35,"%0d\n", o_conv_result[1727:1680]);  
//            $fwrite(PE36,"%0d\n", o_conv_result[1775:1728]);  
//            $fwrite(PE37,"%0d\n", o_conv_result[1823:1776]);  
//            $fwrite(PE38,"%0d\n", o_conv_result[1871:1824]);  
//            $fwrite(PE39,"%0d\n", o_conv_result[1919:1872]); 
//            $fwrite(PE40,"%0d\n", o_conv_result[1967:1920]);  
//            $fwrite(PE41,"%0d\n", o_conv_result[2015:1968]);  
//            $fwrite(PE42,"%0d\n", o_conv_result[2063:2016]);  
//            $fwrite(PE43,"%0d\n", o_conv_result[2111:2064]);  
//            $fwrite(PE44,"%0d\n", o_conv_result[2159:2112]);  
//            $fwrite(PE45,"%0d\n", o_conv_result[2207:2160]);  
//            $fwrite(PE46,"%0d\n", o_conv_result[2255:2208]);  
//            $fwrite(PE47,"%0d\n", o_conv_result[2303:2256]);  
//            $fwrite(PE48,"%0d\n", o_conv_result[2351:2304]);  
//            $fwrite(PE49,"%0d\n", o_conv_result[2399:2352]); 
//            $fwrite(PE50,"%0d\n", o_conv_result[2447:2400]);  
//            $fwrite(PE51,"%0d\n", o_conv_result[2495:2448]);  
//            $fwrite(PE52,"%0d\n", o_conv_result[2543:2496]);  
//            $fwrite(PE53,"%0d\n", o_conv_result[2591:2544]);  
//            $fwrite(PE54,"%0d\n", o_conv_result[2639:2592]);  
//            $fwrite(PE55,"%0d\n", o_conv_result[2687:2640]);  
//            $fwrite(PE56,"%0d\n", o_conv_result[2735:2688]);  
//            $fwrite(PE57,"%0d\n", o_conv_result[2783:2736]);  
//            $fwrite(PE58,"%0d\n", o_conv_result[2831:2784]);  
//            $fwrite(PE59,"%0d\n", o_conv_result[2879:2832]); 
//            $fwrite(PE60,"%0d\n", o_conv_result[2927:2880]);  
//            $fwrite(PE61,"%0d\n", o_conv_result[2975:2928]);  
//            $fwrite(PE62,"%0d\n", o_conv_result[3023:2976]);  
//            $fwrite(PE63,"%0d\n", o_conv_result[3071:3024]);  
//            $fwrite(PE64,"%0d\n", o_conv_result[3119:3072]);  
//            $fwrite(PE65,"%0d\n", o_conv_result[3167:3120]);  
//            $fwrite(PE66,"%0d\n", o_conv_result[3215:3168]);  
//            $fwrite(PE67,"%0d\n", o_conv_result[3263:3216]);  
//            $fwrite(PE68,"%0d\n", o_conv_result[3311:3264]);  
//            $fwrite(PE69,"%0d\n", o_conv_result[3359:3312]); 
//            $fwrite(PE70,"%0d\n", o_conv_result[3407:3360]);  
//            $fwrite(PE71,"%0d\n", o_conv_result[3455:3408]);  
//            $fwrite(PE72,"%0d\n", o_conv_result[3503:3456]);  
//            $fwrite(PE73,"%0d\n", o_conv_result[3551:3504]);  
//            $fwrite(PE74,"%0d\n", o_conv_result[3599:3552]);  
//            $fwrite(PE75,"%0d\n", o_conv_result[3647:3600]);  
//            $fwrite(PE76,"%0d\n", o_conv_result[3695:3648]);  
//            $fwrite(PE77,"%0d\n", o_conv_result[3743:3696]);  
//            $fwrite(PE78,"%0d\n", o_conv_result[3791:3744]);  
//            $fwrite(PE79,"%0d\n", o_conv_result[3839:3792]); 
//            $fwrite(PE80,"%0d\n", o_conv_result[3887:3840]);  
//            $fwrite(PE81,"%0d\n", o_conv_result[3935:3888]);  
//            $fwrite(PE82,"%0d\n", o_conv_result[3983:3936]);  
//            $fwrite(PE83,"%0d\n", o_conv_result[4031:3984]); 
            

            
//        end 
//    end
    
//    initial begin
//    $readmemh("FM_data.txt", FM_data);
//    $readmemh("Kernel_data.txt", KERNEL_data);
//    out_data = $fopen("OUT_data.txt","w");
    
//    PE0 = $fopen("PE0.txt","w");
//    PE1 = $fopen("PE1.txt","w");
//    PE2 = $fopen("PE2.txt","w");
//    PE3 = $fopen("PE3.txt","w");
//    PE4 = $fopen("PE4.txt","w");
//    PE5 = $fopen("PE5.txt","w");
//    PE6 = $fopen("PE6.txt","w");
//    PE7 = $fopen("PE7.txt","w");
//    PE8 = $fopen("PE8.txt","w");
//    PE9 = $fopen("PE9.txt","w");
//    PE10 = $fopen("PE10.txt","w");
//    PE11 = $fopen("PE11.txt","w");
//    PE12 = $fopen("PE12.txt","w");
//    PE13 = $fopen("PE13.txt","w");
//    PE14 = $fopen("PE14.txt","w");
//    PE15 = $fopen("PE15.txt","w");
//    PE16 = $fopen("PE16.txt","w");
//    PE17 = $fopen("PE17.txt","w");
//    PE18 = $fopen("PE18.txt","w");
//    PE19 = $fopen("PE19.txt","w");
//    PE20 = $fopen("PE20.txt","w");
//    PE21 = $fopen("PE21.txt","w");
//    PE22 = $fopen("PE22.txt","w");
//    PE23 = $fopen("PE23.txt","w");
//    PE24 = $fopen("PE24.txt","w");
//    PE25 = $fopen("PE25.txt","w");
//    PE26 = $fopen("PE26.txt","w");
//    PE27 = $fopen("PE27.txt","w");
//    PE28 = $fopen("PE28.txt","w");
//    PE29 = $fopen("PE29.txt","w");
//    PE30 = $fopen("PE30.txt","w");
//    PE31 = $fopen("PE31.txt","w");
//    PE32 = $fopen("PE32.txt","w");
//    PE33 = $fopen("PE33.txt","w");
//    PE34 = $fopen("PE34.txt","w");
//    PE35 = $fopen("PE35.txt","w");
//    PE36 = $fopen("PE36.txt","w");
//    PE37 = $fopen("PE37.txt","w");
//    PE38 = $fopen("PE38.txt","w");
//    PE39 = $fopen("PE39.txt","w");
//    PE40 = $fopen("PE40.txt","w");
//    PE41 = $fopen("PE41.txt","w");
//    PE42 = $fopen("PE42.txt","w");
//    PE43 = $fopen("PE43.txt","w");
//    PE44 = $fopen("PE44.txt","w");
//    PE45 = $fopen("PE45.txt","w");
//    PE46 = $fopen("PE46.txt","w");
//    PE47 = $fopen("PE47.txt","w");
//    PE48 = $fopen("PE48.txt","w");
//    PE49 = $fopen("PE49.txt","w");
//    PE50 = $fopen("PE50.txt","w");
//    PE51 = $fopen("PE51.txt","w");
//    PE52 = $fopen("PE52.txt","w");
//    PE53 = $fopen("PE53.txt","w");
//    PE54 = $fopen("PE54.txt","w");
//    PE55 = $fopen("PE55.txt","w");
//    PE56 = $fopen("PE56.txt","w");
//    PE57 = $fopen("PE57.txt","w");
//    PE58 = $fopen("PE58.txt","w");
//    PE59 = $fopen("PE59.txt","w");
//    PE60 = $fopen("PE60.txt","w");
//    PE61 = $fopen("PE61.txt","w");
//    PE62 = $fopen("PE62.txt","w");
//    PE63 = $fopen("PE63.txt","w");
//    PE64 = $fopen("PE64.txt","w");
//    PE65 = $fopen("PE65.txt","w");
//    PE66 = $fopen("PE66.txt","w");
//    PE67 = $fopen("PE67.txt","w");
//    PE68 = $fopen("PE68.txt","w");
//    PE69 = $fopen("PE69.txt","w");
//    PE70 = $fopen("PE70.txt","w");
//    PE71 = $fopen("PE71.txt","w");
//    PE72 = $fopen("PE72.txt","w");
//    PE73 = $fopen("PE73.txt","w");
//    PE74 = $fopen("PE74.txt","w");
//    PE75 = $fopen("PE75.txt","w");
//    PE76 = $fopen("PE76.txt","w");
//    PE77 = $fopen("PE77.txt","w");
//    PE78 = $fopen("PE78.txt","w");
//    PE79 = $fopen("PE79.txt","w");
//    PE80 = $fopen("PE80.txt","w");
//    PE81 = $fopen("PE81.txt","w");
//    PE82 = $fopen("PE82.txt","w");
//    PE83 = $fopen("PE83.txt","w");
    
    
//    count = 0;
//    i_clk = 0;
//    i_rst = 1;
//    i_go = 0;
//    i_weight_en = 0;
////    i_fm_data <= { FM_data[60],FM_data[30],FM_data[0]};
////    i_fm_data <= { FM_data[36],FM_data[0]};
////    i_fm_data <= {
////                    FM_data[9600],FM_data[9300],FM_data[9000],
////                    FM_data[8700],FM_data[8400],FM_data[8100],
////                    FM_data[7800],FM_data[7500],FM_data[7200],
////                    FM_data[6900],FM_data[6600],FM_data[6300],   
////                    FM_data[6000],FM_data[5700],FM_data[5400],
////                    FM_data[5100],FM_data[4800],FM_data[4500],
////                    FM_data[4200],FM_data[3900],FM_data[3600],
////                    FM_data[3300],FM_data[3000],FM_data[2700],
////                    FM_data[2400],FM_data[2100],FM_data[1800],
////                    FM_data[1500],FM_data[1200],FM_data[900],
////                    FM_data[600],FM_data[300],FM_data[0]};

//    i_fm_data <= {  
//                    FM_data[62748],FM_data[61992],FM_data[61236],  
//                    FM_data[60480],FM_data[59724],FM_data[58968],
//                    FM_data[58212],FM_data[57456],FM_data[56700],             
//                    FM_data[55944],FM_data[55188],FM_data[54432],
//                    FM_data[53676],FM_data[52920],FM_data[52164],
//                    FM_data[51408],FM_data[50652],FM_data[49896],
//                    FM_data[49140],FM_data[48384],FM_data[47628],
//                    FM_data[46872],FM_data[46116],FM_data[45360],
//                    FM_data[44604],FM_data[43848],FM_data[43092],
//                    FM_data[42336],FM_data[41580],FM_data[40824],
//                    FM_data[40068],FM_data[39312],FM_data[38556],  
//                    FM_data[37800],FM_data[37044],FM_data[36288],
//                    FM_data[35532],FM_data[34776],FM_data[34020],
//                    FM_data[33264],FM_data[32508],FM_data[31752],
//                    FM_data[30996],FM_data[30240],FM_data[29484],
//                    FM_data[28728],FM_data[27972],FM_data[27216],
//                    FM_data[26460],FM_data[25704],FM_data[24948],
//                    FM_data[24191],FM_data[23436],FM_data[22680],
//                    FM_data[21924],FM_data[21168],FM_data[20412],
//                    FM_data[19656],FM_data[18900],FM_data[18144],
//                    FM_data[17388],FM_data[16632],FM_data[15876],  
//                    FM_data[15120],FM_data[14364],FM_data[13608],
//                    FM_data[12852],FM_data[12096],FM_data[11340],
//                    FM_data[10584],FM_data[9828],FM_data[9072],
//                    FM_data[8316],FM_data[7560],FM_data[6804],
//                    FM_data[6048],FM_data[5292],FM_data[4536],
//                    FM_data[3780],FM_data[3024],FM_data[2268],
//                    FM_data[1512],FM_data[756],FM_data[0]};
//    i <= 1;


    
//    #150
//    i_rst = 0;
//    i_weight_en = 1;
//    for(j = 0; j<KERNEL_SIZE**2; j=j+1)begin
//      i_weight_data[18-1:0] <= KERNEL_data[j];
//      #10;
//    end

//    #20;
//    i_weight_en = 0;
//    i_go = 1;   

    
////    #690000  
    
//    $fclose(out_data);
//    $finish; 
//  end
//endmodule
