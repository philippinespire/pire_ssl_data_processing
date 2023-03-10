#!/bin/bash -l

#SBATCH --job-name=mitofinder
#SBATCH -o mitofinder-%j.out
#SBATCH --time=00:00:00
#SBATCH -p main
#SBATCH --cpus-per-task=1

enable_lmod 

module load container_env mitofinder/1.4.1 
export SINGULARITY_BIND=/home/e1garcia

SSL_DIR=$1
SPECIES=$2
ASSEMBLY=$3
FAMILY=$4

mkdir ${SSL_DIR}/mitofinder

NAME=${SPECIES}_${ASSEMBLY}_${FAMILY}

cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/mitofinder_refpanel/${FAMILY}.gb ${SSL_DIR}/mitofinder

cp ${SSL_DIR}/${ASSEMBLY}/scaffolds.fasta ${SSL_DIR}/mitofinder

cd ${SSL_DIR}/mitofinder

crun mitofinder -j ${NAME} -a scaffolds.fasta -r ${FAMILY}.gb -o 2
