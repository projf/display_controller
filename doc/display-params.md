# Display Parameters

The display controller includes configuration for four resolutions, all at 60 Hz: 640x480, 800x600, 1280x720, and 1920x1080. This document includes the coordinates, timings, and clocks, for these resolutions.

## Contents

- **[Screen Coordinates](#screen-coordinates)**
- **[Display Timings](#display-timings)**
- **[Display Clocks](#display-clocks)**

See [README](/README.md) and [modules](modules.md) for more documentation.

## Screen Coordinates

Project F uses 16-bit signed integers (two's complement) to represent screen coordinates. Blanking intervals, which have negative coordinates, proceed the active screen area, which starts at (0,0).

| Resolution  | Blanking Begins            | Active Ends                 |
|-------------|----------------------------|-----------------------------|
|  640 x  480 | (-160,-45) (0xFF60,0xFFD3) | ( 639, 479) (0x027F,0x01DF) |
|  800 x  600 | (-256,-28) (0xFF00,0xFFE4) | ( 799, 599) (0x031F,0x0257) |
| 1280 x  720 | (-370,-30) (0xFE8E,0xFFE2) | (1279, 719) (0x04FF,0x02CF) |
| 1920 x 1080 | (-280,-45) (0xFEE8,0xFFD3) | (1919,1079) (0x077F,0x0437) |

Hex values in this table are useful when debugging or writing assembler. For example, you can pack the vertical and horizontal position into a 32-bit value: 0x001FFF60 would be line 31 (1F) and pixel -160 (0xFF60).

The following diagram illustrates the coordinate system for a 1280x720p60 display:

![](display-timings.png?raw=true "")

## Display Timings

Video timings are a complex area with several different specifications; for example, VESA Coordinated Video Timings (CVT) includes four variants for common HD resolutions. This document won't go into all the variants; instead, we provide conservative timings that should work with all displays. These timings are based on VESA DMT v1.3 (available from [vesa.org](https://vesa.org/vesa-standards/)) and CTA-861-G (available from [cta.tech](https://cta.tech/Research-Standards/Standards.aspx)).

See the [display_timings](modules.md#display-timings) module for details on using these parameters.

| Parameter  |  640 x  480 |  800 x  600 | 1280 x  720 | 1920 x 1080 |
|------------|-------------|-------------|-------------|-------------|
| Standard   |  Historical |    VESA DMT |   CTA-770.3 |  SMPTE 274M |
| H_RES      |         640 |         800 |        1280 |        1920 |
| V_RES      |         480 |         600 |         720 |        1080 |
| H_FP       |          16 |          40 |         110 |          88 |
| H_SYNC     |          96 |         128 |          40 |          44 |
| H_BP       |          48 |          88 |         220 |         148 |
| V_FP       |          10 |           1 |           5 |           4 |
| V_SYNC     |           2 |           4 |           5 |           5 |
| V_BP       |          33 |          23 |          20 |          36 |
| H_POL      |           0 |           1 |           1 |           1 |
| V_POL      |           0 |           1 |           1 |           1 |

_FP: front porch, BP: back porch, POL: polarity (0 is negative, 1 is positive)._

## Display Clocks

This table provides parameters for generating suitable pixel and TMDS clocks using the included [display_clocks](modules.md#display-clocks) module or directly with the Xilinx Mixed-Mode Clock Manager (MMCM). The second clock is five times the pixel clock because the display controller uses double data rate (DDR) SerDes to generate TMDS.

| Parameter      |  640 x  480 |  800 x  600 | 1280 x  720 | 1920 x 1080 |
|----------------|-------------|-------------|-------------|-------------|
| 1X Clock (MHz) |        25.2 |          40 |       74.25 |       148.5 |
| 5X Clock (MHz) |         126 |         200 |      371.25 |       742.5 |
| MULT_MASTER    |        31.5 |        10.0 |      37.125 |      37.125 |
| DIV_MASTER     |           5 |           1 |           5 |           5 |
| DIV_5X         |         5.0 |         5.0 |         2.0 |         1.0 |
| DIV_1X         |          25 |          25 |          10 |           5 |

_NB. The canonical clock for 640x480 60Hz is 25.175 MHz, but 25.2 MHz is within VESA spec and simpler to generate._
