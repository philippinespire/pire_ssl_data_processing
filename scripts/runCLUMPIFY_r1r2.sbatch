#!/bin/bash -l

#SBATCH --job-name=clmp_r12
#SBATCH -o clmp_r1r2_-%j.out
#SBATCH --exclusive
#SBATCH -C coreV3|coreV4    ## -C coreV3|coreV4 is Turing only, otherwise comment out

##SBATCH -p himem
##SBATCH --time=00:00:00
##SBATCH --cpus-per-task=1


enable_lmod
module load container_env pire_genome_assembly/2021.07.01
export SINGULARITY_BIND=/home/e1garcia

#module load bbmap/38.90   #tamucc
#module load parallel   #tamucc

## The TEMPDIR must be updated to the users own directory or the script wont run
## For Turing /scratch-lustre/USER, for Wahab /scratch/USER
TEMPDIR=$3    		#/scratch-lustre/r1robert
INDIR=$1      		#/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_wga_c
OUTDIR=$2     		#/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_wga_clmp_c
THREADS=1   		#clumpify uses a ton of ram, be conservative
GROUPS=auto   		#controls how much ram is used, refer to manual
RAMPERTHREAD=120g   	#have had to set as high as 233g with groups=1

ulimit -u 40960
ulimit -a

mkdir -p $OUTDIR

ls $INDIR/*r1.fq.gz | \
  sed -e 's/r1\.fq\.gz//' -e 's/.*\///g' | \
  crun parallel --no-notice -j $THREADS --line-buffer \
    clumpify.sh \
    in=$INDIR/{}r1.fq.gz \
    in2=$INDIR/{}r2.fq.gz \
    out=$OUTDIR/{}clmp_r1.fq.gz \
    out2=$OUTDIR/{}clmp_r2.fq.gz \
    groups=$GROUPS \
    overwrite=t \
    usetmpdir=t \
    tmpdir=$TEMPDIR \
    dedupe=t \
    addcount=t \
    subs=2 \
    containment=t \
    consensus=f \
    -Xmx$RAMPERTHREAD

