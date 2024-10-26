// SPDX-FileCopyrightText: © 2024 Leo Moser <leo.moser@pm.me>
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/1ps
`default_nettype none

module tb;

    initial begin
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
    end

    // Wire up the inputs and outputs:
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Assign to peripherals
    wire [5:0] rrggbb;
    wire hsync;
    wire vsync;
    
    wire spi_sclk;
    wire spi_mosi;
    wire spi_miso;
    wire spi_cs;
    
    wire next_vertical;
    wire next_frame;
    
    wire spi_mode;

    // Output PMOD - Tiny VGA

    assign rrggbb[5:4] = {uo_out[0], uo_out[4]};
    assign rrggbb[3:2] = {uo_out[1], uo_out[5]};
    assign rrggbb[1:0] = {uo_out[2], uo_out[6]};
    
    assign vsync = uo_out[3];
    assign hsync = uo_out[7];
    
    // Bidir PMOD - SPI and additional signals
    
    // Top row - SPI
    assign uio_in[0] = spi_cs;
    assign uio_in[1] = spi_mosi;
    assign spi_miso = uio_out[2];
    assign uio_in[3] = spi_sclk;

    // Bottom row
    assign next_vertical = uio_out[4];
    assign next_frame = uio_out[5];

    // Input PMOD - mode
    
    assign ui_in[0] = spi_mode;
    
    // DUT
    tt_um_top_mole99 tt_um_top_mole99 (
        .ui_in  (ui_in),    // Dedicated inputs
        .uo_out (uo_out),   // Dedicated outputs
        .uio_in (uio_in),   // IOs: Input path
        .uio_out(uio_out),  // IOs: Output path
        .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena    (ena),      // enable - goes high when design is selected
        .clk    (clk),      // clock
        .rst_n  (rst_n)     // not reset
    );

endmodule
