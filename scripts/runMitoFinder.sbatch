#!/bin/bash -l

#SBATCH --job-name=mitofinder
#SBATCH -o mitofinder-%j.out
#SBATCH --time=00:00:00
#SBATCH --exclusive
##SBATCH -p main
##SBATCH --cpus-per-task=1

enable_lmod

module load container_env mitofinder/1.4.1
#module load container_env pire_genome_assembly

export SINGULARITY_BIND=/home/e1garcia

fqPatternFile=$1
fqPath=$2
path2gb=$3
threads=$4
ramPerThreads=$5

all_samples=($(cat ${fqPatternFile}))

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}

echo "----------------"
echo ${sample_name}
echo ${fqPath}/*$sample_name*R1.fq.gz
echo $fqPath/*$sample_name*R2.fq.gz
echo $path2gb
echo $threads
echo $ramPerThreads
echo "----------------"

#mitofinder -j [seqid] -1 [left_reads.fastq.gz] -2 [right_reads.fastq.gz] -r [genbank_reference.gb] -o [genetic_code] -p [threads] -m [memory]

crun mitofinder --megahit \
	-j $sample_name \
	-1 $fqPath/*$sample_name*R1.fq.gz \
	-2 $fqPath/*$sample_name*R2.fq.gz \
	-r $path2gb \
	-o 2 \
	-p $threads \
	-m $ramPerThreads \
	--override
