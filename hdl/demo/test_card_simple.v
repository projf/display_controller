`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Controller Simple Test Card
// (C)2019 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io

module test_card_simple #(
    H_RES=640,
    V_RES=480
    )
    (
    input wire [15:0] i_x,
    input wire [15:0] i_y,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue
    );

    localparam HR = H_RES;  // horizontal resolution (pixels)
    localparam VR = V_RES;  // vertical resolution (lines)
    localparam BW = 16;     // border width

    // Borders
    wire top = (i_x >=     0) & (i_y >=     0) & (i_x < HR) & (i_y < BW);
    wire btm = (i_x >=     0) & (i_y >= VR-BW) & (i_x < HR) & (i_y < VR);
    wire lft = (i_x >=     0) & (i_y >=     0) & (i_x < BW) & (i_y < VR);
    wire rgt = (i_x >= HR-BW) & (i_y >=     0) & (i_x < HR) & (i_y < VR);

    // Colour Output
    assign o_red    = {8{lft | top}};
    assign o_green  = {8{btm | top}};
    assign o_blue   = {8{rgt | top}};
endmodule
