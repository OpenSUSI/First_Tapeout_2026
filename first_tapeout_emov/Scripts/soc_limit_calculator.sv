`timescale 1ns/1ps
`default_nettype none

module soc_limit_calculator (
    input  logic [7:0] soc_data,
    input  logic       data_valid,

    output logic [7:0] soc_limit_level,
    output logic       soc_range_err
);

    // SOCは0.5%単位で表現する
    // 85.0% × 2 = 170
    // 95.0% × 2 = 190
    // 100%  × 2 = 200

    localparam logic [7:0] SOC_LIMIT_START = 8'd170;
    localparam logic [7:0] SOC_REGEN_STOP  = 8'd190;
    localparam logic [7:0] SOC_VALID_MAX   = 8'd200;

    localparam logic [7:0] LIMIT_FULL      = 8'd100;
    localparam logic [7:0] LIMIT_ZERO      = 8'd0;

    // SOC特性ブロックは組合せ回路
    always_comb begin

        // デフォルト値
        // 未受信時や異常時に安全側となる値を設定する
        soc_limit_level = LIMIT_ZERO;
        soc_range_err   = 1'b0;

        // 優先順位1：入力データ未受信
        if (!data_valid) begin
            soc_limit_level = LIMIT_ZERO;
            soc_range_err   = 1'b0;
        end

        // 優先順位2：SOC入力範囲外
        else if (soc_data > SOC_VALID_MAX) begin
            soc_limit_level = LIMIT_ZERO;
            soc_range_err   = 1'b1;
        end

        // SOC 85%以下：SOCによる追加制限なし
        else if (soc_data <= SOC_LIMIT_START) begin
            soc_limit_level = LIMIT_FULL;
            soc_range_err   = 1'b0;
        end

        // SOC 85%超～95%未満：線形減少
        else if (soc_data < SOC_REGEN_STOP) begin
            soc_limit_level =
                (SOC_REGEN_STOP - soc_data) * 8'd5;

            soc_range_err = 1'b0;
        end

        // SOC 95%以上：回生禁止
        // ここへ来るsoc_dataは190～200
        else begin
            soc_limit_level = LIMIT_ZERO;
            soc_range_err   = 1'b0;
        end

    end

endmodule

`default_nettype wire