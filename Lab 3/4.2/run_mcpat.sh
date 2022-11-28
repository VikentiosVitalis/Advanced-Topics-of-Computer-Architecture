#!/bin/bash

OUTPUT_DIR_BASE="/home/el18018/Desktop/Arch/advcomparch-ex3-helpcode/outputs_4.2"
SNIPER_DIR="/home/el18018/sniper-7.3"

echo "Outputs to be processed located in: $OUTPUT_DIR_BASE"

for benchdir in $OUTPUT_DIR_BASE/*; do
  bench=$(basename $benchdir)
  echo -e "\nProcessing directory: $bench"

  cmd="${SNIPER_DIR}/tools/advcomparch_mcpat.py -d $benchdir -t total -o $benchdir/power > $benchdir/power.total.out"
  echo CMD: $cmd
  /bin/bash -c "$cmd"
done
