`timescale 1ns/1ps
`default_nettype none

module temp_limit_calculator_tb;

    logic [7:0] temp_data;
    logic       data_valid;

    logic [7:0] temp_limit_level;
    logic       temp_range_err;

    integer error_count;

    // テスト対象のインスタンス
    temp_limit_calculator dut (
        .temp_data        (temp_data),
        .data_valid       (data_valid),
        .temp_limit_level (temp_limit_level),
        .temp_range_err   (temp_range_err)
    );

    // 1ケース分の確認処理
    task automatic check_case (
        input logic       test_valid,
        input logic [7:0] test_temp,
        input logic [7:0] expected_limit,
        input logic       expected_err
    );
        begin
            data_valid = test_valid;
            temp_data  = test_temp;

            // 組合せ回路の出力が更新されるまで待つ
            #1;

            if ((temp_limit_level !== expected_limit)
                || (temp_range_err !== expected_err)) begin

                $display(
                     "FAIL : valid=%0d temp=%0d -> limit=%0d err=%0d (expected limit=%0d err=%0d)",
                    test_valid,
                    test_temp,
                    temp_limit_level,
                    temp_range_err,
                    expected_limit,
                    expected_err
                );
                error_count = error_count + 1;

            end
            else begin

                $display(
                    "PASS : valid=%0d temp=%0d -> limit=%0d err=%0d",
                    test_valid,
                    test_temp,
                    temp_limit_level,
                    temp_range_err
                );

            end
        end
    endtask


    initial begin

        $dumpfile("temp_limit_calculator_tb.vcd");
        $dumpvars(0, temp_limit_calculator_tb);

        error_count = 0;
        temp_data   = 8'd0;
        data_valid  = 1'b0;

        #1;


        // ============================================================
        // data_valid = 0
        // ============================================================

        check_case(1'b0, 8'd0,   8'd0, 1'b0);
        check_case(1'b0, 8'd255, 8'd0, 1'b0);


        // ============================================================
        // -40℃ ～ -20℃
        // temp_data = 0 ～ 20
        // 制限レベル = 0
        // ============================================================

        check_case(1'b1, 8'd0,  8'd0, 1'b0);  // -40℃
        check_case(1'b1, 8'd19, 8'd0, 1'b0);  // -21℃
        check_case(1'b1, 8'd20, 8'd0, 1'b0);  // -20℃


        // ============================================================
        // -20℃ ～ 0℃
        // 1℃あたり +2
        // ============================================================

        check_case(1'b1, 8'd21, 8'd2,  1'b0); // -19℃
        check_case(1'b1, 8'd30, 8'd20, 1'b0); // -10℃
        check_case(1'b1, 8'd39, 8'd38, 1'b0); // -1℃
        check_case(1'b1, 8'd40, 8'd40, 1'b0); // 0℃


        // ============================================================
        // 0℃ ～ 20℃
        // 0℃時40、1℃あたり +3
        // ============================================================

        check_case(1'b1, 8'd41, 8'd43,  1'b0); // 1℃
        check_case(1'b1, 8'd50, 8'd70,  1'b0); // 10℃
        check_case(1'b1, 8'd59, 8'd97,  1'b0); // 19℃
        check_case(1'b1, 8'd60, 8'd100, 1'b0); // 20℃


        // ============================================================
        // 20℃ ～ 45℃
        // 制限レベル = 100
        // ============================================================

        check_case(1'b1, 8'd61, 8'd100, 1'b0); // 21℃
        check_case(1'b1, 8'd70, 8'd100, 1'b0); // 30℃
        check_case(1'b1, 8'd84, 8'd100, 1'b0); // 44℃
        check_case(1'b1, 8'd85, 8'd100, 1'b0); // 45℃


        // ============================================================
        // 45℃ ～ 50℃
        // 1℃あたり -20
        // ============================================================

        check_case(1'b1, 8'd86, 8'd80, 1'b0); // 46℃
        check_case(1'b1, 8'd87, 8'd60, 1'b0); // 47℃
        check_case(1'b1, 8'd88, 8'd40, 1'b0); // 48℃
        check_case(1'b1, 8'd89, 8'd20, 1'b0); // 49℃
        check_case(1'b1, 8'd90, 8'd0,  1'b0); // 50℃


        // ============================================================
        // 50℃ ～ 125℃
        // 制限レベル = 0
        // ============================================================

        check_case(1'b1, 8'd91,  8'd0, 1'b0); // 51℃
        check_case(1'b1, 8'd100, 8'd0, 1'b0); // 60℃
        check_case(1'b1, 8'd165, 8'd0, 1'b0); // 125℃


        // ============================================================
        // 範囲外
        // temp_data = 166 ～ 255
        // ============================================================

        check_case(1'b1, 8'd166, 8'd0, 1'b1);
        check_case(1'b1, 8'd200, 8'd0, 1'b1);
        check_case(1'b1, 8'd255, 8'd0, 1'b1);


        // ============================================================
        // テスト結果
        // ============================================================

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