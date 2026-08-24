`timescale 1ns/1ps
`default_nettype none

module soc_limit_calculator_tb;

    logic [7:0] soc_data;
    logic       data_valid;

    logic [7:0] soc_limit_level;
    logic       soc_range_err;

    integer error_count;

    // テスト対象のインスタンス
    soc_limit_calculator dut (
        .soc_data        (soc_data),
        .data_valid      (data_valid),
        .soc_limit_level (soc_limit_level),
        .soc_range_err   (soc_range_err)
    );

    // 1ケース分の確認処理
    task automatic check_case (
        input logic       test_valid,
        input logic [7:0] test_soc,
        input logic [7:0] expected_limit,
        input logic       expected_err
    );
        begin
            data_valid = test_valid;
            soc_data   = test_soc;

            // 組合せ回路の出力が更新されるまで待つ
            #1;

            if ((soc_limit_level !== expected_limit) ||
                (soc_range_err   !== expected_err)) begin

                $display(
                    "ERROR: valid=%0b soc=%0d | limit=%0d expected=%0d | err=%0b expected=%0b",
                    data_valid,
                    soc_data,
                    soc_limit_level,
                    expected_limit,
                    soc_range_err,
                    expected_err
                );

                error_count = error_count + 1;
            end
            else begin
                $display(
                    "PASS : valid=%0b soc=%0d -> limit=%0d err=%0b",
                    data_valid,
                    soc_data,
                    soc_limit_level,
                    soc_range_err
                );
            end
        end
    endtask

    integer i;

    initial begin
        error_count = 0;

        $dumpfile("soc_limit_calculator_tb.vcd");
        $dumpvars(0, soc_limit_calculator_tb);

        // -------------------------------------------------
        // data_valid = 0 の全256通り
        // soc_dataの値にかかわらず、
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

            // SOC 0～85.0%
            if (i <= 170) begin
                check_case(
                    1'b1,
                    i,
                    8'd100,
                    1'b0
                );
            end

            // SOC 85.5～94.5%
            else if (i < 190) begin
                check_case(
                    1'b1,
                    i,
                    (190 - i) * 5,
                    1'b0
                );
            end

            // SOC 95.0～100%
            else if (i <= 200) begin
                check_case(
                    1'b1,
                    i,
                    8'd0,
                    1'b0
                );
            end

            // SOC入力範囲外
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