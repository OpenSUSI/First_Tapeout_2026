# test6 Gate 6A result

## Execution

- Simulator: ngspice 46 in IIC-OSIC-TOOLS
- PDK/model: Sky130A TT
- Supply/temperature: 1.8 V / 27 C
- Load: 1 pF per differential output
- Selected low-current bias: VBP=0.585 V, VBN=0.65 V

## Measured result

| Parameter | Measured | Gate | Result |
|---|---:|---:|---|
| Supply current | 31.978 uA | informational | measured |
| Output common mode | 1.5368 V | target 0.9 V | FAIL |
| Differential gain at 10 Hz | 23.037 dB | >=40 dB | FAIL |
| Differential gain at 100 Hz | 23.037 dB | >=40 dB | FAIL |
| Gain-rejection estimate | 26.617 dB | >=80 dB | FAIL |

The simulation flow passes, but the OTA design does not pass Gate 6A. The
open-loop PMOS-load bias cannot reliably place the output common mode at 0.9 V:
the VBP sweep moved between a low-output/high-current point and a high-output,
lower-current point. This is direct evidence that an active CMFB error amplifier
and compensation must be implemented before noise or sigma-delta integration.

## Next implementation gate

1. Add a low-power CMFB error amplifier that drives VBP.
2. Close the common-mode loop around the 2 x 50 kohm sensing network.
3. Target output VCM=0.9 V and phase margin >=60 degrees.
4. Re-size/cascode the differential stage for >=40 dB DC gain.
5. Repeat TT, then PVT and mismatch before chopper/noise integration.
