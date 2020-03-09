`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Serializer Test Bench
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module serializer_10to1_tb();

    reg rst;
    reg clk;
    reg clk_5x;
    reg clk_lock;  // clocks locked?

    wire rst_oserdes;
    reg [9:0] tmds_data_1;
    reg [9:0] tmds_data_2;
    reg [9:0] tmds_data_3;
    wire tmds_data_1_serial;
    wire tmds_data_2_serial;
    wire tmds_data_3_serial;

    initial begin
        $display($time, " << Starting Simulation >>");
        clk = 0;
        clk_5x = 0;
        rst = 0;
        clk_lock = 0;

        #1.5
        rst = 1;  // assert reset async

        #18.5
        rst = 0;

        #20
        clk_lock = 1;
        tmds_data_1 = 10'b0110100110;
        tmds_data_2 = 10'b1001011001;
        tmds_data_3 = 10'b1100000010;

        #100
        tmds_data_1 = 10'b1111111111;
        tmds_data_2 = 10'b1010101010;
        tmds_data_3 = 10'b0000000000;

        #2
        clk_lock = 0;  // simulate loss of clock lock

        #23
        clk_lock = 1;

        #125
        tmds_data_1 = 10'b0110100110;
        tmds_data_2 = 10'b1001011001;
        tmds_data_3 = 10'b1100000010;

        #101.25
        rst = 1;  // assert reset async

        #11.5
        rst = 0;  // de-assert reset async
    end

    // common async reset for serdes
    async_reset async_reset_instance (
        .i_clk(clk),
        .i_rst(rst | ~clk_lock),
        .o_rst(rst_oserdes)
    );

    serializer_10to1 serialize_data_1 (
        .i_clk(clk),
        .i_clk_hs(clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(tmds_data_1),
        .o_data(tmds_data_1_serial)
    );

    serializer_10to1 serialize_data_2 (
        .i_clk(clk),
        .i_clk_hs(clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(tmds_data_2),
        .o_data(tmds_data_2_serial)
    );

     serializer_10to1 serialize_data_3 (
        .i_clk(clk),
        .i_clk_hs(clk_5x),
        .i_rst_oserdes(rst_oserdes),
        .i_data(tmds_data_3),
        .o_data(tmds_data_3_serial)
    );

    always
        #5 clk = ~clk;

    always
        #1 clk_5x = ~clk_5x;

endmodule
