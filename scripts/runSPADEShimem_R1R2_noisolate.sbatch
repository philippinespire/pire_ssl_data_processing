#!/bin/bash -l

#SBATCH --job-name=Sp8s
#SBATCH -o sp8s-%j.out
#SBATCH --time=00:00:00
#SBATCH --exclusive
#SBATCH --ntasks=32
#SBATCH -p himem

# SPAdes manual avail at  http://cab.spbu.ru/files/release3.15.2/manual.html

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
PROJDIR=$(echo $6 | sed 's/\/$//')
FQDIR=$(echo $7 | sed 's/\/$//')

# Get the Library code
if [[ "$LIBRARY" == "all" || "$LIBRARY" == "all_2libs" || "$LIBRARY" == "all_3libs" ]]; then
	LIBCODE=allLibs
elif [[ "$LIBRARY" == "1" ]]; then
	LIBCODE=$(ls ${PROJDIR}/${FQDIR}/*1.fq.gz | head -n1 | sed -e 's/.*\///' -e 's/_.*/\-A/')
elif [[ "$LIBRARY" == "2" ]]; then
        LIBCODE=$(ls ${PROJDIR}/${FQDIR}/*1.fq.gz | head -n2 | tail -n1 | sed -e 's/.*\///' -e 's/_.*/\-B/')
elif [[ "$LIBRARY" == "3" ]]; then
        LIBCODE=$(ls ${PROJDIR}/${FQDIR}/*1.fq.gz | head -n3 | tail -n1 | sed -e 's/.*\///' -e 's/_.*/\-C/')
else
	echo -e "This script is optimize to for up to 3 libraries and can run individual or 2- 3 libraries together\nPlease enter which library(s) to process. Options: all_2libs | all_3libs | 1 | 2 | 3 \n" 
fi

# Set the output dir according to the input data
if [[ "$DATATYPE" == "contam" ]]; then
	OUTDIR=SPAdes_${LIBCODE}_contam_R1R2_noIsolate
	COVCUTOFF=off
elif [[ "$DATATYPE" == "decontam" ]]; then
	OUTDIR=SPAdes_${LIBCODE}_decontam_R1R2_noIsolate
	COVCUTOFF=off
elif [[ "$DATATYPE" == "contam_covAUTO" ]]; then
        OUTDIR=SPAdes_${LIBCODE}_contam_R1R2_noIsolate_covAUTO
	COVCUTOFF=auto
elif [[ "$DATATYPE" == "decontam_covAUTO" ]]; then
        OUTDIR=SPAdes_${LIBCODE}_decontam_R1R2_noIsolate_covAUTO
	COVCUTOFF=auto
else
    	echo "Please enter DATATYPE. Options:  contam | decontam |contam_covAUTO | decontam_covAUTO "
fi


#FQDIR=${PROJDIR}/${FQDIR}
INDIR=${PROJDIR}
TEMPDIR=/scratch-lustre/${USERID}
#OUTDIR=SPAdes_contam_R1R2_noIsolate
FQPATTERN=*  #determines libraries to be assembled
THREADS=32

quastINFILE1=$INDIR/$OUTDIR/contigs.fasta
quastINFILE2=$INDIR/$OUTDIR/scaffolds.fasta
quastOUTDIR1=$INDIR/$OUTDIR/quast_contigs_report
quastOUTDIR2=$INDIR/$OUTDIR/quast_scaffolds_report

rm -rf $INDIR/$OUTDIR $INDIR/$quastOUTDIR1 $INDIR/$quastOUTDIR2

# mkdir $TEMPDIR 
mkdir $INDIR/$OUTDIR
mkdir $quastOUTDIR1
mkdir $quastOUTDIR2


# run SPAdes accordint to the library

if [[ "$LIBRARY" == "all_3libs" || "$LIBRARY" == "all" ]]; then
        crun spades.py \
        -k 21,33,55,77,99 \
        --pe1-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n1) \
        --pe1-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n1) \
        --pe2-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n2 | tail -n1) \
        --pe2-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n2 | tail -n1) \
        --pe3-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n3 | tail -n1) \
        --pe3-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n3 | tail -n1) \
        --threads $THREADS \
        --memory 750 \
        --tmp-dir $TEMPDIR \
        --cov-cutoff $COVCUTOFF \
        -o $INDIR/$OUTDIR
