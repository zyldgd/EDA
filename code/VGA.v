
//=======================================================
//  Structural coding
//=======================================================
`timescale 1ns / 1ps

// ball speed direction
`define RIGHT 1'b1
`define LEFT  1'b0
`define UP    1'b0
`define DOWN  1'b1
`define bar_move_speed 4'b1001


module DE1_SOC(
    input                   CLOCK_50,// mclk
    input    [9:0]          SW,// rst
    input    [3:0]          KEY,//to_left  //to_right
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
    .rst        (SW[0]),
    .clk        (CLOCK_50),
    .to_left    (KEY[3]),
    .to_right   (KEY[2]),
    //.bar_move_speed (bar_move_speed),
    .hs         (VGA_HS),
    .Blue       (VGA_B),
    .Green      (VGA_G),
    .Red        (VGA_R),
    .vs         (VGA_VS),
    .lose       (lose) );


endmodule




module VGA_Dispay(
    input                rst,
    input                clk,
    input                to_left,
    input                to_right,
     //input [3:0] bar_move_speed,
    output reg           hs,
    output reg           vs,
    output reg   [7:0]   Red,
    output reg   [7:0]   Green,
    output reg   [7:0]   Blue,
    output reg           lose );

    //parameter defin ition
    parameter Width = 640;		// Pixels/Active Line (pixels)
    parameter Height = 480;		// Lines/Active Frame (lines)

    parameter PLD = 800;	    // Pixel/Line Divider
    parameter LFD = 521;		// Line/Frame Divider

    parameter Ha = 95;			// Horizontal synchro Pulse Width (pixels)   3.8*25 
    parameter Hd = 15;  		// Horizontal synchro Front Porch (pixels)   0.6*25	
    parameter Va = 2;			// Verical synchro Pulse Width (lines)
    parameter Vd = 10;			// Verical synchro Front Porch (lines)

    parameter UP_BOUND = 10;
    parameter DOWN_BOUND = 480;
    parameter LEFT_BOUND = 10;
    parameter RIGHT_BOUND = 630;
   
    parameter ballR = 10;      // Radius of the ball


    /*register definition*/
    reg   [9:0]   Hcnt;             // horizontal counter  if = PLD-1 >>> Hcnt <= 0
    reg   [9:0]   Vcnt;             // verical counter     if = LFD-1 >>> Vcnt <= 0
    reg           clk_25M = 0;      // 25MHz frequency
    reg           h_speed = `RIGHT;
    reg           v_speed = `UP;

    // The position of the downside bar
    reg   [9:0]   barUp = 400;
    reg   [9:0]   barDown = 410;
    reg   [9:0]   barLeft = 280;
    reg   [9:0]   barRight = 380;

    // The circle heart position of the ball
    reg   [9:0]   ballX = 330;
    reg   [9:0]   ballY = 390;


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


    //Display the downside bar and the ball
    always @ (posedge clk_25M) begin
        if (Vcnt>=barUp && Vcnt<=barDown && Hcnt>=barLeft && Hcnt<=barRight) begin  // Display the downside bar
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


    //flush the image every zhen = =||
    always @ (posedge vs) begin
        if(to_left&&to_right) begin 	// movement of the bar
            barLeft <= barLeft;
            barRight <= barRight;
        end else if (~to_left &&((barLeft - `bar_move_speed) >= LEFT_BOUND)) begin
            barLeft <= barLeft - `bar_move_speed;
            barRight <= barRight - `bar_move_speed;
        end else if(~to_right && ((barRight + `bar_move_speed )<= RIGHT_BOUND)) begin
            barLeft <= barLeft + `bar_move_speed;
            barRight <= barRight + `bar_move_speed;
        end
        //else

        //movement of the ball
        if (v_speed == `UP) // go up
            ballY <= rst?390:ballY - `bar_move_speed;
        else //go down
            ballY <= rst?390:ballY + `bar_move_speed;

        if (h_speed == `RIGHT) // go right
            ballX <= rst?(barLeft+barRight)/2:ballX + `bar_move_speed;
        else //go down
            ballX <= rst?(barLeft+barRight)/2:ballX - `bar_move_speed;
    end

     
    //change directions when reach the edge or crush the bar
    always @ (negedge vs) begin
        if (ballY <= UP_BOUND) begin  // Here, all the jugement should use >= or <= instead of ==
            v_speed <= 1;              // Because when the offset is more than 1, the axis may step over the line
            lose <= 0;
        end else if (ballY >= (barUp - ballR) && ballX <= barRight && ballX >= barLeft) begin
            v_speed <= 0;
        end else if (ballY >= barDown && ballY < (DOWN_BOUND - ballR)) begin // Ahhh!!! What the fuck!!! I miss the ball!!!
            lose <= 1; //Do what you want when lose
        end else if (ballY >= (DOWN_BOUND - ballR + 1)) begin
            v_speed <= 0;
        end else begin
            v_speed <= v_speed;
        end

        if (ballX <= LEFT_BOUND) begin
            h_speed <= 1;
        end else if (ballX >= RIGHT_BOUND) begin
            h_speed <= 0;
        end else begin
            h_speed <= h_speed;
        end

        if (ballX <= LEFT_BOUND) begin
            h_speed <= 1;
        end else if (RIGHT_BOUND <= ballX) begin
            h_speed <= 0;
        end else begin
            h_speed <= h_speed;
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
