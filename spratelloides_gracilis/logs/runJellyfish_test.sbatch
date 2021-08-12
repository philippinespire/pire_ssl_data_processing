#!/bin/bash
#SBATCH --job-name=jelly2
#SBATCH --output=jelly2-%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

enable_lmod
module load container_env pire_genome_assembly/2021.03.25

export SINGULARITY_BIND=/home/e1garcia

SPECIES_ID=$1
FILES_No=$(ls fq_fp1_clmparray_fp2_fqscrn_repaired/*.gz | wc -l)

if [[ "$FILES_No" -ge 40 ]]; then
        PARALLELISM=40
else
	PARALLELISM=$FILES_No
fi

# Make a temporary copy of sequence files in parallel
#mkdir unzipTemp
#mkdir zipTemp
#ls fq_fp1_clmparray_fp2_fqscrn_repaired/*.gz | parallel --no-notice -kj${PARALLELISM} cp {} unzipTemp
#ls fq_fp1_clmparray_fp2_fqscrn_repaired/SgC0072B* | parallel --no-notice -kj${PARALLELISM} cp {} zipTemp

# Unzip temporary files in parallel
#cd unzipTemp
#ls *gz | parallel -kj${PARALLELISM} gunzip {}

#crun jellyfish count -C -m 21 -s 1000000000 -t 10 fq_fp1_clmparray_fp2_fqscrn_repaired/SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_clmp.fp2_repr.R*.fq.gz -o jellyfish_out/${SPECIES_ID}_all_reads.jf
#crun jellyfish histo -t 10 jellyfish_out/${SPECIES_ID}_all_reads.jf > jellyfish_out/${SPECIES_ID}_all_reads.histo

crun jellyfish count -C -m 21 -s 1000000000 -t 40 unzipped/*fq -o jellyfish_out/${SPECIES_ID}_all_reads.jf
crun jellyfish histo -t 40 jellyfish_out/${SPECIES_ID}_all_reads.jf > jellyfish_out/${SPECIES_ID}_all_reads.histo
#SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_clmp.fp2_repr.R2.fq.gz

# Clean up
#rm -f -R unzipTemp

#crun jellyfish count -C -m 21 -s 1000000000 -t 40 <(zcat fq_fp1_clmparray_fp2_fqscrn_repaired/*gz) -o jellyfish_out2/${SPECIES_ID}_all_reads.jf
#crun jellyfish histo -t 40 jellyfish_out2/${SPECIES_ID}_all_reads.jf > jellyfish_out2/${SPECIES_ID}_all_reads.histo
