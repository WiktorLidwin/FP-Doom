`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023
// Design Name: 
// Module Name: gameover_timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Three minute timer for ingame.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module gameover_timer(
    input wire clk, reset,
    input wire timer_start, timer_tick,
    output wire timer_done,
    output reg [12:0] timer_val
    );

    //assumes 60Hz clk for time_tick

    reg [12:0] timer_next;

    always @(posedge clk, posedge reset) begin
    	if (reset) begin
    		timer_val <= 13'b10101000110000;
    	end
    	else
    		timer_val <= timer_next;
    	end
    end

    always @* begin
    	if (timer_start)
    		 timer_next = 13'b10101000110000;
    	else if ((timer_tick) && (timer_val != 0)):
    		timer_next = timer_val - 1;
    	else
    		timer_next = timer_val;
    end
    //output
    assign timer_done = (timer_val == 0);
endmodule

