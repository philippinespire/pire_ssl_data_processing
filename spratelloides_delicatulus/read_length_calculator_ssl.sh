#!/bin/bash

#SBATCH --job-name=readLCal
#SBATCH --output=readLCal-%j.out
#SBATCH -c 32
#SBATCH --mail-user=@odu.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=END

enable_lmod
module load parallel

#######  read_length_calculator_ssl.sh  ########
#Calculates the read length from output *fq.gz files from each preprocessing step

SPDIR=$1

# Determine # of threads
FILES_No=$(ls fq_raw/*gz | wc -l)

if [[ "$FILES_No" -ge 32 ]]; then
        PARALLELISM=32
else
        PARALLELISM=$FILES_No
fi

# Create preprocess_read_change directories
mkdir -p ${SPDIR}/preprocess_read_change
mkdir -p ${SPDIR}/preprocess_read_change/read_length
OUTDIR=${SPDIR}/preprocess_read_change/read_length

## Create files with read lengths
#ls ${SPDIR}/fq_raw/*gz | parallel --no-notice -kj${PARALLELISM} "echo -n {}'	' && zcat {} | awk 'NR % 4 == 2 {print length}' > {}.raw.readL"
#ls ${SPDIR}/fq_fp1/*gz | parallel --no-notice -kj${PARALLELISM} "zcat {} | awk 'NR % 4 == 2 {print length}' > {}.fp1.readL"
#ls ${SPDIR}/fq_fp1_clmp/*gz | parallel --no-notice -kj${PARALLELISM} "zcat {} | awk 'NR % 4 == 2 {print length}' > {}.clm.readL"
#ls ${SPDIR}/fq_fp1_clmp_fp2/*gz | parallel --no-notice -kj${PARALLELISM} "zcat {} | awk 'NR % 4 == 2 {print length}' > {}.fp2.readL"
#ls ${SPDIR}/fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | parallel --no-notice -kj${PARALLELISM} "zcat {} | awk 'NR % 4 == 2 {print length}' > {}.fqscrn.readL"
#ls ${SPDIR}/fq_fp1_clmp_fp2_fqscrn_rprd/*gz | parallel --no-notice -kj${PARALLELISM} "zcat {} | awk 'NR % 4 == 2 {print length}' > {}.rprd.readL"

# Create concatenated files per step (both r1 and r2)
#cat ${SPDIR}/fq_raw/*readL > $OUTDIR/raw.readL
#cat ${SPDIR}/fq_fp1/*readL > $OUTDIR/fp1.readL
#cat ${SPDIR}/fq_fp1_clmp/*readL > $OUTDIR/clmp.readL
#cat ${SPDIR}/fq_fp1_clmp_fp2/*readL > $OUTDIR/fp2.readL
#cat ${SPDIR}/fq_fp1_clmp_fp2_fqscrn/*readL > $OUTDIR/fqscrn.readL
#cat ${SPDIR}/fq_fp1_clmp_fp2_fqscrn_rprd/*readL > $OUTDIR/rprd.readL

# Create concatenated r1 files per step
cat ${SPDIR}/fq_raw/*1.*readL > $OUTDIR/raw.r1.readL
cat ${SPDIR}/fq_fp1/*r1.*readL > $OUTDIR/fp1.r1.readL
cat ${SPDIR}/fq_fp1_clmp/*r1.*readL > $OUTDIR/clmp.r1.readL
cat ${SPDIR}/fq_fp1_clmp_fp2/*r1.*readL > $OUTDIR/fp2.r1.readL
cat ${SPDIR}/fq_fp1_clmp_fp2_fqscrn/*r1.*readL > $OUTDIR/fqscrn.r1.readL
cat ${SPDIR}/fq_fp1_clmp_fp2_fqscrn_rprd/*1.*readL > $OUTDIR/rprd.r1.readL

# Create concatenated r2 files per step
cat ${SPDIR}/fq_raw/*2.*readL > $OUTDIR/raw.r2.readL
cat ${SPDIR}/fq_fp1/*r2.*readL > $OUTDIR/fp1.r2.readL
cat ${SPDIR}/fq_fp1_clmp/*r2.*readL > $OUTDIR/clmp.r2.readL
cat ${SPDIR}/fq_fp1_clmp_fp2/*r2.*readL > $OUTDIR/fp2.r2.readL
cat ${SPDIR}/fq_fp1_clmp_fp2_fqscrn/*r2.*readL > $OUTDIR/fqscrn.r2.readL
cat ${SPDIR}/fq_fp1_clmp_fp2_fqscrn_rprd/*2.*readL > $OUTDIR/rprd.r2.readL

# Create table 
#cd $OUTDIR
#cat <(echo "file	#readL_raw	#readL_fp1	#readL_clmp	#readL_fp2	#readL_fqscrn	#readL_repr") <(\
#        paste raw.readL fp1.readL clmp.readL fp2.readL fqscrn.readL rprd.readL) > read_length_table.tsv

