`include "define.v"

module butterfly(
                //input 34data-->17bit real and 17bit image
                input    wire              [`cacheDataWid]     cache_dout0,
                input    wire              [`cacheDataWid]     cache_dout1,
                input    wire              [`cacheDataWid]     cache_dout2,
                input    wire              [`cacheDataWid]     cache_dout3,

                //input 21bit rotation factors
                input    wire   signed     [`rotfactorWid]     rotfac1_re,
                input    wire   signed     [`rotfactorWid]     rotfac2_re,
                input    wire   signed     [`rotfactorWid]     rotfac3_re,
                input    wire   signed     [`rotfactorWid]     rotfac4_re,
                input    wire   signed     [`rotfactorWid]     rotfac1_im,
                input    wire   signed     [`rotfactorWid]     rotfac2_im,
                input    wire   signed     [`rotfactorWid]     rotfac3_im,
                input    wire   signed     [`rotfactorWid]     rotfac4_im,

                //output 34bit data-->17bit real and 17bit image
                output   wire   signed     [`cacheDataWid]     but_dout0,
                output   wire   signed     [`cacheDataWid]     but_dout1,
                output   wire   signed     [`cacheDataWid]     but_dout2,
                output   wire   signed     [`cacheDataWid]     but_dout3,

                //flush_flag信号作为标志清楚上一轮最后butterfly输出
                input    wire              [`cacheDataWid]     flush_b0,flush_b1,flush_b2,flush_b3,
                input    wire                                  flush_flag
                );

//******************************************************************
//calculate the butterfly output
//******************************************************************
//拆分输入实部和虚部
wire   signed [`xnHalfWid]  x0_re;
wire   signed [`xnHalfWid]  x0_im;
wire   signed [`xnHalfWid]  x1_re;
wire   signed [`xnHalfWid]  x1_im;
wire   signed [`xnHalfWid]  x2_re;
wire   signed [`xnHalfWid]  x2_im;
wire   signed [`xnHalfWid]  x3_re;
wire   signed [`xnHalfWid]  x3_im;

assign  x0_re = cache_dout0[`xnRe];
assign  x0_im = cache_dout0[`xnIm];
assign  x1_re = cache_dout1[`xnRe];
assign  x1_im = cache_dout1[`xnIm];
assign  x2_re = cache_dout2[`xnRe];
assign  x2_im = cache_dout2[`xnIm];
assign  x3_re = cache_dout3[`xnRe];
assign  x3_im = cache_dout3[`xnIm];

//-------------------------------
//计算蝶形输出
//-------------------------------
//计算but_dout0 
wire   signed [`butSum4Wid] sum0_re;
wire   signed [`butSum4Wid] sum0_im;
wire   signed [`butDataWid] mul0_re;
wire   signed [`butDataWid] mul0_im;

assign sum0_re   = x0_re + x1_re + x2_re + x3_re;
assign sum0_im   = x0_im + x1_im + x2_im + x3_im;
assign mul0_re   = sum0_re*rotfac1_re - sum0_im*rotfac1_im;
assign mul0_im   = sum0_re*rotfac1_im + sum0_im*rotfac1_re;
assign but_dout0 = flush_flag?flush_b0:{mul0_re[37],mul0_re[`mult35_20],mul0_im[37],mul0_im[`mult35_20]};

//计算but_dout1
wire   signed [`butSum4Wid] sum1_re;
wire   signed [`butSum4Wid] sum1_im;
wire   signed [`butDataWid] mul1_re;
wire   signed [`butDataWid] mul1_im;

assign sum1_re   = x0_re + x1_im - x2_re - x3_im;
assign sum1_im   = x0_im - x1_re - x2_im + x3_re;
assign mul1_re   = sum1_re*rotfac2_re - sum1_im*rotfac2_im;
assign mul1_im   = sum1_re*rotfac2_im + sum1_im*rotfac2_re;
assign but_dout1 = flush_flag?flush_b1:{mul1_re[37],mul1_re[`mult35_20],mul1_im[37],mul1_im[`mult35_20]};

//计算but_dout2
wire   signed [`butSum4Wid] sum2_re;
wire   signed [`butSum4Wid] sum2_im;
wire   signed [`butDataWid] mul2_re;
wire   signed [`butDataWid] mul2_im;

assign sum2_re   = x0_re - x1_re + x2_re - x3_re;
assign sum2_im   = x0_im - x1_im + x2_im - x3_im;
assign mul2_re   = sum2_re*rotfac3_re - sum2_im*rotfac3_im;
assign mul2_im   = sum2_re*rotfac3_im + sum2_im*rotfac3_re;
assign but_dout2 = flush_flag?flush_b2:{mul2_re[37],mul2_re[`mult35_20],mul2_im[37],mul2_im[`mult35_20]};

//计算but_dout3
wire   signed [`butSum4Wid] sum3_re;
wire   signed [`butSum4Wid] sum3_im;
wire   signed [`butDataWid] mul3_re;
wire   signed [`butDataWid] mul3_im;

assign sum3_re   = x0_re - x1_im - x2_re + x3_im;
assign sum3_im   = x0_im + x1_re - x2_im - x3_re;
assign mul3_re   = sum3_re*rotfac4_re - sum3_im*rotfac4_im;
assign mul3_im   = sum3_re*rotfac4_im + sum3_im*rotfac4_re;
assign but_dout3 = flush_flag?flush_b3:{mul3_re[37],mul3_re[`mult35_20],mul3_im[37],mul3_im[`mult35_20]};

endmodule
