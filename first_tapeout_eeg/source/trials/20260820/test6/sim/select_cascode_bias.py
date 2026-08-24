#!/usr/bin/env python3
from pathlib import Path
p=Path(__file__).resolve().parents[1]/'results'/'cascode_bias_sweep.csv'; best=None
for line in p.read_text().splitlines():
 vals=[]
 for t in line.split():
  try: vals.append(float(t))
  except: pass
 if len(vals)>=8:
  vcn,vcp,vcm,idd=vals[1],vals[3],vals[5],vals[7]
  # prefer VCM accuracy, then current below 100 uA
  score=abs(vcm-.9)+(10 if idd>100e-6 else 0)
  item=(score,idd,vcn,vcp,vcm)
  if best is None or item<best: best=item
if best is None: raise SystemExit('No data')
_,idd,vcn,vcp,vcm=best
q=Path(__file__).resolve().parents[1]/'results'/'cascode_selected_bias.txt'
q.write_text(f'VCN={vcn:.6g}\nVCP={vcp:.6g}\nVCM_OUT={vcm:.6g}\nIDD={idd:.6g}\n')
print(q.read_text(),end='')
