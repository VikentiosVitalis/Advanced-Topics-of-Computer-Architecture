#!/usr/bin/env python3

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import gmean
import os
os.chdir(r'/home/meglr/advcomparch-22-ex2-helpcode/outputs and graphs')
files = ["403.gcc", "429.mcf", "434.zeusmp", "436.cactusADM", "445.gobmk", "450.soplex", "456.hmmer", "458.sjeng", "459.GemsFDTD", "462.libquantum", "470.lbm", "471.omnetpp", "473.astar", "483.xalancbmk"]

predictors_to_plot = [ "  BTB-" ]
pred = ["512-1","512-2", "256-2", "256-4", "128-2" , "128-4", "64-4", "64-8"]
outputDir = "/home/meglr/advcomparch-22-ex2-helpcode/outputs and graphs/out_with_target/"


x_Axis = []
mpki_Axis = []
mpki_Axis1 = []
mpki_dict = {}
mpki_dict1 = {}
mpki_dict2 = {}
for i in files:
    opfile = i + ".cslab_btb_predictors.out"
    fp = open(opfile)
    title = i
    x_Axis = []
    mpki_Axis = []
    mpki_Axis1 = []
    mpki_Axis2 = []
    
    line = fp.readline()
    m = -1
    while line:
        tokens = line.split()
        if line.startswith("Total Instructions:"):
            total_ins = int(tokens[2])
        else:
            
            for pred_prefix in predictors_to_plot:
                
                if line.startswith(pred_prefix):
                    m = m +1
                    predictor_string = tokens[0].split(':')[0]                   
                    correct_predictions = int(tokens[1])
                    incorrect_predictions = int(tokens[2]) + int(tokens[4])
                    incorrect_target = int(tokens[4]) 
                    incorrect_direction = int(tokens[2])
                    #print(correct_predictions)
                    #print(incorrect_predictions)
                    x_Axis.append(pred[m])
                    mpki_Axis.append(incorrect_predictions / (total_ins / 1000.0))
                    mpki_Axis1.append(incorrect_target  / (total_ins / 1000.0))
                    mpki_Axis2.append(incorrect_direction  / (total_ins / 1000.0))
                    mpki_dict.setdefault(pred[m], []).append(incorrect_predictions / (total_ins / 1000.0))
                    mpki_dict1.setdefault(pred[m], []).append(incorrect_target / (total_ins / 1000.0))
                    mpki_dict2.setdefault(pred[m], []).append(incorrect_direction / (total_ins / 1000.0))
                   

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
    ax1.set_xlabel("entries-associativity")
    line1 = ax1.plot(mpki_Axis, label="mpki", color="red",marker='*')
    ax3 = ax1.twinx()
    ax3.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
    ax3.tick_params(axis='y', colors='blue')
    ax3.set_xticklabels(x_Axis, rotation=45)
    ax3.set_xlim(-0.5, len(x_Axis) - 0.5)
    ax3.set_ylim(min(mpki_Axis1)-0.01, max(mpki_Axis1) + 0.05)
    #ax3.set_ylabel("$target incorrect prediction PKI$")
    line3 = ax3.plot(mpki_Axis1, label="target mpki", color="blue",marker='x')
    ax2 = ax1
    ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
    ax2.tick_params(axis='y', colors='green')
    ax2.set_xticklabels(x_Axis, rotation=45)
    ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
    ax2.set_ylim(min(min(mpki_Axis), min(mpki_Axis2)) - 0.05, max(max(mpki_Axis),max(mpki_Axis2)) + 0.05)
    #ax3.set_ylabel("$direction incorrect prediction PKI$")
    line2 = ax2.plot(mpki_Axis2, label="direction mpki", color="green",marker='o')
    
    lns = line1 + line3+line2
    labs = [l.get_label() for l in lns]
    lgd = plt.legend(lns, labs)
    lgd.draw_frame(False)
    plt.title("MPKI, benchmark: " + title)
    plt.savefig(outputDir + title.replace('.', '-') + '.png', bbox_inches="tight", pad_inches = 0.3)
    plt.cla()
    plt.clf()

avg_mpk = []
avg_mpk1 = []
avg_mpk2 = []
for key in x_Axis:
    print(x_Axis)
    avg_mpk.append(gmean(mpki_dict[key]))
    avg_mpk1.append(gmean(mpki_dict1[key]))
    avg_mpk2.append(gmean(mpki_dict2[key]))
   
fig, ax1 = plt.subplots()
ax1.grid(True)

xAx = np.arange(len(x_Axis))

ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=25)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)

ax1.set_ylim(min(avg_mpk) - 0.05 * min(avg_mpk), max(avg_mpk) + 0.05 * max(avg_mpk))
plt.title("Geometric Average MPKI")
line1 = ax1.plot(avg_mpk, label="Geometric Mean mpki", color="red",marker='*')

ax3 = ax1.twinx()
ax3.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax3.set_xticklabels(x_Axis, rotation=25)
ax3.tick_params(axis='y', colors='green')
ax3.set_xlim(-0.5, len(x_Axis) - 0.5)
ax3.set_ylim(min(avg_mpk1) - 0.05 * min(avg_mpk1), max(avg_mpk1) + 0.05 * max(avg_mpk1))
line2 = ax3.plot(avg_mpk1, label="Geometric Mean target mpki", color="green",marker='o')

ax2 = ax1.twinx()
ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax2.set_xticklabels(x_Axis, rotation=25)
ax2.tick_params(axis='y', colors='blue')
ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
ax2.set_ylim(min(avg_mpk2) - 0.05 * min(avg_mpk2), max(avg_mpk2) + 0.05 * max(avg_mpk2))
line3 = ax2.plot(avg_mpk2, label="Geometric Mean direction mpki", color="blue",marker='x')


lns = line1+ line3+line2
labs = [l.get_label() for l in lns]
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
ax1.set_ylabel("$MPKI$")

plt.savefig(outputDir + 'mean.png', bbox_inches="tight", pad_inches=0.3)

