import numpy as np
import csv
import sys
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.gridspec import GridSpec, GridSpecFromSubplotSpec


# 定数とか
fs = 8e6 # IF信号のサンプリングレート(Hz)
fIF = 2e6 # IF 周波数 (Hz)
fb = fs/2 # ベースバンド信号のサンプリングレート
chip_rate = 1.023e6 # C/Aコードのチップレート(Hz)
code_len = 1023 # C/Aコード1周期の長さ
fcw = chip_rate / fb # ベースバンド1サンプルに対するC/Aコードの更新速度
half_chip = 0.5 # アキュムレータ
coherent_time = 1e-3 # 相互相関する時間 (s)
num_coherent_data_sample = int(fb*coherent_time) # 相互相関するサンプル数→4000点
non_cohnum = 4 # ノンコヒーレント積分時間(ms)
f_doppler_candidate = np.arange(-5000, 5000, 100) # ドップラー周波数の探索範囲
#f_doppler_candidate = np.array([-2000]) # ドップラー周波数の探索範囲
LOAD_LENGTH = int(fs * 50e-3)
PRN = int(sys.argv[1])
FILE = "./data/L1L2_20220114_004440_8MHz/L1_20220114_004440_8MHz_I.bin"

print("FILE: {}".format(FILE))
print("Search PRN: {}".format(PRN))
print("Number of coherent data sample: {}".format(num_coherent_data_sample))
print("C/A code update rate per 1 sample: {}".format(fcw))
print("Chip rate based on samples: {}".format(1/fcw))

def prn_taps(prn):
    """
    GPS L1 C/A
    PRN番号 → G2 LFSR タップ位置（0オリジン）
    戻り値: [tap1, tap2]
    """

    g2_tap_table_0based = {
         1:  [1, 5],
         2:  [2, 6],
         3:  [3, 7],
         4:  [4, 8],
         5:  [0, 8],
         6:  [1, 9],
         7:  [0, 7],
         8:  [1, 8],
         9:  [2, 9],
        10:  [1, 2],
        11:  [2, 3],
        12:  [4, 5],
        13:  [5, 6],
        14:  [6, 7],
        15:  [7, 8],
        16:  [8, 9],
        17:  [0, 3],
        18:  [1, 4],
        19:  [2, 5],
        20:  [3, 6],
        21:  [4, 7],
        22:  [5, 8],
        23:  [0, 2],
        24:  [3, 5],
        25:  [4, 6],
        26:  [5, 7],
        27:  [6, 8],
        28:  [7, 9],
        29:  [0, 5],
        30:  [1, 6],
        31:  [2, 7],
        32:  [3, 8],
        33:  [4, 9],
        34:  [3, 9],
        35:  [0, 6],
        36:  [1, 7],
        37:  [3, 9],
    }

    if prn not in g2_tap_table_0based:
        raise ValueError("PRN must be between 1 and 37")

    return g2_tap_table_0based[prn]


# C/Aコードの生成
def shift(g1, g2):
    fb1 = g1[2]^g1[9]
    fb2 = g2[1]^g2[2]^g2[5]^g2[7]^g2[8]^g2[9]

    g1 = np.roll(g1, 1)
    g1[0] = fb1
    g2 = np.roll(g2, 1)
    g2[0] = fb2

    return (g1, g2)

def cacode(g1, g2, sat):
    return g1[9]^g2[sat[0]]^g2[sat[1]]


def gen_cacode(prn):
    g1 = np.ones(10).astype(np.uint8)
    g2 = np.ones(10).astype(np.uint8)

    ca_code = np.zeros(1023).astype(np.int8)

    for n in range(1023):
      ca_code[n] = cacode(g1, g2, prn_taps(prn))
      g1, g2 = shift(g1, g2)

    return (1 - 2*ca_code)

