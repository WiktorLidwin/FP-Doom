`timescale 1ns / 1ps
///////////////////////
// Company: ec551
// Engineer: yt
//
// Create Date: 10/28/2023
// Design Name: Graphics
// Module Name: display
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


// output pixel positions and the pixel clock, use pixel generation to make RGB.

// hsync and vsync act as pixel counters, even in unvisible margin
// video_on tracks if pixel location is visible on screen

// 640 x 480
module display(
	input wire clk, reset,
	output wire hsync, vsync, video_on, p_tick, 
	output wire [9:0] pixel_x, pixel_y 
	);

	// VGA 640 x 480
	localparam HD = 640; //visible display horizontal count
	localparam HF = 48; // left border
	localparam HB = 16; // right border
	localparam HR = 96; // horizontal retrace
	localparam VD = 480; // vertical count
	localparam VF = 101; // top border
	localparam VB = 33; // bottom border
	localparam VR = 2; // retrace

	//mod2 counter, 50 to 25
	reg mod2_reg;
	wire mod2_next;
	// sync counters
	reg [9:0] h_count_reg, h_count_next;
	reg [9:0] v_count_reg, v_count_next;
	// output buffer, delays by 1 tick
	reg v_sync_reg, h_sync_reg;
	wire v_sync_next, h_sync_next;
	// status signal
	wire h_end, v_end, pixel_tick;

	//registers
	always @(posedge clk, posedge reset)
		if(reset)
			begin
				mod2_reg <= 1'b0;
				v_count_reg <= 0;
				h_count_reg <= 0;
				v_sync_reg <=1'b0;
				h_sync_reg <=1'b0;
			end
		else
			begin
				mod2_reg <= mod2_next;
				v_count_reg <= v_count_next;
				h_count_reg <= h_count_next;
				v_sync_reg <= v_sync_next;
				h_sync_reg <= h_sync_next;
			end

	//25Mhz pixel clock using mod2 counter
	assign mod2_next = ~mod2_reg;
	assign pixel_tick = mod2_reg;

	//status signals: end of row/column
	assign h_end = (h_count_reg == (HD + HF + HB + HR -1));
	assign v_end = (v_count_reg == (VD + VF + VB + VR -1));

	//next state logic for vertical sync
	always @*
		if (pixel_tick) begin
			if (v_end) begin
				v_count_next = 0;
			end else begin
				v_count_next = v_count_reg +1;
			end
		end else begin
			v_count_next = v_count_reg;
		end
	// next state logic for horizontal sync
	always @*
		if (pixel_tick & h_end)
			if (v_end)
				v_count_next = 0;
			else
				v_count_next = v_count_reg +1;
		else
			v_count_next = v_count_reg;

	// horizontal and verical sync buufer
	assign h_sync_next = (h_count_reg>=(HD+HB)&&h_count_reg <= (HD+HB+HR-1));
	assign v_sync_next = (v_count_reg>=(VD+VB)&&v_count_reg <= (VD+VB+VR-1));

	//video, if displayable
	assign video_on = (h_count_reg<HD)&&(v_count_reg<VD);

	//output
	assign hsync = h_sync_reg;
	assign vsync = v_sync_reg;
	assign pixel_x = h_count_reg;
	assign pixel_y = v_count_reg;
	assign p_tick = pixel_tick;
endmodule
