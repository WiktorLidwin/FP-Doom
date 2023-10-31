timescale 1ns / 1ps
///////////////////////
// Company: ec551
// Engineer: yt 
//
// Create Date: 10/28/2023
// Design Name: Graphics
// Module Name: textdisplay
// Project Name: FPGA -Doom
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////

module textdisplay(
	input wire clk, reset,
	output wire hsync, vsync,
	output wire [2:0] rgb
	);

	wire [9:0] pixel_x, pixel_y;
	wire video_on, pixel_tick;
	reg [2:0] rgb_reg;
	wire [2:0] rgb_next;

	display vga_display(
		.clk(clk),
		.reset(reset),
		.hsync(hsync),
		.vsync(vsync),
		.video_on(video_on),
		.p_tick(pixel_tick),
		.pixel_y(pixel_y),
		.rgb_text(rgb_next)
	);

	gametext text_out(
		.clk(clk),
		.video_on(video_on),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y),
		.rgb_text(rgb_next)
	);

	always @(posedge clk)
		if(pixel_tick) begin
			rgb_reg <= rgb_next;
		end
		
	assign rgb=rgb_reg;
endmodule
