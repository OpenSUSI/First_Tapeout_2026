SIM ?= iverilog
RTL := ../../rtl/eeg_diff_afe_model.sv
TB  := eeg_diff_afe_tb.sv

.PHONY: all sim clean
all: sim

sim:
	$(SIM) -g2012 -Wall -o eeg_diff_afe.vvp $(RTL) $(TB)
	vvp eeg_diff_afe.vvp

clean:
	rm -f eeg_diff_afe.vvp eeg_diff_afe.vcd
