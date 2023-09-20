#!/bin/bash
#SBATCH -c 40
#SBATCH --job-name=blastn
#SBATCH --output=blastn-parallel-%j.out

blastdbPATH=$1
blastnPATH=$2
taskNAME=$3
queryFASTA=$4
outFILE=$5
outCOLS=$6

echo blastdbPATH: $blastdbPATH
echo blastnPATH: $blastnPATH
echo taskNAME: $taskNAME
echo queryFASTA: $queryFASTA
echo outFILE: $outFILE
echo outCOLS: ${outCOLS[@]}

export SINGULARITY_BIND=/home/e1garcia
export BLASTDB=$blastdbPATH

# Step 1: Split the fasta file into individual sequence files
mkdir -p split_fasta
# awk '/^>/{if(NR>1){close(f)}; f="split_fasta/sequence_"NR".fasta";}{print > f}' $queryFASTA
awk '/^>/{if(NR>1){close(f)}; split($0,a," "); gsub(">","",a[1]); f="split_fasta/"a[1]".fasta";}{print > f}' $queryFASTA

# Step 2: Use GNU parallel to run blast on each sequence separately
mkdir -p split_output
parallel -j 5 "$blastnPATH -db nt -task $taskNAME -query {} -outfmt '$outCOLS' -max_target_seqs 1000 -max_hsps 1 -evalue 1e-25 -num_threads 8 -out split_output/{#}.out" ::: split_fasta/*.fasta

# Step 3: Concatenate the output files together
cat split_output/*.out > $outFILE

# Step 4: Cleanup - remove the split fasta files and split output files
#rm -r split_fasta
#rm -r split_output
