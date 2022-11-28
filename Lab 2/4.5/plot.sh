#!/usr/bin/env python3

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import mstats
from scipy.stats import gmean
import os
os.chdir(r'/mnt/e/pin/parsec-3.0/advcomparch-22-ex2-helpcode/sims/4_5')
outputDir = "/mnt/e/pin/parsec-3.0/advcomparch-22-ex2-helpcode/graphs"

## For nbit predictors
predictors_to_plot = ["  StaticTakenPredictor", "  BTFNTPredictor","  Nbit-8K-4","  Pentium-M","  LocalHistory-PHT(8K,2)-BHT(4K,4)","  LocalHistory-PHT(8K,2)-BHT(8K,2)","  GlobalHistory-PHT(16K,2)-BHR(4)","  GlobalHistory-PHT(8K,4)-BHR(4)","  GlobalHistory-PHT(16K,2)-BHR(8)","  GlobalHistory-PHT(8K,4)-BHR(8)","  ALPHA-PREDICTORLocalHistory-PHT(1K,3)-BHT(1K,10),GlobalHistory-PHT(4K,2)-BHR(12))","  Tournament(GlobalHistory-PHT(8192,2)-BHR(4),LocalHistory-PHT(4096,2)-BHT(2048,4))","  Tournament(LocalHistory-PHT(8192,1)-BHT(2048,4),LocalHistory-PHT(4096,2)-BHT(2048,4))","  Tournament(GlobalHistory-PHT(4096,4)-BHR(4),Nbit-16K-1)","  Tournament(LocalHistory-PHT(4096,2)-BHT(2048,4),Nbit-16K-1)"]
pred_to_print = ["StaticTakenPred", "BTFNTPredictor", "Nbit-8K-4", "Pentium-M", "LocalHPredictor#1",  "LocalHPredictor#2",  "GlobalHPredictor#1",  "GlobalHPredictor#2",  "GlobalHPredictor#3",  "GlobalHPredictor#4",  "AlphaPredictor",  "Tournament#1",  "  Tournament#2",  "Tournament#3",  "Tournament#4"]
files = ["403.gcc", "429.mcf", "434.zeusmp", "436.cactusADM", "445.gobmk", "450.soplex", "456.hmmer", "458.sjeng", "459.GemsFDTD", "462.libquantum", "470.lbm", "471.omnetpp", "473.astar", "483.xalancbmk"]

for outFile in files:
    x_Axis = []
    mpki_Axis = []
    BenchmarkName = outFile
    outFile = outFile + ".4_5.out"
    fp = open(outFile)
    line = fp.readline()
    while line:
            tokens = line.split()
            if (line.startswith("Total Instructions:")):
                    total_ins = float(tokens[2])
            else:
                    for i, pred_prefix in enumerate(predictors_to_plot):
                            if line.startswith(pred_prefix):
                                    predictor_string = tokens[0].split(':')[0]
                                    tcorrect_predictions = float(tokens[1])
                                    incorrect_predictions = float(tokens[2])
                                    print(i)
                                    x_Axis.append(pred_to_print[i])
                                    mpki_Axis.append(incorrect_predictions / (total_ins / 1000.0))
                                    print(predictor_string, " ", (incorrect_predictions / (total_ins / 1000.0)))

            line = fp.readline()

    fig, ax1 = plt.subplots()
    ax1.grid(True)

    xAx = np.arange(len(x_Axis))
    ax1.bar(xAx, mpki_Axis, align='center', alpha=0.5, color='maroon')

    ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
    ax1.set_xticklabels(x_Axis, rotation=85)
    ax1.set_ylabel("$MPKI$")

    plt.title(BenchmarkName + "\n Mean PKI - Different Predictors")
    plt.savefig(outputDir + BenchmarkName + '.png',bbox_inches="tight")
