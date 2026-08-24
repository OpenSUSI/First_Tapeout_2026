#!/usr/bin/env python3
from pathlib import Path
import re

p=Path(__file__).resolve().parents[1]/'results'/'ota_vbp_sweep.csv'
best=None
for line in p.read_text().splitlines():
    vals=[]
    for tok in line.split():
        try: vals.append(float(tok))
        except ValueError: pass
    # wrdata repeats scale/value pairs. Select voltage-looking values.
    if len(vals) >= 6:
        vbp, vcm, idd = vals[1], vals[3], vals[5]
        item=(abs(vcm-0.9),vbp,vcm,idd)
        if best is None or item < best: best=item
if best is None: raise SystemExit('No sweep data parsed')
_,vbp,vcm,idd=best
out=Path(__file__).resolve().parents[1]/'results'/'ota_selected_bias.txt'
out.write_text(f'VBP={vbp:.6g}\nVBN=0.65\nVCM_OUT={vcm:.6g}\nIDD={idd:.6g}\n')
print(out.read_text(),end='')