def readdata(f_name, start, num_sample):
    # ベースバンドデータの読み込み
    x = np.fromfile(f_name, dtype=np.int8, count = num_sample, offset = start)

    samples = len(x)
    print("Loaded {0:.1f} ms".format(samples/fs*1000))

    x_even = x[0::2]
    x_odd = x[1::2]

    num_sample = len(x_even)

    i_tmp = np.zeros(num_sample).astype(np.int8)
    q_tmp = np.zeros(num_sample).astype(np.int8)

    i_tmp[0::2] = (+1)*x_even[0::2]
    i_tmp[1::2] = (-1)*x_even[1::2]

    q_tmp[0::2] = (-1)*x_odd[0::2]
    q_tmp[1::2] = (+1)*x_odd[1::2]

    samples = samples // 2

    return (samples, i_tmp, q_tmp)

class Doppler(object):
    def __init__(self, initial_doppler):
        self.doppler_nco_omega = initial_doppler
        self.doppler_nco_accumlator = 0
        self.i_integral = 0
        self.q_integral = 0
        self.prev_i_integral = 0
        self.prev_q_integral = 0
        self.integral = 0
        self.Ci = 0.00 # T=10ms
        self.Cp = 0.5 # T=10ms
        self.lf_coef_fll = -0.5

    def cancel_doppler(self, i, q):
        carrier_i = np.cos(self.doppler_nco_accumlator)
        carrier_q = np.sin(self.doppler_nco_accumlator)
        i_mix = carrier_i * i + carrier_q * q
        q_mix = carrier_i * q - carrier_q * i

        self.doppler_nco_accumlator = self.doppler_nco_accumlator + 2.0*np.pi * self.doppler_nco_omega/fb
        self.doppler_nco_accumlator %= (2.0*np.pi)
        return (i_mix, q_mix)

    def accumulate_corr(self, i_corr, q_corr):
        self.i_integral += i_corr
        self.q_integral += q_corr

    def update_parameter(self):
        fll_error = self.fll_discriminator(self.i_integral, self.q_integral)
        fll_adjust = self.loopfilter(fll_error/(2.0*np.pi*coherent_time))
        if np.abs(fll_error) > np.pi/4:
            return (fll_error, 0.0)
        self.doppler_nco_omega += fll_adjust * self.lf_coef_fll
        return (fll_error, fll_adjust)

    def loopfilter(self, error):
        self.integral += error * self.Ci
        nco_adjust = self.Cp * error + self.integral
        return nco_adjust

    def fll_discriminator(self, i_integral, q_integral):
        dot = i_integral * self.prev_i_integral + q_integral * self.prev_q_integral
        cross = i_integral * self.prev_q_integral - q_integral * self.prev_i_integral
        self.prev_i_integral = i_integral
        self.prev_q_integral = q_integral
        return np.atan2(cross, dot)
        #return cross/coherent_time

    def pll_discriminator(self, i_integral, q_integral):
        return np.atan2(i_integral, q_integral)

    def costas_discriminator(self, i_integral, q_integral):
        return q_integral * np.sign(i_integral)

    def clear_accumulator(self):
        self.i_integral = 0.0
        self.q_integral = 0.0

