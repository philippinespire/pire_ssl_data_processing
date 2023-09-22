#!/bin/bash -l 
 
#SBATCH --job-name=redundans
#SBATCH -o redundans-%j.out 
#SBATCH --mem 8000 #most runs should be under 1 GB but we'll add a buffer
#SBATCH -p main 
#SBATCH -n 1 #each chromosome will be processed on a single core (-n 1)  
#SBATCH -N 1 #on one machine (-N 1)  
#SBATCH --cpus-per-task=40 
#SBATCH --mail-user=<your email>
#SBATCH --mail-type=begin 
#SBATCH --mail-type=END

enable_lmod 
module load container_env redundans/0.13c 

crun redundans.py -v \
	-i $1 \
	-f $2 \
	-o $3
