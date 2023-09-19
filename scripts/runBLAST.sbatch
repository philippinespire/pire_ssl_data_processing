#!/bin/bash
#SBATCH -c 40
#SBATCH --job-name=blast_assemblyname
#SBATCH --output=blast_assemblyname-%j.out

#blastdbPATH=/home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/nt
blastdbPATH=$1

#blastnPATH=/home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/ncbi-blast-2.11.0+/bin/blastn
blastnPATH=$2

#queryFASTA=successful_genes_NT.fasta
queryFASTA=$3

#outFILE=successful_genes_NT.blastn
outFILE=$4

export SINGULARITY_BIND=/home/e1garcia
export BLASTDB=$blastdbPATH

$blastnPATH -db nt \
	-query $queryFASTA \
	-outfmt "6 qseqid staxids bitscore std" \
	-max_target_seqs 10 \
	-max_hsps 1 \
	-evalue 1e-25 \
	-num_threads 40 \
	-out /scratch/breid/Lle_seqs/contam/Lle_all_contam_dipbub20/results/blobtools/$outFILE
