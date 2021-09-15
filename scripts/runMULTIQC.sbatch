#!/bin/bash -l

#this script runs multiqc on specified dir

#SBATCH --job-name=mqc
#SBATCH -o ./logs/mqc_-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
module load multiqc
<<<<<<< HEAD
=======

export SINGULARITY_BIND=/home/e1garcia
>>>>>>> 80e69e7782512ec74304616bfa2a70afacc8e183

DIR=$1
REPORTNAME=$2

# run multiqc on the fp1, fp2 and fastq screen results

crun multiqc $DIR -n $DIR/$REPORTNAME
