# test6: low-charge chopper validation and topology decision

## Isolated switch result

The revised commutator uses 100 ns non-overlap, layout-valid Sky130 main
devices (0.84/1.68 um NMOS/PMOS), and half-size dummy devices at the held node.
During the full active phase it reduced differential RMS tracking error from
88.171 to 81.223 uV and common-mode RMS error from 16.247 to 11.020 uV. When
the first 1 us after each transition is blanked, differential error falls to
0.083 uVrms. The low-charge cell itself is therefore useful.

## Integration and control experiments

Integration ahead of a static capacitive PGA still failed: synchronous gain was
0.599 V/V instead of 32 and output common-mode excursions reached 3.006 Vpp.
Crucially, replacing the MOS commutator with an ideal behavioral modulator also
failed, with demodulated gain about 0.997 V/V and 2.996 Vpp common-mode spikes.

This proves that switch sizing is not the primary remaining problem. Abruptly
modulating the signal outside the static capacitive PGA excites its summing
nodes and both CMFB loops. The input-only/digital-demod topology is rejected in
this direct form.

## Next topology

Retain the validated low-charge cell and 8 kHz clock, but move chopping inside
the amplifier: modulate before the input differential pair and demodulate at the
interface between the first and second gain stages. The second stage, output
CMFB, capacitive PGA feedback, and ADC input then remain continuous-time. The
next gate will first verify the internal chopper with an open-loop small signal,
then close the gain-32 capacitive loop.
