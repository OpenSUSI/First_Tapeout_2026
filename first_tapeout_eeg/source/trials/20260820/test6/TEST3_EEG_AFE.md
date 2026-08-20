# test3 EEG AFE architecture baseline

This project extends test2 with a fully differential EEG front-end model.

## Baseline

- Fully differential electrode input and signal path
- Chopper/instrumentation-amplifier target architecture
- DC-servo representation for electrode offset rejection
- Programmable PGA target gain: 8/16/32/64
- Fully differential second-order, one-bit sigma-delta target
- 24-bit output container; initial in-band target is 14--16 ENOB
- Caravel `user_clock2`, Wishbone registers/FIFO, and management RISC-V for
  configuration and packet communication

## Initial electrical targets

| Parameter | Target |
|---|---:|
| Optimized band | 1--40 Hz |
| Configurable band | 0.5--100 Hz |
| Input-referred noise | <= 1 uVrms (0.5--100 Hz) |
| CMRR | >= 90 dB architecture target |
| Electrode DC tolerance | at least +/-100 mV differential |
| PGA gain | 8/16/32/64 |
| Output sample rate | 250/500/1000 SPS |

## Verification layers

1. Fixed-point SystemVerilog architectural tests (`verilog/dv/eeg_diff_afe`)
2. Numerical noise/OSR/order sweep
3. xschem/ngspice transistor-level AFE and CMFB verification
4. Extracted-layout PVT, mismatch, and mixed-signal regression

The fixed-point model is not tapeout RTL and is not a transistor-level noise
claim.  It defines interfaces, sign conventions, saturation behavior, and
measurable acceptance tests before schematic implementation.