class Code(object):
    def __init__(self, sat_prn, initial_delay, fratio):
        # C/Aコード生成
        self.prn_code = np.array(gen_cacode(sat_prn))
        localcode = np.roll(self.prn_code, initial_delay)
        chip_index = (np.floor(np.arange(num_coherent_data_sample) * fcw) % code_len).astype(int)
        self.localcode = localcode[chip_index]
        self.code_nco_omega = 1
        self.code_offset = 0
        self.code_nco_accumlator = 0
        self.i_integral_early = 0
        self.i_integral_prompt = 0
        self.i_integral_late = 0
        self.q_integral_early = 0
        self.q_integral_prompt = 0
        self.q_integral_late = 0
        self.prev_i_integral = 0
        self.prev_q_integral = 0
        self.Ci = 0#0.001556 # T=5ms
        self.Cp = 3.77123  # T=5ms
        self.integral = 0
        self.lf_coef = +1

    def correlate_epl(self, i_mixed, q_mixed):
        code_phase_prompt_index = int(self.code_nco_accumlator)
        code_phase_early_index = (code_phase_prompt_index + 2) % num_coherent_data_sample
        code_phase_late_index = (code_phase_prompt_index - 2) % num_coherent_data_sample

        i_corr_prompt = i_mixed * self.localcode[code_phase_prompt_index]
        i_corr_early = i_mixed * self.localcode[code_phase_early_index]
        i_corr_late = i_mixed * self.localcode[code_phase_late_index]

        q_corr_prompt = q_mixed * self.localcode[code_phase_prompt_index]
        q_corr_early = q_mixed * self.localcode[code_phase_early_index]
        q_corr_late = q_mixed * self.localcode[code_phase_late_index]

        self.i_integral_prompt += i_corr_prompt
        self.i_integral_early += i_corr_early
        self.i_integral_late += i_corr_late

        self.q_integral_prompt += q_corr_prompt
        self.q_integral_early += q_corr_early
        self.q_integral_late += q_corr_late

        self.code_nco_accumlator = (self.code_nco_accumlator + self.code_nco_omega) % num_coherent_data_sample

        return (i_corr_prompt, q_corr_prompt)

    def update_parameter(self):
        code_error = self.code_discremenator()
        nco_adjust = self.code_loopfilter(code_error) # ErrorはΔfHz単位で出てきている一方で、ncoのomegaは1023で1ms、つまりキロヘルツの単位なので1000分の1する。
        self.code_nco_omega = 1 + nco_adjust*self.lf_coef
        return (code_error, nco_adjust)

    def code_loopfilter(self, code_error):
        self.integral += self.Ci *code_error
        nco_adjust = (self.Cp * code_error) + self.integral
        return nco_adjust

    def code_discremenator(self):
        pe = self.i_integral_early ** 2 + self.q_integral_early ** 2
        pl = self.i_integral_late ** 2 + self.q_integral_late ** 2
        ip = self.i_integral_prompt * self.i_integral_prompt
        qp = self.q_integral_prompt * self.q_integral_prompt
        
        #return ((self.i_integral_early - self.i_integral_late)*self.i_integral_prompt + (self.q_integral_early - self.q_integral_late)*self.q_integral_prompt)/4.0
        psum = pe + pl
        if psum < 1e-12:
            return 0.0

        dnorm = (pe - pl)/psum/4/num_coherent_data_sample
        return dnorm

        #code_error = ((self.i_integral_early - self.i_integral_late)*self.i_integral_prompt + (self.q_integral_early - self.q_integral_late)*self.q_integral_prompt)/2
        #return code_error

    def clear_accumulator(self):
        self.i_integral_prompt = 0
        self.i_integral_early = 0
        self.i_integral_late = 0

        self.q_integral_prompt = 0
        self.q_integral_early = 0
        self.q_integral_late = 0

