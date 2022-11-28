#!/usr/bin/env python3 

import sys
import numpy as np
import glob
import os
os.chdir(r'/home/orfeas/Documents/Prohgmena_arxitektonikhs/parsec-3.0/advcomparch-ex1-helpcode/outputs')
## We need matplotlib:
## $ apt-get install python-matplotlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

for i in ["blackscholes", "bodytrack", "canneal" ,"fluidanimate","freqmine", "rtview", "swaptions" ,"streamcluster"]:
	x_Axis = []
	ipc_Axis = []
	mpki_Axis = []
	files = glob.glob(i+'*.out')
	files.sort()  
	for outFile in files:
		##sys.argv[1:]:
		print("file = :", outFile);
		fp = open(outFile)
		line = fp.readline()
		while line:
			tokens = line.split()
			if (line.startswith("Total Instructions: ")):
				total_instructions = int(tokens[2])
			elif (line.startswith("IPC:")):
				ipc = float(tokens[1])
			elif (line.startswith("  Data Tlb")):
				sizeLine = fp.readline()
				l1_size = sizeLine.split()[1]
				bsizeLine = fp.readline()
				l1_bsize = bsizeLine.split()[2]
				assocLine = fp.readline()
				l1_assoc = assocLine.split()[1]
			elif (line.startswith("L2-Total-Misses")):
				
				l1_total_misses = int(tokens[1])
				#print("l2 total misses :", l1_total_misses)
				l1_miss_rate = float(tokens[2].split('%')[0])
				mpki = l1_total_misses / (total_instructions / 1000.0)
				#print("mpki =", mpki)
			
			elif (line.startswith("L2_prefetching: Yes ( ")):
				pref_num = int(line.split("(")[1].split(")")[0].replace(" ", ""))
				#print("prefetchinggggggggggggg :", pref_num)
			line = fp.readline()
		
		fp.close() 
		#print("mpki after while =", mpki)
		l1ConfigStr = '{} blocks'.format(pref_num)
		print(l1ConfigStr)
		x_Axis.append(l1ConfigStr)
		ipc_Axis.append(ipc)
		mpki_Axis.append(mpki)

	print(x_Axis)
	print(ipc_Axis)
	print(mpki_Axis)

	fig, ax1 = plt.subplots()
	ax1.grid(True)
	ax1.set_xlabel("NEXT-N-LINE prefetching")

	xAx = np.arange(len(x_Axis))
	ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
	ax1.set_xticklabels(x_Axis, rotation=45)
	ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
	ax1.set_ylim(min(ipc_Axis) - 0.05 * min(ipc_Axis), max(ipc_Axis) + 0.05 * max(ipc_Axis))
	ax1.set_ylabel("$IPC$")
	line1 = ax1.plot(ipc_Axis, label="ipc", color="red",marker='x')

	ax2 = ax1.twinx()
	ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
	ax2.set_xticklabels(x_Axis, rotation=45)
	ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
	ax2.set_ylim(min(mpki_Axis) - 0.05 * min(mpki_Axis), max(mpki_Axis) + 0.05 * max(mpki_Axis))
	ax2.set_ylabel("$MPKI$")
	line2 = ax2.plot(mpki_Axis, label="mpki prefetching", color="green",marker='o')

	lns = line1 + line2
	labs = [l.get_label() for l in lns]

	plt.title(i+": IPC vs MPKI")
	lgd = plt.legend(lns, labs)
	lgd.draw_frame(False)
	plt.savefig( i +"_prefetching.png",bbox_inches="tight")
