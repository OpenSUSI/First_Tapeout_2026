#!/usr/bin/env python3
"""Summarize ngspice Gate 6A without third-party packages."""
from pathlib import Path
import csv, re

root=Path(__file__).resolve().parents[1]
res=root/'results'
log=(res/'ota_tt_ngspice.log').read_text(errors='replace') if (res/'ota_tt_ngspice.log').exists() else ''

def metric(name):
    m=re.search(rf'(?im)^\s*{re.escape(name)}\s*=\s*([-+0-9.eE]+)',log)
    return float(m.group(1)) if m else None

gain10=metric('gain_10hz_db'); gain100=metric('gain_100hz_db')
ugf=metric('ugf_hz'); cmgain=metric('cm_gain_10hz_db')
cmrr=(gain10-cmgain) if gain10 is not None and cmgain is not None else None

rows=[
 ['test_id','test_item','condition','measured_value','unit','acceptance','status','evidence'],
 ['T6-001','TT simulation completed','Sky130A TT, 27 C, 1.8 V','1' if gain10 is not None else '0','boolean','all output files present','PASS' if gain10 is not None else 'NOT_RUN','results/ota_tt_ngspice.log'],
 ['T6-002','Differential gain at 10 Hz','1 V differential AC',gain10 or '','dB','>=40 dB','PASS' if gain10 is not None and gain10>=40 else ('FAIL' if gain10 is not None else 'NOT_RUN'),'results/ota_tt_diff_ac.csv'],
 ['T6-003','Differential gain at 100 Hz','1 V differential AC',gain100 or '','dB','>=40 dB','PASS' if gain100 is not None and gain100>=40 else ('FAIL' if gain100 is not None else 'NOT_RUN'),'results/ota_tt_diff_ac.csv'],
 ['T6-004','Unity-gain frequency','1 pF per output',ugf or '','Hz','>=10 kHz','PASS' if ugf is not None and ugf>=1e4 else ('FAIL' if ugf is not None else 'NOT_RUN'),'results/ota_tt_diff_ac.csv'],
 ['T6-005','Common-mode voltage gain at 10 Hz','both inputs driven in phase',cmgain or '','dB','informational','INFO' if cmgain is not None else 'NOT_RUN','results/ota_tt_cm_ac.csv'],
 ['T6-006','Gain rejection estimate at 10 Hz','differential gain - common-mode voltage gain',cmrr or '','dB','>=80 dB','PASS' if cmrr is not None and cmrr>=80 else ('FAIL' if cmrr is not None else 'NOT_RUN'),'calculated from T6-002/T6-005; mismatch CMRR remains separate'],
]
with (res/'test6_gate6a_results.csv').open('w',newline='',encoding='utf-8-sig') as f:
    csv.writer(f).writerows(rows)
print(f'WROTE {res / "test6_gate6a_results.csv"}')
for r in rows[1:]: print(r[0],r[6],r[3],r[4])
