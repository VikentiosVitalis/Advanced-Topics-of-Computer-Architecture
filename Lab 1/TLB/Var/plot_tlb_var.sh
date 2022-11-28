#!/usr/bin/env python3

import sys
import numpy as np
import glob
import os
os.chdir(r'/home/meglr/Downloads/parsec-3.0/parsec_workspace/outputs_tlb')
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
			elif (line.startswith("Tlb-Total-Misses")):
				l1_total_misses = int(tokens[1])
				l1_miss_rate = float(tokens[2].split('%')[0])
				mpki = l1_total_misses / (total_instructions / 1000.0)


			line = fp.readline()

		fp.close()
		
		ref_size = 64
		ref_assoc = 1
		size_factor =1.15**np.log2(int(l1_size)/ref_size)
		assoc_factor = 1.1**np.log2(int(l1_assoc)/ref_assoc)
		new_cycle = 1*size_factor*assoc_factor
		ipc = ipc/float(new_cycle)



		l1ConfigStr = '{}entr.{}.{}B'.format(l1_size,l1_assoc,l1_bsize)
		print(l1ConfigStr)
		x_Axis.append(l1ConfigStr)
		ipc_Axis.append(ipc)
		mpki_Axis.append(mpki)

	print(x_Axis)
	print(ipc_Axis)
	print(mpki_Axis)

	fig, ax1 = plt.subplots()
	ax1.grid(True)
	ax1.set_xlabel("Entries.Assoc.PageSize")

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
	line2 = ax2.plot(mpki_Axis, label="TLBD_mpki", color="green",marker='o')

	lns = line1 + line2
	labs = [l.get_label() for l in lns]

	plt.title(i+": IPC vs MPKI")
	lgd = plt.legend(lns, labs)
	lgd.draw_frame(False)
	plt.savefig("./PNG/"+i+"_TLB_var.png",bbox_inches="tight")
