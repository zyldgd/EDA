module adder(
input          clk,
input          cin,
input  [7:0]   A,
input  [7:0]   B,

output reg[7:0]   sum,
output reg        cout
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
