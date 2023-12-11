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
// Description: Two second timer for gameover display.
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
    output wire timer_done
    );

    //assumes 60Hz clk for time_tick

    reg [6:0] timer_val, timer_next;

    always @(posedge clk, posedge reset) begin
    	if (reset) begin 
    		timer_val <= 7'b1111000;
    	end
    	else
    		timer_val <= timer_next;
    	end
    end

    always @* begin
    	if (timer_start)
    		 timer_next = 7'b11111111;
    		 timer_tick = 1'b0;
    	else if ((timer_tick) && (timer_val != 0)):
    		timer_next = timer_val - 1;
    		timer_click = 1'b1;
    	else
    		timer_next = timer_val;
    		timer_click = 1'b0;
    end
    //output
    assign timer_done = (timer_val == 0);
endmodule

