# test4 EEG system architecture

test4 connects the fully differential test3 AFE assumptions to a second-order,
one-bit sigma-delta architecture and performs a repeatable system sweep.

Run:

```sh
python3 sim/eeg_architecture_sweep.py
make -C verilog/dv/sigma_delta_2nd sim
```

The sweep covers PGA gain 8/16/32/64, OSR 256/512/1024, output rates
250/500/1000 SPS, 50/60 Hz common-mode interference, and 100/300 mV electrode
offset cases. Results are written to `sim/results`.

This phase is an architecture budget. It does not replace transistor-level
noise, loop stability, mismatch, PVT, or extracted-layout verification.
