#!/bin/bash

FQPATTERN=*R1.fq.gz
fqPath=$1

# input the mitochondial reference path
path2gb=$2

#Pass in the maximum number of nodes to use at once
nodes=$3

# pass in number of threads. since wahab has 40 threads per node, when we have ram limitation issues
#suggested values: 20 (2 jobs per node on wahab), 40 (1 job per node on wahab)
threads=$4

# ramPerThread.  In the bash file, we have the number of threads allowed to run for a job being 1, so this is the ram per 1 thread or 1 node.  Ultimately, the previous threads command controlls how many jobs can run on one node, eg 20 = 2 jobs/wahab node and 40 = 1 job per wahab node
# suggested values:  180g, 233g, 360g
ramPerThread=$5

# queue to submit job to
# suggested values: main   or   himem
queue=$6

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

all_samples=$(ls ${fqPath}/${FQPATTERN} | \
	cut -d "_" -f 9-13 | \
	cut -d "-" -f 3-4)

all_samples=(${all_samples})

sbatch --array=0-$((${#all_samples[@]}-1))%${nodes} -p $queue -c ${threads} ${SCRIPTPATH}/runMitoFinder.sbatch ${fqPath} ${path2gb} ${threads} ${ramPerThread}

#for sample in ${all_samples[@]}; do
#    sbatch -p $queue -c ${threads} ${SCRIPTPATH}/runMitoFinder.sbatch ${sample} ${fqPath} ${path2gb} ${threads} ${ramPerThread}
#done
