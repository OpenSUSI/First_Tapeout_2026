`timescale 1ns/1ps
`default_nettype none

module temp_limit_calculator (
    input  logic [7:0] temp_data,
    input  logic       data_valid,

    output logic [7:0] temp_limit_level,
    output logic       temp_range_err
);

    always_comb begin

        // デフォルト値
        temp_limit_level = 8'd0;
        temp_range_err   = 1'b0;

        // 未受信時
        if (!data_valid) begin
            temp_limit_level = 8'd0;
            temp_range_err   = 1'b0;
        end

        // 温度入力コード範囲外
        else if (temp_data > 8'd165) begin
            temp_limit_level = 8'd0;
            temp_range_err   = 1'b1;
        end

        // -40℃ ～ -20℃
        // temp_data = 0 ～ 20
        else if (temp_data <= 8'd20) begin
            temp_limit_level = 8'd0;
        end

        // -20℃ ～ 0℃
        // 1℃あたり +2
        // temp_data=20 -> 0
        // temp_data=40 -> 40
        else if (temp_data <= 8'd40) begin
            temp_limit_level = 8'd2 * (temp_data - 8'd20);
        end

        // 0℃ ～ 20℃
        // 0℃時 40、1℃あたり +3
        // temp_data=40 -> 40
        // temp_data=60 -> 100
        else if (temp_data <= 8'd60) begin
            temp_limit_level = 8'd40 + 8'd3 * (temp_data - 8'd40);
        end

        // 20℃ ～ 45℃
        // 制限なし
        else if (temp_data <= 8'd85) begin
            temp_limit_level = 8'd100;
        end

        // 45℃ ～ 50℃
        // 1℃あたり -20
        // temp_data=85 -> 100
        // temp_data=90 -> 0
        else if (temp_data < 8'd90) begin
            temp_limit_level =
                8'd20 * (8'd90 - temp_data);
        end

        // 50℃ ～ 125℃
        else begin
            temp_limit_level = 8'd0;
        end

    end

endmodule

`default_nettype wire