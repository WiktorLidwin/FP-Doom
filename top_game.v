`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023
// Design Name: 
// Module Name: game_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This attaches everything together.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module game_top(
    input  A, B, C;
    input wire clk, reset;
    output wire hsync, vsync;
    output RGB; //todo make this correct
    );

    //game states
    localparam [1:0] 
    	newgame = 2'b00,
    	play = 2'b01,
    	over = 2'b11;

    reg [1:0] state_reg, state_next;

    //todo declare input variables for module instatiation
    //todo connect vga, connect raycaster, connect text, connect movement, connect input_drivers. timer

    // FSM for game logic
    // state logic
    always @(posedge clk, posedge reset)
    	if (reset) begin
    		state_reg <= newgame;
    		rgb_reg <= 0;
    	end
	else begin
		state_reg <= state_next;
		if (pixel_tick)
			rgb_reg <= rgb_next;
		end
     //states
     always @* begin
     	timer_start = 1'b0;
     	state_next = state_reg;
     	case (state_reg)
     		newgame: begin
     			//reset data here
     			//clear timers
     			//show game text
     			//initialize raycaster
     			if (btn != 2'b00) begin //if button pressed, go to game
     					state_next = play;
     					// clear text?
			end
		play: begin
			// initialize game timer
			// display game tiemr,
			// if button pressed, movement
			// update raycaster from movement
		end
		over: begin
			//chill for two seconds before next state
			if (timer_up)
				state_next = newgame;
				//stop raycasting updates
		end
	endcase
    end
    //display of graphics and text
    //todo ray caster and text, change text ons. 
    always @* 
    	if (~video_on)
    		rgb_next = "000" //blank at edges
    	else
    		// show start menu at beginning, show gameover at end
    		//TODO check text_on
    		if (text_on[3] || state_reg == newgame && text_on[1] || sate_reg == over && text_on[0]))
			rgb_next = text_rgb
		else if (graph_on)
			rgb_next = graph_rgb
		else if (text_on[2]) //display logo TODO remove?
			rgb_next = text_rgb;
		else
			rgb_next = 3'b1000; //background
	assign rgb = rgb_reg;
endmodule

