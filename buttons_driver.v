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
    input A, B, C;
    output wire [1:0] rotateN90_press; //A
    output wire [1:0] forward_press; //B
    output wire [1:0] rotate90_press; //C
    );

    always @* begin
      //check if only one
      case({A, B, C})
        3'b001: rotateN90_press = 1'b1; // A
        3'b010: forward_press = 1'b1; // B
        3'b100: rotate90_press = 1'b1; // C
        default: begin
        	//reset if none or multiple pressed
        	rotateN90_press = 1'b0;
        	forward_press = 1'b0;
        	rotate90_press = 1'b0;
    endcase
  end

endmodule

