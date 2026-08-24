SIM ?= iverilog
RTL := ../../rtl/sigma_delta_adc_io.sv
TB  := sigma_delta_adc_tb.sv

.PHONY: all sim clean

all: sim

sim:
	$(SIM) -g2012 -Wall -o sigma_delta_adc.vvp $(RTL) $(TB)
	vvp sigma_delta_adc.vvp

clean:
	rm -f sigma_delta_adc.vvp sigma_delta_adc.vcd
