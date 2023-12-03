`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 04:21:35 PM
// Design Name: 
// Module Name: camerax_rom
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


module camerax_rom (
    input clk,
    input [8:0] addr,
    output [15:0] camerax // Q8.8
    );

reg [15:0] camerax_pos [319:0];

reg [15:0] cx_d, cx_q;

assign camerax = cx_q;

initial begin
`include "camerax.rom"
end

always @(*) begin
    if (addr < 9'd320)
        cx_d = camerax_pos[addr];
    else
        cx_d = 16'd0;
end

always @(posedge clk) begin
    cx_q <= cx_d;
end

endmodule