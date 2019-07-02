`timescale 1ns / 1ps
`default_nettype none

// Project F: Async Reset
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module async_reset(
    input  wire i_clk,      // clock
    input  wire i_rst,      // reset (active high)
    output reg  o_rst       // output reset
    );

    (* ASYNC_REG = "TRUE" *) reg [1:0] rst_shf;  // reset shift reg

    initial o_rst = 1'b1;       // start off with reset asserted
    initial rst_shf = 2'b11;    //  and reset shift reg populated

    always @(posedge i_clk or posedge i_rst)
    if (i_rst)
        {o_rst, rst_shf} <= 3'b111;
    else
        {o_rst, rst_shf} <= {rst_shf, 1'b0};

endmodule
