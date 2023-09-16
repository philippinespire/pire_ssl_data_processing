#!/bin/bash -l

#SBATCH --job-name=mitofinder
#SBATCH -o mitofinder-%j.out
#SBATCH --time=00:00:00
##SBATCH -p main
##SBATCH --cpus-per-task=1

enable_lmod

module load container_env mitofinder/1.4.1
#module load container_env pire_genome_assembly

export SINGULARITY_BIND=/home/e1garcia

fqPath=$1
path2gb=$2
threads=$3
ramPerThreads=$4
FQPATTERN=*R1.fq.gz

#mitofinder -j [seqid] -1 [left_reads.fastq.gz] -2 [right_reads.fastq.gz] -r [genbank_reference.gb] -o [genetic_code] -p [threads] -m [memory]

all_samples=$(ls $fqPath/$FQPATTERN | \
        cut -d "_" -f 9-13 | \
        cut -d "-" -f 3-4)
all_samples=($all_samples)

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}

# Define a new variable to store the genbank reference path based on the 3-letter string
genbank_reference=""

# Check the 3-letter string within $sample_name and assign the appropriate genbank reference
if [[ "${sample_name}" == *"Aur"* ]]; then
    genbank_reference="Ambassidae.gb"
elif [[ "${sample_name}" == *"Ako"* ]]; then
    genbank_reference="Ambassidae.gb"
elif [[ "${sample_name}" == *"Dba"* ]]; then
    genbank_reference="Atherinidae.gb"
elif [[ "${sample_name}" == *"Ddu"* ]]; then
    genbank_reference="Atherinidae.gb"
elif [[ "${sample_name}" == *"Dva"* ]]; then
    genbank_reference="Atherinidae.gb"
elif [[ "${sample_name}" == *"Ela"* ]]; then
    genbank_reference="Leiognathidae.gb"
elif [[ "${sample_name}" == *"Ele"* ]]; then
    genbank_reference="Leiognathidae.gb"
elif [[ "${sample_name}" == *"Hte"* ]]; then
    genbank_reference="Atherinidae.gb"
elif [[ "${sample_name}" == *"Ssp"* ]]; then
    genbank_reference="Siganidae.gb"
elif [[ "${sample_name}" == *"Sob"* ]]; then
    genbank_reference="Sphyraenidae.gb"
elif [[ "${sample_name}" == *"Tbi"* ]]; then
    genbank_reference="Apogonidae.gb"
elif [[ "${sample_name}" == *"Tka"* ]]; then
    genbank_reference="Apogonidae.gb"
else
    # Default case if no match is found
    echo "No matching 3-letter string found in sample_name"
    exit 1
fi

echo "----------------"
echo ${sample_name}
echo $fqPath/*$sample_name*R1.fq.gz
echo $fqPath/*$sample_name*R2.fq.gz
echo $path2gb
echo $genbank_reference
echo $threads
echo $ramPerThreads
echo "----------------"

crun mitofinder --metaspades \
	-j $sample_name \
	-1 $fqPath/*$sample_name*R1.fq.gz \
	-2 $fqPath/*$sample_name*R2.fq.gz \
	-r $path2gb/$genbank_reference \
	-o 2 \
	-p $threads \
	-m $ramPerThreads

