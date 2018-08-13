/*
 * file   : ram.v 
 * author : zyl
 * date   : 2018-8-11
 * addr   : whu.edu.ionosphereLab
 */


module ram(
input              clk,
input              reset_n,
input              wr_en,       // 写使能，高电平有效
input              rd_en,       // 读使能，高电平有效
input  [ 7:0]      addr,        // 地址线，8位
inout  [31:0]      data_io      // 数据线
);

reg    [31:0]      RAM [255:0]; // 内存    
reg    [31:0]      data;        // 数据缓冲

integer i; 

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin         // 复位
        for(i=0;i<=255;i=i+1)  
            RAM[i] <= 32'b0;
    end else if (wr_en) begin   // 读
        RAM[addr] <= data_io;
    end else if (rd_en) begin   // 写
        data <= RAM[addr];
    end else begin              // 空闲时，数据缓冲为高阻态
        data <= 32'bz;
    end
end

assign data_io = rd_en? data : 32'bz; //数据端三态门

endmodule

//end ram
