# EEG Xschem design entry v0.1

- `eeg_afe.sch`: correctly connected hierarchical signal-chain schematic.
- `eeg_fd_ota_core.sch`: Sky130 transistor-entry fully differential OTA core.
- `eeg_fd_ota_core.spice`: matching reviewable subcircuit.
- `*.sym`: explicit hierarchical symbols and pin names.

Important: This is design-entry v0.1, not a PVT-verified signoff schematic.
The CMFB error amplifier, chopper switch transistor sizing, DC-servo physical
resistor implementation, and capacitor arrays remain gated by model-backed
ngspice simulations. The schematic deliberately exposes VBP/VBN/VCM signals
instead of hiding ideal behavioral sources.
