`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023
// Design Name: 
// Module Name: game_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This attaches everything together.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module game_top(
    input  A, B, C;
    input wire clk, reset;
    output wire hsync, vsync;
    output RGB; //todo make this correct
    );

    localparam [1:0] state;

    //todo declare input variables for module instatiation
    //todo connect vga, connect raycaster, connect text, connect movement, connect input_drivers

    // todo game FSM:
    // if none 00, chill for a second, then go to start menu 01 . if button driver OR returns, move into playing game 11. if SOMETHING move to game over 10 for 2 seconds. then return to new game.
    // if reset ever pressed go to 00. 

    // todo STARTMENU:
    	// text, initialize ray caster

    // todo PLAYGAME:
    // initialize game timer, display game timer
    // movement and enemy spawning.
    // update raycaster from movement?

    //todo GAMEOVER:
    // end game timer
    // display game over and timer
    // stop ray casting updates, maybe make screen red?

    // todo DISPLAY:
    // depending on state, set text display. from ray caster and text, output RGB to VGA.

endmodule

