`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 04:22:50 PM
// Design Name: 
// Module Name: height_rom
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


module height_rom (
    input clk,
    input [9:0] addr,
    output [39:0] height // 8bit height, Q8.8 texture scale, Q8.8 inverse distance
    );

reg [39:0] heights [1023:0];

reg [39:0] height_d, height_q;

assign height = height_q;

initial begin
`include "height.rom"
end

always @(*) begin
    if (addr < 16'd1023)
        height_d = heights[addr];
    else
        height_d = 40'd0;
end

always @(posedge clk) begin
    height_q <= height_d;
end

endmodule