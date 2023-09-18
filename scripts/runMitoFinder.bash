#!/bin/bash


#bash ../../../shotgun_PIRE/pire_ssl_data_processing/scripts/runMitoFinder.bash inputFqGzPatterns.txt ../fqgz_processing/nowga_fq_fp1_clmp_fp2_fqscrn_rprd ../mitofinder/mitofinder_refpanel 7 32 480 himem
#bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMitoFinder.bash inputFqGzPatterns.txt ../fqgz_processing/nowga_fq_fp1_clmp_fp2_fqscrn_rprd ../mitofinder/mitofinder_refpanel 11 40 320 main

#FQPATTERN=*R1.fq.gz

#
fqPatternFile=$1

#fqPath=../fqgz_processing/nowga_fq_fp1_clmp_fp2_fqscrn_rprd
fqPath=$2

# input the mitochondial reference path
#path2gb=../mitofinder/mitofinder_refpanel
path2gb=$3

#Pass in the maximum number of nodes to use at once
nodes=$4

# pass in number of threads. since wahab has 40 threads per node, when we have ram limitation issues
#suggested values: 20 (2 jobs per node on wahab), 40 (1 job per node on wahab)
threads=$5

# ramPerThread in gb.  In the bash file, we have the number of threads allowed to run for a job being 1, so this is the ram per 1 thread or 1 node.  Ultimately, the previous threads command controlls how many jobs can run on one node, eg 20 = 2 jobs/wahab node and 40 = 1 job per wahab node
# suggested values:  180, 233, 360
ramPerThreads=$6

# queue to submit job to
# suggested values: main   or   himem
queue=$7

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

#all_samples=$(ls ${fqPath}/${FQPATTERN} | \
#	cut -d "_" -f 9-13 | \
#	cut -d "-" -f 3-4)

#all_samples=(${all_samples})
all_samples=($(cat ${fqPatternFile}))

sbatch --array=0-$((${#all_samples[@]}-1))%${nodes} -p $queue -c ${threads} ${SCRIPTPATH}/runMitoFinder.sbatch ${fqPatternFile} ${fqPath} ${path2gb} ${threads} ${ramPerThreads}

#for sample in ${all_samples[@]}; do
#    sbatch -p $queue -c ${threads} ${SCRIPTPATH}/runMitoFinder.sbatch ${sample} ${fqPath} ${path2gb} ${threads} ${ramPerThread}
#done
