/*
 * file   : TestBench_RAM.v 
 * author : zyl
 * date   : 2018-8-11
 * addr   : whu.edu.ionosphereLab
 */

`timescale 1 ps/ 1 ps

module TestBench_RAM();
/******************    端口   ********************/
reg [7:0] addr;
reg clk;
reg [31:0] treg_data_io;
reg rd_en;
reg reset_n;
reg wr_en;
                                        
wire [31:0]  data_io;

assign data_io = treg_data_io;
always #50 clk = ~clk;


/******************   初始化  ********************/
initial begin                                                  
  init();
  
  write(255,99);
  write(254,77); 

  read(255);
  read(254);                                                          
end  


/******************初始化任务块********************/
task init;
  begin
    clk <= 0;
    reset_n <=1;
    addr <=0;
    rd_en <=0;
    wr_en <=0;
    #200 reset_n <=0;
    #200 reset_n <=1;
  end
endtask
   
/**********写任务(8位地址 ,32位数据)***************/   
task write;
  input [7:0]  addr_i;
  input [31:0] data_i;
  begin
     #150;                   
     addr <= addr_i;
     treg_data_io <= data_i;
     #50                 
     wr_en <= 1;
     #100
     wr_en <= 0;
  end
endtask
      
/*****************读任务(8位地址)******************/   
task read;
  input [7:0]  addr_i;
  begin
     #150; 
     //读之前，把数据缓冲端置为高阻态，接受数据
     treg_data_io<= 32'bz;
     addr <= addr_i;
     #50                   
     rd_en <= 1;
     #100
     rd_en <= 0;
  end
endtask
       
/*****************   ram例化    ******************/           
ram i1 (
	.addr(addr),
	.clk(clk),
	.data_io(data_io),
	.rd_en(rd_en),
	.reset_n(reset_n),
	.wr_en(wr_en)
);
  
endmodule
// end testBench module

