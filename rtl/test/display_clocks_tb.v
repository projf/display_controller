`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Clocks Test Bench
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module display_clocks_tb();

    reg rst;
    reg clk;

    // Display clocks: 640x480p60
    wire pix_clk_480p;
    wire pix_clk_5x_480p;
    wire clk_lock_480p;

    display_clocks #(
        .MULT_MASTER(31.5),
        .DIV_MASTER(5),
        .DIV_5X(5.0),
        .DIV_1X(25),
        .IN_PERIOD(10.0)
    )
    display_clocks_480p
    (
       .i_clk(clk),
       .i_rst(rst),
       .o_clk_1x(pix_clk_480p),
       .o_clk_5x(pix_clk_5x_480p),
       .o_locked(clk_lock_480p)
    );


    // Display clocks: 800x600p60
    wire pix_clk_600p;
    wire pix_clk_5x_600p;
    wire clk_lock_600p;

    display_clocks #(
        .MULT_MASTER(10.0),
        .DIV_MASTER(1),
        .DIV_5X(5.0),
        .DIV_1X(25),
        .IN_PERIOD(10.0)
    )
    display_clocks_600p
    (
       .i_clk(clk),
       .i_rst(rst),
       .o_clk_1x(pix_clk_600p),
       .o_clk_5x(pix_clk_5x_600p),
       .o_locked(clk_lock_600p)
    );


    // Display clocks: 1280x720p60
    wire pix_clk_720p;
    wire pix_clk_5x_720p;
    wire clk_lock_720p;

    display_clocks #(
        .MULT_MASTER(37.125),
        .DIV_MASTER(5),
        .DIV_5X(2.0),
        .DIV_1X(10),
        .IN_PERIOD(10.0)
    )
    display_clocks_720p
    (
       .i_clk(clk),
       .i_rst(rst),
       .o_clk_1x(pix_clk_720p),
       .o_clk_5x(pix_clk_5x_720p),
       .o_locked(clk_lock_720p)
    );


    // Display clocks: 1920x1080p60
    wire pix_clk_1080p;
    wire pix_clk_5x_1080p;
    wire clk_lock_1080p;

    display_clocks #(
        .MULT_MASTER(37.125),
        .DIV_MASTER(5),
        .DIV_5X(1.0),
        .DIV_1X(5),
        .IN_PERIOD(10.0)
    )
    display_clocks_1080p
    (
       .i_clk(clk),
       .i_rst(rst),
       .o_clk_1x(pix_clk_1080p),
       .o_clk_5x(pix_clk_5x_1080p),
       .o_locked(clk_lock_1080p)
    );


    initial begin
        $display($time, " << Starting Simulation >>");
        clk = 1;
        rst = 1;
        #10
        rst = 0;
        #10000
        $display($time, " << Simulation Complete >>");
    end

    always
       #5 clk = ~clk;

endmodule