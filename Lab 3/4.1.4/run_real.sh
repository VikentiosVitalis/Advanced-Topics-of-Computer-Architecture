#!/bin/bash

## Example of usage: ./run_sniper.sh gccw
## Modify the following paths appropriately
## CAUTION: use only absolute paths below!!!
BINARY_CODE=/home/el18018/Desktop/Arch/advcomparch-ex3-helpcode/ex4_locks
OUTPUT_DIR_BASE="/home/el18018/Desktop/Arch/advcomparch-ex3-helpcode/outputs"

LOCKTYPES="dtas_cas dtas_ts dttas_cas dttas_ts mutex"
iterations=150000000
for LOCKTYPE in $LOCKTYPES; do
	executable=${BINARY_CODE}/locks-real-${LOCKTYPE}
	echo "Running: $(basename ${executable})"
	benchOutDir=${OUTPUT_DIR_BASE}/$BENCH
	mkdir -p $benchOutDir
	for n_threads in 1 2 4; do
	for grain_size in 1 10 100; do
			outDir=$(printf "%s.NTHREADS_%02d-GRAIN_%03d.out" $LOCKTYPE $n_threads $grain_size)
			outDir="${OUTPUT_DIR_BASE}/${outDir}"
			mkdir -p $outDir
			outfile=$outDir/info.out
			touch $outfile 
			CMD="${executable} ${n_threads} ${iterations} ${grain_size}"
			echo -e "CMD: $CMD\n"
			/bin/bash -c "(time $CMD) &> $outfile"
			cat $outfile
	done
	done
done
