`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 04:10:46 PM
// Design Name: 
// Module Name: map_rom
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


module map_rom (
    input [7:0] x,
    input [7:0] y,
    output reg [3:0] point
    );

reg [3:0] map [5:0][5:0];

initial begin
`include "map.rom"
end

always @(*) begin
    if (x < 6 && y < 6)
        point = map[x][y];
    else
        point = 4'd1;
end

endmodule