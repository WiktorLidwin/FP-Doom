timescale 1ns / 1ps
///////////////////////
// Company: ec551
// Engineer: yt 
//
// Create Date: 10/28/2023
// Design Name: Game
// Module Name: menucontrol
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
module startmenu_text(
	input wire clk,
	input wire [9:0] pix_x, pix_y,
	input wire [3:0] timerdig2, timerdig2, timerdig0; //change when game logic
	output wire [3:0] text_on,
	output reg [2:0] text_rgb
	);

	wire [10:0] rom_addr
	// *_t controls title
	// *_pr controls prompt
	// *_s controls score text
	reg [6:0] char_addr, char_addr_t, char_addr_pr, char_addr_s;
	reg [3:0] row_addr;
	wire [3:0] row_addr_t, row_addr_pr, row_addr_s;
	reg [2:0] bit_addr;
	wire [2:0] bit_addr_t, bit_addr_pr, bit_addr_s;
	wire[7:0] font_word;
	wire font_bit, title_on, prompt_on, score_on;

	font_rom font_unit(
		.clk(clk),
		.addr(rom_addr),
		.data(font_word)
	);

	// score region
	// 16x32 font, display timer of 3:00 in 1 line
	assign score_on = (pix_y[9:5]==0) && (pix_x[9:4]<16);
	assign row_addr_s = pix_y[4:1];
	assign bit_addr_s = pix_x[3:1];
	always @* 
		case (pix_x[7:4])
			//todo make this the timer
			4'h0: char_addr_s = {3'b011,timerdig2}; // X:00
			4'h1: char_addr_s = 7'h3a; // :
			4'h2: char_addr_s = {3'b011, timerdig1}; //second 0:X0
			4'h3: char_addr_s = {3'b011, timerdig0}; //second 0:0X
			default : char_addr_l = 7'h3a; //fix?
		endcase
	// title region
	// 64 x 128 font
	assign title_on = (pix_y [9:7] == 2) && (3 <= pix_x [9:6]) && (pix_x[9:6]) <= 6);
	assign row_addr_t = pix_y [6:3];
	assign bit_addr_t = pix_x [5:3];
	always @*
		case(pix_x[8:6])
			3'o3: char_addr_t = 7'h55; // T
			3'o4: char_addr_t = 7'h49; // I
			3'o5: char_addr_t = 7'h55 // T
			3'o6: char_addr_t = 7'h4c // L
			default: char_addr_l =  7'h45 // E
	//prompt region
	// noraml font, one line
	assign prompt_on = ()
	assign row_addr_t =
	assign bit_addr_t =
	always @*
		case()

endmodule