elif [[ "$LIBRARY" == "all_2libs" ]]; then
        crun spades.py \
        -k 21,33,55,77,99 \
        --pe1-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n1) \
        --pe1-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n1) \
        --pe2-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n2 | tail -n1) \
        --pe2-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n2 | tail -n1) \
        --threads $THREADS \
        --memory 750 \
        --tmp-dir $TEMPDIR \
        --cov-cutoff $COVCUTOFF \
        -o $INDIR/$OUTDIR
elif [[ "$LIBRARY" == "1" ]]; then
	crun spades.py \
	-k 21,33,55,77,99 \
	--pe1-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n1) \
	--pe1-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n1) \
	--threads $THREADS \
	--memory 750 \
	--tmp-dir $TEMPDIR \
	--cov-cutoff $COVCUTOFF \
	-o $INDIR/$OUTDIR
elif [[ "$LIBRARY" == "2" ]]; then
	crun spades.py \
	-k 21,33,55,77,99 \
	--pe1-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n2 | tail -n1) \
	--pe1-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n2 | tail -n1) \
	--threads $THREADS \
	--memory 750 \
	--tmp-dir $TEMPDIR \
	--cov-cutoff $COVCUTOFF \
	-o $INDIR/$OUTDIR
elif [[ "$LIBRARY" == "3" ]]; then
	crun spades.py \
	-k 21,33,55,77,99 \
	--pe1-1 $(ls $FQDIR/${FQPATTERN}1.fq.gz | head -n3 | tail -n1) \
	--pe1-2 $(ls $FQDIR/${FQPATTERN}2.fq.gz | head -n3 | tail -n1) \
	--threads $THREADS \
	--memory 750 \
	--tmp-dir $TEMPDIR \
	--cov-cutoff $COVCUTOFF \
	-o $INDIR/$OUTDIR
elif [[ "$LIBRARY" == "continue" ]]; then
	crun spades.py \
	--continue
	-o .
else
        echo -e "This script is optimize to for up to 3 libraries and can run individual or 2-3 libraries together\nPlease enter which library(s) to process. Options: all_2libs | all_3libs | 1 | 2 | 3 \n"
fi

echo -e "\nRunning QUAST Now\n"

# Run QUAST
crun quast.py $quastINFILE1 -o $quastOUTDIR1 --est-ref-size $GENSIZE -s --eukaryote --large
crun quast.py $quastINFILE2 -o $quastOUTDIR2 --est-ref-size $GENSIZE -s --eukaryote --large

# Redirect quast results
mkdir -p $PROJDIR/quast-reports
cp $quastOUTDIR1/transposed_report.tsv $PROJDIR/quast-reports/quast-report_contigs_${SPECIESID}_spades_${LIBCODE}_${DATATYPE}_R1R2_21-99_isolateoff-cov${COVCUTOFF}.tsv
cp $quastOUTDIR2/transposed_report.tsv $PROJDIR/quast-reports/quast-report_scaffolds_${SPECIESID}_spades_${LIBCODE}_${DATATYPE}_R1R2_21-99_isolateoff-cov${COVCUTOFF}.tsv

# save resource usage stats
sacct -j $SLURM_JOBID --long --units=M > $OUTDIR/resource_usage_m.tsv
# save resource usage stats
sacct -j $SLURM_JOBID --long --units=G > $OUTDIR/resource_usage_g.tsv
# save resource usage stats
sacct -j $SLURM_JOBID --long --units=K > $OUTDIR/resource_usage_k.tsv

