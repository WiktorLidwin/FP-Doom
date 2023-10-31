timescale 1ns / 1ps
///////////////////////
// Company: ec551
// Engineer: yt 
//
// Create Date: 10/28/2023
// Design Name: Display
// Module Name: textgen
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


// note, dependent on font rom
module textgen(
	input wire clk, video on,
	input wire [9:0] pixel_x, pixel_y,
	output reg [2:0] rgb_text
	);

	wire [10:0] rom_addr; //address on rom
	wire [6:0] char_addr; //ascii code of char
	wire [3:0] row_addr; //row number of font
	wire [2:0] bit_addr; //column number of font
	wire [7:0] font_word; //row of pixels of font
	wire font_bit, text_bit_on; // one pixel of word

	font_rom font_unit (
		.clk(clk),
		.addr(rom_addr),
		.date(font_word)
	);

	assign char_addr = {pixel_y[6:5], pixel_x[8:4]};
	assign row_addr = pixel_y[4:1];
	assign rom_addr = {char_addr, row_addr};
	assign bit_addr = pixel_x[3:1];
	assign font_bit = font_word[~bit_addr];
	assign text_bit_on = (pixel_x[9]==0 && pixel_y[9:7]==0 ? font_bit : 1'b0);

	always @*
		if (~video_on) begin
			rgb_text = 3'b010;
		end else begin
			if (text_bit_on) begin
				rgb_text = 3'b010;
			end else begin
				rgb_text = 3'b000;
			end
endmodule
