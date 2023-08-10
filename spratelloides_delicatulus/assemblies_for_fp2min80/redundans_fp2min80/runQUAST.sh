#!/bin/bash
#SBATCH -c 32
#SBATCH --job-name=quast
#SBATCH --output=quast-%j.out


module load container_env pire_genome_assembly/2021.03.25
crun quast.py $1 -o quast-reports --est-ref-size 830000000 -s --eukaryote --large
