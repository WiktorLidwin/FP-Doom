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
        input  [7:0] swt,
        output wire [12:0] led,  
        output wire VGA_HS_O,       // horizontal sync output
        output wire VGA_VS_O,       // vertical sync output
        output wire [3:0] VGA_R,    // 4-bit VGA red output
        output wire [3:0] VGA_G,    // 4-bit VGA green output
        output wire [3:0] VGA_B     // 4-bit VGA blue output
    );
    wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    
    localparam WIDTH = 320;
    localparam HEIGHT = 240;
    
//    reg [7:0] counter;
//    reg clk;
    
//      always @(posedge CLK) begin
//        counter <= counter + 1;
//        if (counter == 10) // Divide input clock frequency by 8
//          clk <= ~clk;
//      end
   reg [31:0] counter; // 27-bit counter to divide 100MHz to 30Hz
    reg clk_30Hz;
  always @(posedge CLK) begin
    if (counter == 32'd8888880) begin // Adjust this value for more accurate division
      counter <= 0;
      clk_30Hz <= ~clk_30Hz;
    end else begin
      counter <= counter + 1;
    end
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
    
    reg [15:0] map_pos_x;
    reg [15:0] map_pos_y;
    
    
    
    
//    wire [8:0] camera_x;
    
    wire cast_busy;
    wire cast_done;
    
    
    reg [6:0] angle_addr;
        
    reg start;
    initial begin
        angle_addr = 7'd0;
        start = 1;
    end
    always @(posedge clk_30Hz) begin
//        angle_addr <= angle_addr + 1'b1;
        if(swt[0] == 1)begin 
            angle_addr = angle_addr + 1'b1;
        end
        if(swt[1] == 1)begin 
            angle_addr = angle_addr - 1'b1;
        end
        if(swt[2] == 1)begin 
            map_pos_x = map_pos_x + 4'd8;
        end
        if(swt[3] == 1)begin 
            map_pos_x = map_pos_x - 4'd8;
        end
        if(swt[4] == 1)begin 
            map_pos_y = map_pos_y + 4'd8;
        end
        if(swt[5] == 1)begin 
            map_pos_y = map_pos_y - 4'd8;
        end
    end
        
    angle_rom angle_rom (
        .clk(CLK),
        .addr(angle_addr),
        .angle(angle) // 4x Q8.8: dirX, dirY, planeX, planeY
    );
    
    reg [4:0] state_d, state_q;
    
    reg [19:0] frame_buffer [WIDTH-1:0]; // 4 bit color, 8 bit height
    
    
    
    
    
    wire [7:0] line_height;
    wire [3:0] line_color;
    
    reg [15:0] map_pos_x_d, map_pos_x_q;
    reg [15:0] map_pos_y_d, map_pos_y_q;
    reg [6:0] turn_addr_d, turn_addr_q; // angle lookup table index
    reg [8:0] camera_x_d, camera_x_q;
    
    
    
    RayCaster2 RayCaster2(
        .clk(CLK),
        .rst(rst),
        .x(camera_x_q),
        .angle(angle),
        .map_pos_x(map_pos_x),
        .map_pos_y(map_pos_y),
        .start(start),
        .busy(cast_busy),
        .done(cast_done),
        .line_height(line_height),
        .line_color(line_color)
    );
    reg [11:0] counter2;
    reg [12:0] counter3;
    reg clk_flag;
    initial begin
        camera_x_d = 9'd099;
        counter3 = 0;
        camera_x_q = 9'd100;
        counter2 = 0;
        clk_flag =0;
         map_pos_x = 16'b00000011_00000000;
        map_pos_y = 16'b00000011_00000000;
    end
    wire casting_next;
    assign casting_next = 0;
    reg [7:0] counter5;
    assign led = counter3;
    
     reg [31:0] counter4; // 27-bit counter to divide 100MHz to 30Hz
    reg clk_1Hz;
    
  always @(posedge CLK) begin
    if (counter4 >= 32'd100000000) begin // Adjust this value for more accurate division
      counter4 <= 0;
      clk_1Hz <= ~clk_1Hz;
    end else begin
      counter4 <= counter4 + 1;
    end
  end
  always @( clk_1Hz) begin
    if(clk_1Hz)begin
        counter5 = counter3[7:0];
        clk_flag <= 1;
    end else begin
        clk_flag = 0;
    end
    
  end
//    wire [9:0] camera_x_wire;
//    assign camera_x_wire = camera_x_q;
    always @(posedge CLK) begin
    
        
        if (((!cast_busy) | cast_done) ) begin
            if ((camera_x_d == camera_x_q)) begin 
            
            frame_buffer[camera_x_q][3:0] = line_color;
            frame_buffer[camera_x_q][11:4] = (HEIGHT - line_height) >> 1;
            frame_buffer[camera_x_q][19:12] = line_height + ((HEIGHT - line_height) >> 1);
            
            
        
                  if (camera_x_q >= (WIDTH - 1)) begin
                        camera_x_q <= 9'b0;
                        counter3 = counter3 + 1;
                    end else begin
                        camera_x_q <= camera_x_q + 1'b1;
                     end  
             
             if (counter2 > 320)begin
                counter2 = 0;
                
             end else begin
                counter2 = counter2 + 1;
             end
             if(clk_flag) begin
                counter3 = 1;
             end
            end
            
             
             
//             start = 1;
        end else begin
            camera_x_d <= camera_x_q;
        end
        
//        else begin
//            start = 0;
//        end
        
    end
//    always @(posedge CLK) begin
//        if (rst) begin
//            state_q = 0;
//            map_pos_x_q <= 0;
//            map_pos_y_q <= 0;
//            camera_x_q <= 0;
//          end else begin
//            state_q = state_d;
//            map_pos_x_q <= map_pos_x_d;
//            map_pos_y_q <= map_pos_y_d;
//            camera_x_q <= camera_x_d;
//          end
//    end
    
    reg red, green,blue;
    
     assign VGA_R[3] = red;
       
     assign VGA_G[3] = green;
     
     
      assign VGA_B[3] = blue;
    reg current_line_height;
    always @ (x, y)
      begin 
       
     green = 0;
        
                red = 0;
                blue = 0;

         if((x < WIDTH) & (y < HEIGHT))
            begin

                
                 if ((frame_buffer[x][11:4] < y) & (y <frame_buffer[x][19:12] ) )begin
                    case(frame_buffer[x][3:0])
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
                        red = 1;
                        blue = 1;
                        end
                     endcase
                end

            end
            else begin
               
            end
        
      end
endmodule
