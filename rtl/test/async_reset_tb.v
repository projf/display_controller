`timescale 1ns / 1ps
`default_nettype none

// Project F: Async Reset Test Bench
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module async_reset_tb();

    reg rst;
    reg clk;

    wire rst_output;
    async_reset async_reset_instance (
        .i_clk(clk),
        .i_rst(rst),
        .o_rst(rst_output)
    );

    initial begin
        $display($time, " << Starting Simulation >>");
        clk = 1;
        rst = 0;

        #3.14159
        rst = 1;

        #27.1828
        rst = 0;

        #40
        rst = 1;

        #15
        rst = 0;
    end

    always
        #5 clk = ~clk;

endmodule
