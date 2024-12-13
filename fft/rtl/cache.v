`include "define.v"

module cache(
             // clk & rst_n
             input   wire                     clk,
             input   wire                     rst_n,

             //work flags
             input   wire                     en_din,      //输入使能
             output  reg                      busy,        //工作标志

             //fifo2cache
             input   wire    [`fifoDataWid]   new_din,     //17bit检测数据
             input   wire                     ld_n,        //load new data 连接fifo empty
             output  reg                      full_n,      //cache full    连接fifo rd_en

             //cache <--> butterfly
             input   wire    [`cacheDataWid]  but_dout0,   //butterfly 最低位addr输出
             input   wire    [`cacheDataWid]  but_dout1,   //base1 = base  + offset 
             input   wire    [`cacheDataWid]  but_dout2,   //base2 = base1 + offset 
             input   wire    [`cacheDataWid]  but_dout3,   //base3 = base2 + offset 

             output  reg     [`cacheDataWid]  cache_dout0, //cache最低地址位输出addr0
             output  reg     [`cacheDataWid]  cache_dout1, //addr1 = addr0 + offset_sx
             output  reg     [`cacheDataWid]  cache_dout2, //addr2 = addr1 + offset_sx
             output  reg     [`cacheDataWid]  cache_dout3, //addr3 = addr2 + offset_sx 
             output  reg     [`stageWid]      stage,       //log_4^256=4 / 00-->11
             output  reg     [`subStageWid]   sub_stage,   //小组循环
             output  wire                     flush_flag,  //冲刷标志位
             output  wire    [`cacheDataWid]  flush_b0,flush_b1,flush_b2,flush_b3,//上一轮but输出冲刷

             //inv_bit
             output  reg     [`cacheDataWid]  invbit_dout, //位倒序输出
             output  reg                      invbit_done, //位倒序完成

             //power output
             output wire     [`cacheDataWid]  power_dout   //能量谱幅度=re^2+im^2
            );

//memory of cache
reg     [`cacheDataWid]  mem    [`cacheDeepWid];

//*****************************************************************************
//FIFO to Cache . 256 clk in total 
//*****************************************************************************
//full_n logic && fifo_read 
reg     [`cacheAddrWid]       wr_ptr;
reg     [`cacheAddrWid]       wr_ptr_r;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        full_n <= 1'b1;
    else if(invbit_done)//准备下一轮
        full_n <= 1'b1;
    else if(wr_ptr_r == `cacheAddrMax)
        full_n <= 1'b0;
    else 
        full_n <= full_n; 
end

