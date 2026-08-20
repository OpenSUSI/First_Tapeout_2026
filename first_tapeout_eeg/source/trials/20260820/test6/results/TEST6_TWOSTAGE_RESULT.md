# test6: compensated two-stage fully differential OTA

## TT result (Sky130A, 1.8 V, 27 C)

The verified first-stage OTA and local CMFB were retained. A low-current NMOS
common-source second stage, a second output CMFB, and 10 pF same-side Miller
capacitors were added. The intended application is the EEG PGA at differential
closed-loop gain 32, not a unity-gain buffer.

| Item | Measured | Acceptance | Result |
|---|---:|---:|---|
| Output common mode | 0.897755 V | 0.81-0.99 V | PASS |
| Total supply current | 72.216 uA | <=100 uA | PASS |
| Differential gain, 10 Hz | 41.7075 dB | >=40 dB | PASS |
| Differential gain, 100 Hz | 41.7075 dB | >=40 dB | PASS |
| Gain-32 loop crossover | about 112.2 kHz | >10 kHz | PASS |
| Gain-32 phase margin | about 98.3 degrees | >=60 degrees | PASS |

The phase margin is inferred from the open-loop differential response at the
noise-gain-32 crossover (30.103 dB). This preliminary amplifier is not unity-
gain stable; it must not be used as a voltage follower without redesigning the
compensation. The 41.7 dB open-loop gain also leaves limited gain accuracy at a
closed-loop gain of 32. The next improvement target is at least 55-60 dB DC
gain, followed by PVT, closed-loop transient, noise, and CMFB-loop checks.
