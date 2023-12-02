`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023
// Design Name: 
// Module Name: movement
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: From button presses, outputs whether to move forward or rotate
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//  TODO: make it so that output is directly pixels for the ray caster. 
//////////////////////////////////////////////////////////////////////////////////

module movement(
    input wire forward_press, rotateCCW90_press, rotateCW90_press;
    output wire [1:0] rotation;
    output wire move;
    );

    initial:
    	move = 1'b0
    	rotation = 2'b00

    always @* begin
	if (forward_press == 1'b1) begin
		move = 1'b1;
		rotation = 2'b00;
	end
	else if (rotateCCW90_press == 1'b1) begin
		move = 1'b0;
		rotation = 2'b10;
	end
	else if (rotateCW90_press == 1'b1) begin
		move = 1'b0;
		rotation = 2'b01;
	end
	else
		move = 1'b0;
		rotation = 2'b00;
	end
endmodule

