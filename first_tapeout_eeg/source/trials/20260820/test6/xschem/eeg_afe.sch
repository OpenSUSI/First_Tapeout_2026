v {xschem version=3.4.5 file_version=1.2}
G {}
K {type=subcircuit
format="@name @pinlist @symname"
template="name=XAFE"
}
V {}
S {}
E {}
T {EEG AFE v0.1 - fully differential signal chain} 350 -300 0 0 0.7 0.7 {}
T {Architecture-entry schematic; transistor/PVT verification pending} 350 -265 0 0 0.32 0.32 {color=4}
N 100 -25 190 -25 {lab=EEG_INP}
N 100 0 190 0 {lab=EEG_INN}
N 410 -10 520 -15 {lab=CHOP_P}
N 410 20 520 10 {lab=CHOP_N}
N 740 -10 850 -15 {lab=AFE_P}
N 740 20 850 10 {lab=AFE_N}
N 1070 -10 1180 -10 {lab=PGA_P}
N 1070 20 1180 20 {lab=PGA_N}
N 740 155 760 155 {lab=SERVO_P}
N 760 155 760 70 {lab=SERVO_P}
N 760 70 190 70 {lab=SERVO_P}
N 190 70 190 70 {lab=SERVO_P}
N 740 190 780 190 {lab=SERVO_N}
N 780 190 780 85 {lab=SERVO_N}
N 780 85 190 85 {lab=SERVO_N}
N 300 110 300 30 {lab=PHI1}
N 330 110 330 50 {lab=PHI2}
N 960 110 960 45 {lab=GAIN_SEL[1:0]}
C {devices/ipin.sym} 100 -25 0 0 {name=p1 lab=EEG_INP}
C {devices/ipin.sym} 100 0 0 0 {name=p2 lab=EEG_INN}
C {devices/ipin.sym} 300 110 1 0 {name=p3 lab=PHI1}
C {devices/ipin.sym} 330 110 1 0 {name=p4 lab=PHI2}
C {devices/ipin.sym} 960 110 1 0 {name=p5 lab=GAIN_SEL[1:0]}
C {devices/iopin.sym} 600 -100 3 0 {name=p6 lab=VDD18}
C {devices/iopin.sym} 600 250 1 0 {name=p7 lab=VSS}
C {devices/ipin.sym} 650 -100 3 0 {name=p8 lab=VCM09}
C {devices/ipin.sym} 700 -100 3 0 {name=p9 lab=VBN}
C {devices/opin.sym} 1180 -10 0 0 {name=p10 lab=PGA_P}
C {devices/opin.sym} 1180 20 0 0 {name=p11 lab=PGA_N}
C {eeg_input_chopper.sym} 300 20 0 0 {name=XCHOP}
C {eeg_fd_ota_cmfb.sym} 630 20 0 0 {name=XOTA}
C {eeg_cap_pga.sym} 960 20 0 0 {name=XPGA}
C {eeg_dc_servo.sym} 630 180 0 0 {name=XSERVO}
C {devices/lab_pin.sym} 450 -12 0 0 {name=l1 lab=CHOP_P}
C {devices/lab_pin.sym} 450 16 0 0 {name=l2 lab=CHOP_N}
C {devices/lab_pin.sym} 790 -12 0 0 {name=l3 lab=AFE_P}
C {devices/lab_pin.sym} 790 16 0 0 {name=l4 lab=AFE_N}
C {devices/lab_pin.sym} 760 100 1 0 {name=l5 lab=SERVO_P}
C {devices/lab_pin.sym} 780 110 1 0 {name=l6 lab=SERVO_N}
C {devices/lab_pin.sym} 740 50 0 0 {name=l7 lab=VDD18}
C {devices/lab_pin.sym} 740 68 0 0 {name=l8 lab=VSS}
C {devices/lab_pin.sym} 520 40 0 0 {name=l9 lab=VCM09}
C {devices/lab_pin.sym} 520 60 0 0 {name=l10 lab=VBN}
C {devices/lab_pin.sym} 410 50 0 0 {name=l11 lab=VDD18}
C {devices/lab_pin.sym} 410 70 0 0 {name=l12 lab=VSS}
C {devices/lab_pin.sym} 1070 50 0 0 {name=l13 lab=VDD18}
C {devices/lab_pin.sym} 1070 68 0 0 {name=l14 lab=VSS}
C {devices/lab_pin.sym} 740 210 0 0 {name=l15 lab=VDD18}
C {devices/lab_pin.sym} 740 230 0 0 {name=l16 lab=VSS}
