timescale 1ns / 1ps
///////////////////////
// Company: ec551
// Engineer: yt 
//
// Create Date: 10/28/2023
// Design Name: Display
// Module Name: displaytest
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

// currently testing display module, need to expand to test framebuffer

module displaytest(
	input wire video_on,
	input wire [9:0] pix_x, pix_y,
	output reg [2:0] graph_rgb
	);

	localparam max_x = 640;
	localparam max_y = 480;

	// todo, turh r g b to graph rgb

	logic [3:0] r, g, b;
	always @*
		if (~video_on) begin
			graph_rgb = 3'b000;
		end else begin
			if (pix_x  < 256 && pix_y < 256)
				r = pix_x[7:4];
				g = pix_y[7:4];
				b = 4'h4;
			end else begin
				r = 4'h0;
				g= 4'h1;
				b=4'h3;
			end
		end
endmodule
