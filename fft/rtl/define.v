//------------------------------------------------------
//复位和置位
`define    set1              1'b1
`define    rst0              1'b0

//------------------------------------------------------
//cache数据和地址
`define    fifoDataWid       16:0        //fifo数据宽度
`define    cacheRst          34'b0      //cache数据清零
`define    cacheDataWid      33:0       //数据位宽
`define    cacheDeepWid      0:255      //cache深度
`define    cacheAddrWid      7:0        //地址位宽
`define    cacheAddrMax      8'hff      //地址最大值
`define    cacheAddrRst      8'h00      //地址复位

//------------------------------------------------------
//stage的参数
`define    stageWid          1:0        //stage位宽
`define    stage1            2'b00      //stage1
`define    stage2            2'b01
`define    stage3            2'b10 
`define    stage4            2'b11

//------------------------------------------------------
//地址计算参数
`define    subStageRst       6'b0
`define    subStageWid       5:0
`define    offset_s1         7'd64      //stage1时，蝶形输入数据地址偏移量
`define    offset_s2         5'd16      //stage2偏移量
`define    offset_s3         3'd4       //stage3偏移量
`define    offset_s4         1'd1       //stage4偏移量

//------------------------------------------------------
//旋转因子表
`define    rotfactorWid      20:0       //旋转因子位宽
`define    rotfactorwid      21         //旋转因子宽度

//------------------------------------------------------
//butterfly
`define    xnHalfWid         16:0        //xn一半位宽
`define    xnRe              33:17       //xn实部
`define    xnIm              16:0        //xn虚部
`define    butSum4Wid        16:0       //4输入和
`define    butDataWid        37:0       //乘积multiply
`define    mult35_20         35:20      //截断

