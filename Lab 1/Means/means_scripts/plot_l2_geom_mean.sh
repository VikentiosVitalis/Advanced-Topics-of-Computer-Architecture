#!/usr/bin/env python3
import sys
import numpy as np
import glob
import os
os.chdir(r'./outputs_L2')
## We need matplotlib:
## $ apt-get install python-matplotlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

list1 = ["L2_0512_08_064", "L2_0512_08_128", "L2_0512_08_256", "L2_1024_08_064", "L2_1024_08_128", "L2_1024_08_256", "L2_1024_16_064", "L2_1024_16_128", "L2_1024_16_256", "L2_2048_16_064", "L2_2048_16_128", "L2_2048_16_256"]

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
	for j in list1:
		##sys.argv[1:]:
		outFile = i + ".dcache_cslab." + j + ".out"
		fp = open(outFile)
		line = fp.readline()
		while line:
			tokens = line.split()
			if (line.startswith("Total Instructions: ")):
				total_instructions = int(tokens[2])
			elif (line.startswith("IPC:")):
				ipc = float(tokens[1])
			elif (line.startswith("  L2-Data Cache")):
				sizeLine = fp.readline()
				L2_size = sizeLine.split()[1]
				bsizeLine = fp.readline()
				L2_bsize = bsizeLine.split()[2]
				assocLine = fp.readline()
				L2_assoc = assocLine.split()[1]
			elif (line.startswith("L2-Total-Misses")):
				L2_total_misses = int(tokens[1])
				L2_miss_rate = float(tokens[2].split('%')[0])
				mpki = L2_total_misses / (total_instructions / 1000.0)


			line = fp.readline()

		fp.close()

		L2ConfigStr = '{}K.{}.{}B'.format(L2_size,L2_assoc,L2_bsize)
		print(L2ConfigStr)
		x_Axis.append(L2ConfigStr)
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
plt.savefig("geometric_mean_L2", bbox_inches="tight")


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
plt.savefig("harmonic_mean_L2", bbox_inches="tight")

