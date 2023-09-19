#!/bin/bash
#SBATCH -c 40
#SBATCH --job-name=blastn
#SBATCH --output=blastn-%j.out

# blastdbPATH=/home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/nt
blastdbPATH=$1

# blastnPATH=/home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/ncbi-blast-2.11.0+/bin/blastn
blastnPATH=$2

# taskNAME=megablast
# https://www.ncbi.nlm.nih.gov/books/NBK569839/#usrman_BLAST_feat.Tasks
taskNAME=$3

# queryFASTA=successful_genes_NT.fasta
queryFASTA=$4

# outFILE=successful_genes_NT.blastn
outFILE=$5

# outCOLS="6 qseqid staxids sscinames sskingdoms saccver pident qcovs length mismatch gapopen qstart qend sstart send evalue bitscore"
outCOLS=$6

echo blastdbPATH: $blastdbPATH
echo blastnPATH: $blastnPATH
echo taskNAME: $taskNAME
echo queryFASTA: $queryFASTA
echo outFILE: $outFILE
echo outCOLS: $outCOLS

export SINGULARITY_BIND=/home/e1garcia
export BLASTDB=$blastdbPATH

$blastnPATH -db $blastdbPATH \
	-task $taskNAME
	-query $queryFASTA \
	-outfmt "$outCOLS" \
	-max_target_seqs 1000 \
	-max_hsps 1 \
	-evalue 1e-25 \
	-num_threads 40 \
	-out $outFILE
