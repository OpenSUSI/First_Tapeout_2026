SIM ?= iverilog
RTL := ../../rtl/sigma_delta_modulator_2nd.sv
TB := sigma_delta_2nd_tb.sv
.PHONY: all sim clean
all: sim
sim:
	$(SIM) -g2012 -Wall -o sigma_delta_2nd.vvp $(RTL) $(TB)
	vvp sigma_delta_2nd.vvp
clean:
	rm -f sigma_delta_2nd.vvp
