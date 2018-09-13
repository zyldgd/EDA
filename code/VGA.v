
//=======================================================
//  Structural coding
//=======================================================
`timescale 1ns / 1ps

// ball speed direction
`define RIGHT 1'b1
`define LEFT  1'b0
`define UP    1'b0
`define DOWN  1'b1

`define ballSpeed  9


module DE1_SOC(
    input                   CLOCK_50,// mclk
    input    [9:0]          SW,// reset
    input    [3:0]          KEY,//keyL,keyR
    //input [3:0] bar_move_speed,
    output                  VGA_HS,
    output                  VGA_BLANK_N,
    output                  VGA_SYNC_N,
    output                  VGA_CLK, //HSync
    output   [7:0]          VGA_B,//OutBlue,
    output   [7:0]          VGA_G,//OutGreen,
    output   [7:0]          VGA_R,//OutRed,
    output                  VGA_VS,//VSync
    //output [3:0]          seg_select,
    output   [6:0]          HEX0,//seg_LED
    output   [6:0]          HEX1,
    output   [6:0]          HEX2,
    output   [6:0]          HEX3 );


    wire lose;

    assign  VGA_BLANK_N=1'b1;
    assign  VGA_SYNC_N=1'b0;
    assign  VGA_CLK=clk_25M;


clk_Div_2 clkDiv(
    .clk        (CLOCK_50),
    .clk_25M    (clk_25M) );


VGA_Dispay VGA(
    .reset        (SW[0]),
    .clk        (CLOCK_50),
    .keyL    (KEY[3]),
    .keyR   (KEY[2]),
    //.bar_move_speed (bar_move_speed),
    .hs         (VGA_HS),
    .Blue       (VGA_B),
    .Green      (VGA_G),
    .Red        (VGA_R),
    .vs         (VGA_VS),
    .lose       (lose) );


endmodule




module VGA_Dispay(
    input                reset,
    input                clk,
    input                keyL,
    input                keyR,
     //input [3:0] bar_move_speed,
    output reg           hs,
    output reg           vs,
    output reg   [7:0]   Red,
    output reg   [7:0]   Green,
    output reg   [7:0]   Blue,
    output reg           lose );

/**************************************************** parameter ****************************************************/
    
    parameter Width = 640;		// Pixels/Active Line (pixels)
    parameter Height = 480;		// Lines/Active Frame (lines)

    parameter PLD = 800;	    // Pixel/Line Divider
    parameter LFD = 521;		// Line/Frame Divider

    parameter Ha = 95;			// Horizontal synchro Pulse Width (pixels)   3.8*25 
    parameter Hd = 15;  		// Horizontal synchro Front Porch (pixels)   0.6*25	
    parameter Va = 2;			// Verical synchro Pulse Width (lines)
    parameter Vd = 10;			// Verical synchro Front Porch (lines)

    parameter boundU = 20;
    parameter boundD = 460;

    parameter boundL = 20;
    parameter boundR = 620;
   

/**************************************************** register  ****************************************************/
    reg                  clk_25M = 0;      // 25MHz frequency

    reg signed  [15:0]   Hcnt;             // horizontal counter  if = PLD-1 >>> Hcnt <= 0
    reg signed  [15:0]   Vcnt;             // verical counter     if = LFD-1 >>> Vcnt <= 0

    // bar
    reg signed  [15:0]   barX = 405;
    reg signed  [15:0]   barY = 430;
    reg signed  [15:0]   barHw = 100/2;
    reg signed  [15:0]   barHh = 10/2; 
    reg signed  [15:0]   barMoveXSpeed = 9;
 
    // ball
    reg signed  [15:0]   ballX = 330;
    reg signed  [15:0]   ballY = 390;
    reg signed  [15:0]   ballR = 10;
    reg signed  [15:0]   ballMoveXSpeed = 9;
    reg signed  [15:0]   ballMoveYSpeed = 9;

