# test6 input-referred noise and chopper-frequency decision

## Transistor-noise result

Sky130 TT noise analysis used the high-gain fully differential OTA at 1.8 V,
27 C, and VBN=0.63 V. The unchopped integrated input noise is 2.6475 uVrms
from 0.5 to 100 Hz and 2.9501 uVrms from 0.5 to 250 Hz. Both miss the proposed
ultra-low-noise EEG targets. The spectrum falls from 1416 nV/sqrtHz at 0.5 Hz
to 133 nV/sqrtHz at 100 Hz, confirming dominant flicker noise.

## Preliminary chopper decision

The measured input-referred density is 30.05 nV/sqrtHz near 4 kHz, 24.29
nV/sqrtHz near 8 kHz, and 20.45 nV/sqrtHz near 16 kHz. An 8 kHz chopper clock
is selected provisionally because it is an exact divide-by-32 derivative of the
existing 256 kHz ADC clock and remains far above the 250 Hz signal band.

Using the 8 kHz noise density and a conservative sqrt(2) modulation factor gives
an idealized estimate of about 0.34 uVrms over 0.5-100 Hz and 0.54 uVrms over
0.5-250 Hz. These are estimates, not transistor-level chopper results. Switch
thermal noise, charge injection, clock feedthrough, ripple, source impedance,
and anti-alias filtering are not yet included.

## Next gate

Implement non-overlapping input/output chopper switches at 8 kHz, add a ripple
reduction path and electrode-source model, then run transient-noise or sampled
noise verification. The design target is <=1.0 uVrms input-referred noise over
0.5-100 Hz with <=5 uV input offset after chopping.
