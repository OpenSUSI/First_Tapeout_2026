# test6: 8 kHz validation and CMOS chopper entry

## Frequency selection

The 4, 8, and 16 kHz candidates are exact divisions of the available 256 kHz
clock. Their conservative ideal-chopper estimates over 0.5-100 Hz are 0.424,
0.343, and 0.289 uVrms. At 8 kHz the OTA still has 58.39 dB open-loop gain,
about 28 dB above the intended noise gain of 32. Moving to 16 kHz improves the
estimate by only 0.054 uV while doubling switching activity. Moving to 4 kHz
reduces switching but leaves only a factor of 16 above the 250 Hz band. Thus
8 kHz is retained as the provisional optimum.

## First transistor-switch result

A four-transmission-gate differential commutator was implemented with Sky130
1.8 V NMOS/PMOS devices at both the input and output. Two 60 us active phases
within the 125 us period provide 2.5 us non-overlap around each commutation.
The complements are separately generated so both NMOS and PMOS devices remain
off during dead time.

The initial switching sanity test uses an ideal differential gain-32 core so the
commutator can be verified independently of OTA settling. For 2.000 mVpp input,
the demodulated output is 64.0697 mVpp, giving gain 32.03485 and +0.109% error.
Residual switching error is 8.321 uVrms output-referred, or about 0.260 uVrms
input-referred.

This passes the switch-entry gate but is not the final chopped AFE result. The
next netlist must replace the ideal core with the high-gain OTA, close the
capacitive PGA loop, include electrode impedance, and measure settling/ripple.
Transient-noise and mismatch verification follow after stable integration.
