`timescale 1ns / 1ps
///////////////////////
// Revision 0.01 - File Created
// Additional Comments: 
//
////////////////////////

module textdisplay(
	input wire clk, reset,
	output wire [3:0] red, 
	output wire [3:0] green, 
	output wire [3:0] blue,
	output wire hsync, vsync,
	output wire p_tick
	);

	//acts like top but it isnt really


	wire [3:0] text_red, text_blue, text_green;
	reg [3:0] red_r, blue_r, green_r;
	wire video_on;
	wire [9:0] pixel_x, pixel_y;
	wire [2:0] timer; //todo fix
	wire [3:0] text_on;
	
	//timer = 
	
	display display(
		.clk(clk),
		.reset(reset),
		.hsync(hsync),
		.vsync(vsync),
		.video_on(video_on),
		.p_tick(p_tick),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y)
	);

	gametext gametext(
		.clk(clk),
		.reset(reset),
		.pix_x(pixel_x),
		.pix_y(pixel_y),
	//	.timer(timer),
		.text_on(text_on),
		.text_red(text_red),
		.text_blue(text_blue),
		.text_green(text_green)
	);

	always @*
		if (~video_on) begin //if looking onscreen
			red_r = 4'b0000;
			green_r = 4'b0000;
			blue_r = 4'b0000;
		end else begin
			//if (text_on[3])

			if (text_on[0] || text_on[1] || text_on[2] || text_on[3]) begin
				red_r = text_red;
				green_r = text_green;
				blue_r = text_blue;
			end else begin
				red_r = 4'b0000;
				green_r = 4'b0000;
				blue_r = 4'b0000;
			end
		end
	//end

	assign red = red_r;
	assign green = green_r;
	assign blue = blue_r;
endmodule
