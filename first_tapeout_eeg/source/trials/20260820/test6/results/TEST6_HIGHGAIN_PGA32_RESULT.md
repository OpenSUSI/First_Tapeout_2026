# test6: high-gain OTA and capacitive PGA32 result

## TT result (Sky130A, 1.8 V, 27 C)

The first and second stages use longer-channel devices. The CMFB averaging
resistors were increased to 5 Mohm so that the sensing network no longer limits
differential output resistance. The closed-loop PGA uses 32 pF input capacitors
and 1 pF cross-coupled feedback capacitors.

| Item | Measured | Acceptance | Result |
|---|---:|---:|---|
| Output common mode | 0.897443 V | 0.81-0.99 V | PASS |
| Total current | 82.741 uA | <=100 uA | PASS |
| Open-loop gain, 10 Hz | 89.4025 dB | >=55 dB | PASS |
| Open-loop gain, 100 Hz | 88.6177 dB | >=55 dB | PASS |
| PGA32 loop phase margin | about 75.4 degrees | >=60 degrees | PASS |
| Closed-loop gain, 10/100 Hz | 31.944 V/V | 32 +/-1% | PASS |
| Closed-loop gain error | about -0.175% | abs(error) <=1% | PASS |
| Closed-loop -3 dB bandwidth | about 234.4 kHz | >1 kHz | PASS |

This is a TT schematic-level result. The 5 Mohm ideal sensing resistors must be
replaced or implemented with a layout-feasible high-resistance structure (for
example a validated MOS pseudo-resistor or a switched-capacitor CMFB sensor).
Before sign-off, PVT/Monte Carlo, CMFB loop stability, input-referred noise,
large-signal swing, settling, and extracted-parasitic simulations are required.
