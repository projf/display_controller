# Porting the Display Controller

We strive to create generic HDL designs where possible. However, vendor-specific components are critical to certain functionality, such as high-speed clock generation. The display controller uses three Xilinx-specific components: all display options use the `MMCM` for clock generation, while TMDS encoding on the FPGA requires `OSERDESE2` and `OBUFDS`. Expanded hardware support will be available in future, but in the meantime, we offer the following advice:

* **MMCM** - Mixed-Mode Clock Manager: Replace with the clock or clock synthesizer of your choice, such as PLL. The simplest pixel clock to generate is usually the 40.0 MHz required by 800x600 60 Hz. Some of the pixel clocks are quite hard to generate accurately, which is where the MMCM's support for multiplying and dividing by eighths comes in handy, for example: `74.25 MHz = 100 MHz * 37.125 / 50`. Analogue VGA is relatively tolerant of inaccurate clock frequencies; DVI and HDMI much less so.
* **OSERDESE2** - SerDes: TMDS requires 10:1 serialization, which is supported by chaining two OSERDESE2 together. SerDes is generally the hardest part to port as FPGAs vary enormously in their capabilities. If native 10:1 serialization isn't available you can sometimes make use of logic designed for DDR memory or divide serialization into two 5-bit steps. Only needed for on-FPGA TMDS generation.
* **OBUFDS** - Differential Signalling: Provided your FPGA has at least four pairs of DS pins you should easily be able to use this design. Only needed for on-FPGA TMDS generation.

See [modules](modules.md) for the interfaces and parameters of the display controller modules. See [README](/README.md) for other documentation.

