#!/bin/bash -l

# mitofinder_ssl.bash is a bash script for running MitoFinder (https://github.com/RemiAllio/MitoFinder) on genome assembly produced through the ssl pipeline
# the script executes the runmitofinder_ssl.sbatch script
# outputs are the full output from MitoFinder for the assembly, as well as a summary FASTA file with all COI sequences recovered from the genomes and a "completeness" summary of the final results giving # genes recovered (ideal = 13 coding genes, 22 tRNAs, and 2 rRNAs)
# script assumes the assembly .fasta is named "scaffolds.fasta" as per spades naming convention 
# subdirectory naming convention = mitofinder_{Species_Code}_{Assembly}
# you will also need to provide a tab-separated config file with no header and 4 fields: 
# Directory (path to the base directory, e.g. /home/breid/denovo_genome_assembly/mitofinder/mitofinder_batch1)
# Species_code (three-letter PIRE code)
# Assembly (some descriptive name, could be treatment, could be "best", etc)
# Family (family to which the species belongs)
# I have a folder containing a panel of reference Genbank files for our PIRE species of interest at /home/breid/denovo_genome_assembly/mitofinder/mitofinder_refpanel, the script will copy the family-appropriate .gb file from here
# If we add more species from outside the 12 families currently represented we might have to update this
# this is a modification that copies scaffolds to the denovo_genome_assembly/mitofinder_all folder first
# run (with: mitofinder_ssl.bash mitofinder.config) from the assembly directory

CONFIG=$1

mkdir mitofinder

while read i; do
	combo=$(echo $i |  tr " " "\t" |cut -f2,3,4 | tr "\t" "_")
	sbatch --cpus-per-task=1 \
	       --output=slurm-mitofinder-${combo}.%j.out \
	       --partition main \
	       run_mitofinder_ssl.sbatch $i
done < $CONFIG
