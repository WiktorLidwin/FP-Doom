`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 02:20:09 PM
// Design Name: 
// Module Name: RayCaster2
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



module RayCaster2(
    input clk,
    input rst,
     
    input [8:0] x, // camera X position
    input [79:0] angle, // directional position

    input [15:0] map_pos_x,
    input [15:0] map_pos_y,

    input start,
    
    input shot,
    
    output reg busy,
    output reg done,

    // line writer wires.
    output [7:0] line_height,
    output [3:0] line_color
    );
    
    reg [7:0] map_rom_x, map_rom_y;
    
    reg [3:0] map [5:0][5:0];
    initial begin
        map[0][0] = 4'd 1;
        map[0][1] = 4'd 1;
        map[0][2] = 4'd 1;
        map[0][3] = 4'd 1;
        map[0][4] = 4'd 1;
        map[0][5] = 4'd 1;
        
        map[1][0] = 4'd 1;
        map[1][1] = 4'd 2;
        map[1][2] = 4'd 0;
        map[1][3] = 4'd 0;
        map[1][4] = 4'd 0;
        map[1][5] = 4'd 1;
        
        map[2][0] = 4'd 1;
        map[2][1] = 4'd 0;
        map[2][2] = 4'd 0;
        map[2][3] = 4'd 0;
        map[2][4] = 4'd 0;
        map[2][5] = 4'd 1;
        
        map[3][0] = 4'd 1;
        map[3][1] = 4'd 0;
        map[3][2] = 4'd 0;
        map[3][3] = 4'd 0;
        map[3][4] = 4'd 0;
        map[3][5] = 4'd 1;
        
        map[4][0] = 4'd 1;
        map[4][1] = 4'd 0;
        map[4][2] = 4'd 0;
        map[4][3] = 4'd 0;
        map[4][4] = 4'd 1;
        
        map[5][0] = 4'd 1;
        map[5][1] = 4'd 1;
        map[5][2] = 4'd 1;
        map[5][3] = 4'd 1;
        map[5][4] = 4'd 1;
        map[5][5] = 4'd 1;
    end
    
    reg [8:0] camerax_addr;
    wire [15:0] camerax; // Q2.14
    reg signed [15:0] camerax_d, camerax_q; // internal registers
    camerax_rom camerax_rom (
        .clk(clk),
        .addr(camerax_addr),
        .camerax(camerax)
    );
    
    
    
    reg signed [15:0] dirx_d, dirx_q;
    reg signed [15:0] diry_d, diry_q;
    reg signed [15:0] planex_d, planex_q;
    reg signed [15:0] planey_d, planey_q;
    
    // height ROM
    wire [9:0] height_addr;
    reg [39:0] line_height_d, line_height_q;
    wire [39:0] line_height_read;
    height_rom height_rom (
        .clk(clk),
        .addr(height_addr),
        .height(line_height_read)
    );
    
    // divider
    reg div_valid;
    wire div_out_valid, div_ready, dividen_ready;
    reg [23:0] dividend;
    reg [15:0] divisor;
    reg [15:0] divisor_hold;
    reg [15:0] divres_hold;
    wire [39:0] div_result;
    div_8_dot_8_nodsp div (
        .clk_100MHz(clk),
        .s_axis_divisor_tvalid(div_valid),
        .s_axis_dividend_tvalid(div_valid),
        
        .s_axis_dividend_tdata(dividend),
        .s_axis_divisor_tdata(divisor),
        .s_axis_divisor_tready(div_ready),
        
        .m_axis_dout_tvalid(div_out_valid),
        .m_axis_dout_tdata(div_result)
    );
    
    
    reg [2:0] cdelta_d, cdelta_q;
    
    
    
    
    reg signed [15:0] raydir_x_d, raydir_x_q;
    reg signed [15:0] raydir_y_d, raydir_y_q;
    reg [15:0] delta_dist_x_d, delta_dist_x_q;
    reg [15:0] delta_dist_y_d, delta_dist_y_q;
    reg signed [15:0] delta_dist_n_x_d, delta_dist_n_x_q;
    reg signed [15:0] delta_dist_n_y_d, delta_dist_n_y_q;
    reg [15:0] map_pos_x_d, map_pos_x_q;
    reg [15:0] map_pos_y_d, map_pos_y_q;
    
    reg [15:0] step_x_d, step_x_q;
    reg [15:0] step_y_d, step_y_q;
    reg [15:0] sidestep_x_d, sidestep_x_q;
    reg [15:0] sidestep_y_d, sidestep_y_q;
    
    reg [15:0] map_x_d, map_x_q, map_y_d, map_y_q;
    reg side_d, side_q;
    
    // 32bit to hold multiplication
    reg [15:0] side_dist_x_d, side_dist_x_q;
    reg [15:0] side_dist_y_d, side_dist_y_q;
    reg signed [15:0] p_wall_dist_d, p_wall_dist_q;
    
    
    // shared multiplier
    reg signed [15:0] mul_res_d, mul_res_q;
    reg signed [15:0] mul_arg1_d, mul_arg1_q;
    reg signed [15:0] mul_arg2_d, mul_arg2_q;
    
    
    //line colors
    reg [7:0] color_d, color_q;
    
    initial begin
        sidestep_x_q = 16'd0;
        sidestep_y_q = 16'd0;
        step_x_q = 8'd0;
        step_y_q = 8'd0;
    end
    
    
    assign line_height = line_height_q;
    assign line_color = color_q;
    assign line_pos_x = map_pos_x_q;
    assign line_pos_y = map_pos_y_q;
    
    
    assign height_addr[9:0] = p_wall_dist_q[12:3];
    assign wall_z = p_wall_dist_q;
    
    
    reg [4:0] state_d, state_q;
    reg [4:0] next_state_d, next_state_q;
    
    localparam IDLE = 0,
        START_CAST = 1,
        DDA_DIST_CALC = 2,
        DDA_FIND_HIT = 3,
        CALC_WALLDIST = 6,
        FIND_LINEHEIGHT = 8,
        DRAW_LINE_GO = 9,
        WAIT_LINE = 10,
        CALC_WALLDIST2 = 11,
        ROM_LOOKUP = 12,
        RAY_CALC = 13,
        DELTADIST_CALC = 14,
        DDA_DIST_CALCX_SETUP = 15,
        DDA_DIST_CALCY_SETUP = 16,
        DDA_DIST_CALC_FINAL = 17,
        WALL_TEX = 18,
        WALL_TEX2 = 19,
        WALL_TEX3 = 20,
        MULTIPLY = 21,
        RAY_CALC_ADDX = 22,
        RAY_CALC_ADDY = 23;
    
    
    
    initial begin
            busy = 1'b0;
            done = 1'b0;
    end
    
    
    reg [7:0] last_middle_x, last_middle_y;
    
    always @(shot)begin
        if(shot)begin
            if(map[last_middle_x][last_middle_y] == 2) begin
                map[last_middle_x][last_middle_y] = 4;
            end
        end
    end
    
    
    always @(*) begin
        state_d = state_q;
        delta_dist_x_d = delta_dist_x_q;
        delta_dist_y_d = delta_dist_y_q;
        delta_dist_n_x_d = delta_dist_n_x_q;
        delta_dist_n_y_d = delta_dist_n_y_q;
        sidestep_x_d = sidestep_x_q;
        sidestep_y_d = sidestep_y_q;
        step_x_d = step_x_q;
        step_y_d = step_y_q;
        side_dist_x_d = side_dist_x_q;
        side_dist_y_d = side_dist_y_q;
        map_x_d = map_x_q;
        map_y_d = map_y_q;
        map_pos_x_d = map_pos_x_q;
        map_pos_y_d = map_pos_y_q;
        map_rom_x = 0;
        map_rom_y = 0;
        side_d = side_q;
        p_wall_dist_d = p_wall_dist_q;
        // texture/line info
        
        
        color_d = color_q;
        line_height_d = line_height_q;
        
        
        // divider
        div_valid = 1'b0;
        dividend = 24'h01_00_00; // ray calculations are "1 / raydir[xy]"
        divisor = 16'h00_01; // dummy value, overwritten when used.
        divisor_hold = 16'd0;
        cdelta_d = cdelta_q;
        // ROM indexes
        camerax_addr = x;
        // plane and rays.
        raydir_x_d = raydir_x_q;
        raydir_y_d = raydir_y_q;
        dirx_d = dirx_q;
        diry_d = diry_q;
        planex_d = planex_q;
        planey_d = planey_q;
        camerax_d = camerax_q;
        busy = 1'b1;
        done = 1'b0;
        // multiplier
        mul_res_d = mul_res_q;
        mul_arg1_d = mul_arg1_q;
        mul_arg2_d = mul_arg2_q;
        next_state_d = next_state_q;
    
        case (state_q)
            IDLE: begin
                busy = 1'b0;

                if (start) begin
                   map_pos_x_d = map_pos_x;
                   map_pos_y_d = map_pos_y;
                   state_d = ROM_LOOKUP;
                end
            end
            MULTIPLY: begin
                mul_res_d = trunc_fixed_mul(mul_arg1_q * mul_arg2_q);
                state_d = next_state_q;
            end
            ROM_LOOKUP: begin
                // grab/split cameraX and directionals
                camerax_d = camerax;
                dirx_d = angle[79:64];
                diry_d = angle[63:48];
                planex_d = angle[47:32];
                planey_d = angle[31:16];
                // move on to ray calculations
                state_d = RAY_CALC;
            end
            RAY_CALC: begin
                // calculate rayDirX, rayDirY
                // original simpler calculation.
                /*raydir_x_d = dirx_q + trunc_fixed_mul(planex_q * camerax_q);
                raydir_y_d = diry_q + trunc_fixed_mul(planey_q * camerax_q);
                state_d = DELTADIST_CALC;*/
                // want to share the multiplier, so we step through one at a time.
                mul_arg1_d = planex_q;
                mul_arg2_d = camerax_q;
                next_state_d = RAY_CALC_ADDX;
                state_d = MULTIPLY;
            end
            RAY_CALC_ADDX: begin
                // finalize result of first multiply.
                raydir_x_d = dirx_q + mul_res_q;
                // prepare the next multiply.
                mul_arg1_d = planey_q;
                // arg2 is still camerax_q
                next_state_d = RAY_CALC_ADDY;
                state_d = MULTIPLY;
            end
            RAY_CALC_ADDY: begin
                // reset counter for tracking division progress.
                cdelta_d = 2'b00;
                // finalize the y direction.
                raydir_y_d = diry_q + mul_res_q;
                state_d = DELTADIST_CALC;
            end
            DELTADIST_CALC: begin
                // the divider is ready and gives a result every 4 cycles, with
                // a long (~30 cycle) delay. This queues up our divisions as the
                // divider becomes ready, so we don't have to wait for the full
                // delay twice.
                if (div_ready && !cdelta_q[2]) begin
                if (!cdelta_q[0]) begin
                    divisor_hold = raydir_x_q;
                    cdelta_d[0] = 1'b1;
                end else begin
                    divisor_hold = raydir_y_q;
                    // all divisions queued.
                    cdelta_d[2] = 1'b1;
                end

                // avoid divide by zero.
                if (divisor_hold != 16'd0) begin
                    divisor = divisor_hold;
                end else begin
                    // TODO: Can skip the division in this case since we
                    // divisor/dividend are both static.
                    divisor = 16'd00_01;
                end
                div_valid = 1'b1;
            end

            // divisions come home to roost.
            if (div_out_valid) begin
                // handle special cases where we overflow our 16bit results.
                // the division is 24bit so we can detect this situation.
                if (div_result[31:16] == 16'd0) begin
                    // to infinity, and beyond!
                    if (div_result[39]) begin // negative max
                        divres_hold = 16'h8000;
                    end else begin // positive max
                        divres_hold = 16'h7FFF;
                    end
                end else begin
                    divres_hold = div_result[31:16];
                end

                if (!cdelta_q[1]) begin
                    delta_dist_n_x_d = divres_hold;
                    cdelta_d[1] = 1'b1;
                end else begin
                    delta_dist_n_y_d = divres_hold;
                    // all divisions are done. resume processing.
                    state_d = START_CAST;
                end
            end
            end
            START_CAST: begin
                // keep positive values of delta distance
                // hold step and sidestep for DDA calculations
                if (delta_dist_n_x_q[15]) begin // negative
                    delta_dist_x_d = (~delta_dist_n_x_q) + 16'h00_01;
                    step_x_d = 16'b1111_1111_0000_0000;
                    sidestep_x_d = 16'b0000_0001_0000_0000;
                end else begin // pos
                    delta_dist_x_d = delta_dist_n_x_q;
                    step_x_d = 16'b0000_0001_0000_0000;
                    sidestep_x_d = 16'b0000_0000_0000_0000;
                end
                if (delta_dist_n_y_q[15]) begin // n
                    delta_dist_y_d = (~delta_dist_n_y_q) + 16'h00_01;
                    step_y_d = 16'b1111_1111_0000_0000;
                    sidestep_y_d = 16'b0000_0001_0000_0000;
                end else begin // p
                    delta_dist_y_d = delta_dist_n_y_q;
                    step_y_d = 16'b0000_0001_0000_0000;
                    sidestep_y_d = 16'b0000_0000_0000_0000;
                end
                map_x_d = (map_pos_x_q & 16'hFF_00);
                map_y_d = (map_pos_y_q & 16'hFF_00);
                state_d = DDA_DIST_CALCX_SETUP;
            end
            DDA_DIST_CALCX_SETUP: begin
                mul_arg2_d = delta_dist_x_q;
                if (delta_dist_n_x_q[15]) begin // negative
                    mul_arg1_d = map_pos_x_q & 16'h00_FF;
                end else begin // pos
                    mul_arg1_d = (map_pos_x_q & 16'hFF_00) + 16'h01_00 - map_pos_x_q;
                end
                next_state_d = DDA_DIST_CALCY_SETUP;
                state_d = MULTIPLY;
            end
            DDA_DIST_CALCY_SETUP: begin
                // result of last multiply.
                side_dist_x_d = mul_res_q;
                // setup next multiply.
                mul_arg2_d = delta_dist_y_q;
                if (delta_dist_n_y_q[15]) begin // negative
                    mul_arg1_d = map_pos_y_q & 16'h00_FF;
                end else begin // pos
                    mul_arg1_d = (map_pos_y_q & 16'hFF_00) + 16'h01_00 - map_pos_y_q;
                end
                next_state_d = DDA_DIST_CALC_FINAL;
                state_d = MULTIPLY;
            end
            DDA_DIST_CALC_FINAL: begin
                side_dist_y_d = mul_res_q;
                state_d = DDA_FIND_HIT;
            end
            // The actual DDA loop (single cycle!)!
            // we implement the map by slice memory, so a combinatorial lookup can
            // happen so long as the logic isn't too deep.
            // if we want to run the design at a higher clock rate, would likely
            // have to split this into multiple cycles.
            // or, if we want to use block ram (single cycle delay), it would have
            // to pipeline the map lookup for the next check ahead of time.
            DDA_FIND_HIT: begin
                if (side_dist_x_q < side_dist_y_q) begin
                    side_dist_x_d = side_dist_x_q + (delta_dist_x_q);
                    map_x_d = map_x_q + step_x_q;
                    side_d = 0;
                end else begin
                    side_dist_y_d = side_dist_y_q + (delta_dist_y_q);
                    map_y_d = map_y_q + step_y_q;
                    side_d = 1'b1;
                end
    
                map_rom_x = map_x_d[15:8];
                map_rom_y = map_y_d[15:8];
    
                if (map[map_rom_x][map_rom_y] != 4'd0) begin
                    color_d[3:0] = map[map_rom_x][map_rom_y]; // placeholder "color"
                    if(x == 160) begin
                    
                    last_middle_x =  map_rom_x;
                    last_middle_y = map_rom_y;
                    
                    end
                    color_d[7] = side_d; // change color depending on side hit
                    state_d = CALC_WALLDIST;
                end
            end
            // DDA is done now. Prepare a few calculations for floor/ceiling
            // casting, grab the wall line height, etc.
            CALC_WALLDIST: begin
                // use the shared multiplier to find the wall distance.
                if (side_q == 1'b0) begin
                    mul_arg1_d = (map_x_q - map_pos_x_q + sidestep_x_q);
                    mul_arg2_d = delta_dist_n_x_q;
                end else begin
                    mul_arg1_d = (map_y_q - map_pos_y_q + sidestep_y_q);
                    mul_arg2_d = delta_dist_n_y_q;
                end
                state_d = MULTIPLY;
                next_state_d = CALC_WALLDIST2;
            end
            CALC_WALLDIST2: begin
                p_wall_dist_d = mul_res_q;
                state_d = FIND_LINEHEIGHT;
            end
            FIND_LINEHEIGHT: begin
                // while we're loading the line height, we also need to calculate
                // the texture x offset.
                // first, take the fractional part after calculating in the angle
                mul_arg1_d = p_wall_dist_q;
                if (side_q == 1'b0) begin
                    mul_arg2_d = raydir_y_q;
                end else begin
                    mul_arg2_d = raydir_x_q;
                end
                state_d = MULTIPLY;
                next_state_d = DRAW_LINE_GO;
            end
            
            DRAW_LINE_GO: begin
                line_height_d = line_height_read;
                // line_height_q and texture_x_q should be correct now.
                state_d = WAIT_LINE;
                
            end
            WAIT_LINE : begin
                done = 1'b1;
                busy = 1'b0;
                if(start)begin
                    state_d = IDLE;
                end
            end
            default: begin
                state_d = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state_q = IDLE;
            delta_dist_x_q <= 0;
            delta_dist_y_q <= 0;
            delta_dist_n_x_q <= 0;
            delta_dist_n_y_q <= 0;
            sidestep_x_q <= 0;
            sidestep_y_q <= 0;
            step_x_q <= 0;
            step_y_q <= 0;
            side_dist_x_q <= 0;
            side_dist_y_q <= 0;
            map_x_q <= 0;
            map_y_q <= 0;
            side_q <= 0;
            p_wall_dist_q <= 0;
            color_q <= 0;
            line_height_q <= 0;
            map_pos_x_q <= 0;
            map_pos_y_q <= 0;
        end else begin
            state_q = state_d;
            delta_dist_x_q <= delta_dist_x_d;
            delta_dist_y_q <= delta_dist_y_d;
            delta_dist_n_x_q <= delta_dist_n_x_d;
            delta_dist_n_y_q <= delta_dist_n_y_d;
            sidestep_x_q <= sidestep_x_d;
            sidestep_y_q <= sidestep_y_d;
            step_x_q <= step_x_d;
            step_y_q <= step_y_d;
            side_dist_x_q <= side_dist_x_d;
            side_dist_y_q <= side_dist_y_d;
            map_x_q <= map_x_d;
            map_y_q <= map_y_d;
            p_wall_dist_q <= p_wall_dist_d;
            side_q <= side_d;
            color_q <= color_d;
            line_height_q <= line_height_d;
            map_pos_x_q <= map_pos_x_d;
            map_pos_y_q <= map_pos_y_d;
            
        end
        raydir_x_q <= raydir_x_d;
        raydir_y_q <= raydir_y_d;
        dirx_q <= dirx_d;
        diry_q <= diry_d;
        planex_q <= planex_d;
        planey_q <= planey_d;
        camerax_q <= camerax_d;
        
        mul_res_q <= mul_res_d;
        mul_arg1_q <= mul_arg1_d;
        mul_arg2_q <= mul_arg2_d;
        next_state_q <= next_state_d;
        cdelta_q <= cdelta_d;
    end
    
    // middle result of a Q8.8 multiplication is the actual result.
    // verilog complains a lot about unused bits in registers unless you use
    // a function like this.
    // should also simplify the rest of the math.
    // FIXME: use it for sidedist calc.
    function signed [15:0] trunc_fixed_mul(input signed [31:0] mulres);
      trunc_fixed_mul = mulres[23:8];
    endfunction

    
    
endmodule
