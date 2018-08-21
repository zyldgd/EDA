`timescale 1 ps/ 1 ps

module testBench_lockeddoor();

reg              clk;
reg              reset_n;
reg  [11:0]      inputChar;    // 输入信号，0-9 * #
wire             open;         // 开门信号

always #50 clk = ~clk;

parameter CHR_0 = 12'b000000000001; // num 0
parameter CHR_1 = 12'b000000000010; // num 1
parameter CHR_2 = 12'b000000000100; // num 2
parameter CHR_3 = 12'b000000001000; // num 3
parameter CHR_4 = 12'b000000010000; // num 4
parameter CHR_5 = 12'b000000100000; // num 5
parameter CHR_6 = 12'b000001000000; // num 6
parameter CHR_7 = 12'b000010000000; // num 7
parameter CHR_8 = 12'b000100000000; // num 8
parameter CHR_9 = 12'b001000000000; // num 9
parameter CHR_s = 12'b010000000000; // start key [*]
parameter CHR_p = 12'b100000000000; // pound key [#]

initial begin                                                  
init();
                     
end  

task init;
begin
    clk  <= 0;
    reset_n <= 1;
    #200 
    reset_n <= 0;
    #200 
    reset_n <= 1;


    #200
    // 输入原密码测试是否能通过
    press(CHR_1);
    press(CHR_2);
    press(CHR_3);
    press(CHR_4);
    press(CHR_5);
    press(CHR_6);

    #4000
    // 中间输入[#]测试是否能退出
    press(CHR_1);
    press(CHR_2);
    press(CHR_p);

    #4000
    // 输入*号，重设密码
    press(CHR_s); 

    #1000
    // 首先需要输入原密码进行验证
    press(CHR_1);
    press(CHR_2);
    press(CHR_3);
    press(CHR_4);
    press(CHR_5);
    press(CHR_6);

    #4000
    // 然后输入新密码修改
    press(CHR_1);
    press(CHR_3);
    press(CHR_5);
    press(CHR_7);
    press(CHR_9);
    press(CHR_0);

    #4000
    // 输入旧密码测试是否能通过
    press(CHR_1);
    press(CHR_2);
    press(CHR_3);
    press(CHR_4);
    press(CHR_5);
    press(CHR_6);

    #4000
    // 输入新密码测试是否能通过
    press(CHR_1);
    press(CHR_3);
    press(CHR_5);
    press(CHR_7);
    press(CHR_9);
    press(CHR_0);
    
end
endtask
   
lockeddoor i1 (
.clk        (clk),
.reset_n    (reset_n),
.inputChar  (inputChar),  
.password   (),
.open       (open)
);
  
   
task press;
  input [12:0]  INPUTS;
  
  begin
    #1000                  
    inputChar<= INPUTS;
    #1000 
    inputChar<= 0;
  end
endtask

                                           
endmodule


