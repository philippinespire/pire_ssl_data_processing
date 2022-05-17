#!/bin/bash -l

#SBATCH --job-name=mqc
#SBATCH -o mqc-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
module load multiqc

DIR=$1
REPORTNAME=$2

srun crun multiqc $DIR -n $DIR/$REPORTNAME
