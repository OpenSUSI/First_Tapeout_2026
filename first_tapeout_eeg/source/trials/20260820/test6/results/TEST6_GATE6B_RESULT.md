# test6 Gate 6B: transistor CMFB result

## Result at Sky130A TT, 27 C, 1.8 V

| Item | Measured | Acceptance | Result |
|---|---:|---:|---|
| Closed-loop output common mode | 0.899355 V | 0.81-0.99 V | PASS |
| Total supply current | 36.884 uA | <=100 uA | PASS |
| Differential gain at 10 Hz | 24.0456 dB | >=40 dB | FAIL |
| Differential gain at 100 Hz | 24.0456 dB | >=40 dB | FAIL |

The five-transistor CMFB amplifier successfully controls the OTA output common
mode at the 0.9 V reference without exceeding the preliminary current budget.
The remaining dominant failure is differential gain. The next design gate will
compare a cascoded first stage against a compensated two-stage fully
differential amplifier. Noise integration is deferred until gain and both loop
stabilities pass.
