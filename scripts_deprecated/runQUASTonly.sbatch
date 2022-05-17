#!/bin/bash -l

#SBATCH --job-name=QSTonly
#SBATCH -o QSTonly-%j.out
#SBATCH --time=00:00:00
#SBATCH --exclusive
#SBATCH --ntasks=32
#SBATCH -p main

# Execute this script in command line with:

#runQUASTonly.sbatch <your user ID> <3-letter species ID> <library: all | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
# example: sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"


enable_lmod
module load container_env pire_genome_assembly/2021.03.25
#module load spades/gcc7/3.15.2
#module load quast/5.0.2

export SINGULARITY_BIND=/home/e1garcia

USERID=$1
SPECIESID=$2
LIBRARY=$3
DATATYPE=$4
GENSIZE=$5
PROJDIR=$6

# Get the Library code
if [[ "$LIBRARY" == "all" ]]; then
	LIBCODE=allLibs
elif [[ "$LIBRARY" == "1" ]]; then
	LIBCODE=$(ls ${PROJDIR}/fq_fp1_clmparray_fp2/*1.fq.gz | head -n1 | sed -e 's/.*\///' -e 's/_.*//')
elif [[ "$LIBRARY" == "2" ]]; then
        LIBCODE=$(ls ${PROJDIR}/fq_fp1_clmparray_fp2/*1.fq.gz | head -n2 | tail -n1 | sed -e 's/.*\///' -e 's/_.*//')
elif [[ "$LIBRARY" == "3" ]]; then
        LIBCODE=$(ls ${PROJDIR}/fq_fp1_clmparray_fp2/*1.fq.gz | head -n3 | tail -n1 | sed -e 's/.*\///' -e 's/_.*//')
else
	echo -e "This script is optimize to for up to 3 libraries and can run individual or all 3 libraries together\nPlease enter which library(s) to process. Options: all | 1 | 2 | 3 \n" 
fi

# Set the output dir according to the input data
if [[ "$DATATYPE" == "contam" ]]; then
        FQDIR=${PROJDIR}/fq_fp1_clmparray_fp2
	OUTDIR=SPAdes_${LIBCODE}_contam_R1R2_noIsolate
	COVCUTOFF=off
elif [[ "$DATATYPE" == "decontam" ]]; then
        FQDIR=${PROJDIR}/fq_fp1_clmparray_fp2_fqscrn_repaired
	OUTDIR=SPAdes_${LIBCODE}_decontam_R1R2_noIsolate
	COVCUTOFF=off
elif [[ "$DATATYPE" == "contam_covAUTO" ]]; then
        FQDIR=${PROJDIR}/fq_fp1_clmparray_fp2
        OUTDIR=SPAdes_${LIBCODE}_contam_R1R2_noIsolate_covAUTO
	COVCUTOFF=auto
elif [[ "$DATATYPE" == "decontam_covAUTO" ]]; then
        FQDIR=${PROJDIR}/fq_fp1_clmparray_fp2_fqscrn_repaired
        OUTDIR=SPAdes_${LIBCODE}_decontam_R1R2_noIsolate_covAUTO
	COVCUTOFF=auto
else
    	echo "Please enter DATATYPE. Options:  contam | decontam |contam_covAUTO | decontam_covAUTO "
fi


#FQDIR=${PROJDIR}/fq_fp1_clmparray_fp2
INDIR=${PROJDIR}
TEMPDIR=/scratch-lustre/${USERID}
#OUTDIR=SPAdes_contam_R1R2_noIsolate
FQPATTERN=*  #determines libraries to be assembled
THREADS=32

quastINFILE1=$INDIR/$OUTDIR/contigs.fasta
quastINFILE2=$INDIR/$OUTDIR/scaffolds.fasta
quastOUTDIR1=$INDIR/$OUTDIR/quast_contigs_report
quastOUTDIR2=$INDIR/$OUTDIR/quast_scaffolds_report

echo -e "\nRunning QUAST Now\n"

# Run QUAST
crun quast.py $quastINFILE1 -o $quastOUTDIR1 --est-ref-size $GENSIZE -s --eukaryote --large
crun quast.py $quastINFILE2 -o $quastOUTDIR2 --est-ref-size $GENSIZE -s --eukaryote --large

# Redirect quast results
#mv $PROJDIR/quast-reports $PROJDIR/quast-reports_v1
mkdir -p $PROJDIR/quast-reports

cp $quastOUTDIR1/transposed_report.tsv $PROJDIR/quast-reports/quast-report_contigs_${SPECIESID}_spades_${LIBCODE}_${DATATYPE}_R1R2_21-99_isolateoff-cov${COVCUTOFF}.tsv
cp $quastOUTDIR2/transposed_report.tsv $PROJDIR/quast-reports/quast-report_scaffolds_${SPECIESID}_spades_${LIBCODE}_${DATATYPE}_R1R2_21-99_isolateoff-cov${COVCUTOFF}.tsv

