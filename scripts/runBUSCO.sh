#!/bin/bash
#SBATCH -c 32
#SBATCH --job-name=busco
#SBATCH --output=busco-%j.out

enable_lmod
module load container_env/0.1
module load busco/5.0.0

export SINGULARITY_BIND=/home/e1garcia

SPDIR=$1
SPAdesDIR=$2
SCAFFIG=$3
INDIR=$SPDIR/$SPAdesDIR


if [[ "$SCAFFIG" == "contigs" ]]; then
	crun busco --in $INDIR/contigs.fasta \
        	--out busco_contigs_results-${SPAdesDIR} \
        	--mode genome \
        	--lineage_dataset /home/e1garcia/shotgun_PIRE/abyss/busco_downloads/lineages/actinopterygii_odb10 \
        	-c $SLURM_CPUS_PER_TASK
elif [[ "$SCAFFIG" == "scaffolds" ]]; then
	crun busco --in $INDIR/scaffolds.fasta \
        	--out busco_scaffolds_results-${SPAdesDIR} \
        	--mode genome \
        	--lineage_dataset /home/e1garcia/shotgun_PIRE/abyss/busco_downloads/lineages/actinopterygii_odb10 \
        	-c $SLURM_CPUS_PER_TASK
else
        echo "Please enter type of assembly. Options:  contigs | scaffolds "
fi

# Copy summaries into busco-results dir
cp busco_*_results-${SPAdesDIR}/short* busco-results


#crun busco -i $INDIR/final_assembly.fa \
#           -o busco \
#           -m genome \
#           -l actinopterygii_odb10 \
#	         --config config_all.ini \
#           -c $SLURM_CPUS_PER_TASK

#crun busco --in $INDIR/contigs.fasta \
#	--out busco_contigs_results-${SPAdesDIR} \
#	--mode genome \
#	--lineage_dataset /home/e1garcia/shotgun_PIRE/abyss/busco_downloads/lineages/actinopterygii_odb10 \
#	-c $SLURM_CPUS_PER_TASK

#crun busco --in $INDIR/scaffolds.fasta \
#	--out busco_scaffolds_results-${SPAdesDIR} \
#	--mode genome \
#	--lineage_dataset /home/e1garcia/shotgun_PIRE/abyss/busco_downloads/lineages/actinopterygii_odb10 \
#	-c $SLURM_CPUS_PER_TASK

# if you need to rerun busco for a set of files use --force
