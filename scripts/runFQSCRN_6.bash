#!/bin/bash

# this script sends several jobs each to their own compute node using an array, which limits the number of nodes used at one time

INDIR=$1
OUTDIR=$2
#TMPDIR=$3
NUMNODES=$3   # 5 to 10 on tamucc
FQPATTERN=$4

if [[ -z "$FQPATTERN" ]]; then
       FQPATTERN=*.fq.gz
fi
mkdir $OUTDIR

all_samples=( $(ls $INDIR/$FQPATTERN) )

JOBID=$(sbatch --array=0-$((${#all_samples[@]}-1))%${NUMNODES} \
       --output=slurm-fqscrn.%A.%a.out \
       --partition main \
       -t 96:00:00 \
       ../scripts/runFQSCRN_6.sbatch ${INDIR} ${OUTDIR} ${FQPATTERN})
NUMBER1=$(echo ${JOBID} | sed 's/[^0-9]*//g')

#Run Multiqc after array finishes
JOBID=$(sbatch --dependency=afterany:${NUMBER1} ../scripts/runMULTIQC.sbatch ${OUTDIR} fqscrn_report)
NUMBER2=$(echo ${JOBID} | sed 's/[^0-9]*//g')
