`timescale 1ns/1ps
`default_nettype none

module soh_limit_calculator_tb;

    logic [7:0] soh_data;
    logic       data_valid;

    logic [7:0] soh_limit_level;
    logic       soh_range_err;

    integer error_count;

    // テスト対象のインスタンス
    soh_limit_calculator dut (
        .soh_data        (soh_data),
        .data_valid      (data_valid),
        .soh_limit_level (soh_limit_level),
        .soh_range_err   (soh_range_err)
    );

    // 1ケース分の確認処理
    task automatic check_case (
        input logic       test_valid,
        input logic [7:0] test_soh,
        input logic [7:0] expected_limit,
        input logic       expected_err
    );
        begin
            data_valid = test_valid;
            soh_data   = test_soh;

            // 組合せ回路の出力が更新されるまで待つ
            #1;

            if ((soh_limit_level !== expected_limit) ||
                (soh_range_err   !== expected_err)) begin

                $display(
                    "ERROR: valid=%0b soh=%0d | limit=%0d expected=%0d | err=%0b expected=%0b",
                    data_valid,
                    soh_data,
                    soh_limit_level,
                    expected_limit,
                    soh_range_err,
                    expected_err
                );

                error_count = error_count + 1;
            end
            else begin
                $display(
                    "PASS : valid=%0b soh=%0d -> limit=%0d err=%0b",
                    data_valid,
                    soh_data,
                    soh_limit_level,
                    soh_range_err
                );
            end
        end
    endtask

    integer i;

    initial begin
        error_count = 0;

        $dumpfile("soh_limit_calculator_tb.vcd");
        $dumpvars(0, soh_limit_calculator_tb);

        // -------------------------------------------------
        // data_valid = 0 の全256通り
        // soh_dataの値にかかわらず、
        // limit=0、range_err=0であることを確認する
        // -------------------------------------------------
        for (i = 0; i < 256; i = i + 1) begin
            check_case(
                1'b0,
                i,
                8'd0,
                1'b0
            );
        end

        // -------------------------------------------------
        // data_valid = 1 の全256通り
        // -------------------------------------------------
        for (i = 0; i < 256; i = i + 1) begin

            // SOH 0～60.0%
            if (i <= 120) begin
                check_case(
                    1'b1,
                    i,
                    8'd0,
                    1'b0
                );
            end

            // SOH 60.5～79.5%
            else if (i < 160) begin
                check_case(
                    1'b1,
                    i,
                    ((i - 120) * 5) /2,
                    1'b0
                );
            end

            // SOH 80.0～100%
            else if (i <= 200) begin
                check_case(
                    1'b1,
                    i,
                    8'd100,
                    1'b0
                );
            end

            // SOH入力範囲外
            else begin
                check_case(
                    1'b1,
                    i,
                    8'd0,
                    1'b1
                );
            end
        end

        if (error_count == 0) begin
            $display("--------------------------------");
            $display("ALL 512 TESTS PASSED");
            $display("--------------------------------");
        end
        else begin
            $fatal(1, "%0d test(s) failed.", error_count);
        end

        $finish;
    end

endmodule

`default_nettype wire