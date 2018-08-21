/*
 * file   : lockeddoor.v
 * author : zyl
 * date   : 2018-8-20
 * addr   : whu.edu.ionosphereLab
 */

module lockeddoor(
input              clk,
input              reset_n,
input  [11:0]      inputChar,   // 输入信号，0-9 * #
input  [ 7:0]      password,    // 外部密码输入
output reg         open         // 开门信号
);

integer                i             = 0;
reg                    KEEP          = 0;          // 继续标志
reg        [ 7: 0]     PASSWD [5:0];               // 初始密码
reg        [ 7: 0]     INPUTS [5:0];

reg                    pressing      = 0;          // 正在输入
reg        [ 7: 0]     curInputChar  = 0;          // 当前输入字符
reg        [ 7: 0]     curMode       = 0;          // 当前模式 (0:待选择模式 1:登录 2:修改 3:更新)
reg        [ 7: 0]     state         = 0;
reg        [ 3: 0]     num           = 0;

/************************   输入判定  ************************/
always @(posedge clk) begin
    case (inputChar)
      12'b000000000001:begin
        curInputChar <= 0;
        pressing     <= 1;
      end
      12'b000000000010:begin
        curInputChar <= 1;
        pressing     <= 1;
      end
      12'b000000000100:begin
        curInputChar <= 2;
        pressing     <= 1;
      end
      12'b000000001000:begin
        curInputChar <= 3;
        pressing     <= 1;
      end
      12'b000000010000:begin
        curInputChar <= 4;
        pressing     <= 1;
      end
      12'b000000100000:begin
        curInputChar <= 5;
        pressing     <= 1;
      end
      12'b000001000000:begin
        curInputChar <= 6;
        pressing     <= 1;
      end
      12'b000010000000:begin
        curInputChar <= 7;
        pressing     <= 1;
      end
      12'b000100000000:begin
        curInputChar <= 8;
        pressing     <= 1;
      end
      12'b001000000000:begin
        curInputChar <= 9;
        pressing     <= 1;
      end
      12'b010000000000:begin
        curInputChar <= 10;
        pressing     <= 1;
      end
      12'b100000000000:begin
        curInputChar <= 11;
        pressing     <= 1;
      end
      default:begin
        curInputChar <= 0;
        pressing     <= 0;
      end
    endcase
end


/************************  初始化密码  ************************/
initial begin
    PASSWD[0] <= 1;
    PASSWD[1] <= 2;
    PASSWD[2] <= 3;
    PASSWD[3] <= 4;
    PASSWD[4] <= 5;
    PASSWD[5] <= 6;
end


/************************  一段状态机  ************************/

always @(posedge clk ) begin
if (!reset_n) begin
    state <= 0; 
    KEEP <= 0;
    open <= 0;
end else begin
    case (state)
      0:begin// 初始化
        if (KEEP) begin
            state <= 1;
        end else begin
            num  <= 0;
            open <= 0;
            state <= 1;
            curMode <= 0;
            for (i=0;i<6;i=i+1) begin
                INPUTS[i]<= 0;
            end
        end
      end
      1:begin// 接受输入
        KEEP  <= 0;
        state <= 2;
      end
      2:begin// 等待输入
        if (pressing) begin
            state <= 3;
        end
      end
      3:begin// 决策阶段
        if (curMode == 0) begin /************************  等待确认当前模式  ************************/
            if (curInputChar<=9) begin          /***** 输入是[0-9]  *****/
                curMode <= 1;
            end else if (curInputChar==10) begin/***** 输入是[ * ]  *****/
                curMode <= 2;
                KEEP  <= 1;
                state <= 255;
            end else begin
                state <= 255;
            end
        end else begin         /************************ 　　　返回现场 　　 ************************/
            if (curMode==1) begin
                state <= 4;
            end else if (curMode==2) begin
                state <= 4; // 输入原密码
            end else if (curMode==3) begin
                state <= 7; // 输入新密码
            end else begin
                state <= 255;
            end
        end
        if (curInputChar==11) begin/***** 输入是[ # ] *****/
            state <= 255;
        end
      end
      4:begin// 记录输入
        if (num<5) begin// 输入6位密码
            INPUTS[num] <= curInputChar;
            num <= num + 1;
            KEEP  <= 1;
            state <= 255;// !!!
        end else begin
            INPUTS[num] <= curInputChar;
            state <= 5;  // 密码输入完成，等待确认
            num <= 0;
        end
      end
      5:begin// 验证阶段
        if (INPUTS[num]==PASSWD[num] && num<6) begin
            num<=num+1;
        end else if (num>=6) begin
            state <= 6;
        end else begin
            state <= 255;
        end
      end
      6:begin// 输出阶段
        if (curMode == 1) begin
            open  <= 1;
            state <= 255;
        end else if (curMode == 2) begin
            num   <=0;
            curMode <= 3;// 输入新密码
            KEEP  <= 1;
            state <= 255;
        end else begin
            state <= 255;
        end
      end
      7:begin// 输入新密码
         if (num<5) begin
            PASSWD[num] <= curInputChar;
            num   <= num + 1;
            KEEP  <= 1;
            state <= 255;
        end else begin
            PASSWD[num] <= curInputChar;
            state <= 255;
        end
      end

      255:begin // 等待按键释放
        if (!pressing) begin
            state <= 0;
        end
      end

      default:
        state <= 255;
    endcase
end
end

endmodule
//end lockeddoor