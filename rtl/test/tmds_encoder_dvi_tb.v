`timescale 1ns / 1ps
`default_nettype none

// Project F: Display DVI TMDS Encoder Test Bench
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module tmds_encode_dvi_tb();

    reg rst;
    reg clk;

    reg [7:0] data;
    reg [1:0] ctrl;
    reg de;
    wire [9:0] tmds;
    reg [8:0] cycle;

    // encoded TMDS data $display(...) is within tmds_encoder_dvi.v
    initial begin
        $display("\t               1s    B   O");
        clk = 1;
        rst = 1;
        de = 0;
        ctrl = 2'b00;

        #10
        rst = 0;

        #10
        de = 1;
    end

    tmds_encoder_dvi tmds_test (
        .i_clk(clk),
        .i_rst(rst),
        .i_data(data),
        .i_ctrl(ctrl),
        .i_de(de),
        .o_tmds(tmds)
    );

    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            cycle <= 0;
            data <= 0;
        end
        else
        begin
            cycle <= cycle + 1;
            data <= cycle[7:0];
        end
    end

    always
       #5 clk = ~clk;

endmodule
