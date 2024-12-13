`include "define.v"

module rotfactor(
                //stage flags
                input   wire               [`stageWid]         stage, 
                input   wire               [`subStageWid]      sub_stage,  
                input   wire                                   invbit_done,

                //output rotation factors
                output  reg     signed     [`rotfactorWid]     rotfac1_re,
                output  reg     signed     [`rotfactorWid]     rotfac2_re,
                output  reg     signed     [`rotfactorWid]     rotfac3_re,
                output  reg     signed     [`rotfactorWid]     rotfac4_re,
                output  reg     signed     [`rotfactorWid]     rotfac1_im,
                output  reg     signed     [`rotfactorWid]     rotfac2_im,
                output  reg     signed     [`rotfactorWid]     rotfac3_im,
                output  reg     signed     [`rotfactorWid]     rotfac4_im
                );

//**************************************************************
///base rotation factors
//**************************************************************
wire    signed  [`rotfactorWid]     Wre32     [0:32];   //W0~W33
wire    signed  [`rotfactorWid]     Wim32     [0:32];

assign Wre32[0]  = `rotfactorwid'b011111111111111111111;            //W_256^0 Real -->21bit
assign Wim32[0]  = `rotfactorwid'b000000000000000000000;            //W_256^0 Image
assign Wre32[1]  = `rotfactorwid'b011111111111011000011;
assign Wim32[1]  = `rotfactorwid'b111111001101101111011;
assign Wre32[2]  = `rotfactorwid'b011111111101100010000;
assign Wim32[2]  = `rotfactorwid'b111110011011100000101;
assign Wre32[3]  = `rotfactorwid'b011111111010011100110;
assign Wim32[3]  = `rotfactorwid'b111101101001010101110;
assign Wre32[4]  = `rotfactorwid'b011111110110001000110;
assign Wim32[4]  = `rotfactorwid'b111100110111010000110;
assign Wre32[5]  = `rotfactorwid'b011111110000100110001;
assign Wim32[5]  = `rotfactorwid'b111100000101010011011;
assign Wre32[6]  = `rotfactorwid'b011111101001110101010;
assign Wim32[6]  = `rotfactorwid'b111011010011011111110;
assign Wre32[7]  = `rotfactorwid'b011111100001110110010;
assign Wim32[7]  = `rotfactorwid'b111010100001110111110;
assign Wre32[8]  = `rotfactorwid'b011111011000101001011;
assign Wim32[8]  = `rotfactorwid'b111001110000011101001;
assign Wre32[9]  = `rotfactorwid'b011111001110001111001;
assign Wim32[9]  = `rotfactorwid'b111000111111010010000;
assign Wre32[10] = `rotfactorwid'b011111000010100111111;
assign Wim32[10] = `rotfactorwid'b111000001110011000001;
assign Wre32[11] = `rotfactorwid'b011110110101110011111;
assign Wim32[11] = `rotfactorwid'b110111011101110001100;
assign Wre32[12] = `rotfactorwid'b011110100111110100000;
assign Wim32[12] = `rotfactorwid'b110110101101011111111;
assign Wre32[13] = `rotfactorwid'b011110011000101000100;
assign Wim32[13] = `rotfactorwid'b110101111101100101001;
assign Wre32[14] = `rotfactorwid'b011110001000010010000;
assign Wim32[14] = `rotfactorwid'b110101001110000011010;
assign Wre32[15] = `rotfactorwid'b011101110110110001001;
assign Wim32[15] = `rotfactorwid'b110100011110111011111;
assign Wre32[16] = `rotfactorwid'b011101100100000110101;        
assign Wim32[16] = `rotfactorwid'b110011110000010001000;
assign Wre32[17] = `rotfactorwid'b011101010000010011001;
assign Wim32[17] = `rotfactorwid'b110011000010000100010;
assign Wre32[18] = `rotfactorwid'b011100111011010111101;
assign Wim32[18] = `rotfactorwid'b110010010100010111100;
assign Wre32[19] = `rotfactorwid'b011100100101010100101;
assign Wim32[19] = `rotfactorwid'b110001100111001100101;
assign Wre32[20] = `rotfactorwid'b011100001110001011001;
assign Wim32[20] = `rotfactorwid'b110000111010100101001;
assign Wre32[21] = `rotfactorwid'b011011110101111011111;
assign Wim32[21] = `rotfactorwid'b110000001110100010111;
assign Wre32[22] = `rotfactorwid'b011011011100101000001;
assign Wim32[22] = `rotfactorwid'b101111100011000111101;
assign Wre32[23] = `rotfactorwid'b011011000010010000100;
assign Wim32[23] = `rotfactorwid'b101110111000010100111;
assign Wre32[24] = `rotfactorwid'b011010100110110110010;
assign Wim32[24] = `rotfactorwid'b101110001110001100011;
assign Wre32[25] = `rotfactorwid'b011010001010011010011;
assign Wim32[25] = `rotfactorwid'b101101100100101111110;
assign Wre32[26] = `rotfactorwid'b011001101100111101111;
assign Wim32[26] = `rotfactorwid'b101100111100000000101;
assign Wre32[27] = `rotfactorwid'b011001001110100010000;
assign Wim32[27] = `rotfactorwid'b101100010100000000100;
assign Wre32[28] = `rotfactorwid'b011000101111000111111;
assign Wim32[28] = `rotfactorwid'b101011101100110000111;
assign Wre32[29] = `rotfactorwid'b011000001110110000110;
assign Wim32[29] = `rotfactorwid'b101011000110010011011;
assign Wre32[30] = `rotfactorwid'b010111101101011101111;
assign Wim32[30] = `rotfactorwid'b101010100000101001100;
assign Wre32[31] = `rotfactorwid'b010111001011010000011;
assign Wim32[31] = `rotfactorwid'b101001111011110100101;
assign Wre32[32] = `rotfactorwid'b010110101000001001110;
assign Wim32[32] = `rotfactorwid'b101001010111110110010;

//**************************************************************
//rotation factors generate
//**************************************************************
wire    signed [`rotfactorWid]     Wre     [0:191];
wire    signed [`rotfactorWid]     Wim     [0:191];

genvar k;
generate
    for(k=0;k<192;k=k+1)begin:rotfactor_gen
        if(k<33)begin:w32_gen
            assign Wre[k] = Wre32[k];
            assign Wim[k] = Wim32[k];
        end
        else if(k<64)begin:w64_gen
            assign Wre[k] = -Wim32[64-k];
            assign Wim[k] = -Wre32[64-k];
        end
        else begin:w192_gen
            assign Wre[k] =  Wim[k-64];
            assign Wim[k] = -Wre[k-64];
        end
    end
endgenerate

//**************************************************************
//decide rotation factors for stage
//**************************************************************
//sub_stage位宽扩展匹配地址
wire [`cacheAddrWid]    sub_stage_exp;
wire [`cacheAddrWid]    sub_stage_exp30;
wire [`cacheAddrWid]    sub_stage_exp10;

