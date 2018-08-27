`timescale 1ns / 1ps
module spi_master(
	input          clk, 
	input  [7:0]   in_data,// 数据输入
	input  [1:0]   addr,// 地址线
	input          wr,// 写使能
	input          rd,// 读使能
	input          cs,// 片选
	inout          mosi,// 主发从收
	input          miso,// 主收从发
	inout          sclk,// 时钟
	output reg[7:0] out_data// 数据输出
);
	
	// --------定义内部寄存器和缓存--------
	reg sclk_buf = 0;
	reg mosi_buf = 0;
	// 忙碌标志寄存器 , 没有数据收发时 busy = 0 否则 busy = 1
	reg busy = 0;
	// 移位寄存器
	reg[7:0] in_buf = 0;
	reg[7:0] out_buf = 0;
	// 分频 , 无分频时 clk_div=0	
	reg[7:0] clk_cnt = 0;
	reg[7:0] clk_div = 0;
	reg[4:0] cnt = 0;
	// 组合逻辑 连接外部端口
	assign sclk = sclk_buf;
	assign mosi = mosi_buf;

	// 在sclk 上升沿时，从miso读入数据到out-shift 
	always @(posedge sclk_buf) begin
		out_buf[0] <= miso;
		out_buf <= out_buf << 1;
	end 

	// 读数据
	always @(cs or wr or rd or addr or out_buf or busy or clk_div) begin
		out_data = 8'bx;
		if (cs && rd) begin
			case(addr)
				2'b00 : out_data = out_buf;
				2'b01 : out_data = {7'b0 , busy};//当发送冲突的时候，返回busy信号
				2'b10 : out_data = clk_div;
				default : out_data = out_data;
			endcase
		end
	end

	// sclk 下降沿时 写入数据到 mosi
	always @(posedge clk) begin
		if (!busy) begin // 空闲时加载数据到发送缓冲中
			if(cs && wr) begin
				case(addr)
					2'b00 : begin
						in_buf <= in_data;
						busy <= 1;
						cnt <= 0;
					end
					2'b10 : begin
						in_buf <= clk_div;
					end
					default : in_buf <= in_buf; 
				endcase
			end
			else if(cs && rd) begin
				busy <= 1;
				cnt <= 0;
			end
		end
		else begin //当8位数据写入到缓冲后，开始按位发送
			clk_cnt <= clk_cnt + 1;
			if (clk_cnt >= clk_div) begin
				clk_cnt <= 0;
				if (cnt % 2 == 0) begin //当 csk_buf 为 negitive ,将数据移位到 mosi 缓冲中
					mosi_buf <= in_buf[7];
					in_buf <= in_buf << 1;
				end 
				else begin
					mosi_buf <= mosi_buf;
				end
				if (cnt > 0 && cnt < 17) begin
					sclk_buf <= ~sclk_buf;
				end
				// 8位数据发送完成,SPI空闲
				if (cnt >= 17) begin 
					cnt <= 0;
					busy <= 0;
				end
				else begin
					cnt <= cnt;
					busy <= busy;
				end
				cnt <= cnt + 1;
			end
		end
	end
endmodule
