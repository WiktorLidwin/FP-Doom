`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 03:49:45 PM
// Design Name: 
// Module Name: Raycaster
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


module Raycaster(input wire signed [5:0] xPos,
                  input wire signed [5:0] yPos,
                  input wire signed [5:0] angle,
                  input wire signed [9:0] x,
                  input wire signed [8:0] y,
                  output reg [959:0] red ,
                  output reg [959:0] blue ,
                  output reg [959:0] green );
  
  // Define constants
  parameter screenWidth = 640;
  parameter screenHeight = 480;
  parameter mapWidth = 6;
  parameter mapHeight = 6;
  parameter inf = 1000000000;
  parameter deltaX = 10000; // Scaling factor for x-coordinate
  parameter deltaY = 10000; // Scaling factor for y-coordinate
  parameter counter_max = 100; 
  
  // Declare internal variables
  reg signed [31:0] posX, posY, dirX, dirY, planeX, planeY;
  reg signed [31:0] mapX, mapY, sideDistX, sideDistY, deltaDistX, deltaDistY, perpWallDist;
  reg signed [31:0] stepX, stepY, hit, side, lineHeight, drawStart, drawEnd;
  reg signed [31:0] cameraX, rayDirX, rayDirY;
  reg signed [10:0] counter;
  
  reg [2:0] worldMap [0:mapHeight-1][0:mapWidth-1];
  reg [11:0] color;
  
   

  
  // Initial values
  initial begin
    posX = xPos*deltaX;
    posY = yPos * deltaY;
    dirX = -1* deltaX;
    dirY = 0 + angle;
    planeX = 0;
    planeY = (66 * deltaY )/ 100;
    hit = 0;
    side = 0;
    color = 0;
    
    // Initialize world map
      // Row 0
      worldMap[0][0] = 1;
      worldMap[0][1] = 2;
      worldMap[0][2] = 2;
      worldMap[0][3] = 2;
      worldMap[0][4] = 2;
      worldMap[0][5] = 1;
      // Row 1
      worldMap[1][0] = 1;
      worldMap[1][1] = 0;
      worldMap[1][2] = 0;
      worldMap[1][3] = 0;
      worldMap[1][4] = 0;
      worldMap[1][5] = 3;
      // Row 2
      worldMap[2][0] = 3;
      worldMap[2][1] = 0;
      worldMap[2][2] = 0;
      worldMap[2][3] = 0;
      worldMap[2][4] = 0;
      worldMap[2][5] = 3;
      // Row 3
      worldMap[3][0] = 2;
      worldMap[3][1] = 0;
      worldMap[3][2] = 0;
      worldMap[3][3] = 0;
      worldMap[3][4] = 0;
      worldMap[3][5] = 3;
      // Row 4
      worldMap[4][0] = 1;
      worldMap[4][1] = 0;
      worldMap[4][2] = 0;
      worldMap[4][3] = 0;
      worldMap[4][4] = 0;
      worldMap[4][5] = 3;
      // Row 5
      worldMap[5][0] = 1;
      worldMap[5][1] = 1;
      worldMap[5][2] = 1;
      worldMap[5][3] = 1;
      worldMap[5][4] = 1;
      worldMap[5][5] = 1;
    
    // ...
  end
  
  // Compute ray casting
  always @(*)
  begin
    // Calculate ray position and direction
    cameraX = ((2 * x * deltaX)/ screenWidth) - deltaX;
    rayDirX = dirX + ((planeX * cameraX) / deltaX);
    rayDirY = dirY + ((planeY * cameraX) / deltaX);
    
    // Determine map position
    mapX = xPos;
    mapY = yPos;
    
    deltaDistX = (rayDirX == 0) ? inf : ((deltaX * deltaX  )  / rayDirX);
    deltaDistY = (rayDirY == 0) ? inf : ((deltaY * deltaY  ) / rayDirY);
    
    if (deltaDistX < 0) begin
        deltaDistX = -deltaDistX;
      end
    if (deltaDistY < 0) begin
        deltaDistY = -deltaDistY;
      end
    // Compute side distance
    if (rayDirX < 0) begin
      stepX = -1;
      sideDistX = (posX - mapX * deltaX) * deltaDistX / deltaX;
    end
    else begin
      stepX = 1;
      sideDistX = ((mapX * deltaX + deltaX) - posX) * deltaDistX / deltaX;
    end
    
    if (rayDirY < 0) begin
      stepY = -1;
      sideDistY = (posY - mapY* deltaY) * deltaDistY / deltaY;
    end
    else begin
      stepY = 1;
      sideDistY = ((mapY* deltaY + deltaY) - posY) * deltaDistY / deltaY;
    end
    
    // Perform DDA
    hit = 0;
    counter = 0;
    while (hit == 0 && counter < counter_max) begin
       counter = counter + 1;
      if (sideDistX < sideDistY) begin
        sideDistX = sideDistX + deltaDistX;
        mapX = mapX + stepX;
        side = 0;
      end
      else begin
        sideDistY = sideDistY + deltaDistY;
        mapY = mapY + stepY;
        side = 1;
      end
      
      // Check if ray has hit a wall
      if (worldMap[mapY][mapX] > 0) hit = 1;
      else if(mapY < 0 || mapY > mapHeight || mapX < 0 || mapX > mapWidth) begin 
        hit = 1;
        mapY = 0;
        mapX = 0;
      end
    end
    
    if (side == 0) perpWallDist = sideDistX - deltaDistX;
    else perpWallDist = sideDistY - deltaDistY;
    
    // Compute height of line to draw on screen
    lineHeight = (screenHeight * deltaY)  / perpWallDist;
    if (lineHeight > deltaY)begin
        lineHeight = lineHeight / deltaY;
    end
    // Compute lowest and highest pixel to fill in current stripe
    drawStart = -lineHeight / 2 + screenHeight / 2;
    if (drawStart < 0) drawStart = 0;
    drawEnd = lineHeight / 2 + screenHeight / 2;
    if (drawEnd >= screenHeight) drawEnd = screenHeight - 1;
    
    // Choose wall color
    case (worldMap[mapY][mapX])
      1: color = 'hF00; // Red
      2: color = 'h0F0; // Green
      3: color = 'h00F; // Blue
      4: color = 'hFFF; // White
      default: color = 'hFF0; // Yellow
    endcase
    
    // Give x and y sides different brightness
    if (side == 1) color = color / 2;
//    if (screenHeight - drawStart >= y && screenHeight - drawEnd <= y )begin
//        color = color;
//    end else begin
//        color = 'h000;
//    end
    // Assign outputs
    //red = color[11:8];
    //blue = color[3:0];
    //green = color[7:4];
  end
  
  integer i;
  
  always @(color) begin
    // Initialize the entire 1D array
    
    for ( i = 0; i < 480; i = i + 1) begin
      if (i >= drawStart && i < drawEnd )begin 
      red[i*2 +: 1] = color[10+: 1];
      green[i*2 +: 1] = color[6+: 1];
      blue[i*2+: 1] = color[2+: 1];
      end
      else begin
      red[i*2 +:1] = 'b00; // Initialize to a default value (e.g., all zeros)
      blue[i*2 +: 1] = 'b00; // Initialize to a default value (e.g., all zeros)
      green[i*2 +: 1] = 'b00; // Initialize to a default value (e.g., all zeros)
      
      end
      
    end

    
  end
endmodule