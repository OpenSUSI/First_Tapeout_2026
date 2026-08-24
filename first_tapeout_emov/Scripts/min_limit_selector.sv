`timescale 1ns/1ps
`default_nettype none

module min_limit_selector (
    input  logic [7:0] soc_limit_level,
    input  logic [7:0] soh_limit_level,
    input  logic [7:0] temp_limit_level,

    output logic [7:0] selected_limit_level,
    output logic [2:0] limit_source_mask
);

    always_comb begin
        // まずSOCを最小値候補とする
        selected_limit_level = soc_limit_level;

        // SOHの方が小さければ更新
        if (soh_limit_level < selected_limit_level) begin
            selected_limit_level = soh_limit_level;
        end

        // 温度の方が小さければ更新
        if (temp_limit_level < selected_limit_level) begin
            selected_limit_level = temp_limit_level;
        end

        // 最小値と一致する要因をすべて記録
        limit_source_mask[0] = (soc_limit_level  == selected_limit_level);
        limit_source_mask[1] = (soh_limit_level  == selected_limit_level);
        limit_source_mask[2] = (temp_limit_level == selected_limit_level);
    end

endmodule

`default_nettype wire