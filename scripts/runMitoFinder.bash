#!/bin/bash

#bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMitoFinder.bash inputFqGzPatterns.txt ../fqgz_processing/nowga_fq_fp1_clmp_fp2_fqscrn_rprd ../mitofinder/mitofinder_refpanel 11 40 320 main

#
fqPatternFile=$1

#fqPath=../fqgz_processing/nowga_fq_fp1_clmp_fp2_fqscrn_rprd
fqPath=$2

outDIR=$3

# input the mitochondial reference genome fasta file path
#path2gb=/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/mtGenomes/<NameOfFile>.gb
path2gb=$4

#Pass in the maximum number of nodes to use at once
nodes=$5

# pass in number of threads. since wahab has 40 threads per node, when we have ram limitation issues
#suggested values: 20 (2 jobs per node on wahab), 40 (1 job per node on wahab)
threads=$6

# ramPerThread in gb.  In the bash file, we have the number of threads allowed to run for a job being 1, so this is the ram per 1 thread or 1 node.  Ultimately, the previous threads command controlls how many jobs can run on one node, eg 20 = 2 jobs/wahab node and 40 = 1 job per wahab node
# suggested values:  180, 233, 360
ramPerThreads=$7

# queue to submit job to
# suggested values: main   or   himem
queue=$8

assembler=$9 # --megahit or --metaspades
maxcontigsize=${10}
minqcov=${11}

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

#all_samples=(${all_samples})
all_samples=($(cat ${fqPatternFile}))

mkdir $outDIR
cp $fqPatternFile $outDIR
cd $outDIR

sbatch --array=0-$((${#all_samples[@]}-1))%${nodes} -p $queue -c ${threads} ${SCRIPTPATH}/runMitoFinder.sbatch ${fqPatternFile} ${fqPath} ${path2gb} ${threads} ${ramPerThreads} ${assembler} ${maxcontigsize} ${minqcov}