class DataStore(object):
    def __init__(self, num_sample, graph):
        self.i = np.zeros((num_sample, 2))
        self.q = np.zeros((num_sample, 2))
        self.i_prompt = np.zeros((num_sample, 2))
        self.i_early = np.zeros((num_sample, 2))
        self.i_late = np.zeros((num_sample, 2))
        self.q_prompt = np.zeros((num_sample, 2))
        self.q_early = np.zeros((num_sample, 2))
        self.q_late = np.zeros((num_sample, 2))
        self.corr_prompt = np.zeros((num_sample, 2))
        self.corr_early = np.zeros((num_sample, 2))
        self.corr_late = np.zeros((num_sample, 2))
        self.code_nco = np.zeros((num_sample, 2))
        self.code_error = np.zeros((num_sample, 2))
        self.code_adjust = np.zeros((num_sample, 2))
        self.code_accumlator = np.zeros((num_sample, 2))
        self.doppler_nco = np.zeros((num_sample, 2))
        self.doppler_error = np.zeros((num_sample, 2))
        self.doppler_adjust = np.zeros((num_sample, 2))
        self.num_code = 0
        self.num_doppler = 0
        self.graph = graph

    def store_code(self, code, error, offset, n):
        self.i_prompt[self.num_code] = (n, code.i_integral_prompt)
        self.i_early[self.num_code] = (n, code.i_integral_early)
        self.i_late[self.num_code] = (n, code.i_integral_late)

        self.q_prompt[self.num_code] = (n, code.q_integral_prompt)
        self.q_early[self.num_code] = (n, code.q_integral_early)
        self.q_late[self.num_code] = (n, code.q_integral_late)

        self.corr_prompt[self.num_code] = (n, np.sqrt(code.i_integral_prompt ** 2 + code.q_integral_prompt ** 2))
        self.corr_early[self.num_code] = (n, np.sqrt(code.i_integral_early ** 2 + code.q_integral_early ** 2))
        self.corr_late[self.num_code] = (n, np.sqrt(code.i_integral_late ** 2 + code.q_integral_late ** 2))

        self.code_nco[self.num_code] = (n, code.code_nco_omega)
        self.code_error[self.num_code] = (n, error)
        self.code_adjust[self.num_code] = (n, offset)
        self.code_accumlator[self.num_code] = (n, code.code_nco_accumlator)

        #self.show_code()

        self.num_code += 1

    def show_code(self):
        print("Show CODE NCO update: {}".format(self.num_code))
        print("-----I----")
        print("Early: {}".format(self.i_early[self.num_code]))
        print("Prompt: {}".format(self.i_prompt[self.num_code]))
        print("Late: {}".format(self.i_late[self.num_code]))
        print("----Q----")
        print("Early: {}".format(self.q_early[self.num_code]))
        print("Prompt: {}".format(self.q_prompt[self.num_code]))
        print("Late: {}".format(self.q_late[self.num_code]))
        print("----Corr----")
        print("Early: {}".format(self.corr_early[self.num_code]))
        print("Prompt: {}".format(self.corr_prompt[self.num_code]))
        print("Late: {}".format(self.corr_late[self.num_code]))
        print("----Code nco----")
        print("Omega: {}".format(self.code_nco[self.num_code]))
        print("Error: {}".format(self.code_error[self.num_code]))
        print("Adjust: {}".format(self.code_adjust[self.num_code]))
        print()
        print()

    def store_doppler(self, doppler, error, adjust, n):
        self.i[self.num_doppler] = (n, doppler.i_integral)
        self.q[self.num_doppler] = (n, doppler.q_integral)
        self.doppler_nco[self.num_doppler] = (n, doppler.doppler_nco_omega)
        self.doppler_error[self.num_doppler] = (n, error)
        self.doppler_adjust[self.num_doppler] = (n, adjust)

        self.show_doppler()

        self.num_doppler += 1

    def show_doppler(self):
        print("Show Doppler NCO update: {}".format(self.num_doppler))
        print("Correlator")
        print("I: {}".format(self.i[self.num_doppler]))
        print("Q: {}".format(self.q[self.num_doppler]))
        print("NCO")
        print("Omega: {}".format(self.doppler_nco[self.num_doppler]))
        print("Error: {}".format(self.doppler_error[self.num_doppler]))
        print("Adjust: {}".format(self.doppler_adjust[self.num_doppler]))
        print()
        print()

    def show_graph(self):
        fig = plt.figure(figsize=(16,8))
        gs_master = GridSpec(nrows = 5, ncols = 2, height_ratios=[1, 1, 1, 1, 1])
        gs_1 = GridSpecFromSubplotSpec(nrows = 1, ncols = 1, subplot_spec=gs_master[0, 0])
        gs_2 = GridSpecFromSubplotSpec(nrows = 1, ncols = 1, subplot_spec=gs_master[1, 0])
        gs_3 = GridSpecFromSubplotSpec(nrows = 1, ncols = 1, subplot_spec=gs_master[2, 0])
        gs_4 = GridSpecFromSubplotSpec(nrows = 1, ncols = 1, subplot_spec=gs_master[3, 0])
        gs_5 = GridSpecFromSubplotSpec(nrows = 1, ncols = 1, subplot_spec=gs_master[4, 0])
        gs_2_1 = GridSpecFromSubplotSpec(nrows = 2, ncols = 2, subplot_spec=gs_master[2:6, 1])
        ax1 = fig.add_subplot(gs_1[:,:])
        ax2 = fig.add_subplot(gs_2[:,:], sharex=ax1)
        ax3 = fig.add_subplot(gs_3[:,:], sharex=ax1)
        ax4 = fig.add_subplot(gs_4[:,:], sharex=ax1)
        ax5 = fig.add_subplot(gs_5[:,:], sharex=ax1)
        ax_2_1 = fig.add_subplot(gs_2_1[:,:])
        ax_2_1.set_aspect('equal')

        ax1.plot(self.i_prompt[:self.num_code, 0]/fb, self.i_prompt[:self.num_code, 1])
        ax1.plot(self.q_prompt[:self.num_code, 0]/fb, self.q_prompt[:self.num_code, 1])
        ax1.set_title('I and Q')

        ax2.plot(self.code_nco[:self.num_code, 0]/fb, self.code_nco[:self.num_code, 1])
        ax2.set_title('Code NCO')

        ax3.plot(self.code_error[:self.num_code, 0]/fb, self.code_error[:self.num_code, 1])
        ax3.set_title('Code NCO discriminator')

        ax4.plot(self.doppler_nco[:self.num_doppler, 0]/fb, self.doppler_nco[:self.num_doppler, 1]%1)
        ax4.set_title('Doppler NCO')

        ax5.plot(self.doppler_error[:self.num_doppler, 0]/fb, self.doppler_error[:self.num_doppler, 1])
        ax5.set_title('Doppler discriminator')
        #ax5.plot(self.corr_early[:self.num_code, 0]/fb, self.corr_early[:self.num_code, 1])
        #ax5.plot(self.corr_late[:self.num_code, 0]/fb, self.corr_late[:self.num_code, 1])
        #ax5.set_title('Corr. PE(blue), PL(red)')

        ax_2_1.plot(self.i[:self.num_doppler, 1], self.q[:self.num_doppler, 1], '.')
        ax_2_1.set_xlim((-3000*self.graph, 3000*self.graph))
        ax_2_1.set_ylim((-3000*self.graph, 3000*self.graph))
        ax_2_1.set_title("Prompt Correlator Output")


        fig.tight_layout()
        plt.show()

