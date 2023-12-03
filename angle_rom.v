`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 05:17:38 PM
// Design Name: 
// Module Name: angle_rom
// Project Name: 
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
//////////////////////////////////////////////////////////////////////////////////


module angle_rom (
    input clk,
    input [6:0] addr,
    output [79:0] angle // dirX, dirY, planeX, planeY Q8.8, invDet Q8.8
    );

reg [79:0] angles [125:0];

reg [79:0] a_d, a_q;

assign angle = a_q;

initial begin
`include "angle.rom"
end

always @(*) begin
    if (addr < 7'd126)
        a_d = angles[addr];
    else
        a_d = 80'd0;
end

always @(posedge clk) begin
    a_q <= a_d;
end

endmodule
