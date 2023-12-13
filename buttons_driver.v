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
    output reg rotateCCW, //A
    output reg forward, //B
    output reg rotateCW, //C
    output reg pressed
    );

    always @* begin
      //check if only one
      case({A, B, C})
      	3'b000: begin
      		//none
      		rotateCCW = 1'b0;
		forward = 1'b0;
		rotateCW = 1'b0;
		pressed = 1'b0;
	end
        3'b001: begin
        	rotateCCW = 1'b0; // C
        	forward = 1'b0;
        	rotateCW = 1'b1;
        	pressed = 1'b1;
	end
        3'b010: begin
        	rotateCCW = 1'b0;
        	forward = 1'b1; // B
        	rotateCW = 1'b0;
        	pressed = 1'b1;
        end
        3'b100: begin
        	rotateCCW = 1'b1; //A
        	forward = 1'b0;
        	rotateCW = 1'b0;
        	pressed = 1'b1;
        end
        default: begin
        	//multiple pressed
        	rotateCCW = 1'b0;
        	forward = 1'b0;
        	rotateCW = 1'b0;
        	pressed = 1'b1;
        end
      endcase
  end

endmodule

