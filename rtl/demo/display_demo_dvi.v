`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Controller DVI Demo
// (C)2020 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

// This demo requires the following Verilog modules:
//  * display_clocks
//  * display_timings
//  * dvi_generator
//  * serializer_10to1
//  * async_reset
//  * tmds_encoder_dvi
//  * test_card_simple or another test card

module display_demo_dvi(
    input  wire CLK,                // board clock: 100 MHz on Arty/Basys3/Nexys
    input  wire RST_BTN,            // reset button
    inout  wire hdmi_tx_cec,        // CE control bidirectional
    input  wire hdmi_tx_hpd,        // hot-plug detect
    inout  wire hdmi_tx_rscl,       // DDC bidirectional
    inout  wire hdmi_tx_rsda,       // DDC bidirectional
    output wire hdmi_tx_clk_n,      // HDMI clock differential negative
    output wire hdmi_tx_clk_p,      // HDMI clock differential positive
    output wire [2:0] hdmi_tx_n,    // Three HDMI channels differential negative
    output wire [2:0] hdmi_tx_p     // Three HDMI channels differential positive
    );

    // Display Clocks
    wire pix_clk;                   // pixel clock
    wire pix_clk_5x;                // 5x clock for 10:1 DDR SerDes
    wire clk_lock;                  // clock locked?

    display_clocks #(               // 640x480  800x600 1280x720 1920x1080
        .MULT_MASTER(37.125),       //    31.5     10.0   37.125    37.125
        .DIV_MASTER(5),             //       5        1        5         5
        .DIV_5X(2.0),               //     5.0      5.0      2.0       1.0
        .DIV_1X(10),                //      25       25       10         5
        .IN_PERIOD(10.0)            // 100 MHz = 10 ns
    )
    display_clocks_inst
    (
       .i_clk(CLK),
       .i_rst(~RST_BTN),            // reset is active low on Arty & Nexys Video
       .o_clk_1x(pix_clk),
       .o_clk_5x(pix_clk_5x),
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
        .H_RES(1280),               //     640      800     1280      1920
        .V_RES(720),                //     480      600      720      1080
        .H_FP(110),                 //      16       40      110        88
        .H_SYNC(40),                //      96      128       40        44
        .H_BP(220),                 //      48       88      220       148
        .V_FP(5),                   //      10        1        5         4
        .V_SYNC(5),                 //       2        4        5         5
        .V_BP(20),                  //      33       23       20        36
        .H_POL(1),                  //       0        1        1         1
        .V_POL(1)                   //       0        1        1         1
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
        .H_RES(1280)    // horizontal resolution
    ) test_card_inst (
        .i_x(sx),
        .o_red(red),
        .o_green(green),
        .o_blue(blue)
    );

    // // Test Card: Squares - ENABLE ONE TEST CARD INSTANCE ONLY
    // test_card_squares #(
    //     .H_RES(1280),   // horizontal resolution
    //     .V_RES(720)     // vertical resolution
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
    //     .i_y(sy[GRAD_STEP+7:GRAD_STEP]),
    //     .i_x(sx[5:0]),
    //     .o_red(red),
    //     .o_green(green),
    //     .o_blue(blue)
    // );

    // TMDS Encoding and Serialization
    wire tmds_ch0_serial, tmds_ch1_serial, tmds_ch2_serial, tmds_chc_serial;
    dvi_generator dvi_out (
        .i_pix_clk(pix_clk),
        .i_pix_clk_5x(pix_clk_5x),
        .i_rst(!clk_lock),
        .i_de(de),
        .i_data_ch0(blue),
        .i_data_ch1(green),
        .i_data_ch2(red),
        .i_ctrl_ch0({v_sync, h_sync}),
        .i_ctrl_ch1(2'b00),
        .i_ctrl_ch2(2'b00),
        .o_tmds_ch0_serial(tmds_ch0_serial),
        .o_tmds_ch1_serial(tmds_ch1_serial),
        .o_tmds_ch2_serial(tmds_ch2_serial),
        .o_tmds_chc_serial(tmds_chc_serial)  // encode pixel clock via same path
    );

    // TMDS Buffered Output
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch0 (.I(tmds_ch0_serial), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch1 (.I(tmds_ch1_serial), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch2 (.I(tmds_ch2_serial), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_chc (.I(tmds_chc_serial), .O(hdmi_tx_clk_p), .OB(hdmi_tx_clk_n));

    assign hdmi_tx_cec   = 1'bz;
    assign hdmi_tx_rsda  = 1'bz;
    assign hdmi_tx_rscl  = 1'b1;
endmodule