assign sub_stage_exp   = {{2{1'b0}},sub_stage};
assign sub_stage_exp30 = {{4{1'b0}},sub_stage[3:0]};
assign sub_stage_exp10 = {{6{1'b0}},sub_stage[1:0]};

//蝶形运算的4个旋转因子地址索引
always @(*)begin
   rotfac1_re = `rotfactorwid'd0; 
   rotfac1_im = `rotfactorwid'd0;
   rotfac2_re = `rotfactorwid'd0; 
   rotfac2_im = `rotfactorwid'd0;
   rotfac3_re = `rotfactorwid'd0; 
   rotfac3_im = `rotfactorwid'd0;
   rotfac4_re = `rotfactorwid'd0; 
   rotfac4_im = `rotfactorwid'd0;
   if(invbit_done)begin
      rotfac1_re = `rotfactorwid'd0; 
      rotfac1_im = `rotfactorwid'd0;
      rotfac2_re = `rotfactorwid'd0; 
      rotfac2_im = `rotfactorwid'd0;
      rotfac3_re = `rotfactorwid'd0; 
      rotfac3_im = `rotfactorwid'd0;
      rotfac4_re = `rotfactorwid'd0; 
      rotfac4_im = `rotfactorwid'd0;
   end
   else begin
       case(stage)
           `stage1:begin
                       rotfac1_re = Wre[0]; 
                       rotfac1_im = Wim[0];
                       rotfac2_re = Wre[sub_stage_exp]; 
                       rotfac2_im = Wim[sub_stage_exp];
                       rotfac3_re = Wre[sub_stage_exp<<1]; 
                       rotfac3_im = Wim[sub_stage_exp<<1];
                       rotfac4_re = Wre[(sub_stage_exp<<1)+sub_stage_exp]; 
                       rotfac4_im = Wim[(sub_stage_exp<<1)+sub_stage_exp];
                   end
           `stage2:begin
                       rotfac1_re = Wre[0]; 
                       rotfac1_im = Wim[0];
                       rotfac2_re = Wre[sub_stage_exp30<<2];                        //将W_64^x转变为W_256^4x 
                       rotfac2_im = Wim[sub_stage_exp30<<2];
                       rotfac3_re = Wre[sub_stage_exp30<<3]; 
                       rotfac3_im = Wim[sub_stage_exp30<<3];
                       rotfac4_re = Wre[(sub_stage_exp30<<3)+(sub_stage_exp30<<2)]; 
                       rotfac4_im = Wim[(sub_stage_exp30<<3)+(sub_stage_exp30<<2)];
                   end
           `stage3:begin
                       rotfac1_re = Wre[0]; 
                       rotfac1_im = Wim[0];
                       rotfac2_re = Wre[sub_stage_exp10<<4];                        //将W_16^x转变为W_256^16x  
                       rotfac2_im = Wim[sub_stage_exp10<<4];
                       rotfac3_re = Wre[sub_stage_exp10<<5]; 
                       rotfac3_im = Wim[sub_stage_exp10<<5];
                       rotfac4_re = Wre[(sub_stage_exp10<<5)+(sub_stage_exp10<<4)]; 
                       rotfac4_im = Wim[(sub_stage_exp10<<5)+(sub_stage_exp10<<4)];
                   end
           `stage4:begin
                       rotfac1_re = Wre32[0];                                       //最后一级全为W_256^0
                       rotfac1_im = Wim32[0];
                       rotfac2_re = Wre32[0];
                       rotfac2_im = Wim32[0];
                       rotfac3_re = Wre32[0];
                       rotfac3_im = Wim32[0];
                       rotfac4_re = Wre32[0];
                       rotfac4_im = Wim32[0];
                   end
           default:;
        endcase 
    end
end

endmodule
