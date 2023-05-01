# Processing SSL data for *Spratelloides delicatulus* 

The purpose of this repository is to generate a *de novo* genome assembly and develop probes for *Spratelloides delicatulus* as outlined 
by the [PIRE Shotgun Data Processing and Analysis - SSL Repo](https://github.com/philippinespire/pire_ssl_data_processing) of the [Philippines PIRE Project - PPP](https://github.com/philippinespire).

All scripts and software used are explained on the SSL.  

This README documents all work done.

Bioinformatic work was performed by *Eric* in the Old Dominion University High Performance Computing Cluster. 

---

## Pre-Processing


### 1. Set up directories and data

**Directories**

```sh
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing
mkdir spratelloides_delicatulus 
mkdir spratelloides_delicatulus/logs
mkdir spratelloides_delicatulus/fq_raw
```

**Data**

SSL data files were downloaded using gridDownloader.sh

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_raw
sbatch gridDownloader.sh . https://gridftp.tamucc.edu/genomics/20230425_PIRE-Sde-ssl
```

All 3 library sets are from the same individual: Sde-CMat_061_Ex1


**Make a copy of your raw data in the RC**

I made a copy of the raw files in the RC
```
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/
module load parallel
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_raw/* | parallel --no-notice -kj 8 cp {} . &
```

### 2. Initial processing

Now following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo to run FASTQC, FASTP1, CLUMPIFY, FASTP2, FASTQ SCREEN, and file repair scripts


```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/
mkdir fq_raw fq_fp1 fq_fp1_clmp fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd
```

Modified the `Sde_SSL_SequenceNameDecode.tsv` file from:
```
Sequence_Name   Extraction_ID
SdC0106107A     Sde-C01_061-Ex1-7A-ssl-1-1
SdC0106108A     Sde-C01_061-Ex1-8A-ssl-1-1
SdC0106109A     Sde-C01_061-Ex1-9A-ssl-1-1
```
new name: Sde_SSL_SequenceNameDecode_original_deprecated.tsv


to:
```
Sequence_Name   Extraction_ID
SdC0106107A     Sde-CMat_061-Ex1-7A-ssl
SdC0106108A     Sde-CMat_061-Ex1-8A-ssl
SdC0106109A     Sde-CMat_061-Ex1-9A-ssl
```
new name: Sde_SSL_SequenceNameDecode_fixed.tsv

Running a dry run for renaming files
```
cd fq_raw
bash ../../../pire_fq_gz_processing/renameFQGZ.bash Sde_SSL_SequenceNameDecode_fixed.tsv
```

Everything looks good so renaming for real
```
bash ../../../pire_fq_gz_processing/renameFQGZ.bash Sde_SSL_SequenceNameDecode_fixed.tsv rename
y
y
```

#### FASTQC

Running FASTQC on raw files (Multiple hours).
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"  
```

Highlights:
* % duplication -
	* 13-16% (not too bad)
* GC content -
        * 44-45% (seems ok)
* number of reads -
        * 2 sets of files around 45M and one set around 1130M

Potential issues:

Adapter content seems high. I believe this has happenned before. 
Overrepresented sequences. Probably duplication

Everything else looks good.

#### FASTP1

Running the first Trim
```
sbatch ../../pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1
```

Highlights:  
* % duplication - 
	* 9-10% (not too bad)
* GC content - 
	* 43-44% (seems ok)
* Adapter content
	* 30-34% (seems high)
* percent of reads passing filters
	*87-88% (seems ok)
* number of reads - 
	* 2 libs around 90M and one around 220M (this is forward and reverse files together)


#### Clumpify

Running Clumpify
```
bash ../../pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/e1garcia 20
```

Running MultiQC on Clumpify
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
```

Checking that clmpy worked
```
enable_lmod
module load container_env mapdamage2
crun R < ../../pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Had an issue with some libs and then with tidyverse. I am trying to reinstalling tidyverse but I am getting a new error
```
crun R
install.packages("tidyverse")
mirror 74
```
error:
```
In file included from caches.h:7:0,
                 from caches.cpp:1:
ft_cache.h:9:10: fatal error: ft2build.h: No such file or directory
 #include <ft2build.h>
          ^~~~~~~~~~~~
compilation terminated.

make: *** [/opt/mapdamage2/lib/R/etc/Makeconf:175: caches.o] Error 1
ERROR: compilation failed for package ‘systemfonts’
* removing ‘/home/e1garcia/R/x86_64-conda_cos6-linux-gnu-library/4.0/systemfonts’
ERROR: dependency ‘systemfonts’ is not available for package ‘textshaping’
* removing ‘/home/e1garcia/R/x86_64-conda_cos6-linux-gnu-library/4.0/textshaping’
ERROR: dependencies ‘systemfonts’, ‘textshaping’ are not available for package ‘ragg’
* removing ‘/home/e1garcia/R/x86_64-conda_cos6-linux-gnu-library/4.0/ragg’
ERROR: dependency ‘ragg’ is not available for package ‘tidyverse’
* removing ‘/home/e1garcia/R/x86_64-conda_cos6-linux-gnu-library/4.0/tidyverse’

The downloaded source packages are in
‘/tmp/RtmpjKtJda/downloaded_packages’

Warning messages:
1: In doTryCatch(return(expr), name, parentenv, handler) :
  unable to load shared object '/opt/mapdamage2/lib/R/modules//R_X11.so':
  libXt.so.6: cannot open shared object file: No such file or directory
2: In install.packages("tidyverse") :
  installation of package ‘systemfonts’ had non-zero exit status
3: In install.packages("tidyverse") :
  installation of package ‘textshaping’ had non-zero exit status
4: In install.packages("tidyverse") :
  installation of package ‘ragg’ had non-zero exit status
5: In install.packages("tidyverse") :
  installation of package ‘tidyverse’ had non-zero exit status
> sudo apt install libtiff-dev
Error: unexpected symbol in "sudo apt"
```

I don't think I can install libraries in the hpc so I contacted Min.

Running MultiQC on clmpy files
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
```


Highlights:
* % duplication -
	* 7-9% (not too bad)
* GC content -
        * 43-44% (seems ok)
* number of reads -
        * 2 sets of files around 35M and one set around 90M

Adapter content is now good (Green). 

#### FASTP2

Running Fastp2
```
sbatch ../../pire_fq_gz_processing/runFASTP_2_<ssl or cssl>.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

Potential issues:
* % duplication -
	* down to ~5%
* GC content -
	* 42-43%
* passing filter -
	* 32-34% (lost a lot of reads)
* % adapter -
	* 0.6% (nice and low)
* number of reads -
	* 2 libs around 70M and one around 180M


Everything looks good. However, we did lose a lot of read. Good to step to go back if we need to gain more reads.

#### FASTQ SCREEN

Runnig Fastq Screen
```
bash ../../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 20
```

That ran successfully.

Running MultiQC on screened files
```
sbatch ../../pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
```

That worked too

* No hits. This is what we want:
	92-94% of all reads
* Multiple hits, Multiple genomes (any potential contaminators: bacteria, virus, human, etc)
	1-6% depending on contaminant


#### REPAIR

Movng on. Running Repair
```
sbatch ../../pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 40
```

Running MultiQC on re-paired reads
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" "fq.gz"
```

Highlights:
* % duplication -
	* 4-6% (interesting that MultiQC still reports duplication)
* GC content -
	* 42% , good
* number of reads -
	* 2 sets of files around 10-11M and one set around 30M

We lost a lot of reads in fastp2.

#### Cleanning up 

outs to logs
```
mv *out logs
```

---

## B. GENOME ASSEMBLY

### 1. Genome Properties

*Spratelloides delicatulus* is not in [genomesize.com](https://www.genomesize.com/) database but other confamilials have about 1000 Mb


**Estimating genome size, heterozygosity, and other characteristics using Jellyfish and Genomescope**
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sde" "fq_fp1_clmp_fp2_fqscrn_rprd"
```


Genome stats for Sde from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions:

Unfortunately, using default settings, the model in Genomescope v1 did not converge at all (see report [here](http://qb.cshl.edu/genomescope/analysis.php?code=vVHSvYopX21GHjsmJ8X3)
and in v2 the fit is really low, heterozygocity is too high, and length very shor (see report [here](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=b8QuAj0Vg8vOuScJL9ii)).

version    |stat    |min    |max
------  |------ |------ |------
2  |Heterozygosity  |0%       |40.128%
2  |Genome Haploid Length   |286,019,856 bp |292,883,627 bp
2  |Model Fit       |50.48%       |83.06%

I won't trust these values


From genomesize.com the average across 18 confamilials is about 1000 Mbp, so I will be using this number downstream but will see if concatenating files make jellyfish work (see below)

Brendan recommends concatenating libraries if the model fails to converge so I am giving it a try.

UPDATE: even with concatenated files the GenomeScope v1 model did not converge. The v2 still gave weird values. I did try incresing the kmer size and noticed that max heterozygosity decreased with higher kmers. 

Either way, I don't trust the results still. Deleting the concat files and dir and keeping the 1bp arbitrary genome estimate 

```
mkdir concat_re-pairedFiles_forJelly
cat fq_fp1_clmp_fp2_fqscrn_rprd/*R1*gz > concat_re-pairedFiles_forJelly/Sde-CMat_061-Ex1-CONCAT-7-8-9A-ssl.clmp.fp2_repr.R1.fq.gz &
cat fq_fp1_clmp_fp2_fqscrn_rprd/*R2*gz > concat_re-pairedFiles_forJelly/Sde-CMat_061-Ex1-CONCAT-7-8-9A-ssl.clmp.fp2_repr.R2.fq.gz &
```
Using concat libs in Jellyfish
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sde-3libs" "concat_re-pairedFiles_forJelly"
```

### 2. Genome Assembly with SPAdes

goint to Turing
```
ssh username@turing.hpc.odu.edu
```

Running SPAdes in each library independently and all3-together , using decontaminated files and genome size of 1,000,000,000 bp.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sde" "1" "decontam" "1000000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "fq_fp1_clmp_fp2_fqscrn_rprd"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sde" "2" "decontam" "1000000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "fq_fp1_clmp_fp2_fqscrn_rprd"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sde" "3" "decontam" "1000000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "fq_fp1_clmp_fp2_fqscrn_rprd"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sde" "all_3libs" "decontam" "1000000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

There were only 2 himem nodes open so running lib 1 and all_3libs first. Lib 2 and 3 are pending

