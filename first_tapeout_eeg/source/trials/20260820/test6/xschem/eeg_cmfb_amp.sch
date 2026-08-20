v {xschem version=3.4.8RC file_version=1.2}
G {}
K {type=subcircuit
format="@name @pinlist @symname"
template="name=X1"
}
V {}
S {}
E {}
T {Sky130 CMFB error amplifier} 250 -300 0 0 0.65 0.65 {}
T {Positive VCM error raises VBP and reduces PMOS load current} 250 -270 0 0 0.28 0.28 {color=4}
N 250 -160 250 -120 {lab=VDD18}
N 550 -160 550 -120 {lab=VDD18}
N 250 -80 250 -20 {lab=NLEFT}
N 550 -80 550 -20 {lab=VBP}
N 250 60 400 110 {lab=NTAIL}
N 550 60 400 110 {lab=NTAIL}
N 400 170 400 220 {lab=VSS}
N 140 20 210 20 {lab=VCM_SENSE}
N 660 20 590 20 {lab=VCM_REF}
N 360 140 320 140 {lab=VBN}
N 550 -20 680 -20 {lab=VBP}
C {sky130_fd_pr/pfet_01v8.sym} 250 -105 0 0 {name=M8 W=8 L=2 nf=2 mult=1 model=pfet_01v8 spiceprefix=X}
C {sky130_fd_pr/pfet_01v8.sym} 550 -105 0 1 {name=M9 W=8 L=2 nf=2 mult=1 model=pfet_01v8 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} 250 20 0 0 {name=M6 W=20 L=2 nf=4 mult=1 model=nfet_01v8 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} 550 20 0 1 {name=M7 W=20 L=2 nf=4 mult=1 model=nfet_01v8 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} 400 140 0 0 {name=M10 W=8 L=2 nf=2 mult=1 model=nfet_01v8 spiceprefix=X}
C {devices/capa.sym} 610 -70 0 0 {name=CCMFB m=1 value=2p footprint=1206 device="ceramic capacitor"}
C {devices/ipin.sym} 140 20 0 0 {name=p1 lab=VCM_SENSE}
C {devices/ipin.sym} 660 20 0 1 {name=p2 lab=VCM_REF}
C {devices/ipin.sym} 320 140 0 0 {name=p3 lab=VBN}
C {devices/opin.sym} 680 -20 0 1 {name=p4 lab=VBP}
C {devices/iopin.sym} 250 -160 3 0 {name=p5 lab=VDD18}
C {devices/iopin.sym} 400 220 1 0 {name=p6 lab=VSS}
