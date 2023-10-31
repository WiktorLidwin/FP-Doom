timescale 1ns / 1ps
///////////////////////
// Company: ec551
// Engineer: yt 
//
// Create Date: 10/28/2023
// Design Name: Graphics
// Module Name: gametext
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
module gametext(
	input wire clk,
	input wire [9:0] pix_x, pix_y,
	input wire [3:0] timerdig2, timerdig2, timerdig0; //change when game logic
	output wire [3:0] text_on,
	output reg [2:0] text_rgb
	);

	wire [10:0] rom_addr;
	// *_t controls title
	// *_pr controls prompt
	// *_s controls score text
	// *_o controls game over text
	reg [6:0] char_addr, char_addr_t, char_addr_pr, char_addr_s, char_addr_o;
	reg [3:0] row_addr;
	wire [3:0] row_addr_t, row_addr_pr, row_addr_s, row_addr_o;
	reg [2:0] bit_addr;
	wire [2:0] bit_addr_t, bit_addr_pr, bit_addr_s, row_addr_o;
	wire[7:0] font_word;
	wire font_bit, title_on, prompt_on, score_on, over_on;

	font_rom font_unit(
		.clk(clk),
		.addr(rom_addr),
		.data(font_word)
	);

	// score region
	// display timer of 3:00 in 1 line on top left
	assign score_on = (pix_y[9:5]==0) && (pix_x[9:4]<16);
	// 16 x 32 font
	assign row_addr_s = pix_y[4:1];
	assign bit_addr_s = pix_x[3:1];
	always @* begin
		case (pix_x[7:4])
			//todo make this the timer
			4'h0: char_addr_s = {3'b011,timerdig2}; // X:00
			4'h1: char_addr_s = 7'h3a; // :
			4'h2: char_addr_s = {3'b011, timerdig1}; //second 0:X0
			4'h3: char_addr_s = {3'b011, timerdig0}; //second 0:0X
			default : char_addr_l = 7'h00; 
		endcase
	end
	
	// title region
	// top center
	assign title_on = (pix_y [9:7] == 2) && (3 <= pix_x [9:6]) && (pix_x[9:6]) <= 6);
	// 64 x 128 font
	assign row_addr_t = pix_y [6:3];
	assign bit_addr_t = pix_x [5:3];
	always @* begin
		case(pix_x[8:6])
			3'o3: char_addr_t = 7'h55; // T
			3'o4: char_addr_t = 7'h49; // I
			3'o5: char_addr_t = 7'h55 // T
			3'o6: char_addr_t = 7'h4c // L
			3'o7: char_addr_t = 7'h45 //E
			default: char_addr_l =  7'h00 //
		endcase
	end

	// prompt region
	// Press to start.
	// one line below title
	assign prompt_on = (pix_x[9:7] == 2) && ( pix_y [9:6] == 7);
	// 16 x 32 font
	assign row_addr_t = pix_y[4:1];
	assign bit_addr_t = pix_x[3:1];
	assign prompt_rom_addr = {pix_y[5:4], pix_x[6:3]};
	always @* begin
		case(prompt_rom_addr) // this controls where text goes, need to fix
			6'h00: char_addr_r = 7'h50; //P
			6'h01: char_addr_r = 7'h72; //r
			6'h02: char_addr_r = 7'h65; //e
			6'h03: char_addr_r = 7'h73; //s
			6'h04: char_addr_r = 7'h73; //s
			6'h05: char_addr_r = 7'h00; //
			6'h06: char_addr_r = 7'h74; //t
			6'h07: char_addr_r = 7'h6f; //o
			6'h08: char_addr_r = 7'h00; //
			6'h09: char_addr_r = 7'h73; //s
			6'h0a: char_addr_r = 7'h74; //t
			6'h0b: char_addr_r = 7'h61; //a
			6'h0c: char_addr_r = 7'h72; //r
			6'h0d: char_addr_r = 7'h74; //t
			6'h0e: char_addr_r = 7'h2e; //.
			default : char_addr_r = 7'h00;
		endcase
	end

	// gameover region
	// center
	assign over_on = (pix_y [9:6] == 3) && (5 <= pix_x[9:5]) && (pix_x[9:5] <= 13)
	//32 x 64
	assign row_addr_o = pix_y[5:2];
	assign bit_addr_o = pix_x[4:2];
	always @* begin
		case(pix_x[8:5])
			4'h5: char_addr_o = 7'h47; //G
			4'h6: char_addr_o = 7'h61; //a
			4'h7: char_addr_o = 7'h6d; //m
			4'h8: char_addr_o = 7'h65; //e
			4'h9: char_addr_o = 7'h00; // 
			4'ha: char_addr_o = 7'h4f; //O
			4'hb: char_addr_o = 7'h76; //v
			4'hc: char_addr_o = 7'h65; //e
			4'hd: char_addr_o = 7'h72; //r
			default: char_addr_o = 7'h00;
		endcase
	end

	//mux logic
	always @* begin
		text_rgb 3'b111;
		if (title_on) begin
			char_addr = char_addr_t;
			row_addr = row_addr_t;
			bit_addr = bit_addr_t;
			if (font_bit) begin
				text_rgb = 3'b000;
			end
		end else if (prompt_on) begin
			char_addr = char_addr_pr;
			row_addr = row_addr_pr;
			bit_addr = bit_addr_pr;
			if(font_bit) begin
				text_rgb = 3'b000;
			end
		end else if (score_on) begin
			char_addr = char_addr_s;
			row_addr = row_addr_s;
			bit_addr = bit_addr_s;
			if(font_bit) begin
				text_rgb = 3'b000;
			end
		end else begin //gameover
			char_addr = char_addr_o;
			row_addr = row_addr_o;
			bit_addr = bit_addr_o;
			if (font_bit) begin
				text_rgb = 3'b000;
			end
		end
	end
	assign text_on = {score_on, title_on, prompt_on, over_on}
	assign rom_addr = {char_addr, row_addr};
	assign font_bit = font_word[~bit_addr];

endmodule
