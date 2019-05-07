# Display Controller Modules

The display controller is a set of five core modules. This document explains their interfaces and parameters for the three you interact with: `display_clocks`, `display_timings` and `dvi_generator`. The other two modules are used by `dvi_generator`.

* **[display_clocks](/hdl/display_clocks.v)** - pixel and high-speed clocks for TMDS 
* **[display_timings](/hdl/display_timings.v)** - generates display timings, including horizontal and vertical sync
* **[dvi_generator](/hdl/dvi_generator.v)** - uses `serializer_10to1` and `tmds_encode_dvi` to generate a DVI signal

See [architecture](/README.md#Architecture) for an overview of the two different signal paths.

You can see examples of these modules being used in the [demos](/hdl/demo) and [test benches](/hdl/test).
See [README](/README.md) for more documentation.


## Contents

- [Display Clocks](#display-clocks)
- [Display Timings](#display-timings)
- [DVI Generator](#dvi-generator)


## Display Clocks

Timing is everything when it comes to working with screens. Everything marches in step with the pixel clock: we need to generate this before we can do anything else. For example, 1280x720p60 uses a pixel clock of 74.25 MHz, which means each pixel is 13.5 ns long. This module generates a high-quality pixel clock using the mixed-mode clock manager (MMCM). When doing our own SerDes, we also need a 5x pixel clock; we provide this too.

### Inputs

* `i_clk` - input clock
* `i_rst` - reset (active high)

The `IN_PERIOD` parameter (below) must match the frequency of the input clock.

### Outputs

* `o_clk_1x` - pixel clock
* `o_clk_5x` - 5x clock for 10:1 DDR SerDes
* `o_locked` - clock locked? (active high)

You shouldn't use the clocks until the locked signal is high. You can safely ignore the `o_clk_5x` output if you don't need it.

### Parameters

* `MULT_MASTER` - multiplication for both output clocks
* `DIV_MASTER` - division for both output clocks
* `DIV_5X` - division for 5x (SerDes) clock
* `DIV_1X` - division for pixel clock
* `IN_PERIOD` - period of input clock in nanoseconds (ns)

The `IN_PERIOD` needs to match the input clock `i_clk`. For example, a 100 MHz clock has a 10 ns period, so `IN_PERIOD` would be 10.

The output clocks are calculated as follows:

    o_clk_1x = (i_clk * MULT_MASTER / DIV_MASTER) / DIV_1X
    o_clk_5x = (i_clk * MULT_MASTER / DIV_MASTER) / DIV_5X

For example, 720p60:

    74.25 MHz = (100 MHz * 37.125 / 5) / 10
    371.25 MHz = (100 MHz * 37.125 / 5) / 2

The [demos](/hdl/demo) modules include appropriate parameters for four common pixel clock to get you started.


## Display Timings
The heart of the display controller is the display timings generator. This turns timing parameters into appropriately timed sync pulses and provides the current screen co-ordinates.

### Inputs

* `i_pixclk` - pixel clock
* `i_rst` - reset (active high)

The pixel clock must be suitable for the timings given in the parameters (see display clocks, above). 

### Outputs

* `o_hs` - horizontal sync
* `o_vs` - vertical sync
* `o_de` - display enable: high during active video
* `o_frame` - high for one tick at the start of each frame
* `o_h` - horizontal beam position (including blanking)
* `o_v` - vertical beam position (including blanking)
* `o_x` - horizontal screen position (active pixels)
* `o_y` - vertical screen position (active pixels)

The positional outputs `(h,v)` and `(x,y)` allow you to determine the current pixel AKA "beam position". The values provided by `h` & `v `include the blanking interval, while `x` & `y` only include valid on screen positions. For simple drawing or bitmap display you can use `(x,y)` and safely ignore `(h,v)`. However, if you're doing calculations in real time "racing the beam", then you'll want to perform actions in the blanking interval, which is where (h,v) comes in.

The following sketch shows how (x,y) relates to (h,v) for 1280x720p60:

![](display-controller-hv-xy.jpg?raw=true "")

NB. 'x' and 'y' are 0 during the blanking interval.

Horizontal and vertical sync may be active high or low, depending on the display mode. This is controlled using the `H_POL` and `V_POL` parameters (below).

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

The [demos](/hdl/demo) modules include appropriate parameters for four common resolutions.


## DVI Generator

_Details being added..._

* **[serializer_10to1](/hdl/serializer_10to1.v)** - serializes the 10-bit TMDS data
* **[tmds_encoder_dvi](/hdl/tmds_encoder_dvi.v)** - encodes 8-bit per colour into 10-bit TMDS values for DVI

