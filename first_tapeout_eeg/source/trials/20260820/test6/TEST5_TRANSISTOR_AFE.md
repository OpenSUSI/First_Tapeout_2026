# test5: Sky130 transistor-level EEG AFE preparation

## Selected architecture

The first transistor implementation is a fully differential, capacitively
coupled chopper instrumentation amplifier followed by a programmable
capacitor-ratio PGA and a fully differential second-order sigma-delta loop.

## Electrical design targets

| Item | Nominal | Acceptance |
|---|---:|---:|
| Supply | 1.8 V | 1.62--1.98 V |
| Signal common mode | 0.9 V | 0.7--1.1 V |
| AFE gain | 16 V/V | 15.2--16.8 V/V |
| PGA total gain | 8/16/32/64 | within 5% |
| Bandwidth | 0.5--100 Hz | configurable |
| Input noise | 0.7 uVrms target | <=1.0 uVrms |
| CMRR | 90 dB target | >=80 dB PVT, >=70 dB mismatch |
| Electrode offset | +/-300 mV | no persistent saturation |
| Differential output | +/-0.8 V | >=50% nominal headroom |
| Differential-loop PM | 65 deg target | >=60 deg |
| CMFB-loop PM | 65 deg target | >=60 deg |

## First schematic partition

1. Symmetric pad/ESD and input test multiplexer.
2. Capacitive input network and non-overlap chopper switches.
3. Low-noise fully differential OTA with continuous-time CMFB.
4. DC-servo path with selectable corner.
5. Binary capacitor-ratio PGA.
6. Differential anti-alias/output isolation network.

## Required simulation matrix

- Corners: TT/SS/FF/SF/FS; -20/27/85 C; 1.62/1.8/1.98 V.
- AC: differential gain, bandwidth, CMRR, PSRR, both loop margins.
- Noise: integrated 0.5--100 Hz, including chopper ripple aliases.
- Transient: 10--500 uV EEG, 50/60 Hz common-mode, +/-300 mV offset,
  gain switching, startup, and overload recovery.
- Monte Carlo: input-pair mismatch, capacitor mismatch, switch asymmetry.

The PDK model-backed runs require the IIC-OSIC Docker engine. The current host
inspection found the project assets but no active Docker daemon or standalone
WSL ngspice, so this gate is explicitly recorded rather than presenting an
unverified transistor result.
