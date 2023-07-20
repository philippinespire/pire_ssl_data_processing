#!/bin/bash

#SBATCH --job-name=insertCal
#SBATCH --output=insertCal-%j.out
#SBATCH -c 32
##SBATCH --mail-user=<your email>
##SBATCH --mail-type=begin
##SBATCH --mail-type=END

enable_lmod
module load parallel
module load container_env samtools
export SINGULARITY_BIND=/home/e1garcia

#regex=$1
mkdir -p Cal_Insert_Sizes

ls Sde-A*RG.bam | parallel --no-notice -kj32 "crun.samtools samtools view {} | cut -f9 > Cal_Insert_Sizes/{}.insertSizes"

cd Cal_Insert_Sizes

for i in *insertSizes
do
	sed 's/-//' $i | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' > $i.AveinsertSize
done

cat *.AveinsertSize | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' > Ave_insertSize_allfiles

