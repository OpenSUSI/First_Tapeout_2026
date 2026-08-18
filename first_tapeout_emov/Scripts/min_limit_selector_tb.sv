`timescale 1ns/1ps
`default_nettype none

module min_limit_selector_tb;

    logic [7:0] soc_limit_level;
    logic [7:0] soh_limit_level;
    logic [7:0] temp_limit_level;

    logic [7:0] selected_limit_level;
    logic [2:0] limit_source_mask;

    integer error_count;

    // テスト対象のインスタンス
    min_limit_selector dut (
        .soc_limit_level      (soc_limit_level),
        .soh_limit_level      (soh_limit_level),
        .temp_limit_level     (temp_limit_level),
        .selected_limit_level (selected_limit_level),
        .limit_source_mask    (limit_source_mask)
    );

    // 1ケース分の確認処理
    task automatic check_case (
        input logic [7:0] test_soc,
        input logic [7:0] test_soh,
        input logic [7:0] test_temp,
        input logic [7:0] expected_limit,
        input logic [2:0] expected_mask
    );
        begin
            soc_limit_level  = test_soc;
            soh_limit_level  = test_soh;
            temp_limit_level = test_temp;

            // 組合せ回路の出力が更新されるまで待つ
            #1;

            if ((selected_limit_level !== expected_limit) ||
                (limit_source_mask !== expected_mask)) begin

                $display(
                    "FAIL : SOC=%0d SOH=%0d TEMP=%0d -> limit=%0d mask=%03b (expected limit=%0d mask=%03b)",
                    test_soc,
                    test_soh,
                    test_temp,
                    selected_limit_level,
                    limit_source_mask,
                    expected_limit,
                    expected_mask
                );

                error_count = error_count + 1;
            end
            else begin
                $display(
                    "PASS : SOC=%0d SOH=%0d TEMP=%0d -> limit=%0d mask=%03b",
                    test_soc,
                    test_soh,
                    test_temp,
                    selected_limit_level,
                    limit_source_mask
                );
            end
        end
    endtask

    initial begin
        $dumpfile("min_limit_selector_tb.vcd");
        $dumpvars(0, min_limit_selector_tb);

        error_count = 0;

        // SOCのみが最小
        check_case(8'd50,  8'd80,  8'd100, 8'd50,  3'b001);
        check_case(8'd0,   8'd50,  8'd100, 8'd0,   3'b001);

        // SOHのみが最小
        check_case(8'd80,  8'd50,  8'd100, 8'd50,  3'b010);
        check_case(8'd100, 8'd0,   8'd50,  8'd0,   3'b010);

        // TEMPのみが最小
        check_case(8'd100, 8'd80,  8'd50,  8'd50,  3'b100);
        check_case(8'd100, 8'd50,  8'd0,   8'd0,   3'b100);

        // SOCとSOHが同じ最小値
        check_case(8'd50,  8'd50,  8'd100, 8'd50,  3'b011);

        // SOCとTEMPが同じ最小値
        check_case(8'd50,  8'd100, 8'd50,  8'd50,  3'b101);

        // SOHとTEMPが同じ最小値
        check_case(8'd100, 8'd50,  8'd50,  8'd50,  3'b110);

        // 3つすべて同じ
        check_case(8'd50,  8'd50,  8'd50,  8'd50,  3'b111);
        check_case(8'd100, 8'd100, 8'd100, 8'd100, 3'b111);

        $display("--------------------------------");

        if (error_count == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("%0d TEST(S) FAILED", error_count);
        end

        $finish;
    end

endmodule

`default_nettype wire