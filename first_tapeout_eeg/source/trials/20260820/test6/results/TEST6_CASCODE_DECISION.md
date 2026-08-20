# test6 cascode topology decision

## Bias search

A two-dimensional Sky130 TT sweep selected:

- VCN = 0.60 V
- VCP = 0.30 V
- output common mode = 0.899996 V
- supply current = 17.806 uA

## AC result

| Item | Measured | Acceptance | Result |
|---|---:|---:|---|
| Output common mode | 0.899996 V | 0.81-0.99 V | PASS |
| Supply current | 17.806 uA | <=100 uA | PASS |
| Gain at 10 Hz | -29.083 dB | >=40 dB | FAIL |
| Gain at 100 Hz | -29.083 dB | >=40 dB | FAIL |

## Decision

Reject the telescopic-cascode option for this 1.8 V EEG AFE. The bias point
that preserves 0.9 V output common mode and low current does not leave enough
headroom to bias the cascode devices as a useful gain stage. Proceed to a
two-stage fully differential amplifier with explicit Miller compensation and
retain the verified five-transistor CMFB loop.
