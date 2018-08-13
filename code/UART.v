`timescale 1ns/1ps
// https://www.cnblogs.com/qingkai/p/7729621.html
// 系统时钟50MHz，波特率115200，带忙闲指示信号ready
module uart_tx #(parameter BAUDRATE = 115200, parameter FREQ = 50_000_000)(
input               clk,
input               reset_n,
input               wrreq,
input       [7:0]   wdata,
input  reg          rx,
output reg          tx,
output reg          ready
);

localparam T = FREQ / BAUDRATE;

reg         [3:0]   cnt_bit;
reg         [31:0]  cnt_clk;
wire                end_cnt_clk;
wire                end_cnt_bit;


assign end_cnt_clk = cnt_clk == T - 1;
assign end_cnt_bit = end_cnt_clk && cnt_bit == 10 - 1;


// 有写请求时将ready信号拉底，待到数据发送完毕再将信号拉
always @(posedge clk or negedge reset_n) begin
    if(!reset_n)
        ready <= 1;
    else if(wrreq)
        ready <= 0;
    else if(end_cnt_bit)
        ready <= 1;
end

// 两层计数结构，cnt_clk计数每一位所占的时钟数，cnt_bit计数1个开始位，8个数据位，一个停止位，共10位
always @(posedge clk or negedge reset_n) begin
    if(!reset_n)
        cnt_clk <= 0;
    else if(ready == 0) begin
        if(end_cnt_clk)
            cnt_clk <= 0;
        else
            cnt_clk <= cnt_clk + 1;
    end
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)
        cnt_bit <= 0;
    else if(end_cnt_clk) begin
        if(end_cnt_bit)
            cnt_bit <= 0;
        else
            cnt_bit <= cnt_bit + 1;
    end
end

/*
0x41 <=> 0b0100 0001
┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
│ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │
└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘

┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
│ S │ 1 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │ 0 │ E │
└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘

┐   ┌───┐                   ┌───┐   ┌───┐
│ S │ 1 │ 0   0   0   0   0 │ 1 │ 0 │ 1 │
└───┘   └───────────────────┘   └───┘   └

*/
// 先发送一个起始位0，然后8位数据位，最后是停止位1
always @(posedge clk or negedge reset_n) begin
    if(!reset_n)
        tx <= 1;
    else if(ready == 0 && cnt_clk == 0) begin
        if(cnt_bit == 0)
            tx <= 0;
        else if(cnt_bit == 9)
            tx <= 1;
        else
            tx <= wdata[cnt_bit - 1];
    end
end

endmodule
