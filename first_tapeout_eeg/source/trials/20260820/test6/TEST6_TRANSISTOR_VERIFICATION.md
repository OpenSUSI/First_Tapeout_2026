# test6: Sky130 transistor verification

test6 advances the test5 design-entry schematic into model-backed verification.

## Gate 6A - OTA core nominal verification

- Sky130A TT, 27 C, 1.8 V
- DC operating point and supply current
- Differential AC gain and -3 dB bandwidth
- Common-mode AC response and calculated CMRR
- Output common-mode and output headroom

## Gate 6B - AFE loop completion

After Gate 6A passes, implement and verify:

1. CMFB error amplifier and compensation.
2. Non-overlap chopper switch network.
3. DC-servo physical integrator and selectable corner.
4. Capacitor-ratio PGA and gain switching.
5. Integrated 0.5-100 Hz noise and transient overload recovery.

No value in Gate 6A is a complete EEG-AFE performance claim. It isolates the
OTA core so that bias, gain, bandwidth, output common mode, and device operating
regions can be corrected before closing CMFB and chopper loops.
