#!/bin/bash

SNIPER_EXE=/home/orfeas/sniper-7.3/run-sniper
SNIPER_CONFIG=/home/orfeas/Documents/Prohgmena_arxitektonikhs/ex3/advcomparch-ex3-helpcode/ask3.cfg
BINARY_CODE=/home/orfeas/Documents/Prohgmena_arxitektonikhs/ex3/advcomparch-ex3-helpcode/locks/sniper

OUTPUT_DIR_BASE="/home/orfeas/Documents/Prohgmena_arxitektonikhs/ex3/advcomparch-ex3-helpcode/outputs_sniper"
architectures="1_1_1 2_2_2 4_4_4 8_4_8 16_1_8"

LOCKTYPES="dtas_cas dtas_ts dttas_cas dttas_ts mutex"
iterations=1000

for LOCKTYPE in $LOCKTYPES; do
	executable=${BINARY_CODE}/locks-sniper-${LOCKTYPE}
	echo "Running: $(basename ${executable})"
	benchOutDir=${OUTPUT_DIR_BASE}/$BENCH
	mkdir -p $benchOutDir

for architecture in $architectures; do
	n_threads=$(echo $architecture | cut -d'_' -f1)
	l2=$(echo $architecture | cut -d'_' -f2)
	l3=$(echo $architecture | cut -d'_' -f3)

	for grain_size in 1 10 100; do
			outDir=$(printf "%s.NTHREADS_%02d-GRAIN_%03d.out" $LOCKTYPE $n_threads $grain_size)
			outDir="${OUTPUT_DIR_BASE}/${outDir}"

			sniper_cmd="${SNIPER_EXE} \\
				-c ${SNIPER_CONFIG} \\
				-n ${n_threads} \\
				-d ${outDir} \\
				--roi -g --perf_model/l2_cache/shared_cores=$l2 \\
				-g --perf_model/l3_cache/shared_cores=$l3 \\
				-- ${executable} ${n_threads} ${iterations} ${grain_size}"
				echo -e "CMD: $sniper_cmd\n"
				/bin/bash -c "time $sniper_cmd"
	done
done
done
