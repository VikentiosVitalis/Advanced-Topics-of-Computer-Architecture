#!/usr/bin/env python3

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import gmean
import os
os.chdir(r'/home/el18018/Desktop/Arch/parsec-3.0/advcomparch-22-ex2-helpcode/outputs')
files = ["403.gcc", "429.mcf", "434.zeusmp", "436.cactusADM", "445.gobmk", "450.soplex", "456.hmmer", "458.sjeng", "459.GemsFDTD", "462.libquantum", "470.lbm", "471.omnetpp", "473.astar", "483.xalancbmk"]

predictors_to_plot = [ "  BTB-" ]
outputDir = "/home/el18018/Desktop/Arch/parsec-3.0/advcomparch-22-ex2-helpcode/outputs/"


x_Axis = []
mpki_Axis = []
mpki_dict = {}

for i in files:
    opfile = i + ".cslab_btb_predictors.out"
    fp = open(opfile)
    title = i
    x_Axis = []
    mpki_Axis = []
    line = fp.readline()
    while line:
        tokens = line.split()
        if line.startswith("Total Instructions:"):
            total_ins = int(tokens[2])
        else:
            for pred_prefix in predictors_to_plot:
                if line.startswith(pred_prefix):
                    predictor_string = tokens[0].split(':')[0]
                    correct_predictions = int(tokens[1])
                    incorrect_predictions = int(tokens[2]) + int(tokens[4])
                    #print(correct_predictions)
                    #print(incorrect_predictions)
                    x_Axis.append(predictor_string)
                    mpki_Axis.append(incorrect_predictions / (total_ins / 1000.0))
                    mpki_dict.setdefault(predictor_string, []).append(incorrect_predictions / (total_ins / 1000.0))

        line = fp.readline()

    #print(mpki_Axis)
    fig, ax1 = plt.subplots()
    ax1.grid(True)

    xAx = np.arange(len(x_Axis))
    ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
    ax1.set_xticklabels(x_Axis, rotation=25)
    ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
    ax1.set_ylim(min(mpki_Axis) - 0.05, max(mpki_Axis) + 0.05)
    ax1.set_ylabel("$MPKI$")
    line1 = ax1.plot(mpki_Axis, label="mpki", color="red",marker='x')

    plt.title("MPKI of " + title)
    plt.savefig(outputDir + title.replace('.', '-') + '.png', bbox_inches="tight", pad_inches = 0.3)
    plt.cla()
    plt.clf()

avg_mpk = []
for key in x_Axis:
    avg_mpk.append(gmean(mpki_dict[key]))
fig, ax1 = plt.subplots()
ax1.grid(True)

xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=25)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(avg_mpk) - 0.05 * min(avg_mpk), max(avg_mpk) + 0.05 * max(avg_mpk))
plt.title("Geometric Average MPKI")
ax1.set_ylabel("$MPKI$")
line2 = ax1.plot(avg_mpk, label="Geometric Mean mpki", color="green",marker='o')
plt.savefig(outputDir + 'mean.png', bbox_inches="tight", pad_inches=0.3)
