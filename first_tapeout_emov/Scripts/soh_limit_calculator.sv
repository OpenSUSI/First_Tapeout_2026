`timescale 1ns/1ps
`default_nettype none

module soh_limit_calculator(
    input logic [7:0] soh_data,
    input logic       data_valid,

    output logic [7:0] soh_limit_level,
    output logic       soh_range_err
);

    //SOHは0.5%単位で実装する
    //60% x 2 = 120
    //80% x 2 = 160 
    //100% x 2 = 200

    localparam logic [7:0] SOH_LINEAR_START = 8'd120; //60%
    localparam logic [7:0] SOH_LINEAR_END  = 8'd160;  //80%
    localparam logic [7:0] SOH_VALID_MAX   = 8'd200;  //100%

    localparam logic [7:0] LIMIT_FULL      = 8'd100;
    localparam logic [7:0] LIMIT_ZERO      = 8'd0;

    //SOH特性ブロックは組み合わせ回路
    always_comb begin

        // デフォルト値
        // 未受信時や異常時に安全側となる値を設定する
        soh_limit_level = LIMIT_ZERO;
        soh_range_err   = 1'b0;

        // 優先順位1：入力データ未受信
        if (!data_valid) begin
            soh_limit_level = LIMIT_ZERO;
            soh_range_err   = 1'b0;
        end

        // 優先順位2：SOH入力範囲外
        else if (soh_data > SOH_VALID_MAX) begin
            soh_limit_level = LIMIT_ZERO;
            soh_range_err   = 1'b1;
        end

        // SOH 60%以下：回生禁止
        else if (soh_data <= SOH_LINEAR_START) begin
            soh_limit_level = LIMIT_ZERO;
            soh_range_err   = 1'b0;
        end

        // SOH 60%超～80%未満：線形増加
        else if (soh_data < SOH_LINEAR_END) begin
            soh_limit_level = ((soh_data - SOH_LINEAR_START) * 8'd5) >> 1;
            soh_range_err = 1'b0;
        end

        // SOH 80%以上：SOHによる回生制限なし
        // ここへ来るsoh_dataは160～200
        else begin
            soh_limit_level = LIMIT_FULL;
            soh_range_err   = 1'b0;
        end

    end

endmodule

`default_nettype wire