#!/bin/bash -l

#SBATCH --job-name=mkBAM-mkVCF
#SBATCH -o mkBAM-fltrBAM-mkVCF-%j.out
#SBATCH -p main
#SBATCH -c 40

enable_lmod
module load container_env ddocent

CONFIG=$1

crun bash ../../scripts/dDocentHPC/dDocentHPC.bash mkBAM $CONFIG

#this will use dDocent fltrBAM to filter the BAM files
crun bash ../../scripts/dDocentHPC/dDocentHPC.bash fltrBAM $CONFIG

#this will use freebayes to genotype the bam files and make a VCF
crun bash ../../scripts/dDocentHPC/dDocentHPC.bash mkVCF $CONFIG
