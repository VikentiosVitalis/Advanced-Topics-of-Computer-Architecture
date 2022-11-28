#!/usr/bin/env python3 

import sys
import numpy as np
import glob
import os
os.chdir(r'./outputs')
## We need matplotlib:
## $ apt-get install python-matplotlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

glob_list_ipc = []
glob_list_mpki = []

def calc_geom_mean(l):
 res = []
 for j in range(len(l[0])):
  temp_sum = 1
  counter = 0
  for i in range(len(l)):
   temp_sum *= l[i][j]
   counter += 1
  res.append(temp_sum ** (1/counter))
 return res


def calc_harm_mean(l):
	res = []
	for j in range(len(l[0])):
		temp_sum = 0
		counter = 0
		for i in range(len(l)):
			temp_sum += 1/l[i][j]
			counter += 1
		res.append(counter/temp_sum)	
	return res


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
	glob_list_mpki.append(mpki_Axis)	
	glob_list_ipc.append(ipc_Axis)
	
geo_mean_ipc = calc_geom_mean(glob_list_ipc)
geo_mean_mpki = calc_geom_mean(glob_list_mpki)

f, ax1 = plt.subplots()
ax1.grid(True)
line1 = ax1.plot(geo_mean_ipc, color='red', label="ipc", marker='x')
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
#plt.legend()
ax2 = ax1.twinx()
line2 = ax2.plot(geo_mean_mpki, color='green', label="mpki", marker='o')
lns = line1 + line2
labs = [l.get_label() for l in lns]
plt.title("IPC vs MPKI geometric mean")
#plt.legend()
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("geometric_mean_prefetch", bbox_inches="tight")


harm_mean_ipc = calc_harm_mean(glob_list_ipc)
harm_mean_mpki = calc_harm_mean(glob_list_mpki)

f, ax1 = plt.subplots()
line1 = ax1.plot(harm_mean_ipc, color='red', label="ipc", marker='x')
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
ax1.grid(True)
#plt.legend()
ax2 = ax1.twinx()
line2 = ax2.plot(harm_mean_mpki, color='green', label="mpki", marker='o')
lns = line1 + line2
labs = [l.get_label() for l in lns]
print(labs)
plt.title("IPC vs MPKI harmonic mean")
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("harmonic_mean_prefetch", bbox_inches="tight")
	
	
	
	
	
	

