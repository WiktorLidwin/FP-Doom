`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2020 12:29:25 PM
// Design Name: 
// Module Name: top_square
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
//////////////////////////////////////////////////////////////////////////////
module top_square(
    input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire RST_BTN,      
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [3:0] VGA_R,    // 4-bit VGA red output
    output wire [3:0] VGA_G,    // 4-bit VGA green output
    output wire [3:0] VGA_B     // 4-bit VGA blue output
    );

    wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    

    // generate a 25 MHz pixel strobe
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y)
    );

    // Wires to hold regions on FPGA
	
    //Registers for entities
	reg [1:0] green,red, blue;
	
  reg [5:0] xPos = 3;
  reg [5:0] yPos = 3;
  reg [5:0] angle = 0;
  
  wire [ 959:0] redOutput ;
  wire [959:0] blueOutput ;
  wire [959:0] greenOutput ;
  
   assign VGA_R[2] = red[0];
   assign VGA_R[3] = red[1];
   
 assign VGA_G[2] = green[0];
 assign VGA_G[3] = green[1];
 
 
  assign VGA_B[2] = blue[0];
  
  assign VGA_B[3] = blue[1];
  
  reg [5:0] color_map[0:640][0:480];
  
  integer i;
  integer j;
  reg [9:0] i2;  // current pixel x position: 10-bit value: 0-1023
    reg [8:0] j2;  // current pixel y position:  9-bit value: 0-511
    reg [26:0] counter;  // 27-bit counter for dividing the clock

  initial begin 
  
  red = 0;
  green = 0;
  blue = 0;
  i2 = 0;
  j2 = 0;
  counter = 0;
  for ( i = 0; i < 640; i = i + 1) begin
    for ( j = 0; j < 480; j = j + 1) begin
            color_map[i][j] <= 'b0;
    //      red[i*4 +: 3] = 3'b000; // Initialize to a default value (e.g., all zeros)
    //      blue[i*4 +: 3] = 3'b000; // Initialize to a default value (e.g., all zeros)
    //      green[i*4 +: 3] = 3'b000; // Initialize to a default value (e.g., all zeros)
        end
        end
  end
  Raycaster ray(xPos,yPos, angle,i2,j2,redOutput, greenOutput,blueOutput );
  
  always @(posedge CLK) begin
      if (counter == 100000) begin  // 100,000,000 / 60 = 1,666,666.67
            
          
          for ( j = 0; j < 480; j = j + 1) begin
            color_map[i2][j] <= {redOutput[j*2 +: 1], greenOutput[j*2 +: 1], blueOutput[j*2 +: 1]};
    //      red[i*4 +: 3] = 3'b000; // Initialize to a default value (e.g., all zeros)
    //      blue[i*4 +: 3] = 3'b000; // Initialize to a default value (e.g., all zeros)
    //      green[i*4 +: 3] = 3'b000; // Initialize to a default value (e.g., all zeros)
        end
          counter = 0;
          i2 = i2 + 1;
          if (i2 == 640) begin
            i2 = 0;
          end
          j2 = 0;
    
      end else begin
        counter <= counter + 1;
      end
    end
  
//  initial begin
//        for (i = 0; i <= 640; i = i + 1) begin
//            for (j = 0; j <= 480; j = j + 1) begin
//                // Example: Set color values based on x and y (you can customize this)
//                i2 = i1;
//                color_map[i][j] = {redOutput[3], greenOutput[3], blueOutput[3]}; // Red and green based on x and y, no blue
//            end
//        end
//    end
  
  //Raycaster ray(xPos,yPos, angle,x,y,redOutput, greenOutput,blueOutput );
  assign SQ10 = ((x > 100) & (y > 60) &  (x < 181) & (y < 140)) ? 1 : 0; // Green Square
  assign SQ11 = ((x > 100) & (y > 200) & (x < 181) & (y < 280)) ? 1 : 0; // Green Square
always @ (x, y)
  begin 
	//At start of every input change reset the screen and grid. Check inputs and update grid accordingly
	
	//Green = 0 means that there will be no values of x/y on the VGA that will display green
    green = 0;
    
	//This statement makes it so that within SQ1, a 3x3 grid of squares appears, with the middle square blacked out
//    grid =  SQ1 - SQ2 - SQ3 - SQ4 - SQ5 - SQ6 - SQ7 - SQ8 - SQ9 - SQMid;
    red = 0;
    blue = 0;
    if(1)
        begin
			//Add SQ10 to the areas which will display strong green.
			//Note: This displays yellow on the display, as red+green = yellow.
//            green = green + color_map[x][y][2];
//            if(color_map[0][0][0] == 1) begin
//             green = green + SQ11;
//            end

            red = ((^color_map[x][y][4+: 1] === 1'bX || ^color_map[x][y][4+: 1] === 1'bZ)? 0 : color_map[x][y][4+: 1]);
            blue = ((^color_map[x][y][0+: 1] === 1'bX || ^color_map[x][y][0+: 1] === 1'bZ)? 0 : color_map[x][y][0+: 1]);
            green = ((^color_map[x][y][2+: 1] === 1'bX || ^color_map[x][y][2+: 1] === 1'bZ)? 0 : color_map[x][y][2+: 1]);
            
            
//            blue = blue + color_map[x][y][0];
//            {red, green, blue} = color_map[x][y];
//            green = green + SQ10; 
        end
    
  end
  
  
//      wire SQ1,SQ2,SQ3,SQ4,SQ5,SQ6,SQ7,SQ8,SQ9,SQ10,SQ11,SQ12,SQ13,SQ14,SQ15,SQ16,SQ17,SQMid,SQ10hit,SQ11hit,SQ12hit,SQ13hit,SQ14hit,SQ15hit,SQ16hit,SQ17hit;
	
//    //Registers for entities
//	reg green,grid;
	
//	// Creating Regions on the VGA Display represented as wires (640x480)
	
//	// SQ1 is a large Square, and SQ2-9, along with SQ Mid are areas within SQ1
//    assign SQ1 = ((x > 100) & (y > 60) & (x < 540) & (y < 420)) ? 1 : 0;
//    assign SQ2 = ((x > 180) & (y > 60) & (x < 280) & (y < 420)) ? 1 : 0; 
//    assign SQ3 = ((x > 360) & (y > 60) & (x < 460) & (y < 420)) ? 1 : 0; 
//    assign SQ4 = ((x > 100) & (y > 279) & (x < 181) & (y < 341)) ? 1 : 0; // Red Square
//    assign SQ5 = ((x > 100) & (y > 139) & (x < 181) & (y < 201)) ? 1 : 0; // Red Square
//    assign SQ6 = ((x > 279) & (y > 279) & (x < 361) & (y < 341)) ? 1 : 0; // Red Square
//    assign SQ7 = ((x > 279) & (y > 139) & (x < 361) & (y < 201)) ? 1 : 0; // Red Square
//    assign SQ8 = ((x > 459) & (y > 279) & (x < 540) & (y < 341)) ? 1 : 0; // Red Square
//    assign SQ9 = ((x > 459) & (y > 139) & (x < 540) & (y < 201)) ? 1 : 0; // Red Square
//    assign SQMid = ((x > 279) & (y > 200) & (x < 361) & (y < 280)) ? 1 : 0; // Center Square
    
//	// SQ10-17 are also areas within SQ1
//    assign SQ10 = ((x > 100) & (y > 60) &  (x < 181) & (y < 140)) ? 1 : 0; // Green Square
//    assign SQ11 = ((x > 100) & (y > 200) & (x < 181) & (y < 280)) ? 1 : 0; // Green Square
//    assign SQ12 = ((x > 100) & (y > 340) & (x < 181) & (y < 420)) ? 1 : 0; // Green Square
//    assign SQ13 = ((x > 279) & (y > 60 ) & (x < 361) & (y < 140)) ? 1 : 0; // Green Square
//    assign SQ14 = ((x > 279) & (y > 340) & (x < 361) & (y < 420)) ? 1 : 0; // Green Square
//    assign SQ15 = ((x > 459) & (y > 60 ) & (x < 540) & (y < 140)) ? 1 : 0; // Green Square
//    assign SQ16 = ((x > 459) & (y > 200) & (x < 540) & (y < 280)) ? 1 : 0; // Green Square
//    assign SQ17 = ((x > 459) & (y > 340) & (x < 540) & (y < 420)) ? 1 : 0; // Green Square
//    // SQ10hit-17hit are the same areas as SQ10-17
//    assign SQ10hit = ((x > 100) & (y > 60) &  (x < 181) & (y < 140)) ? 1 : 0; // Hit Square
//    assign SQ11hit = ((x > 100) & (y > 200) & (x < 181) & (y < 280)) ? 1 : 0; // Hit Square
//    assign SQ12hit = ((x > 100) & (y > 340) & (x < 181) & (y < 420)) ? 1 : 0; // Hit Square
//    assign SQ13hit = ((x > 279) & (y > 60 ) & (x < 361) & (y < 140)) ? 1 : 0; // Hit Square
//    assign SQ14hit = ((x > 279) & (y > 340) & (x < 361) & (y < 420)) ? 1 : 0; // Hit Square
//    assign SQ15hit = ((x > 459) & (y > 60 ) & (x < 540) & (y < 140)) ? 1 : 0; // Hit Square
//    assign SQ16hit = ((x > 459) & (y > 200) & (x < 540) & (y < 280)) ? 1 : 0; // Hit Square
//    assign SQ17hit = ((x > 459) & (y > 340) & (x < 540) & (y < 420)) ? 1 : 0; // Hit Square


//    wire [7:0] random_num;
    
// // Assign the registers to the VGA 3rd output. This will display strong red on the Screen when 
// // grid = 1, and strong green on the screen when green = 1;
// assign VGA_R[3] = grid;
// assign VGA_G[3] = green;
  
//  always @ (*)
//  begin 
//	//At start of every input change reset the screen and grid. Check inputs and update grid accordingly
	
//	//Green = 0 means that there will be no values of x/y on the VGA that will display green
//    green = 0;
//	//This statement makes it so that within SQ1, a 3x3 grid of squares appears, with the middle square blacked out
////    grid =  SQ1 - SQ2 - SQ3 - SQ4 - SQ5 - SQ6 - SQ7 - SQ8 - SQ9 - SQMid;
//    grid = 0;
//    if(1)
//        begin
//			//Add SQ10 to the areas which will display strong green.
//			//Note: This displays yellow on the display, as red+green = yellow.
//            green = green + SQ10; 
//            grid = grid + 1;
//        end
    
//  end
    
endmodule
