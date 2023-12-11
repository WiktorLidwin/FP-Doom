`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023
// Design Name: 
// Module Name: buttons_driver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: takes in the button inputs and outputs a wire, restricts so that only one can be pressed and can't be held 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module buttons_driver(
    input A, B, C, 
    output reg rotateN90_press, //A
    output reg forward_press, //B
    output reg rotate90_press, //C
    output reg pressed
    );

    always @* begin
      //check if only one
      case({A, B, C})
      	3'b000: begin
      		//none
      		rotateN90_press = 1'b0;
		forward_press = 1'b0;
		rotate90_press = 1'b0;
		pressed = 1'b0;
	end
        3'b001: begin
        	rotateN90_press = 1'b0; // C
        	forward_press = 1'b0;
        	rotate90_press = 1'b1;
        	pressed = 1'b1;
	end
        3'b010: begin
        	rotateN90_press = 1'b0;
        	forward_press = 1'b1; // B
        	rotate90_press = 1'b0;
        	pressed = 1'b1;
        end
        3'b100: begin
        	rotateN90_press = 1'b1; //A
        	forward_press = 1'b0;
        	rotate90_press = 1'b0;
        	pressed = 1'b1;
        end
        default: begin
        	//multiple pressed
        	rotateN90_press = 1'b0;
        	forward_press = 1'b0;
        	rotate90_press = 1'b0;
        	pressed = 1'b1;
        end
      endcase
  end

endmodule

