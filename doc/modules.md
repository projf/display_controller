# Display Controller Modules

The display controller consists of six core modules. This document describes the interfaces for the three you interact with: `display_clocks`, `display_timings` and `dvi_generator`. The other three modules are used internally by `dvi_generator`. You can see the modules being put to use in the [demos](/rtl/demo) and [test benches](/rtl/test).

The design aims to be as generic as possible but does make use of Xilinx Series 7 specific features, such as SerDes. If you want advice on adapting this design to other FPGAs, then take a look at [porting](/doc/porting.md).

See [README](/README.md) for more documentation.


## Contents

- **[Architecture](#architecture)**
- **[Display Clocks](#display-clocks)** ([RTL](/rtl/display_clocks.v)) - pixel and high-speed clocks for TMDS
- **[Display Timings](#display-timings)** ([RTL](/rtl/display_timings.v)) - generates display timings, including horizontal and vertical sync
- **[DVI Generator](#dvi-generator)** ([RTL](/rtl/dvi_generator.v)) - uses `serializer_10to1` and `tmds_encode_dvi` to generate a DVI signal


## Architecture

### TMDS Encoding on FPGA for DVI or HDMI

1. [Display Clocks](#display-clocks) - synthesizes the pixel and SerDes clocks, for example, 74.25 and 371.25 MHz for 720p
2. [Display Timings](#display-timings) - generates the display sync signals and active pixel position
3. Colour Data - the colour of a pixel, taken from a bitmap, sprite, test card etc.
4. [DVI Generator](#dvi-generator)
    1. TMDS Encoder - encodes 8-bit red, green, and blue pixel data into 10-bit TMDS values
    2. 10:1 Serializer - converts parallel 10-bit TMDS value into serial form
6. Differential Signal Output - converts TMDS data into differential form for output via two FPGA pins

### Analogue VGA and BML DVI Pmod

1. [Display Clocks](#display-clocks) - synthesizes the pixel clock, for example, 40 MHz for 800x600
2. [Display Timings](#display-timings) - generates the display sync signals and active pixel position
3. Colour Data - the colour of a pixel, taken from a bitmap, sprite, test card etc.
4. Parallel Colour Output - external hardware converts this to analogue VGA or TMDS DVI as appropriate


## Display Clocks
Timing is everything when it comes to working with screens: everything marches in step with the pixel clock. Pixel clocks are typically in the range 25-165 MHz for SD and HD resolutions; for example, 1280x720p60 uses a pixel clock of 74.25 MHz. If our pixel clock deviates by more than 0.5%, it'll be out of Vesa spec and will likely fail to display. This module generates a high-quality pixel clock using the mixed-mode clock manager (MMCM). When doing our own TMDS SerDes, we also need a 5x pixel clock, which this module also generates. ([display_clocks.v](/rtl/display_clocks.v))

[Display parameters](display-params.md#display-clocks) includes appropriate parameters for four standard pixel clocks, and you can see examples in the [demos](/rtl/demo).

### Inputs

* `i_clk` - input clock
* `i_rst` - reset (active high)

The `IN_PERIOD` parameter (below) must match the frequency of the input clock.

### Outputs

* `o_clk_1x` - pixel clock
* `o_clk_5x` - 5x clock for 10:1 DDR SerDes
* `o_locked` - clock locked? (active high)

You shouldn't use the clocks until the locked signal is high. You can safely ignore the `o_clk_5x` output if you're not doing TMDS encoding on the FPGA.

### Parameters

* `MULT_MASTER` - multiplication for both output clocks
* `DIV_MASTER` - division for both output clocks
* `DIV_5X` - division for 5x (SerDes) clock
* `DIV_1X` - division for pixel clock
* `IN_PERIOD` - period of input clock in nanoseconds (ns)

The `IN_PERIOD` needs to match the input clock `i_clk` frequency. For example, a 100 MHz clock has a 10 ns period, so `IN_PERIOD` would be 10.

The output clocks are calculated as follows:

    o_clk_1x = (i_clk * MULT_MASTER / DIV_MASTER) / DIV_1X
    o_clk_5x = (i_clk * MULT_MASTER / DIV_MASTER) / DIV_5X

For example, 720p60:

     74.25 MHz = (100 MHz * 37.125 / 5) / 10
    371.25 MHz = (100 MHz * 37.125 / 5) /  2


## Display Timings
The display timings module turns timing parameters into appropriately timed sync pulses and provides the current screen coordinates. Accurate timings depend on an accurate [pixel clock](#display-clocks). ([display_timings.v](/rtl/display_timings.v))

### Inputs

* `i_pix_clk` - pixel clock
* `i_rst` - reset (active high)

The pixel clock must be suitable for the timings given in the parameters (see display clocks, above).

### Outputs

* `o_hs` - horizontal sync
* `o_vs` - vertical sync
* `o_de` - display enable: high during active video
* `o_frame` - high for one tick at the start of each frame
* `o_sx [15:0]` - horizontal screen position (signed)
* `o_sy [15:0]` - vertical screen position (signed)

The current beam position is given by `(o_sx,o_sy)`. `o_sx` and `o_sy` are **signed** 16-bit values.

When display enable (`o_de`) is high, these values provide the active drawing pixel and are always positive. During the blanking interval, one or both of `o_sx` and `o_sy` will be negative, which allows you to prepare for drawing. For example, if you have a two-cycle latency to retrieve a pixel's colour you can request the data for the first pixel of a line when `o_sx == -2`.

![](display-timings.png?raw=true "")

The screen coordinate diagram, above, shows a 1280x720p60 frame. At the start of the frame `o_sx == -370` and `o_sy == -30`. Active drawing starts at `o_sx == 0` and `o_sy == 0` with the final coordinates being `o_sx == 1279` and `o_sy == 719`. See [drawing coordinates](display-params.md#screen-coordinates) for details on all supported resolutions.

Horizontal and vertical sync may be active high or low depending on the display mode; this is controlled using the `H_POL` and `V_POL` parameters (below).

### Parameters

* `H_RES` - active horizontal resolution in pixels
* `V_RES` - active vertical resolution in lines
* `H_FP` - horizontal front porch length in pixels
* `H_SYNC` - horizontal sync length in pixels
* `H_BP` - horizontal back porch length in pixels
* `V_FP` - vertical front porch length in lines
* `V_SYNC` - vertical sync length in lines
* `V_BP` - vertical back porch length in lines
* `H_POL` - horizontal sync polarity (0:negative, 1:positive)
* `V_POL` - vertical sync polarity (0:negative, 1:positive)

[Display parameters](display-params.md#display-timings) includes appropriate timing parameters for four standard resolutions. You can also see examples of the parameters in the [demos](/rtl/demo).

## DVI Generator
The DVI generator has many inputs but is straightforward to use. You hook it up to the display clocks and display timings then add your pixel colour data. ([dvi_generator.v](/rtl/dvi_generator.v))

DVI generator instantiates two other modules to do the actual work: one for [TMDS encoding](/rtl/tmds_encoder_dvi.v) and the other for [10:1 serialization](/rtl/serializer_10to1.v). The TMDS encoder has a [Python model](/README.md#tmds-encoder-model) to aid with development and testing.

### Inputs

* `i_pix_clk` - pixel clock ([display clocks](#display-clocks) provides this)
* `i_pix_clk_5x` - 5x pixel clock for DDR serialization ([display clocks](#display-clocks) provides this)
* `i_clk_lock` - clock locked? (active high) ([display clocks](#display-clocks) provides this)
* `i_rst` - reset (active high)
* `i_de` - display enable ([display timings](#display-timings) provides this)
* `i_data_ch0 [7:0]` - 8-bit blue colour data (TMDS channel 0)
* `i_data_ch1 [7:0]` - 8-bit green colour data (TMDS channel 1)
* `i_data_ch2 [7:0]` - 8-bit red colour data (TMDS channel 2)
* `i_ctrl_ch0 [1:0]` - channel 0 control data; set to `{v_sync, h_sync}` from [display timings](#display-timings)
* `i_ctrl_ch1 [1:0]` - channel 1 control data; set to `2'b00`
* `i_ctrl_ch2 [1:0]` - channel 2 control data; set to `2'b00`

### Outputs

The output is the four TMDS encoded serial channels ready for output as differential signals:

* `o_tmds_ch0_serial` - channel 0 - serial TMDS
* `o_tmds_ch1_serial` - channel 1 - serial TMDS
* `o_tmds_ch2_serial` - channel 2 - serial TMDS
* `o_tmds_chc_serial` - channel clock - serial TMDS

You can use these signals with `OBUFDS`, for example:

    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch0 (.I(tmds_ch0_serial), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));

Where `hdmi_tx_p[0]` and `hdmi_tx_n[0]` are the differential output pins for TMDS channel 0.

You can see an example of this in the [DVI TMDS demo](/rtl/demo/display_demo_dvi.v).
