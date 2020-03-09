`timescale 1ns / 1ps
`default_nettype none

// Project F: Display DVI Generator
// (C)2019 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io

module dvi_generator(
    input  wire i_pix_clk,          // pixel clock
    input  wire i_pix_clk_5x,       // 5 x pixel clock for DDR serialization
    input  wire i_rst,              // reset (active high)
    input  wire i_de,               // display enable (draw video)
    input  wire [7:0] i_data_ch0,   // channel 0 - 8-bit colour data
    input  wire [7:0] i_data_ch1,   // channel 1 - 8-bit colour data
    input  wire [7:0] i_data_ch2,   // channel 2 - 8-bit colour data
    input  wire [1:0] i_ctrl_ch0,   // channel 0 - 2-bit control data
    input  wire [1:0] i_ctrl_ch1,   // channel 1 - 2-bit control data
    input  wire [1:0] i_ctrl_ch2,   // channel 2 - 2-bit control data
    output wire o_tmds_ch0_serial,  // channel 0 - serial TMDS
    output wire o_tmds_ch1_serial,  // channel 1 - serial TMDS
    output wire o_tmds_ch2_serial,  // channel 2 - serial TMDS
    output wire o_tmds_chc_serial   // channel clock - serial TMDS
    );

    wire [9:0] tmds_ch0, tmds_ch1, tmds_ch2;

    tmds_encoder_dvi encode_ch0 (
        .i_clk(i_pix_clk),
        .i_rst(i_rst),
        .i_data(i_data_ch0),
        .i_ctrl(i_ctrl_ch0),
        .i_de(i_de),
        .o_tmds(tmds_ch0)
    );

    tmds_encoder_dvi encode_ch1 (
        .i_clk(i_pix_clk),
        .i_rst(i_rst),
        .i_data(i_data_ch1),
        .i_ctrl(i_ctrl_ch1),
        .i_de(i_de),
        .o_tmds(tmds_ch1)
    );

    tmds_encoder_dvi encode_ch2 (
        .i_clk(i_pix_clk),
        .i_rst(i_rst),
        .i_data(i_data_ch2),
        .i_ctrl(i_ctrl_ch2),
        .i_de(i_de),
        .o_tmds(tmds_ch2)
    );

    // common async reset for serdes
    wire rst_oserdes;
    async_reset async_reset_instance (
        .i_clk(i_pix_clk),
        .i_rst(i_rst),
        .o_rst(rst_oserdes)
    );

    serializer_10to1 serialize_ch0 (
        .i_clk(i_pix_clk),
        .i_clk_hs(i_pix_clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(tmds_ch0),
        .o_data(o_tmds_ch0_serial)
    );

    serializer_10to1 serialize_ch1 (
        .i_clk(i_pix_clk),
        .i_clk_hs(i_pix_clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(tmds_ch1),
        .o_data(o_tmds_ch1_serial)
    );

    serializer_10to1 serialize_ch2 (
        .i_clk(i_pix_clk),
        .i_clk_hs(i_pix_clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(tmds_ch2),
        .o_data(o_tmds_ch2_serial)
    );

    serializer_10to1 serialize_chc (
        .i_clk(i_pix_clk),
        .i_clk_hs(i_pix_clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(10'b0000011111),
        .o_data(o_tmds_chc_serial)
    );

endmodule
