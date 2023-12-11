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
    output wire [3:0] red, green, blue
    );

    //game states
    localparam [1:0]
    	newgame = 2'b00,
    	play = 2'b01,
    	over = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] red_r, blue_r, green_r, red_next, blue_next, green_next;

    //todo declare input variables for module instatiation
    //todo connect raycaster, connect movement

   // display variables / subsystem
    wire video_on, p_tick;
    wire pix_x, pix_y;
    wire [3:0] text_on, text_red, text_blue, text_green;

    // display / vga driver
    display display(
	.clk(clk),
	.reset(reset),
	.hsync(hsync),
	.vsync(vsync),
	.video_on(video_on),
	.p_tick(p_tick),
	.pixel_x(pix_x),
	.pixel_y(pix_y)
    );

    // text generator
    gametext gametext(
	.clk(clk),
	.reset(reset),
	.pix_x(pix_x),
	.pix_y(pix_y),
	.timer(timer_val),
	.text_on(text_on),
	.text_red(text_red),
	.text_blue(text_blue),
	.text_green(text_green)
    )

   // FSM guards
    wire rotateCCW, forward, rotateCW;
    reg game_start, over_start; //TODO check this
    wire game_done, over_done, timer_tick;
    wire [12:0] timer_val;

    buttons_driver buttons_driver(
	.A(A),
	.B(B),
	.C(C),
	.rotateCCW(rotateCCW),
	.forward(forward),
	.rotateCW(rotateCW)
    );

    game_timer game_timer(
	.clk(clk),
	.reset(reset),
	.timer_start(game_start),
	.timer_tick(timer_tick),
	.timer_done(game_done),
	.timer_val(timer_val)
    );

    gameover_timer gameover_timer(
	.clk(clk),
	.reset(reset),
	.timer_start(over_start),
	.timer_tick(timer_tick),
	.timer_done(over_done)
    );

    // FSM for game logic
    // register logic and frame rgb
    always @(posedge clk, posedge reset) begin
    	if (reset) begin
    		state_reg <= newgame;
    		red_r <= 4'b0000;
    		green_r <= 4'b0000;
    		blue_r <=4'b0000;
    	end
	else begin
		state_reg <= state_next;
		if (pixel_tick) begin
			red_r <= red_next;
			blue_r <= blue_next;
			green_r <= green_next;
		end
	end
     end

     // state guards
     always @* begin
     	timer_start = 1'b0;
     	state_next = state_reg;
     	case (state_reg)
     		newgame: begin
     			//reset data here
     			if (pressed)
     				state_next = play;
		end
		play: begin
			game_start <= 1'b1;
			//movement here and raycaster //TODO
			if (game_done)
				state_next = over;
		end
		over: begin
			over_start <= 1'b1;
			if (over_done)
				state_next = newgame;
				//stop raycasting updates
		end
	endcase
    end

    //display of graphics and text
    always @* begin
    	if (~video_on) //black at edges
    		red_next = 4'b0000;
    		green_next = 4'b0000;
    		blue_next = 4'b0000;
    	else begin
    		// text display
		// in new state, want title and prompt on [2, 1]
		// in over state, want over on [3]
		// in play state, want score on [0]
    		if (state_reg == over && text_on[3] || state_reg == newgame && text_on[1] && text_on[2] || state_reg == play && text_on[0]))
    			red_next = text_red;
    			blue_next = text_blue;
    			green_next = text_green;
		else if (graph_on) //otherwise show raycast //TODO
			rgb_next = graph_rgb
		else  //otherwise screen is black
			red_next = 4'b0000;
			blue_next = 4'b0000;
			green_next = 4'b0000;
	end
	assign red = red_r;
	assign green = green_r;
	assign blue = blue_r;
endmodule