LOAD_LENGTH = int(fs*5000e-3)
TOTAL_LENGTH = int(fs*2000e-3)
#TOTAL_SAMPLES = TOTAL_LENGTH//4

samples, i, q = readdata(FILE, 0, LOAD_LENGTH)

initial_doppler = 2000 
initial_code_delay = 339

doppler = Doppler(initial_doppler)
code = Code(PRN, initial_code_delay, fcw)
dop_length = 2
datastore = DataStore(samples, dop_length)

code_error = 0
code_adjust = 0

doppler_error = 0
doppler_adjust = 0

for n in range(samples):
    i_mixed, q_mixed = doppler.cancel_doppler(i[n], q[n])
    i_corr, q_corr = code.correlate_epl(i_mixed, q_mixed)
    doppler.accumulate_corr(i_corr, q_corr)

    if (n+1) % (num_coherent_data_sample*dop_length) == 0:
        print("Update: {}".format(n))
        (doppler_error, doppler_adjust) = doppler.update_parameter()
        datastore.store_doppler(doppler, doppler_error, doppler_adjust, n)
        doppler.clear_accumulator()

    if (n+1) % (num_coherent_data_sample*1) == 0:
        print("Update: {}".format(n))
        (code_error, code_adjust) = code.update_parameter()
        datastore.store_code(code, code_error, code_adjust, n)
        code.clear_accumulator()

datastore.show_graph()
