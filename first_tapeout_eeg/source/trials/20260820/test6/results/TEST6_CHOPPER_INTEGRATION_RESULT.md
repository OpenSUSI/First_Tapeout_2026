# test6: chopper integration result and architecture decision

## Outcome

The selected 8 kHz frequency remains valid, but the first direct CMOS-switch
integration is rejected. Multiple variants were simulated with the transistor
OTA and capacitive gain-32 feedback. All variants showed large instantaneous
common-mode excursions of about 2-3 Vpp and failed to recover gain 32.

Adding 100 pF output capacitance increased current and reduced signal gain.
Adding an ideal output isolation buffer proved that output kickback was not the
only mechanism. Reducing transmission-gate size and adding 5 pF input hold
capacitors also failed. An input-only chopper with behavioral ADC-side digital
demodulation produced synchronous gain only 0.534 V/V because switching charge
disturbed the capacitive virtual-input and CMFB loops.

## Decision

Do not connect a simple transmission-gate commutator directly to the OTA's
high-impedance input/output nodes. Preserve these simulations as failed design
evidence. The next implementation gate is a low-charge-injection chopper cell:

1. shorten non-overlap from 2.5 us to the 50-100 ns range;
2. use dummy switches and fully symmetric bottom-plate timing;
3. provide a defined hold/common-mode path during commutation;
4. design a transistor output isolation buffer before any analog demodulator;
5. verify switch kickback with the OTA disconnected before closing the PGA loop.

The 8 kHz clock decision is not the cause of failure; the switch/interface
topology is. Noise projections remain estimates until the revised commutator
passes transient integration and sampled/transient-noise verification.
