`timescale 1ns/1ps
`default_nettype none

// Fixed-point, simulation-oriented model of a fully differential EEG AFE.
// All signal values are signed integer microvolts.  This model is used to
// establish the architecture and verification limits before transistor-level
// implementation in xschem/ngspice.
module eeg_diff_afe_model #(
    parameter integer VCM_UV            = 900000,
    parameter integer GAIN              = 32,
    parameter integer CM_LEAK_PPM       = 32,   // about 90 dB CMRR
    parameter integer SERVO_SHIFT       = 14,
    parameter integer OUTPUT_LIMIT_UV   = 800000
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire signed [31:0]       vin_p_uv,
    input  wire signed [31:0]       vin_n_uv,
    output reg  signed [31:0]       vout_diff_uv,
    output reg  signed [31:0]       input_referred_ac_uv,
    output reg  signed [31:0]       servo_estimate_uv,
    output reg                      saturated
);
    reg signed [63:0] raw_diff_uv;
    reg signed [63:0] raw_cm_error_uv;
    reg signed [63:0] cm_to_diff_uv;
    reg signed [63:0] afe_input_uv;
    reg signed [63:0] ac_uv;
    reg signed [63:0] amplified_uv;
    reg signed [63:0] servo_accum_q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vout_diff_uv        <= 0;
            input_referred_ac_uv <= 0;
            servo_estimate_uv   <= 0;
            servo_accum_q       <= 0;
            saturated           <= 1'b0;
        end else begin
            raw_diff_uv     = $signed(vin_p_uv) - $signed(vin_n_uv);
            raw_cm_error_uv = (($signed(vin_p_uv) + $signed(vin_n_uv)) >>> 1)
                              - VCM_UV;
            cm_to_diff_uv   = (raw_cm_error_uv * CM_LEAK_PPM) / 1000000;
            afe_input_uv    = raw_diff_uv + cm_to_diff_uv;

            // Digital representation of an analog DC-servo loop.  The pole is
            // approximately fs/(2*pi*2^SERVO_SHIFT).
            // Keep fractional state in Q(SERVO_SHIFT) form.  Without this,
            // integer truncation would leave a false residual near 2^shift uV.
            servo_accum_q <= servo_accum_q
                             + (((afe_input_uv <<< SERVO_SHIFT) - servo_accum_q)
                                >>> SERVO_SHIFT);
            servo_estimate_uv <= servo_accum_q >>> SERVO_SHIFT;
            ac_uv          = afe_input_uv - (servo_accum_q >>> SERVO_SHIFT);
            amplified_uv   = ac_uv * GAIN;
            input_referred_ac_uv <= ac_uv[31:0];

            if (amplified_uv > OUTPUT_LIMIT_UV) begin
                vout_diff_uv <= OUTPUT_LIMIT_UV;
                saturated    <= 1'b1;
            end else if (amplified_uv < -OUTPUT_LIMIT_UV) begin
                vout_diff_uv <= -OUTPUT_LIMIT_UV;
                saturated    <= 1'b1;
            end else begin
                vout_diff_uv <= amplified_uv[31:0];
                saturated    <= 1'b0;
            end
        end
    end
endmodule

`default_nettype wire
