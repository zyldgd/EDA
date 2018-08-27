/**************** 普通8位加法器 ****************/

module adder1(

input       [7:0]      A,
input       [7:0]      B,
output      [8:0]      sum
);

assign sum[8:0] = {1'd0, A} + {1'd0, B};

endmodule


/*************** 8位流水线加法器 **************/
module adder2(
input          clk,
input          cin,
input  [7:0]   A,
input  [7:0]   B,
output reg [7:0]   sum,
output reg         cout
);
  
reg            cout1; //插入的寄存器
reg   [3:0]    sum1; //插入的寄存器
reg   [3:0]    A_reg;
reg   [3:0]    B_reg;//插入的寄存器

//第一级流水
always @(posedge clk) begin 
    {cout1 ,sum1} <= A[3:0] + B [3:0] + cin;
    A_reg <= A[7:4];
    B_reg <= B[7:4];
end

//第二级流水
always @(posedge clk) begin
    {cout ,sum} <= {{1'b0, A_reg} + {1'b0, B_reg} + cout1, sum1} ;
end

endmodule