//write pointer logic
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        busy <= 1'b0;
    else if(invbit_done)//传输结束时拉低
        busy <= `rst0;
    else if(wr_ptr==`cacheAddrMax)//传输指针达到最大时拉高
        busy <= `set1;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        wr_ptr <= `cacheAddrRst;
    else if(wr_ptr==`cacheAddrMax)
        wr_ptr <= `cacheAddrRst;
    else if(~ld_n && ~busy)//fifo_empty=0且指针未达最大,可以加载
        wr_ptr <= wr_ptr + 1'b1; 
    else 
        wr_ptr <= wr_ptr;
end

always @(posedge clk or negedge rst_n)begin
    if(~rst_n)
        wr_ptr_r <= `cacheAddrRst;
    else
        wr_ptr_r <= wr_ptr;//外部数据传输需要1拍，因此指针打1拍，将输入数据同数组地址对齐
end

//data tansfer
always @(posedge clk or negedge rst_n)begin
    if(~rst_n)
        mem[wr_ptr_r] <= `cacheRst;
    else if(en_din && full_n)
        mem[wr_ptr_r] <= {new_din,{17{1'b0}}};//mem被不同阶段用到.else情况由其他语句决定
    else
        mem[wr_ptr_r] <= mem[wr_ptr_r];
end

//*****************************************************************************
//Cache to Butterfly
//*****************************************************************************
//----stage logic----
reg     [`cacheAddrWid]  addr0,addr1,addr2,addr3;
reg     [`cacheAddrWid]  addr0_r;     //寄存输出数据基地址
reg     [`cacheAddrWid]  addr1_r;
reg     [`cacheAddrWid]  addr2_r;
reg     [`cacheAddrWid]  addr3_r;
reg                      c2b_done;    //cache to buttfly done in stage 4

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        stage <= `stage1;
        c2b_done <= 1'b0;
    end
    else if(invbit_done)
        c2b_done <= 1'b0;
    else if(addr3_r==`cacheAddrMax)begin
        if(stage==`stage4)begin//butterfly to cache over
            c2b_done <= 1'b1;
            stage <= `stage1;
        end
        else if(~c2b_done)
            stage <= stage + 1'b1;
    end
    else begin
        c2b_done <= c2b_done;
        stage <= stage;
    end
end

//----address generate logic----
//substage logic 
//旋转因子采用组合逻辑，cache数据输出晚一拍。
//将晚一拍的sub_stage作为旋转因子索引，早一拍的pre_sub_stage作为数据输出索引
reg     [`subStageWid]    pre_sub_stage;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        pre_sub_stage <= `subStageRst; 
    else if(pre_sub_stage== 6'd63)
        pre_sub_stage <= `subStageRst;
    else if(!full_n && !c2b_done)//开始和截止flag
        pre_sub_stage <= pre_sub_stage + 1'b1;
    else
        pre_sub_stage <= `subStageRst;
end

always @(posedge clk or negedge rst_n)begin
    if(~rst_n)
        sub_stage <= `subStageRst;
    else
        sub_stage <= pre_sub_stage;
end

//address logic
always @ (*)begin
    addr0 = `cacheAddrRst;
    addr1 = `cacheAddrRst;
    addr2 = `cacheAddrRst;
    addr3 = `cacheAddrRst;
    case(stage)
        `stage1: begin
                    addr0[5:0] = pre_sub_stage;
                    addr1[6:0] = addr0[5:0] + `offset_s1;           
                    addr2[7:0] = addr1[6:0] + `offset_s1;
                    addr3[7:0] = addr2[7:0] + `offset_s1;
                 end
        `stage2: begin
                    addr0 = {pre_sub_stage[5:4],{2{1'b0}},pre_sub_stage[3:0]};//高2位为大组循环，低4位为小组循环
                    addr1 = addr0 + {{3{1'b0}},`offset_s2};   
                    addr2 = addr1 + {{3{1'b0}},`offset_s2};
                    addr3 = addr2 + {{3{1'b0}},`offset_s2};
                 end
        `stage3: begin
                    addr0 = {pre_sub_stage[5:2],{2{1'b0}},pre_sub_stage[1:0]};
                    addr1 = addr0 + {{5{1'b0}},`offset_s3};
                    addr2 = addr1 + {{5{1'b0}},`offset_s3};
                    addr3 = addr2 + {{5{1'b0}},`offset_s3};
                 end
        `stage4: begin
                    addr0 = {pre_sub_stage[5:0],{2{1'b0}}};
                    addr1 = addr0 + `offset_s4;
                    addr2 = addr1 + `offset_s4;
                    addr3 = addr2 + `offset_s4;
                 end
    endcase
end

//cache output data 
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cache_dout0 <= `cacheRst;
        cache_dout1 <= `cacheRst;
        cache_dout2 <= `cacheRst;
        cache_dout3 <= `cacheRst;
    end
    else if(!full_n && !c2b_done)begin//fifo传输结束而butterfly和cache传输未结束
        cache_dout0 <= mem[addr0];
        cache_dout1 <= mem[addr1];
        cache_dout2 <= mem[addr2];
        cache_dout3 <= mem[addr3];
    end
end

//*****************************************************************************
//Butterfly to Cache
//*****************************************************************************
//addrx_r logic
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr0_r <= `cacheAddrRst;
        addr1_r <= `cacheAddrRst;
        addr2_r <= `cacheAddrRst;
        addr3_r <= `cacheAddrRst;
    end
    else if(~full_n && ~c2b_done)begin
        addr0_r <= addr0;
        addr1_r <= addr1;
        addr2_r <= addr2;
        addr3_r <= addr3;
    end
end

//transfer data
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mem[addr0_r] <= `cacheRst;
        mem[addr1_r] <= `cacheRst;
        mem[addr2_r] <= `cacheRst;
        mem[addr3_r] <= `cacheRst;
    end
    else if(!full_n && !c2b_done)begin          
        mem[addr0_r] <= but_dout0;
        mem[addr1_r] <= but_dout1;
        mem[addr2_r] <= but_dout2;
        mem[addr3_r] <= but_dout3;
    end
end

//*****************************************************************************
//Inv_bit logic
//*****************************************************************************
reg     [`cacheAddrWid]     addr_cnt;
wire    [`cacheAddrWid]     invaddr_cnt;
assign invaddr_cnt = {addr_cnt[1:0],addr_cnt[3:2],addr_cnt[5:4],addr_cnt[7:6]};//位倒序

//addr_cnt logic
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        addr_cnt    <= `cacheAddrRst;
    else if(c2b_done && (addr_cnt<`cacheAddrMax))
        addr_cnt <= addr_cnt + 1'b1;
    else 
        addr_cnt <= `cacheAddrRst;
end

//转换结束
always @(posedge clk or negedge rst_n)begin
    if(~rst_n)
        invbit_done <= `rst0;
    else if(addr_cnt==`cacheAddrMax)
        invbit_done <= `set1;
    else
        invbit_done <= `rst0;
end

//transfer inv_bit data
assign invbit_dout = (c2b_done && ~invbit_done)? mem[invaddr_cnt]:`cacheRst;

//compute power=re^2+im^2
wire    signed  [`xnHalfWid]   real_dout;  
wire    signed  [`xnHalfWid]   imag_dout;  

assign real_dout = invbit_dout[`xnRe];
assign imag_dout = invbit_dout[`xnIm];
assign power_dout = real_dout*real_dout + imag_dout*imag_dout;

//*****************************************************************************
//赋值和生成冲刷标志位
//*****************************************************************************
reg     full_nr;
assign flush_b0 = mem[0];
assign flush_b1 = mem[1];
assign flush_b2 = mem[2];
assign flush_b3 = mem[3];

always @(posedge clk or negedge rst_n)begin
    if(~rst_n)
        full_nr <= `rst0;
    else 
        full_nr <= full_n;
end

assign flush_flag = full_n ^ full_nr;

endmodule


