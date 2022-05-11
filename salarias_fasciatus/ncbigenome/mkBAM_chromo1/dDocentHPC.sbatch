#!/bin/bash -l

#SBATCH --job-name=fltrBAM
#SBATCH -o fltrBAM-%j.out
#SBATCH -p main
#SBATCH -c 40
#SBATCH --mail-user=e1garcia@odu.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=END

enable_lmod
module load container_env ddocent

CONFIG=$1

crun bash dDocentHPC.bash mkBAM $CONFIG

#this will use dDocent fltrBAM to filter the BAM files
crun bash dDocentHPC.bash fltrBAM $CONFIG

#this will use freebayes to genotype the bam files and make a VCF
#crun bash dDocentHPC.bash mkVCF $CONFIG
