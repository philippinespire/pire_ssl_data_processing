#!/bin/bash
#SBATCH -N 1
#SBATCH --job-name=blob
#SBATCH --output=blob-%j.out

# This script runs Blobtools to analyze the quality of your assembly.
# You need to runBLAST and runBWA before running this script
# The output of this script can be used to visualize stats and filter contamination from assembly (i.e. with filter script).

# Execute:
# sbatch runBlobtools.sb <blobDIR> <plotDIR> <ASSEM> <filtBAM> <BUSCOdir>

# Easiest to execute if you cd into the same dir where BLAST and BWA were ran. Example:
# cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140_contam
# sbatch runBlobtools.sb . Sde_min140_contam_blobplot scaffolds.contam.fasta Sde_minlen140_contam.sort.filt.bam ../assemblies_for_fp2min140/busco_scaffolds_results-SPAdes_allLibs_contam_R1R2_noIsolate

enable_lmod
module load container_env/0.1
module load busco/5.0.0
module load container_env blobtoolkit

export SINGULARITY_BIND=/home/e1garcia

blobDIR=$1	# directory were BLAST and BWA were previously ran
plotDIR=$2	# ourdir
ASSEM=$3	# assembly file
filtBAM=$4	# filt.bam files previously created by BWA
BUSCOdir=$5	# BUSCO dir with results for your assembly

# Make sure dirs don't have trailing slashes
if [[ blobDIR="." ]]
then
	blobDIR=$PWD
else
	blobDIR=$(echo $blobDIR | sed 's/\/$//')
fi
plotDIR=$(echo $plotDIR | sed 's/\/$//')
BUSCOdir=$(echo $BUSCOdir | sed 's/\/$//')

# Print Arguments
echo -e "\nRunning Blobtools create, and adding blast hits, taxonomy, busco and coverage\n"
echo -e "blobDIR=$blobDIR"
echo -e "plotDIR=plotDIR"
echo -e "ASSEM=$ASSEM"
echo -e "fltrBAM=$flterBAM"
echo -e "BUSCOdir=$BUSCOdir"

# Run Blobtools
echo -e "\nRunning Blobtools create\n"
crun blobtools create \
	--fasta $ASSEM \
	${plotDIR}
echo -e "\nRunning Blobtools add --hits, --taxdump, --taxrule\n"
crun blobtools add \
 	--hits ${blobDIR}/blastn.out \
	--taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
	--taxrule bestsumorder \
	${plotDIR}
echo -e "\nRunning Blobtools add --busco\n"
crun blobtools add \
	--busco	${BUSCOdir}/run_actinopterygii_odb10/full_table.tsv \
	${plotDIR}
echo -e "\nRunning Blobtools add --cov\n"
crun blobtools add \
	--cov ${blobDIR}/${filtBAM} \
	${plotDIR}


