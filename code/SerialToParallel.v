module SerialToParallel(
    input         CLK,    //时钟
    input         RSTn,    //复位
    input         Enable,    //输入有效
    input         DataIn,    //串行输入
    output reg    Ready,    //输出有效
    output[7:0]    Index,    //并行数据索引
    output[7:0] ParallelData    //并行数据输出
    );
    
    reg[7:0]    Data_Temp;    //数据缓存
    reg[3:0]    counter;    //位数计数器
    reg[3:0]    state;        //状态机
    reg[7:0]    Index_Temp;    //索引缓存
    
    assign    Index=Index_Temp;
    assign    ParallelData=Ready?Data_Temp:8'd0;
    
    ////////////////////////////////////////
    //state:
    //4'd0:复位 
    //
    //4'd1:未复位，未使能
    //
    //4'd2:未复位，输入使能
    //
    
    always@(posedge CLK or negedge RSTn)
    if(!RSTn)
        begin
            state<=4'd0;        //复位
            Ready<=0;
            counter<=4'd0;
            Data_Temp<=8'd0;
            Index_Temp<=8'd0;
        end
    else
        begin
            case(state)
                4'd0:
                begin
                    if(!Enable)state<=4'd1;
                    else state<=4'd2;
                    Ready<=0;
                end
                4'd1:
                begin
                    if(!Enable)state<=4'd1;
                    else state<=4'd2;
                    Ready<=0;
                    counter<=4'd0;
                    Data_Temp<=8'd0;
                end
                4'd2:
                begin
                    if(!Enable)state<=4'd1;
                    else state<=4'd2;
                    case(counter)
                    4'd0:begin Data_Temp[0]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd1:begin Data_Temp[1]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd2:begin Data_Temp[2]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd3:begin Data_Temp[3]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd4:begin Data_Temp[4]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd5:begin Data_Temp[5]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd6:begin Data_Temp[6]<=DataIn;counter<=counter + 1'b1;Ready<=0;end
                    4'd7:begin Data_Temp[7]<=DataIn;counter<=4'd0;Index_Temp<=Index_Temp + 1'b1;Ready<=1'b1;end
                    endcase
                end
            endcase
        end

endmodule
