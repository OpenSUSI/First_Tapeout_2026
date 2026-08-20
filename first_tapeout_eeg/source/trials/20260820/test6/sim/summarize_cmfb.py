#!/usr/bin/env python3
from pathlib import Path
import csv,re
root=Path(__file__).resolve().parents[1]; res=root/'results'
log=(res/'cmfb_tt_ngspice.log').read_text(errors='replace')
def m(name):
 x=re.search(rf'(?im)^\s*{re.escape(name)}\s*=\s*([-+0-9.eE]+)',log); return float(x.group(1)) if x else None
def op_values():
 p=res/'cmfb_tt_op.csv'
 if not p.exists(): return (None,)*4
 vals=[]
 for t in p.read_text().split():
  try: vals.append(float(t))
  except: pass
 return (vals[1],vals[3],vals[5],vals[7]) if len(vals)>=8 else (None,)*4
outp,outn,vcm,idd=op_values(); g10=m('gain_10hz_db'); g100=m('gain_100hz_db')
rows=[['test_id','test_item','measured_value','unit','acceptance','status','evidence'],
['T6B-001','Closed-loop output common mode',vcm or '','V','0.81 to 0.99 V','PASS' if vcm is not None and .81<=vcm<=.99 else 'FAIL','results/cmfb_tt_op.csv'],
['T6B-002','Total supply current',idd or '','A','<=100 uA','PASS' if idd is not None and idd<=100e-6 else 'FAIL','results/cmfb_tt_op.csv'],
['T6B-003','Differential gain at 10 Hz',g10 or '','dB','>=40 dB','PASS' if g10 is not None and g10>=40 else 'FAIL','results/cmfb_tt_diff_ac.csv'],
['T6B-004','Differential gain at 100 Hz',g100 or '','dB','>=40 dB','PASS' if g100 is not None and g100>=40 else 'FAIL','results/cmfb_tt_diff_ac.csv']]
with (res/'test6_gate6b_cmfb_results.csv').open('w',newline='',encoding='utf-8-sig') as f: csv.writer(f).writerows(rows)
for r in rows[1:]: print(*r[:6])
