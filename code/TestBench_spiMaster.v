`timescale 1ns / 1ps
module spi_master_tb;
	// Inputs
	reg [7:0] in_data;
	reg clk;
	reg [1:0] addr;
	reg wr;
	reg rd;
	reg cs;
	reg miso;
	// Outputs
	wire [7:0] out_data;
	// Bidirs
	wire mosi;
	wire sclk;

	spi_master uut (
		.in_data(in_data), 
		.clk(clk), 
		.addr(addr), 
		.wr(wr), 
		.rd(rd), 
		.cs(cs), 
		.out_data(out_data), 
		.mosi(mosi), 
		.miso(miso), 
		.sclk(sclk)
	);

	initial begin
		// 初始化
		in_data = 0;
		clk = 0;
		addr = 0;
		wr = 0;
		rd = 0;
		cs = 0;
		miso = 0;

		#40;
		addr = 0;
        in_data = 8'haa;
        wr = 1;
        cs = 1;

		// 写数据
		#20 ;
		wr = 0;
		cs = 0;
		#360 ;
		wr = 1;
		cs = 1;
		in_data = 8'h91;
		#20 ;
		wr = 0;
		cs = 0;
	end
	// 定义时钟
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end
endmodule
