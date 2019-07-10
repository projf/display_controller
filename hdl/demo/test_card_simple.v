`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Controller Simple Test Card
// (C)2019 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io

module test_card_simple #(H_RES=640) (
    input wire signed [15:0] i_x,
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue
    );

    localparam HW = H_RES >> 3; // horizontal colour width = H_RES / 8

    // Bands
    wire b0 = (i_x >= 0     ) & (i_x < HW    );
    wire b1 = (i_x >= HW    ) & (i_x < HW * 2);
    wire b2 = (i_x >= HW * 2) & (i_x < HW * 3);
    wire b3 = (i_x >= HW * 3) & (i_x < HW * 4);
    wire b4 = (i_x >= HW * 4) & (i_x < HW * 5);
    wire b5 = (i_x >= HW * 5) & (i_x < HW * 6);
    wire b6 = (i_x >= HW * 6) & (i_x < HW * 7);
    wire b7 = (i_x >= HW * 7) & (i_x < HW * 8);

    // Colour Output
    assign o_red    = {8{b0 | b1 | b5}} + {2'b0,{6{b6}}} + {b7, 7'b0};
    assign o_green  = {8{b1 | b2 | b3}} + {2'b0,{6{b6}}} + {b7, 7'b0};
    assign o_blue   = {8{b3 | b4 | b5}} + {2'b0,{6{b6}}} + {b7, 7'b0};
endmodule
