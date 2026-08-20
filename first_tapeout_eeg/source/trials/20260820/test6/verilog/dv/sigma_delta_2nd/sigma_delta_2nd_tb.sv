`timescale 1ns/1ps
`default_nettype none
module sigma_delta_2nd_tb;
    localparam integer OSR=1024;
    reg clk=0, rst_n=0;
    reg signed [23:0] input_q23;
    wire bitstream;
    integer i, ones, failures=0;
    reg signed [63:0] expected, error;
    always #5 clk=~clk;
    sigma_delta_modulator_2nd dut(.clk(clk),.rst_n(rst_n),
        .input_q23(input_q23),.bitstream(bitstream));

    task measure;
        input integer stimulus;
        begin
            input_q23=stimulus; rst_n=0; repeat(4) @(posedge clk); rst_n=1;
            repeat(OSR) @(posedge clk); // discard startup transient
            ones=0;
            for(i=0;i<OSR;i=i+1) begin @(posedge clk); if(bitstream) ones=ones+1; end
            expected=64'sd512 + ($signed(stimulus) * 64'sd1024) / 64'sd16777214;
            error=ones-expected; if(error<0) error=-error;
            if(error>8) begin $display("FAIL input=%0d ones=%0d expected=%0d",stimulus,ones,expected); failures=failures+1; end
            else $display("PASS input=%0d ones=%0d expected=%0d",stimulus,ones,expected);
        end
    endtask
    initial begin
        measure(-4194304); measure(-1048576); measure(0);
        measure(1048576); measure(4194304);
        if(failures) $fatal(1,"SIGMA_DELTA_2ND_TEST: FAIL");
        $display("SIGMA_DELTA_2ND_TEST: PASS"); $finish;
    end
endmodule
`default_nettype wire
