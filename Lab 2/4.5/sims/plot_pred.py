#!/usr/bin/env python3

import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import os
os.chdir("")
## For nbit predictors
predictors_to_plot = ["  StaticTakenPredictor", "  BTFNTPredictor", "  Nbit-16K-2", "  Pentium-M", "  Local_1",  "  Local_2",  "  Global_1",  "  Global_2",  "  Global_3",  "  Global_4",  "  Alpha",  "  Tournament_1",  "  Tournament_2",  "  Tournament_3",  "  Tournament_4"]

files = ["403.gcc", "429.mcf", "434.zeusmp", "436.cactusADM", "445.gobmk", "450.soplex", "456.hmmer", "458.sjeng", "459.GemsFDTD", "462.libquantum", "470.lbm", "471.omnetpp", "473.astar", "483.xalancbmk"]


x_Axis = []
mpki_Axis = []
mpki_dict = {}
for i in files:
	openfile = i + ".cslab_btb_predictors.out"
	fp = open(openfile)
	line = fp.readline()
	while line:
		tokens = line.split()
		if (line.startswith("Total Instructions:")):
			total_ins = float(tokens[2])
		else:
			for pred_prefix in predictors_to_plot:
				if line.startswith(pred_prefix):
					predictor_string = tokens[0].split(':')[0]
					tcorrect_predictions = float(tokens[1])
					incorrect_predictions = float(tokens[2])
					x_Axis.append(predictor_string)
					mpki_Axis.append(incorrect_predictions / (total_ins / 1000.0))
					#print(predictor_string, " ", type_of_branch / total_br)
					mpki_dict.setdefault(predictor_string, []).append(incorrect_predictions / (total_ins / 1000.0))
		line = fp.readline()
	
	fig, ax1 = plt.subplots()
	ax1.grid(True)

	xAx = np.arange(len(x_Axis))
	ax1.bar(xAx, mpki_Axis, align='center', alpha=0.5, color='maroon')

	ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
	ax1.set_xticklabels(x_Axis, rotation=45)
	ax1.set_ylabel("$MPKI$")
	#line1 = ax1.plot(y_Axis, label="mpki", color="",marker='x')

	plt.title("MPKI - Different Predictors")
	plt.savefig(("plot"),bbox_inches="tight")
	
#save the means
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
