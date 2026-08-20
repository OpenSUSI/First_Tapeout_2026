`timescale 1ns/1ps
`default_nettype none

module sigma_delta_adc_tb;
    localparam integer OSR = 65536;
    localparam integer TOLERANCE = 300;

    reg clk = 1'b0;
    reg rst_n = 1'b1;
    reg start = 1'b0;
    reg signed [23:0] analog_in_q23 = 24'sd0;
    wire busy;
    wire data_valid;
    wire [23:0] adc_code;
    wire sd_bit;

    reg spi_cs_n = 1'b1;
    reg spi_sclk = 1'b0;
    wire spi_sdata;

    integer failures = 0;
    integer vector_index;
    reg [23:0] spi_word;

    sigma_delta_adc_io #(.OSR(OSR)) dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .analog_in_q23(analog_in_q23),
        .busy(busy), .data_valid(data_valid), .adc_code(adc_code),
        .sd_bit(sd_bit), .spi_cs_n(spi_cs_n), .spi_sclk(spi_sclk),
        .spi_sdata(spi_sdata)
    );

    always #5 clk = ~clk;

    task read_spi;
        integer bit_index;
        begin
            spi_word = 24'd0;
            spi_cs_n = 1'b0;
            #2;
            for (bit_index = 23; bit_index >= 0; bit_index = bit_index - 1) begin
                spi_word[bit_index] = spi_sdata;
                #2 spi_sclk = 1'b1;
                #2 spi_sclk = 1'b0;
            end
            spi_cs_n = 1'b1;
            #4;
        end
    endtask

    task convert_and_check;
        input signed [23:0] input_code;
        input [23:0] expected_code;
        integer error_codes;
        begin
            analog_in_q23 = input_code;
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            wait (data_valid === 1'b1);

            error_codes = $signed({1'b0, adc_code}) - $signed({1'b0, expected_code});
            if (error_codes < 0)
                error_codes = -error_codes;

            read_spi();
            $display("VIN_Q23=%0d ADC=0x%06h EXPECT=0x%06h ERROR=%0d SPI=0x%06h",
                     input_code, adc_code, expected_code, error_codes, spi_word);
            if (error_codes > TOLERANCE) begin
                $display("ERROR: conversion outside tolerance");
                failures = failures + 1;
            end
            if (spi_word !== adc_code) begin
                $display("ERROR: SPI readback mismatch");
                failures = failures + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sigma_delta_adc.vcd");
        $dumpvars(0, sigma_delta_adc_tb);
        #1 rst_n = 1'b0;
        repeat (5) @(negedge clk);
        rst_n = 1'b1;

        convert_and_check(-24'sd6291455, 24'h200000); // -0.75 FS
        convert_and_check(-24'sd2097152, 24'h600000); // -0.25 FS
        convert_and_check( 24'sd0,       24'h800000); //  0.00 FS
        convert_and_check( 24'sd2097152, 24'hA00000); // +0.25 FS
        convert_and_check( 24'sd6291455, 24'hE00000); // +0.75 FS

        if (failures == 0) begin
            $display("PASS: all ADC transfer and SPI IO checks passed");
            $finish;
        end else begin
            $fatal(1, "FAIL: %0d checks failed", failures);
        end
    end
endmodule

`default_nettype wire
