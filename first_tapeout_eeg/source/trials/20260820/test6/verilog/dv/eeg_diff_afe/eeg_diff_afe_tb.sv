`timescale 1ns/1ps
`default_nettype none

module eeg_diff_afe_tb;
    localparam integer VCM_UV = 900000;
    localparam integer GAIN = 32;
    localparam integer CM_LEAK_PPM = 32;
    localparam integer SERVO_SHIFT = 8; // accelerated verification pole

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg signed [31:0] vin_p_uv = VCM_UV;
    reg signed [31:0] vin_n_uv = VCM_UV;
    wire signed [31:0] vout_diff_uv;
    wire signed [31:0] input_referred_ac_uv;
    wire signed [31:0] servo_estimate_uv;
    wire saturated;
    integer failures = 0;
    integer measured;

    always #5 clk = ~clk;

    eeg_diff_afe_model #(
        .VCM_UV(VCM_UV), .GAIN(GAIN), .CM_LEAK_PPM(CM_LEAK_PPM),
        .SERVO_SHIFT(SERVO_SHIFT), .OUTPUT_LIMIT_UV(800000)
    ) dut (
        .clk(clk), .rst_n(rst_n), .vin_p_uv(vin_p_uv),
        .vin_n_uv(vin_n_uv), .vout_diff_uv(vout_diff_uv),
        .input_referred_ac_uv(input_referred_ac_uv),
        .servo_estimate_uv(servo_estimate_uv), .saturated(saturated)
    );

    task reset_dut;
        begin
            rst_n = 0; repeat (4) @(posedge clk); rst_n = 1; @(posedge clk);
        end
    endtask

    task check_range;
        input [8*48-1:0] label;
        input integer value;
        input integer minimum;
        input integer maximum;
        begin
            if ((value < minimum) || (value > maximum)) begin
                $display("FAIL %-30s value=%0d expected=[%0d,%0d]", label,
                         value, minimum, maximum);
                failures = failures + 1;
            end else begin
                $display("PASS %-30s value=%0d", label, value);
            end
        end
    endtask

    initial begin
        $dumpfile("eeg_diff_afe.vcd");
        $dumpvars(0, eeg_diff_afe_tb);

        // Differential gain: 100 uV differential input should produce 3.2 mV.
        vin_p_uv = VCM_UV + 50;
        vin_n_uv = VCM_UV - 50;
        reset_dut();
        repeat (3) @(posedge clk);
        measured = vout_diff_uv;
        check_range("100uV differential gain", measured, 3100, 3250);

        // CMRR: a +100 mV common-mode step leaks about 3 uV input referred.
        vin_p_uv = VCM_UV + 100000;
        vin_n_uv = VCM_UV + 100000;
        reset_dut();
        repeat (3) @(posedge clk);
        measured = input_referred_ac_uv;
        check_range("100mV common-mode leakage", measured, 2, 4);

        // Electrode offset: 100 mV differential DC must be removed by servo.
        vin_p_uv = VCM_UV + 50000;
        vin_n_uv = VCM_UV - 50000;
        reset_dut();
        repeat (4096) @(posedge clk);
        measured = input_referred_ac_uv;
        check_range("100mV offset residual", measured, -10, 10);

        // After settling, a 100 uV change must still be observable.
        vin_p_uv = VCM_UV + 50050;
        vin_n_uv = VCM_UV - 50050;
        repeat (2) @(posedge clk);
        measured = vout_diff_uv;
        check_range("signal after DC servo", measured, 3000, 3300);

        if (failures == 0) begin
            $display("EEG_DIFF_AFE_TEST: PASS");
            $finish;
        end else begin
            $display("EEG_DIFF_AFE_TEST: FAIL (%0d checks)", failures);
            $fatal(1);
        end
    end
endmodule

`default_nettype wire
