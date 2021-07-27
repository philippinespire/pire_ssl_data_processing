#!/bin/bash -l

#SBATCH --job-name=clmp_orph
#SBATCH -o clmp_orph_-%j.out
#SBATCH --exclusive
#SBATCH -C coreV3|coreV4	## -C coreV3|coreV4 is Turing only

##SBATCH -p himem
##SBATCH --time=00:00:00
##SBATCH --cpus-per-task=1

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
export SINGULARITY_BIND=/home/e1garcia

## The TEMPDIR must be updated to the users own directory or the script wont run
## For Turing /scratch-lustre/USER, for Wahab /scratch/USER
TEMPDIR=$3		#Example - /scratch-lustre/cbird
INDIR=$1		#Example - /home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_nowga_a
OUTDIR=$2		#Example - /home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp_a
THREADS=1   		#clumpify uses a ton of ram, be conservative
GROUPS=auto   		#controls how much ram is used, refer to manual
RAMPERTHREAD=120g   	#have had to set as high as 233g with groups=1

ulimit -u 40960
ulimit -a

mkdir $OUTDIR

ls $INDIR/*unprd.fq.gz | \
  sed -e 's/unprd\.fq\.gz//' -e 's/.*\///g' | \
  crun parallel --no-notice -j $THREADS \
    clumpify.sh \
    in=$INDIR/{}unprd.fq.gz \
    out=$OUTDIR/{}clmp_orph.fq.gz \
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
