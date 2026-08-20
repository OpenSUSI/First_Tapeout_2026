#!/usr/bin/env python3
from pathlib import Path
import csv,re
root=Path(__file__).resolve().parents[1]; res=root/'results'; log=(res/'cascode_tt_ngspice.log').read_text(errors='replace')
def m(n):
 x=re.search(rf'(?im)^\s*{n}\s*=\s*([-+0-9.eE]+)',log); return float(x.group(1)) if x else None
def op():
 vals=[]
 for t in (res/'cascode_tt_op.csv').read_text().split():
  try: vals.append(float(t))
  except: pass
 return vals[1],vals[3],vals[5],vals[7]
outp,outn,vcm,idd=op(); g10=m('gain_10hz_db'); g100=m('gain_100hz_db'); g10k=m('gain_10khz_db')
rows=[['test_id','topology','test_item','measured_value','unit','acceptance','status'],
['T6C-001','telescopic cascode','output common mode',vcm,'V','0.81 to 0.99','PASS' if .81<=vcm<=.99 else 'FAIL'],
['T6C-002','telescopic cascode','supply current',idd,'A','<=100e-6','PASS' if idd<=100e-6 else 'FAIL'],
['T6C-003','telescopic cascode','gain at 10 Hz',g10 or '','dB','>=40','PASS' if g10 is not None and g10>=40 else 'FAIL'],
['T6C-004','telescopic cascode','gain at 100 Hz',g100 or '','dB','>=40','PASS' if g100 is not None and g100>=40 else 'FAIL'],
['T6C-005','telescopic cascode','gain at 10 kHz',g10k or '','dB','informational','INFO' if g10k is not None else 'NOT_RUN']]
with (res/'test6_cascode_results.csv').open('w',newline='',encoding='utf-8-sig') as f: csv.writer(f).writerows(rows)
for r in rows[1:]: print(*r)
