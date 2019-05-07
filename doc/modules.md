# Project F Display Controller Modules

_Work in progress..._

See [README](/README.md) for other documentation.

## Summary
* **[display_clocks](hdl/display_clocks.v)** - pixel and high-speed clocks for TMDS (includes Xilinx MMCM)
* **[display_timings](hdl/display_timings.v)** - generates display timings, including horizontal and vertical sync
* **[dvi_generator](hdl/dvi_generator.v)** - uses `serializer_10to1` and `tmds_encode_dvi` to generate a DVI signal
* **[serializer_10to1](hdl/serializer_10to1.v)** - serializes the 10-bit TMDS data (includes Xilinx OSERDESE2)
* **[tmds_encoder_dvi](hdl/tmds_encoder_dvi.v)** - encodes 8-bit per colour into 10-bit TMDS values for DVI

You need a _top_ module to operate the display controller; the project includes [demo](hdl/demo) versions for different display interfaces. When performing TMDS encoding on FPGA, the top module makes use of the Xilinx OBUFDS buffer to generate the differential output. See [demos](#demos) for details.

### Display Timings
To create your own graphics you generally want to use the pixel position output from `display_timings`. You can see an example instance of this module in the [demos](#demos).

#### I/O
* `i_pixclk`
* `i_rst`
* `o_hs`
* `o_vs`
* `o_de`
* `o_frame`
* `o_h`
* `o_v`
* `o_x`
* `o_y`

#### Parameters
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

### Module Parameters

#### Display Clocks
* `MULT_MASTER` - multiplication for both output clocks
* `DIV_MASTER` - division for both output clocks
* `DIV_5X` - division for SerDes clock
* `DIV_1X` - division for pixel clock
* `IN_PERIOD` - period of input clock in nanoseconds (ns)

#### Test Card & Test Card Simple
* `H_RES` - horizontal test card resolution in pixels 
* `V_RES` - vertical test card resolution in lines 
