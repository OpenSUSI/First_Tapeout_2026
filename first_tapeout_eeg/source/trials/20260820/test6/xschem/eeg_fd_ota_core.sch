v {xschem version=3.4.5 file_version=1.2}
G {}
K {type=subcircuit
format="@name @pinlist @symname"
template="name=X1"
}
V {}
S {}
E {}
T {Fully differential low-noise OTA core - Sky130 1.8 V} 300 -330 0 0 0.65 0.65 {}
T {M1/M2 common-centroid target; long-L devices reduce 1/f noise. VBP is driven by CMFB block.} 300 -295 0 0 0.28 0.28 {color=4}
N 250 -80 250 0 {lab=OUTP}
N 550 -80 550 0 {lab=OUTN}
N 250 -180 250 -140 {lab=VDD18}
N 550 -180 550 -140 {lab=VDD18}
N 250 80 400 130 {lab=TAIL}
N 550 80 400 130 {lab=TAIL}
N 400 190 400 240 {lab=VSS}
N 140 40 210 40 {lab=INP}
N 660 40 590 40 {lab=INN}
N 180 -105 210 -105 {lab=VBP}
N 620 -105 590 -105 {lab=VBP}
N 360 160 320 160 {lab=VBN}
N 290 0 510 0 {lab=VCM_SENSE}
C {sky130_fd_pr/pfet_01v8.sym} 250 -105 0 0 {name=M3 W=24 L=2 nf=4 mult=1 model=pfet_01v8 spiceprefix=X}
C {sky130_fd_pr/pfet_01v8.sym} 550 -105 0 1 {name=M4 W=24 L=2 nf=4 mult=1 model=pfet_01v8 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} 250 40 0 0 {name=M1 W=120 L=2 nf=12 mult=1 model=nfet_01v8 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} 550 40 0 1 {name=M2 W=120 L=2 nf=12 mult=1 model=nfet_01v8 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} 400 160 0 0 {name=M5 W=48 L=2 nf=8 mult=1 model=nfet_01v8 spiceprefix=X}
C {sky130_fd_pr/res_high_po_0p69.sym} 340 0 1 0 {name=RCM1 W=0.69 L=50 model=res_high_po_0p69 mult=1}
C {sky130_fd_pr/res_high_po_0p69.sym} 460 0 1 0 {name=RCM2 W=0.69 L=50 model=res_high_po_0p69 mult=1}
C {devices/ipin.sym} 140 40 0 0 {name=p1 lab=INP}
C {devices/ipin.sym} 660 40 0 1 {name=p2 lab=INN}
C {devices/ipin.sym} 180 -105 0 0 {name=p3 lab=VBP}
C {devices/ipin.sym} 320 160 0 0 {name=p4 lab=VBN}
C {devices/opin.sym} 250 -80 0 0 {name=p5 lab=OUTP}
C {devices/opin.sym} 550 -80 0 1 {name=p6 lab=OUTN}
C {devices/opin.sym} 400 0 1 0 {name=p7 lab=VCM_SENSE}
C {devices/iopin.sym} 250 -180 3 0 {name=p8 lab=VDD18}
C {devices/iopin.sym} 400 240 1 0 {name=p9 lab=VSS}
