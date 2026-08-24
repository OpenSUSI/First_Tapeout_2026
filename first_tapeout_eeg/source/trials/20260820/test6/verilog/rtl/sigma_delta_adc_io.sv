`timescale 1ns/1ps
`default_nettype none

// Behavioral 24-bit sigma-delta ADC demonstrator.
// analog_in_q23 is a signed Q1.23 proxy for a differential analog input:
//   -8388607 = -full-scale, 0 = common mode, +8388607 = +full-scale.
// The first-order 1-bit loop is averaged for OSR clocks and scaled to a
// 24-bit offset-binary output.  It is intended for mixed-signal/IO simulation,
// not as a claim of 24-bit ENOB silicon performance.
module sigma_delta_adc_io #(
    parameter integer OSR = 65536
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    start,
    input  wire signed [23:0]      analog_in_q23,
    output reg                     busy,
    output reg                     data_valid,
    output reg        [23:0]       adc_code,
    output reg                     sd_bit,

    input  wire                    spi_cs_n,
    input  wire                    spi_sclk,
    output wire                    spi_sdata
);
    localparam signed [63:0] FULL_SCALE = 64'sd8388607;

    reg signed [63:0] integrator;
    reg        [31:0] sample_count;
    reg        [31:0] ones_count;

    reg        [4:0]  spi_count;

    wire signed [63:0] input_ext = {{40{analog_in_q23[23]}}, analog_in_q23};
    wire signed [63:0] feedback  = sd_bit ? FULL_SCALE : -FULL_SCALE;
    wire signed [63:0] next_integrator = integrator + input_ext - feedback;
    wire               next_bit = (next_integrator >= 0);
    wire        [31:0] final_ones = ones_count + (next_bit ? 1 : 0);
    wire        [63:0] final_ones_ext = {32'd0, final_ones};
    wire        [63:0] scaled_code =
        (final_ones_ext * 64'd16777215) / OSR;

    // Conversion path. A complete result is emitted once per OSR clocks.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy         <= 1'b0;
            data_valid   <= 1'b0;
            adc_code     <= 24'h800000;
            sd_bit       <= 1'b0;
            integrator   <= 64'sd0;
            sample_count <= 32'd0;
            ones_count   <= 32'd0;
        end else begin
            data_valid <= 1'b0;
            if (start && !busy) begin
                busy         <= 1'b1;
                integrator   <= 64'sd0;
                sample_count <= 32'd0;
                ones_count   <= 32'd0;
                sd_bit       <= 1'b0;
            end else if (busy) begin
                integrator <= next_integrator;
                sd_bit     <= next_bit;
                if (next_bit)
                    ones_count <= ones_count + 1'b1;

                if (sample_count == OSR - 1) begin
                    // For OSR=65536 this is exactly final_ones * 256, with
                    // saturation so +FS maps to 0xFFFFFF instead of wrapping.
                    if (final_ones >= OSR)
                        adc_code <= 24'hFFFFFF;
                    else
                        adc_code <= scaled_code[23:0];
                    busy         <= 1'b0;
                    data_valid   <= 1'b1;
                end else begin
                    sample_count <= sample_count + 1'b1;
                end
            end
        end
    end

    // Simple mode-0-like readout: assert CS low, then sample MSB first before
    // each rising SCLK edge. CS high resets the bit counter for the next word.
    assign spi_sdata = (!spi_cs_n && spi_count < 24)
                     ? adc_code[23 - spi_count] : 1'b0;
    always @(posedge spi_sclk or posedge spi_cs_n or negedge rst_n) begin
        if (!rst_n || spi_cs_n) begin
            spi_count <= 5'd0;
        end else begin
            if (spi_count < 5'd24)
                spi_count <= spi_count + 1'b1;
        end
    end
endmodule

`default_nettype wire
