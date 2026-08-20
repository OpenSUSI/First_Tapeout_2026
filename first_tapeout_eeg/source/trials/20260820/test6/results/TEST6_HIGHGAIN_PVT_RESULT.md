# test6 high-gain OTA: PVT result

## Conditions and acceptance

Five representative Sky130 process corners were simulated. SS used 1.62 V and
125 C; FF used 1.98 V and -40 C. TT, SF, and FS used 1.8 V and 27 C. The common
NMOS bias was adjusted from 0.65 V to 0.63 V to prevent fast-NMOS overcurrent.

Acceptance limits were: output common mode within +/-10% of its reference,
total current <=100 uA, low-frequency differential gain >=55 dB, and phase
margin >=60 degrees at the intended noise gain of 32.

| Corner | VCM out | Current | Gain at 10 Hz | Gain-32 PM | Overall |
|---|---:|---:|---:|---:|---|
| TT | 0.8971 V | 69.02 uA | 88.85 dB | 78.90 deg | PASS |
| SS, 1.62 V, 125 C | 0.8080 V | 67.79 uA | 86.93 dB | 71.23 deg | PASS |
| FF, 1.98 V, -40 C | 0.9861 V | 89.69 uA | 89.57 dB | 84.25 deg | PASS |
| SF | 0.8845 V | 99.83 uA | 89.90 dB | 74.58 deg | PASS |
| FS | 0.8975 V | 47.52 uA | 87.38 dB | 82.38 deg | PASS |

All five representative corners pass. SF is the current-limiting corner with
only about 0.17 uA margin to the preliminary 100 uA ceiling. The present VBN is
still an ideal voltage source; a process-aware bias/reference circuit and
mismatch Monte Carlo analysis remain mandatory. The next verification gate is
input-referred noise in the EEG band, followed by CMFB loop injection and
large-signal settling/swing.
