#!/bin/bash -l

#SBATCH --job-name=Mersp8s
#SBATCH -o sp8s_MerContSgr-%j.out
#SBATCH --time=00:00:00
#SBATCH --exclusive
#SBATCH --ntasks=32
#SBATCH -p himem

enable_lmod
module load container_env pire_genome_assembly/2021.03.25
#module load spades/gcc7/3.15.2
#module load quast/5.0.2

USERID=$1
PROJDIR=$2
FQDIR=${PROJDIR}/fq_fp1_clmparray_fp2
INDIR=${PROJDIR}
TEMPDIR=/scratch-lustre/${USERID}
OUTDIR=SPAdes_contam_R1R2_noIsolate
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

crun spades.py \
-k 21,33,55,77,99 \
--pe1-1 $(ls $FQDIR/${FQPATTERN}r1.fq.gz | head -n1) \
--pe1-2 $(ls $FQDIR/${FQPATTERN}r2.fq.gz | head -n1) \
--pe1-m $(ls $FQDIR/${FQPATTERN}mrgd*.fq.gz | head -n1) \
--pe2-1 $(ls $FQDIR/${FQPATTERN}r1.fq.gz | head -n2 | tail -n1) \
--pe2-2 $(ls $FQDIR/${FQPATTERN}r2.fq.gz | head -n2 | tail -n1) \
--pe2-m $(ls $FQDIR/${FQPATTERN}mrgd*.fq.gz | head -n2 | tail -n1) \
--pe3-1 $(ls $FQDIR/${FQPATTERN}r1.fq.gz | head -n3 | tail -n1) \
--pe3-2 $(ls $FQDIR/${FQPATTERN}r2.fq.gz | head -n3 | tail -n1) \
--pe3-m $(ls $FQDIR/${FQPATTERN}mrgd*.fq.gz | head -n3 | tail -n1) \
--threads $THREADS \
--memory 750 \
--tmp-dir $TEMPDIR \
--cov-cutoff off \
-o $INDIR/$OUTDIR
	
crun quast.py $quastINFILE1 -o $quastOUTDIR1 --est-ref-size 694000000 -s --eukaryote --large
crun quast.py $quastINFILE2 -o $quastOUTDIR2 --est-ref-size 694000000 -s --eukaryote --large

# save resource usage stats
sacct -j $SLURM_JOBID --long --units=M > $OUTDIR/resource_usage_m.tsv
# save resource usage stats
sacct -j $SLURM_JOBID --long --units=G > $OUTDIR/resource_usage_g.tsv
# save resource usage stats
sacct -j $SLURM_JOBID --long --units=K > $OUTDIR/resource_usage_k.tsv
