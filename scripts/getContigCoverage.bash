#!/bin/bash

# this script gets the coverage information from contigs assembled by mitofinder
# this is slow and will be replaced with a parallel version

inFILE=$1
outFILE=$2

rm $outFILE

# Print the header line with the new column name to the output file
head -n 1 $inFILE | awk -F'\t' '{print $0"\tcontig_coverage"}' > $outFILE

# Skip the first line (header line)
tail -n +2 $inFILE | while IFS=$'\t' read -r assembler treatment initial_contig_name contig_number length gc_content circularization; do
  # Initialize contig_coverage variable
  contig_coverage="NA"

  # Check if the assembler is megahit
  if [ "$assembler" == "megahit" ]; then
    # Construct the file path
    filepath="${treatment}/${treatment}_${assembler}/${treatment}_${assembler}.contigs.fa"

    # Use grep to find the line with the Initial_Contig_Name in the constructed file path and extract the coverage information
    contig_coverage=$(grep ">${initial_contig_name} " "$filepath" | sed -e 's/^.*multi=//' -e 's/ len.*$//')
  elif [[ "$assembler" == *"spades"* ]]; then
    contig_coverage=$(echo "$initial_contig_name" | sed 's/^.*_cov_//')
  fi

  # Print the line with the new column value to the output file
  echo -e "${assembler}\t${treatment}\t${initial_contig_name}\t${contig_number}\t${length}\t${gc_content}\t${circularization}\t${contig_coverage}" >> $outFILE
done
