#!/bin/bash
#SBATCH -c 32
#SBATCH --job-name=busco
#SBATCH --output=busco-%j.out

enable_lmod
module load container_env/0.1
module load busco/5.0.0

export SINGULARITY_BIND=/home/e1garcia

crun busco --in ./$1 \
        	--out busco_scaffolds_results-redundans \
        	--mode genome \
        	--lineage_dataset /home/e1garcia/shotgun_PIRE/abyss/busco_downloads/lineages/actinopterygii_odb10 \
        	-c 40

