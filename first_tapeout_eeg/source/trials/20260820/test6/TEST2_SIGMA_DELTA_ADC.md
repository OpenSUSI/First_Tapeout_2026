# test2: 24-bit Sigma-Delta ADC simulation model

This project is based on ChipFoundry's `caravel_user_project_analog` template.
It adds a self-checking mixed-signal-oriented behavioral model for a sigma-delta
ADC and its digital IO.

## Chosen demonstration specification

| Item | Value |
|---|---|
| Architecture | First-order, 1-bit sigma-delta modulator + boxcar decimator |
| Output format | 24-bit offset binary |
| Input model | Signed Q1.23 differential full-scale proxy |
| Input range | -1.0 FS to +1.0 FS |
| Oversampling ratio | 65,536 |
| IO | start, busy, data_valid, 24-bit parallel data, SPI-style serial readout |
| Intended use | RTL/IO and integration simulation |

The 24-bit value is an output word size. The simple first-order demonstration
model does not claim 24-bit ENOB, noise, linearity, or PVT performance in
silicon. A fabrication design would require transistor-level analog design,
device noise and mismatch simulation, clock-jitter analysis, and extracted
post-layout verification.

## Run

From WSL:

```bash
cd /mnt/c/projects/ft/test2/caravel_user_project_analog/verilog/dv/sigma_delta_adc
make sim
```

The test converts five input points from -0.75 FS to +0.75 FS, checks the
parallel result within 300 output codes, verifies the 24-bit SPI readback, and
writes `sigma_delta_adc.vcd` for waveform inspection.

## Files

- `verilog/rtl/sigma_delta_adc_io.sv`: ADC and IO behavioral model
- `verilog/dv/sigma_delta_adc/sigma_delta_adc_tb.sv`: self-checking testbench
- `verilog/dv/sigma_delta_adc/Makefile`: Icarus Verilog simulation target
