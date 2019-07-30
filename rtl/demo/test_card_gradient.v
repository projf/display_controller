`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Controller Test Card: Gradient
// (C)2019 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io

module test_card_gradient (
    input wire [5:0] i_x,
    input wire [7:0] i_y,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue
    );

    localparam base_red     = 8'h00;
    localparam base_green   = 8'h10;
    localparam base_blue    = 8'h4C;

    assign o_red    = base_red + i_y + {2'b0, i_x};
    assign o_green  = base_green + i_y;
    assign o_blue   = base_blue + i_y;
endmodule
