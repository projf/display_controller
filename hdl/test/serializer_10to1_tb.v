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

    reg [9:0] tmds_data_1;
    reg [9:0] tmds_data_2;
    reg [9:0] tmds_data_3;
    wire tmds_data_1_serial;
    wire tmds_data_2_serial;
    wire tmds_data_3_serial;

    initial begin
        $display($time, " << Starting Simulation >>");
        clk <= 0;
        clk_5x <= 1;
        rst <= 1;
        clk_lock <= 0;

        #10
        rst <= 0;

        #10
        clk_lock <=1;
        tmds_data_1 <= 10'b0110100110;
        tmds_data_2 <= 10'b1001011001;
        tmds_data_3 <= 10'b1100000010;
    end

    serializer_10to1 serialize_data_1 (
        .i_clk(clk),
        .i_clk_hs(clk_5x),
        .i_rst(rst | ~clk_lock),
        .i_data(tmds_data_1),
        .o_data(tmds_data_1_serial)
    );

    serializer_10to1 serialize_data_2 (
        .i_clk(clk),
        .i_clk_hs(clk_5x),
        .i_rst(rst | ~clk_lock),
        .i_data(tmds_data_2),
        .o_data(tmds_data_2_serial)
    );

     serializer_10to1 serialize_data_3 (
        .i_clk(clk),
        .i_clk_hs(clk_5x),
        .i_rst(rst | ~clk_lock),
        .i_data(tmds_data_3),
        .o_data(tmds_data_3_serial)
    );

    always
        #5 clk = ~clk;

    always
        #1 clk_5x = ~clk_5x;

endmodule
