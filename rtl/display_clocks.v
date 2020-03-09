`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Clocks
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

// Defaults to 25.2 and 126 MHz for 640x480 at 60 Hz

module display_clocks #(
    MULT_MASTER=31.5,       // master clock multiplier (2.000-64.000)
    DIV_MASTER=5,           // master clock divider (1-106)
    DIV_5X=5.0,             // 5x clock divider (1-128)
    DIV_1X=25,              // 1x clock divider (1-128)
    IN_PERIOD=10.0          // period of i_clk in ns (100 MHz = 10.0 ns)
    )
    (
    input  wire i_clk,      // input clock
    input  wire i_rst,      // reset (active high)
    output wire o_clk_1x,   // pixel clock
    output wire o_clk_5x,   // 5x clock for 10:1 DDR SerDes
    output wire o_locked    // clock locked? (active high)
    );

    wire clk_fb;  // internal clock feedback
    wire clk_1x_pre;
    wire clk_5x_pre;

    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),        // Jitter programming (OPTIMIZED, HIGH, LOW)
        .CLKFBOUT_MULT_F(MULT_MASTER),  // Multiply value for all CLKOUT (2.000-64.000).
        .CLKFBOUT_PHASE(0.0),           // Phase offset in degrees of CLKFB (-360.000-360.000).
        .CLKIN1_PERIOD(IN_PERIOD),      // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        .CLKOUT0_DIVIDE_F(DIV_5X),      // Divide amount for CLKOUT0 (1.000-128.000).
        .CLKOUT1_DIVIDE(DIV_1X),
        .CLKOUT2_DIVIDE(1),
        .CLKOUT3_DIVIDE(1),
        .CLKOUT4_DIVIDE(1),
        .CLKOUT5_DIVIDE(1),
        .CLKOUT6_DIVIDE(1),
        // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT1_DUTY_CYCLE(0.5),
        .CLKOUT2_DUTY_CYCLE(0.5),
        .CLKOUT3_DUTY_CYCLE(0.5),
        .CLKOUT4_DUTY_CYCLE(0.5),
        .CLKOUT5_DUTY_CYCLE(0.5),
        .CLKOUT6_DUTY_CYCLE(0.5),
        // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        .CLKOUT0_PHASE(0.0),
        .CLKOUT1_PHASE(0.0),
        .CLKOUT2_PHASE(0.0),
        .CLKOUT3_PHASE(0.0),
        .CLKOUT4_PHASE(0.0),
        .CLKOUT5_PHASE(0.0),
        .CLKOUT6_PHASE(0.0),
        .CLKOUT4_CASCADE("FALSE"),      // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        .DIVCLK_DIVIDE(DIV_MASTER),     // Master division value (1-106)
        .REF_JITTER1(0.010),            // Reference input jitter in UI (0.000-0.999).
        .STARTUP_WAIT("FALSE")          // Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    MMCME2_BASE_inst (
        /* verilator lint_off PINCONNECTEMPTY */
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(clk_5x_pre),           // 1-bit output: CLKOUT0
        .CLKOUT0B(),                    // 1-bit output: Inverted CLKOUT0
        .CLKOUT1(clk_1x_pre),           // 1-bit output: CLKOUT1
        .CLKOUT1B(),                    // 1-bit output: Inverted CLKOUT1
        .CLKOUT2(),                     // 1-bit output: CLKOUT2
        .CLKOUT2B(),                    // 1-bit output: Inverted CLKOUT2
        .CLKOUT3(),                     // 1-bit output: CLKOUT3
        .CLKOUT3B(),                    // 1-bit output: Inverted CLKOUT3
        .CLKOUT4(),                     // 1-bit output: CLKOUT4
        .CLKOUT5(),                     // 1-bit output: CLKOUT5
        .CLKOUT6(),                     // 1-bit output: CLKOUT6
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT(clk_fb),              // 1-bit output: Feedback clock
        .CLKFBOUTB(),                   // 1-bit output: Inverted CLKFBOUT
        // Status Ports: 1-bit (each) output: MMCM status ports
        .LOCKED(o_locked),              // 1-bit output: LOCK
        // Clock Inputs: 1-bit (each) input: Clock input
        .CLKIN1(i_clk),                 // 1-bit input: Clock
        // Control Ports: 1-bit (each) input: MMCM control ports
        .PWRDWN(),                      // 1-bit input: Power-down
        /* verilator lint_on PINCONNECTEMPTY */
        .RST(i_rst),                    // 1-bit input: Reset
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN(clk_fb)                // 1-bit input: Feedback clock
    );

    // explicitly buffer output clocks
    BUFG bufg_clk_pix(.I(clk_1x_pre), .O(o_clk_1x));
    BUFG bufg_clk_pix_5x(.I(clk_5x_pre), .O(o_clk_5x));

endmodule
