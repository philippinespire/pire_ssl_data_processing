#!/bin/bash
#SBATCH --job-name=jelly
#SBATCH --output=jelly-%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32

enable_lmod
module load container_env pire_genome_assembly/2021.07.01

export SINGULARITY_BIND=/home/e1garcia

SPECIES_ID=$1
INDIR=$2

#CEB: no need for outdir, just write to the indir
#OUTDIR=$3

#mkdir $OUTDIR

#crun jellyfish count -C -m 21 -s 1000000000 -t 32 <(zcat ${INDIR}/*.fq.gz) -o ${OUTDIR}/${SPECIES_ID}_all_reads.jf &&
#crun jellyfish histo -t 32 ${OUTDIR}/${SPECIES_ID}_all_reads.jf > ${OUTDIR}/${SPECIES_ID}_all_reads.histo &&
#rm ${OUTDIR}/${SPECIES_ID}_all_reads.jf

crun jellyfish count -C -m 21 -s 1000000000 -t 32 <(zcat ${INDIR}/*.fq.gz) -o ${INDIR}/${SPECIES_ID}_all_reads.jf &&
crun jellyfish histo -t 32 ${INDIR}/${SPECIES_ID}_all_reads.jf > ${INDIR}/${SPECIES_ID}_all_reads.histo &&
rm ${INDIR}/${SPECIES_ID}_all_reads.jf

