`timescale 1ns/1ps
`default_nettype none

// Architecture-level second-order, one-bit sigma-delta modulator.
// Input is signed Q1.23. Integrator widths include guard bits.
module sigma_delta_modulator_2nd (
    input  wire                clk,
    input  wire                rst_n,
    input  wire signed [23:0]  input_q23,
    output reg                 bitstream
);
    localparam signed [39:0] FS = 40'sd8388607;
    wire signed [39:0] x = {{16{input_q23[23]}}, input_q23};
    reg signed [39:0] i1;
    reg signed [39:0] i2;
    wire signed [39:0] fb = bitstream ? FS : -FS;
    wire signed [39:0] next_i1 = i1 + x - fb;
    wire signed [39:0] next_i2 = i2 + next_i1 - fb;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i1 <= 0; i2 <= 0; bitstream <= 1'b0;
        end else begin
            i1 <= next_i1;
            i2 <= next_i2;
            bitstream <= (next_i2 >= 0);
        end
    end
endmodule

`default_nettype wire
