#!/bin/bash

## Modify the following paths appropriately
PARSEC_PATH=/home/orfeas/Documents/Prohgmena_arxitektonikhs/parsec-3.0
PIN_EXE=/home/orfeas/Documents/Prohgmena_arxitektonikhs/pin-3.22-98547-g7a303a835-gcc-linux/pin
PIN_TOOL=/home/orfeas/Documents/Prohgmena_arxitektonikhs/parsec-3.0/advcomparch-ex1-helpcode/pintool/obj-intel64/simulator.so

CMDS_FILE=./cmds_simlarge.txt
outDir="./outputs/"

export LD_LIBRARY_PATH=$PARSEC_PATH/pkgs/libs/hooks/inst/amd64-linux.gcc-serial/lib/

## Triples of <cache_size>_<associativity>_<block_size>
L2prf_="1 2 4 8 16 32 64"
##IFS="," read -a L2prf_ <<< $CONFS 

L2size=1024
L2assoc=8
L2bsize=128
L1size=32
L1bsize=64
L1assoc=8
TLBe=64
TLBp=4096
TLBa=4
##L2prf=0

BENCHMARKS="blackscholes bodytrack canneal fluidanimate freqmine rtview swaptions streamcluster"

##BENCHMARKS="freqmine rtview swaptions streamcluster"

for BENCH in $BENCHMARKS; do
	cmd=$(cat ${CMDS_FILE} | grep "$BENCH")
for conf in $L2prf_; do
	## Get parameters
##    L1size=$(echo $conf | cut -d'_' -f1)
##    L1assoc=$(echo $conf | cut -d'_' -f2)
##    L1bsize=$(echo $conf | cut -d'_' -f3)
     L2prf=$(echo $conf)	
     printf "L2prf = %s\n" "${L2prf}"	
	outFile=$(printf "%s.dcache_cslab.%02d.out" $BENCH ${L2prf})
	outFile="$outDir/$outFile"

	pin_cmd="$PIN_EXE -t $PIN_TOOL -o $outFile -L1c ${L1size} -L1a ${L1assoc} -L1b ${L1bsize} -L2c ${L2size} -L2a ${L2assoc} -L2b ${L2bsize} -TLBe ${TLBe} -TLBp ${TLBp} -TLBa ${TLBa} -L2prf ${L2prf} -- $cmd"

	time $pin_cmd
done
done
