`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Timings Test Bench
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module display_timings_tb();

    // Display timings: 640x480p60
    reg rst_480p;
    reg clk_480p;

    wire [15:0] x_480p;  // horizontal screen position (active pixels)
    wire [15:0] y_480p;  // vertical screen position (active pixels)
    wire [15:0] h_480p;  // horizontal beam position (including blanking)
    wire [15:0] v_480p;  // vertical beam position (including blanking)
    wire h_sync_480p;    // horizontal sync
    wire v_sync_480p;    // vertical sync
    wire de_480p;        // display enable: high during active video
    wire frame_480p;     // high for one tick at the start of each frame

    display_timings #(
        .H_RES(640),
        .V_RES(480),
        .H_FP(16),
        .H_SYNC(96),
        .H_BP(48),
        .V_FP(10),
        .V_SYNC(2),
        .V_BP(33),
        .H_POL(0),
        .V_POL(0)
    )
    display_timings_480p (
        .i_pixclk(clk_480p),
        .i_rst(rst_480p),
        .o_hs(h_sync_480p),
        .o_vs(v_sync_480p),
        .o_de(de_480p),
        .o_frame(frame_480p),
        .o_h(h_480p),
        .o_v(v_480p),
        .o_x(x_480p),
        .o_y(y_480p)
    );


    // Display timings: 1280x720p60
    reg rst_720p;
    reg clk_720p;

    wire [15:0] x_720p;  // horizontal screen position (active pixels)
    wire [15:0] y_720p;  // vertical screen position (active pixels)
    wire [15:0] h_720p;  // horizontal beam position (including blanking)
    wire [15:0] v_720p;  // vertical beam position (including blanking)
    wire h_sync_720p;    // horizontal sync
    wire v_sync_720p;    // vertical sync
    wire de_720p;        // display enable: high during active video
    wire frame_720p;     // high for one tick at the start of each frame

    display_timings #(
        .H_RES(1280),
        .V_RES(720),
        .H_FP(110),
        .H_SYNC(40),
        .H_BP(220),
        .V_FP(5),
        .V_SYNC(5),
        .V_BP(20),
        .H_POL(1),
        .V_POL(1)
    )
    display_timings_720p (
        .i_pixclk(clk_720p),
        .i_rst(rst_720p),
        .o_hs(h_sync_720p),
        .o_vs(v_sync_720p),
        .o_de(de_720p),
        .o_frame(frame_720p),
        .o_h(h_720p),
        .o_v(v_720p),
        .o_x(x_720p),
        .o_y(y_720p)
    );


    initial begin
        $display($time, " << Starting Simulation >>");
        clk_480p <= 1;
        rst_480p <= 1;
        clk_720p <= 1;
        rst_720p <= 1;

        #10
        rst_480p <= 0;
        rst_720p <= 0;
    end

    always
       #19.84 clk_480p = ~clk_480p;  // 39.68 ns clock cycle (25.2 MHz)

    always
       #6.73 clk_720p = ~clk_720p;  // 13.47 ns clock cycle (74.5 MHz)

endmodule
