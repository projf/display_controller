`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Timings
// (C)2019 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io

// Defaults to 640x480 at 60 Hz

module display_timings #(
    H_RES=640,      // horizontal resolution (pixels)
    V_RES=480,      // vertical resolution (lines)
    H_FP=16,        // horizontal front porch
    H_SYNC=96,      // horizontal sync
    H_BP=48,        // horizontal back porch
    V_FP=10,        // vertical front porch
    V_SYNC=2,       // vertical sync
    V_BP=33,        // vertical back porch
    H_POL=0,        // horizontal sync polarity (0:neg, 1:pos)
    V_POL=0         // vertical sync polarity (0:neg, 1:pos)
    )
    (
    input  wire i_pixclk,       // pixel clock
    input  wire i_rst,          // reset: restarts frame (active high)
    output wire o_hs,           // horizontal sync
    output wire o_vs,           // vertical sync
    output wire o_de,           // display enable: high during active video
    output wire o_frame,        // high for one tick at the start of each frame
    output reg  [15:0] o_h,     // horizontal beam position (including blanking)
    output reg  [15:0] o_v,     // vertical beam position (including blanking)
    output wire [15:0] o_x,     // horizontal screen position (active pixels)
    output wire [15:0] o_y      // vertical screen position (active pixels)
    );
    
    // Horizontal: sync, active, and pixels
    localparam HS_STA = H_FP - 1;           // sync start (first pixel is 0)
    localparam HS_END = HS_STA + H_SYNC;    // sync end
    localparam HA_STA = HS_END + H_BP;      // active start
    localparam HA_END = HA_STA + H_RES;     // active end 
    localparam LINE   = HA_END;             // line pixels 

    // Vertical: sync, active, and pixels
    localparam VS_STA = V_FP - 1;           // sync start (first line is 0)
    localparam VS_END = VS_STA + V_SYNC;    // sync end
    localparam VA_STA = VS_END + V_BP;      // active start
    localparam VA_END = VA_STA + V_RES;     // active end 
    localparam FRAME  = VA_END;             // frame lines 

    // generate sync signals with correct polarity
    assign o_hs = H_POL ? (o_h > HS_STA && o_h <= HS_END)
        : ~(o_h > HS_STA && o_h <= HS_END);
    assign o_vs = V_POL ? (o_v > VS_STA && o_v <= VS_END)
        : ~(o_v > VS_STA && o_v <= VS_END);
        
    // display enable: high during active period
    assign o_de = o_h > HA_STA && o_h <= HA_END
        && o_v > VA_STA && o_v <= VA_END;
    
    // keep o_x and o_y bound within active pixels
    assign o_x = (o_de && o_h > HA_STA && o_h <= HA_END) ?
                    o_h - (HA_STA + 1): 0;
    assign o_y = (o_de && o_v > VA_STA && o_v <= VA_END) ?
                    o_v - (VA_STA + 1): 0;
    
    // o_frame: high for one tick at the start of each frame
    assign o_frame = (o_v == 0 && o_h == 0);

    always @ (posedge i_pixclk or posedge i_rst)
    begin
        if (i_rst)  // reset to start of frame
        begin
            o_h <= 0;
            o_v <= 0;
        end
        else
        begin
            if (o_h == LINE)  // end of line
            begin
                o_h <= 0;
                if (o_v == FRAME)  // end of frame
                    o_v <= 0;
                else
                    o_v <= o_v + 1;
            end
            else 
                o_h <= o_h + 1;
        end
    end
endmodule
