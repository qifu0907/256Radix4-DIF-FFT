`include "define.v"

module tb_fft;

reg                          clk; 
reg                          rst_n; 
reg                          en_din; 
reg      [`fifoDataWid]      time_din;
reg                          ld_n;
wire                         full_n;
wire     [`cacheDataWid]     invbit_dout;
wire     [`cacheDataWid]     power_dout;
wire                         done;
wire                         busy;

reg     [`fifoDataWid]  fifo [0:1023];

fft     u_fft(
             .clk(clk), 
             .rst_n(rst_n), 
             .en_din(en_din), 
             .busy(busy), 
             .time_din(time_din),
             .ld_n(ld_n),
             .full_n(full_n),
             .invbit_dout(invbit_dout),
             .power_dout(power_dout),
             .done(done)
             );

//clk & rst_n
initial begin
    clk = 0;
    rst_n = 0;
    en_din = 1;
    $readmemb("/home/zjh/ic_prj/asic/fft/matlab/src.txt",fifo);
    #18
    rst_n = 1;
    #35000 $finish;
end

initial 
    forever #5 clk = ~clk; 

//counter logic
reg     [9:0]     cnt;
always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        cnt  <= 11'd0;
        ld_n <= 1'b1;
    end
    else if(~busy)begin
        ld_n = 1'b0;
        cnt  <= cnt + 1'b1;
    end
    else begin
        ld_n = 1'b1;
        cnt <= cnt;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(~rst_n)
        time_din <= 17'd0;
    else 
        time_din <= fifo[cnt];
end

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,"+mda");
end

endmodule

