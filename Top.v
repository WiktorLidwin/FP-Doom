`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 02:58:02 PM
// Design Name: 
// Module Name: Top
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


module Top(
        input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
        input wire RST_BTN,      
        output wire VGA_HS_O,       // horizontal sync output
        output wire VGA_VS_O,       // vertical sync output
        output wire [3:0] VGA_R,    // 4-bit VGA red output
        output wire [3:0] VGA_G,    // 4-bit VGA green output
        output wire [3:0] VGA_B     // 4-bit VGA blue output
    );
    wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    
    localparam WIDTH = 320;
    localparam HEIGHT = 240;
    
    reg [7:0] counter;
    reg clk;
    
      always @(posedge CLK) begin
        counter <= counter + 1;
        if (counter == 100) // Divide input clock frequency by 8
          clk <= ~clk;
      end
    

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
    
    
    
    
    
    
    wire [79:0] angle;
    
    wire [15:0] map_pos_x;
    wire [15:0] map_pos_y;
    
    assign map_pos_x = 16'b00000011_00000000;
    assign map_pos_y = 16'b00000011_00000000;
    
    
//    wire [8:0] camera_x;
    
    wire cast_busy;
    wire cast_done;
    
    
    reg [6:0] angle_addr;
    
    initial begin
        angle_addr = 7'd0;
        
    end
    
    angle_rom angle_rom (
        .clk(CLK),
        .addr(angle_addr),
        .angle(angle) // 4x Q8.8: dirX, dirY, planeX, planeY
    );
    
    reg [4:0] state_d, state_q;
    
    reg [11:0] frame_buffer [WIDTH-1:0]; // 4 bit color, 8 bit height
    
    wire start;
    assign start = 1;
    
    
    reg [7:0] line_height;
    reg [3:0] line_color;
    
    reg [15:0] map_pos_x_d, map_pos_x_q;
    reg [15:0] map_pos_y_d, map_pos_y_q;
    reg [6:0] turn_addr_d, turn_addr_q; // angle lookup table index
    reg [8:0] camera_x_d, camera_x_q;
    
    initial begin
        camera_x_d = 9'd0;
        
        camera_x_q = 9'd0;
        
    end
    
    RayCaster2 RayCaster2(
        .clk(CLK),
        .rst(rst),
        .x(camera_x_d),
        .angle(angle),
        .map_pos_x(map_pos_x),
        .map_pos_y(map_pos_y),
        .start(start),
        .busy(cast_busy),
        .done(cast_done),
        .line_height(line_height),
        .line_color(line_color)
    );
    
    
    always @(*) begin
        state_d = state_q;
        if (!cast_busy) begin
        
            frame_buffer[camera_x_q] = { line_color,line_height};
            
            if (camera_x_q == WIDTH - 1) begin
                camera_x_d = 9'b0;
            end else begin
                camera_x_d = camera_x_q + 1'b1;
             end
        end
        
    end
    always @(posedge clk) begin
        if (rst) begin
            state_q = 0;
            map_pos_x_q <= 0;
            map_pos_y_q <= 0;
            camera_x_q <= 0;
          end else begin
            state_q = state_d;
            map_pos_x_q <= map_pos_x_d;
            map_pos_y_q <= map_pos_y_d;
            camera_x_q <= camera_x_d;
          end
    end
    
    reg red, green,blue;
    
     assign VGA_R[3] = red;
       
     assign VGA_G[3] = green;
     
     
      assign VGA_B[3] = blue;
    reg current_line_height;
    always @ (x, y)
      begin 
        //At start of every input change reset the screen and grid. Check inputs and update grid accordingly
        
        //Green = 0 means that there will be no values of x/y on the VGA that will display green
        green = 0;
        
        //This statement makes it so that within SQ1, a 3x3 grid of squares appears, with the middle square blacked out
    //    grid =  SQ1 - SQ2 - SQ3 - SQ4 - SQ5 - SQ6 - SQ7 - SQ8 - SQ9 - SQMid;
        red = 0;
        blue = 0;
        if(x < WIDTH && y < HEIGHT)
            begin
                //Add SQ10 to the areas which will display strong green.
                //Note: This displays yellow on the display, as red+green = yellow.
    //            green = green + color_map[x][y][2];
    //            if(color_map[0][0][0] == 1) begin
    //             green = green + SQ11;
    //            end
    
                current_line_height = (HEIGHT - frame_buffer[x][0:7]) >> 1;
                
                if (current_line_height < y < (HEIGHT - current_line_height) )begin
                    case(frame_buffer[x][8:11])
                        4'b0001:begin
                            red = 1;
                        end
                        4'b0010:begin
                            green = 1;
                        end
                        4'b0100:begin
                            blue = 1;
                        end
                        default: begin
                        
                        end
                     endcase
                end
    
//                red = ((^color_map[x][y][4+: 1] === 1'bX || ^color_map[x][y][4+: 1] === 1'bZ)? 0 : color_map[x][y][4+: 1]);
//                blue = ((^color_map[x][y][0+: 1] === 1'bX || ^color_map[x][y][0+: 1] === 1'bZ)? 0 : color_map[x][y][0+: 1]);
//                green = ((^color_map[x][y][2+: 1] === 1'bX || ^color_map[x][y][2+: 1] === 1'bZ)? 0 : color_map[x][y][2+: 1]);
                
                
    //            blue = blue + color_map[x][y][0];
    //            {red, green, blue} = color_map[x][y];
    //            green = green + SQ10; 
            end
        
      end
endmodule
