#!/bin/bash -l

#SBATCH --job-name=mtofndr
#SBATCH -o mitofinder_annotate-%j.out
#SBATCH --time=00:00:00
#SBATCH -p main
#SBATCH --cpus-per-task=1

enable_lmod 

module load container_env mitofinder/1.4.1 
export SINGULARITY_BIND=/home/e1garcia

ASSEMBLY=$1
mtGENOMES=$2
seqID=$3
outDIR=$4

mkdir $outDIR

cd $outDIR

crun mitofinder -j $seqID -a $ASSEMBLY -r $mtGENOMES -o 2
