`include "define.v"

module fft(
            //clk & rst_n
           input    wire                        clk, 
           input    wire                        rst_n, 

           //flags
           input    wire                        en_din,
           output    reg                        busy,

           //data in & flags
           input    wire    [`fifoDataWid]      time_din,
           input    wire                        ld_n,
           output   reg                         full_n,

           //output data & flags
           output   reg     [`cacheDataWid]     invbit_dout,
           output   reg     [`cacheDataWid]     power_dout,
           output   reg                         done
           );

//wires
wire    [`cacheDataWid]     but_dout0;
wire    [`cacheDataWid]     but_dout1;
wire    [`cacheDataWid]     but_dout2;
wire    [`cacheDataWid]     but_dout3;

wire    [`cacheDataWid]     cache_dout0;
wire    [`cacheDataWid]     cache_dout1;
wire    [`cacheDataWid]     cache_dout2;
wire    [`cacheDataWid]     cache_dout3;

wire    [`rotfactorWid]     rotfac1_re;
wire    [`rotfactorWid]     rotfac2_re;
wire    [`rotfactorWid]     rotfac3_re;
wire    [`rotfactorWid]     rotfac4_re;
wire    [`rotfactorWid]     rotfac1_im;
wire    [`rotfactorWid]     rotfac2_im;
wire    [`rotfactorWid]     rotfac3_im;
wire    [`rotfactorWid]     rotfac4_im;

wire    [`stageWid]         stage;
wire    [`subStageWid]      sub_stage;

wire                        flush_flag;
wire    [`cacheDataWid]     flush_b0;
wire    [`cacheDataWid]     flush_b1;
wire    [`cacheDataWid]     flush_b2;
wire    [`cacheDataWid]     flush_b3;

cache       u_cache(
                    .clk(clk),
                    .rst_n(rst_n),
                    .en_din(en_din),
                    .busy(busy),
                    .flush_flag(flush_flag),
                    .new_din(time_din),
                    .ld_n(ld_n),       
                    .full_n(full_n),   
                    .but_dout0(but_dout0),
                    .but_dout1(but_dout1),
                    .but_dout2(but_dout2),
                    .but_dout3(but_dout3),
                    .cache_dout0(cache_dout0), 
                    .cache_dout1(cache_dout1), 
                    .cache_dout2(cache_dout2), 
                    .cache_dout3(cache_dout3), 
                    .stage(stage),
                    .sub_stage(sub_stage),
                    .invbit_done(done),    
                    .invbit_dout(invbit_dout),
                    .power_dout(power_dout),
                    .flush_b0(flush_b0),
                    .flush_b1(flush_b1),
                    .flush_b2(flush_b2),
                    .flush_b3(flush_b3)
                   );

butterfly    u_but(
                   .cache_dout0(cache_dout0),
                   .cache_dout1(cache_dout1),
                   .cache_dout2(cache_dout2),
                   .cache_dout3(cache_dout3),
                   .rotfac1_re(rotfac1_re),
                   .rotfac2_re(rotfac2_re),
                   .rotfac3_re(rotfac3_re),
                   .rotfac4_re(rotfac4_re),
                   .rotfac1_im(rotfac1_im),
                   .rotfac2_im(rotfac2_im),
                   .rotfac3_im(rotfac3_im),
                   .rotfac4_im(rotfac4_im),
                   .but_dout0(but_dout0),
                   .but_dout1(but_dout1),
                   .but_dout2(but_dout2),
                   .but_dout3(but_dout3),
                   .flush_flag(flush_flag),
                   .flush_b0(flush_b0),
                   .flush_b1(flush_b1),
                   .flush_b2(flush_b2),
                   .flush_b3(flush_b3)
                  );

rotfactor u_rotfct(
                   .stage(stage), 
                   .sub_stage(sub_stage),  
                   .invbit_done(done),
                   .rotfac1_re(rotfac1_re),
                   .rotfac2_re(rotfac2_re),
                   .rotfac3_re(rotfac3_re),
                   .rotfac4_re(rotfac4_re),
                   .rotfac1_im(rotfac1_im),
                   .rotfac2_im(rotfac2_im),
                   .rotfac3_im(rotfac3_im),
                   .rotfac4_im(rotfac4_im)
                  );

endmodule
