`timescale 1 ps/ 1 ps

module top();

reg              clk;
reg              reset_n;
reg  [11:0]      inputChar;    // 输入信号，0-9 * #
wire             open;         // 开门信号

always #50 clk = ~clk;

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

    //press(12'b010000000000);

    press(12'b000000000010);
    press(12'b000000000100);
    press(12'b000000001000);
    press(12'b000000010000);
    press(12'b000000100000);
    press(12'b000001000000);
    // 2 6 1 4 3 5
    #4000
    press(12'b000000000010);
    press(12'b000000000100);
    press(12'b100000000000);

    #4000
    press(12'b010000000000);
    press(12'b000000000010);
    press(12'b000000000100);
    press(12'b000000001000);
    press(12'b000000010000);
    press(12'b000000100000);
    press(12'b000001000000);

    #4000
    press(12'b000000000100);
    press(12'b000001000000);
    press(12'b000000000010);
    press(12'b000000010000);
    press(12'b000000001000);
    press(12'b000000100000);

    #4000
    press(12'b000000000010);
    press(12'b000000000100);
    press(12'b000000001000);
    press(12'b000000010000);
    press(12'b000000100000);
    press(12'b000000100000);

    #4000
    press(12'b000000000100);
    press(12'b000001000000);
    press(12'b000000000010);
    press(12'b000000010000);
    press(12'b000000001000);
    press(12'b000000100000);
    
end
endtask
   
lockeddoor i1 (
.clk        (clk),
.reset_n    (reset_n),
.inputChar  (inputChar),  
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


