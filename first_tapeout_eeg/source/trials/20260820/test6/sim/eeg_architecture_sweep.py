#!/usr/bin/env python3
"""Dependency-free architecture sweep for the test4 EEG signal chain.

This is a system noise/dynamic-range budget, not a transistor-level claim.
It ranks gain, OSR, modulator clock, interference, and electrode-offset cases.
"""
from __future__ import annotations

import csv
import itertools
import math
from pathlib import Path

GAINS = (8, 16, 32, 64)
OSRS = (256, 512, 1024)
OUTPUT_RATES = (250, 500, 1000)
LINE_FREQS = (50, 60)
OFFSETS_MV = (100, 300)

SIGNAL_RMS_UV = 100.0 / math.sqrt(2.0)  # 100 uVpk EEG tone
AFE_NOISE_RMS_UV = 0.70
CMRR_DB = 90.0
COMMON_MODE_RMS_UV = 100_000.0          # 100 mVrms line/common-mode
INPUT_RANGE_UV = 25_000.0                # post-servo differential range
ADC_FULL_SCALE_UV = 800_000.0
OUTPUT_BITS = 24


def adc_enob(osr: int, rate: int) -> float:
    """Conservative second-order 1-bit architecture estimate.

    The estimate is deliberately capped by assumed analog nonidealities. The
    transistor/PVT simulations in the next phase replace this model.
    """
    clock_penalty = max(0.0, math.log2((osr * rate) / 512_000.0)) * 0.20
    return min(18.0, 13.5 + 2.0 * math.log2(osr / 256.0) - clock_penalty)


def evaluate(gain: int, osr: int, rate: int, line_hz: int, offset_mv: int):
    fmod = osr * rate
    enob = adc_enob(osr, rate)
    adc_noise_out_uv = ADC_FULL_SCALE_UV / (math.sqrt(12.0) * (2.0 ** enob))
    adc_noise_in_uv = adc_noise_out_uv / gain
    cm_leak_uv = COMMON_MODE_RMS_UV / (10.0 ** (CMRR_DB / 20.0))

    # 50/60 Hz remains in the configurable 0.5--100 Hz band. Report both the
    # broadband result and the result after a digital line-frequency notch.
    total_noise_uv = math.sqrt(AFE_NOISE_RMS_UV**2 + cm_leak_uv**2
                               + adc_noise_in_uv**2)
    notch_noise_uv = math.sqrt(AFE_NOISE_RMS_UV**2 + adc_noise_in_uv**2
                               + (0.01 * cm_leak_uv)**2)
    snr_db = 20.0 * math.log10(SIGNAL_RMS_UV / total_noise_uv)
    notch_snr_db = 20.0 * math.log10(SIGNAL_RMS_UV / notch_noise_uv)

    # DC servo target: 80 dB rejection of electrode offset before PGA.
    residual_offset_uv = offset_mv * 1000.0 / (10.0 ** (80.0 / 20.0))
    peak_out_uv = gain * (100.0 + residual_offset_uv + math.sqrt(2)*cm_leak_uv)
    headroom_pct = 100.0 * (1.0 - peak_out_uv / ADC_FULL_SCALE_UV)
    saturates = peak_out_uv >= ADC_FULL_SCALE_UV or offset_mv*1000 > 300_000
    passes = (not saturates and fmod <= 1_024_000 and notch_snr_db >= 38.0
              and enob >= 15.0 and headroom_pct >= 50.0)
    score = notch_snr_db + 0.6*enob + 0.02*headroom_pct - 0.8*(fmod/1_000_000)
    return {
        "gain": gain, "osr": osr, "output_rate_sps": rate,
        "mod_clock_hz": fmod, "line_hz": line_hz,
        "electrode_offset_mv": offset_mv, "adc_enob_est": round(enob, 2),
        "adc_noise_input_uvrms": round(adc_noise_in_uv, 4),
        "cm_leak_uvrms": round(cm_leak_uv, 4),
        "snr_no_notch_db": round(snr_db, 2),
        "snr_with_notch_db": round(notch_snr_db, 2),
        "headroom_pct": round(headroom_pct, 2),
        "pass": passes, "score": round(score, 3),
    }


def main() -> None:
    out_dir = Path(__file__).resolve().parent / "results"
    out_dir.mkdir(parents=True, exist_ok=True)
    rows = [evaluate(*case) for case in itertools.product(
        GAINS, OSRS, OUTPUT_RATES, LINE_FREQS, OFFSETS_MV)]
    fields = list(rows[0])
    with (out_dir / "architecture_sweep.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader(); writer.writerows(rows)

    passing = sorted((r for r in rows if r["pass"]),
                     key=lambda r: r["score"], reverse=True)
    best = passing[0] if passing else max(rows, key=lambda r: r["score"])
    unique_pass = {(r["gain"], r["osr"], r["output_rate_sps"])
                   for r in passing}
    report = f"""# test4 architecture sweep result

Generated from {len(rows)} corner cases without external Python packages.

## Recommended baseline

- PGA gain: **{best['gain']}x**
- OSR: **{best['osr']}**
- Output rate: **{best['output_rate_sps']} SPS**
- Sigma-delta clock: **{best['mod_clock_hz']/1000:.0f} kHz**
- Estimated ADC ENOB: **{best['adc_enob_est']} bit**
- Input-referred ADC noise: **{best['adc_noise_input_uvrms']} uVrms**
- SNR with 50/60 Hz notch: **{best['snr_with_notch_db']} dB**
- ADC headroom: **{best['headroom_pct']} %**

Passing architecture triples: {len(unique_pass)} / {len(GAINS)*len(OSRS)*len(OUTPUT_RATES)}.

## Interpretation

The 90 dB CMRR assumption converts 100 mVrms common-mode interference into
{best['cm_leak_uvrms']} uVrms input-referred line interference. Therefore a
50/60 Hz digital notch materially improves the system result. The ENOB number
is an architecture estimate capped for analog nonidealities; it must be
replaced by transistor-level PVT/noise results before tapeout.
"""
    (out_dir / "summary.md").write_text(report, encoding="utf-8")
    print(report)
    print(f"PASSING_CORNERS={len(passing)}/{len(rows)}")
    if not passing:
        raise SystemExit("No architecture meets the acceptance criteria")


if __name__ == "__main__":
    main()