/*****************************************************************************************************************/

    //generate a half frequency clock of 25MHz
    always@(posedge(clk)) begin
        clk_25M <= ~clk_25M;
    end



    /*generate the hs && vs timing*/
    always@(posedge(clk_25M)) begin
        /*conditions of reseting Hcnter && Vcnter*/
        if(Hcnt == PLD-1) begin//have reached the edge of one line
            Hcnt <= 0; //reset the horizontal counter
            Vcnt <= (Vcnt == LFD-1) ? 0 : (Vcnt + 1); //only when horizontal pointer reach the edge can the vertical counter ++
        end else
            Hcnt <= Hcnt + 1;

        /*generate hs timing*/
        if(Hcnt == Width + Hd)
            hs <= 1'b0;
        else if(Hcnt == Width + Hd + Ha + 1)
            hs <= 1'b1;

        /*generate vs timing*/
        if(Vcnt == Height + Vd)
            vs <= 1'b0;
        else if(Vcnt == Height + Vd + Va + 1)
            vs <= 1'b1;
    end





    // modify the Xspeed of the bar 
    always @ (posedge vs) begin
        if (~keyL && (barX-barHw-barMoveXSpeed)>boundL) begin
            barX  <= barX - barMoveXSpeed;
        end else if(~keyR && (barX+barHw+barMoveXSpeed)<boundR) begin
            barX  <= barX + barMoveXSpeed;
        end         
    end

    // modify the Xspeed of the ball
    always @ (posedge vs) begin
        if (reset) begin
            ballMoveXSpeed <= +`ballSpeed; 
        end else begin
            if (ballX+ballR > boundR) begin
                ballMoveXSpeed <= -`ballSpeed;
            end else if (  ballX-ballR < boundL) begin
                ballMoveXSpeed <= +`ballSpeed;
            end         
        end            
    end

    // modify the Yspeed of the ball
    always @ (posedge vs) begin
        if (reset) begin
            ballMoveYSpeed <= -`ballSpeed;
        end else begin
            if (ballY-ballR < boundU) begin
                ballMoveYSpeed <= +`ballSpeed;
            end else if (ballY+ballR > boundD) begin
                ballMoveYSpeed <= -`ballSpeed;
            end 
            if ((barX-barHw) < (ballX+ballMoveXSpeed) && (ballX+ballMoveXSpeed) < (barX+barHw)  && (barY-barHh)<(ballY+ballR + ballMoveYSpeed) && (ballY+ballR + ballMoveYSpeed)<(barY+barHh) ) begin
                ballMoveYSpeed <= -`ballSpeed;
            end
        end            
    end

    // flush the poistion of the bar and ball
    always @ (posedge vs) begin
        if (reset) begin
            ballX <= barX;
            ballY <= barY-barHh-ballR;
        end else begin
            ballX <= ballX + ballMoveXSpeed;
            ballY <= ballY + ballMoveYSpeed;
        end
    end

    //Display the bar and the ball
    always @ (posedge clk_25M) begin
        if (Vcnt>=(barY-barHh) && Vcnt<=(barY+barHh) && Hcnt>=(barX-barHw) && Hcnt<=(barX+barHw)) begin  // Display the bar
            Red    <= 255;
            Green  <= 255;
            Blue   <= 255;
        end else if ((Hcnt - ballX)*(Hcnt - ballX) + (Vcnt - ballY)*(Vcnt - ballY) <= (ballR * ballR)) begin  // Display the ball
            Red    <= 227;
            Green  <= 85;
            Blue   <= 26;
        end else begin
            Red    <= 8'b0;
            Green  <= 8'b0;
            Blue   <= 8'b0;
        end
    end

endmodule



module clk_Div_2(
    input           clk,
    output  reg     clk_25M );

    always@(posedge(clk)) begin
        clk_25M <= ~clk_25M;
    end
endmodule
