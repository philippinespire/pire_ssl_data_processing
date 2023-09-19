#!/bin/bash -l

#SBATCH --job-name=mtofndr
#SBATCH -o mitofinder_annotate-%j.out
#SBATCH --time=00:00:00
#SBATCH -p main
#SBATCH --cpus-per-task=1

enable_lmod 

module load container_env mitofinder/1.4.1 
export SINGULARITY_BIND=/home/e1garcia

SSL_DIR=$1
ASSEMBLY=$2
mtGENOMES=$3
seqID=$4
outDIR=$5

mkdir ${SSL_DIR}/$outDIR

cd ${SSL_DIR}/$outDIR

crun mitofinder -j $seqID -a $ASSEMBLY -r $mtGENOMES -o 2
