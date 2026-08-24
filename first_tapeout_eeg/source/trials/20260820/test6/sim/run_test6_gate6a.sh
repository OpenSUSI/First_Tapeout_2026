#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$ROOT/results"
cd "$ROOT/xschem"
ngspice -b -o "$ROOT/results/ota_tt_ngspice.log" eeg_fd_ota_core_tt.spice
test -s "$ROOT/results/ota_tt_op.csv"
test -s "$ROOT/results/ota_tt_diff_ac.csv"
test -s "$ROOT/results/ota_tt_cm_ac.csv"
echo "TEST6_GATE6A_RUN: PASS"
