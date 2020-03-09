`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Controller VGA Demo
// (C)2020 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

// This demo requires the following Verilog modules:
//  * display_clocks
//  * display_timings
//  * test_card_simple or another test card

module display_demo_vga(
    input  wire CLK,                // board clock: 100 MHz on Arty/Basys3/Nexys
    input  wire RST_BTN,            // reset button
    output wire VGA_HS,             // horizontal sync output
    output wire VGA_VS,             // vertical sync output
    output wire [3:0] VGA_R,        // 4-bit VGA red output
    output wire [3:0] VGA_G,        // 4-bit VGA green output
    output wire [3:0] VGA_B         // 4-bit VGA blue output
    );

    // Display Clocks
    wire pix_clk;                   // pixel clock
    wire clk_lock;                  // clock locked?

    display_clocks #(               // 640x480  800x600 1280x720 1920x1080
        .MULT_MASTER(31.5),         //    31.5     10.0   37.125    37.125
        .DIV_MASTER(5),             //       5        1        5         5
        .DIV_5X(5.0),               //     5.0      5.0      2.0       1.0
        .DIV_1X(25),                //      25       25       10         5
        .IN_PERIOD(10.0)            // 100 MHz = 10 ns
    )
    display_clocks_inst
    (
       .i_clk(CLK),
       .i_rst(~RST_BTN),            // reset is active low on Arty & Nexys Video
       .o_clk_1x(pix_clk),
       .o_clk_5x(),                 // 5x clock not needed for VGA
       .o_locked(clk_lock)
    );

    // Display Timings
    wire signed [15:0] sx;          // horizontal screen position (signed)
    wire signed [15:0] sy;          // vertical screen position (signed)
    wire h_sync;                    // horizontal sync
    wire v_sync;                    // vertical sync
    wire de;                        // display enable
    wire frame;                     // frame start

    display_timings #(              // 640x480  800x600 1280x720 1920x1080
        .H_RES(640),                //     640      800     1280      1920
        .V_RES(480),                //     480      600      720      1080
        .H_FP(16),                  //      16       40      110        88
        .H_SYNC(96),                //      96      128       40        44
        .H_BP(48),                  //      48       88      220       148
        .V_FP(10),                  //      10        1        5         4
        .V_SYNC(2),                 //       2        4        5         5
        .V_BP(33),                  //      33       23       20        36
        .H_POL(0),                  //       0        1        1         1
        .V_POL(0)                   //       0        1        1         1
    )
    display_timings_inst (
        .i_pix_clk(pix_clk),
        .i_rst(!clk_lock),
        .o_hs(h_sync),
        .o_vs(v_sync),
        .o_de(de),
        .o_frame(frame),
        .o_sx(sx),
        .o_sy(sy)
    );

    // test card colour output
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;

    // Test Card: Simple - ENABLE ONE TEST CARD INSTANCE ONLY
    test_card_simple #(
        .H_RES(640)    // horizontal resolution
    ) test_card_inst (
        .i_x(sx),
        .o_red(red),
        .o_green(green),
        .o_blue(blue)
    );

    // // Test Card: Squares - ENABLE ONE TEST CARD INSTANCE ONLY
    // test_card_squares #(
    //     .H_RES(640),    // horizontal resolution
    //     .V_RES(480)     // vertical resolution
    // )
    // test_card_inst (
    //     .i_x(sx),
    //     .i_y(sy),
    //     .o_red(red),
    //     .o_green(green),
    //     .o_blue(blue)
    // );

    // // Test Card: Gradient - ENABLE ONE TEST CARD INSTANCE ONLY
    // localparam GRAD_STEP = 2;  // step right shift: 480=2, 720=2, 1080=3
    // test_card_gradient test_card_inst (
    //     .i_x(sx[5:0]),
    //     .i_y(sy[GRAD_STEP+7:GRAD_STEP]),
    //     .o_red(red),
    //     .o_green(green),
    //     .o_blue(blue)
    // );

    // VGA Output
    // VGA Pmod is 12-bit so we take the upper nibble of each colour
    assign VGA_HS   = h_sync;
    assign VGA_VS   = v_sync;
    assign VGA_R    = de ? red[7:4] : 4'b0;
    assign VGA_G    = de ? green[7:4] : 4'b0;
    assign VGA_B    = de ? blue[7:4] : 4'b0;
endmodule