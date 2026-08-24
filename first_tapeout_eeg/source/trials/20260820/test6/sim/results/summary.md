# test4 architecture sweep result

Generated from 144 corner cases without external Python packages.

## Recommended baseline

- PGA gain: **32x**
- OSR: **1024**
- Output rate: **250 SPS**
- Sigma-delta clock: **256 kHz**
- Estimated ADC ENOB: **17.5 bit**
- Input-referred ADC noise: **0.0389 uVrms**
- SNR with 50/60 Hz notch: **40.07 dB**
- ADC headroom: **99.54 %**

Passing architecture triples: 21 / 36.

## Interpretation

The 90 dB CMRR assumption converts 100 mVrms common-mode interference into
3.1623 uVrms input-referred line interference. Therefore a
50/60 Hz digital notch materially improves the system result. The ENOB number
is an architecture estimate capped for analog nonidealities; it must be
replaced by transistor-level PVT/noise results before tapeout.
