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

Every run was successful

| Assembly | Library |
|--- | --- |
| A | Sde-CMat_061-Ex1-7A-ssl |
| B | Sde-CMat_061-Ex1-8A-ssl |
| C | Sde-CMat_061-Ex1-9A-ssl |
| allLibs | all 3 above |

QUAST was ran together with SPAdes.


Running Busco
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "SPAdes_Sde-CMat-A_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "SPAdes_Sde-CMat-B_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "SPAdes_Sde-CMat-C_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
```

**Assembly Results**

MINLEN |Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    | BUSCO Single Copy | contigs >50000    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp   
-------| ------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
140 |Sde  |7A  |decontam       |scaffolds    |off       |na       | 5.8% |0  | 24466       |30150206       |30.1%       |4138       |2568       |14.89
140 |Sde  |8A  |decontam       |scaffolds       |off       |na       | 27.7% | 0 | 48093      |280020878       |28.8%       |5111       |18521       |3.2
140 |Sde  |9A  |decontam       |scaffolds       |off       |na      | 4.7% | 0 | 22963       |18478859       |0.2%       |4666       |1431       |14.99
140 |Sde  |allLibs  |decontam       |scaffolds       |off       |na       | 32.1% | 2 | 85042       |347842987       |34.8%       |5471       |20780       |4.44
100 |Sde  |8A  |decontam       |scaffolds       |off       |na       | 35.1.7% | 4 |148834      |380518335       |45.8%       |5913       |20462       |6.57
100 |Sde  |allLibs  |decontam       |scaffolds       |off       |na       | 35.6% | 8 | 79798       |430676003       |51.9%       |6020       |22404       |12.67
80 |Sde  |8A  |decontam       |scaffolds       |off       |na       | 35.9% | 2 |137756      |388908883       |46.9%       |5916       |20792       |6.02
80 |Sde  |allLibs  |decontam       |scaffolds       |off       |na       | 36.2% | 6 | 79797       |441403536       |53.2%       |6094       |22613       |14.27
50 |Sde  |8A  |decontam       |scaffolds       |off       |na       | 35.7% | 4 |137466      |395146084       |47.6%       |5938       |21009       |5.74
50 |Sde  |allLibs  |decontam       |scaffolds       |off       |na      | 36.7.1% | 9 | 79872       |449343306       |54.1%       |6136       |22799       |14.22

In general, assemblies are very poor. The best assembly, the allLibs, reaches only 32.1% of BUSCO. Will continue with this one.

**UPDATE July 2023** Rerunning SPAdes. I noticed I was losing a lot of read in fp2 bc of MINLEN=140, I am going back and relaxing to 100, 80 and 50.

### Re-doing the Assembly

The last assembly was not so hot. I reviewed the steps and noticed that I am loosing ~60% of the reads in fp2 because of the 140bp minimum length filter. I am going back and relax this filter to see if I can get a better assembly.

Previously MINLENN=140

* Repeating fp2 with MINLEN of 100, 80 and 50
* will repeat every step after fp2 for each of the more relaxed MINLENs

**Fp2**

* MINLEN=100, has approx. doubled the number of reads passing fp2 from ~35% to ~65% :)
* MINLEN=80, has increased the number of reads passing fp2 from ~35% to ~76%,, maybe will have a buch of contam
* MINLEN=50, has approx. tripled the number of reads passing fp2 from ~35% to ~92%,, mmm maybe will have a buch of contam

**FQScreen**
As I decreased MINLEN the amount of contam removed by FQScreen increased, but in theory it eliminated. Will have to check this.

80 still running

**Jelly**

witht the MINLEN=100, [jelly v1](http://qb.cshl.edu/genomescope/analysis.php?code=mSgaLXRcK1nlProygnf7) looks better. 
The lines are a good fit and model fit is better for the min and max values.
 Here the [v2 report](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=A9MZd9rDusOa6Dwkm2YF) for comparisons

MINLEN=80, interesting.... it failed to converge or looks bad. Makes sense. [v1 report](http://qb.cshl.edu/genomescope/analysis.php?code=KuvBMuMWY6XWxKQbgZFH), 
 [v2 report](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=tt65rYoaqhnrBFsNPM9W) 

MINLEN=50, doesn't seem to have red flags. In fact, at least v1 gave the same results as with MINLEN=100 [v1 report](http://qb.cshl.edu/genomescope/analysis.php?code=yiEg0tUkaFRFWYvch4BO)
 [v2 report](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=aEzTcF5Dse3Pr8akKoGS)



MINLEN | version    |stat    |min    |max
----| ------  |------ |------ |------
100 |1  |Heterozygosity  |1.77%       |1.79%
100 |1  |Genome Haploid Length   |828,005,456 bp |830,227,327 bp
100 |1  |Model Fit       |96.49%       |99.55%
----| ------  |------ |------ |------
80 |2  |Heterozygosity  |0%       |27.21%
80 |2  |Genome Haploid Length   |231,869,610 bp |237,408,799 bp
80 |2  |Model Fit       |42.7%       |75.3%
----| ------  |------ |------ |------
50 |1  |Heterozygosity  |1.74%       |1.75%
50 |1  |Genome Haploid Length   |843,598,424 bp |845,430,053 bp
50 |1  |Model Fit       |96.47%       |99.54%


For MINLEN=100, I will use v1, genome L= 830,000,000


**Organizng Assemblies**

To avoid confusion, I have created subdir for each assembly using a different mininum read length (MINLEN) in fp2 
```
assemblies_for_fp2min140
assemblies_for_fp2min100
assemblies_for_fp2min80
assemblies_for_fp2min50
```
### Redundans

I have moved forward to run redundans on the allLibs fp2_min140 (i.e. one of the original assemblies).

I created a dir for this, copied a script to run redundans in the scaffold.fasta (redundans.sb) and then ran BUSCO and QUAST in the reduced.fa
```
mkdir assemblies_for_fp2min140/redundans_fp2min140
sbatch redundans.sb "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140_fqscrn_rprd/Sde-CMat_061*.R*gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta" "redundans_fp2min140"
# once redundans is done, I ran BUSCO and QUAST
cd assemblies_for_fp2min140
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140" "redundans_fp2min140" "scaffolds"
sbatch runQUAST.sh redundans_fp2min140/scaffolds.fasta
```
I initially `mv scaffold.reduced.fa scaffolds.fasta` so I wouldn't have to modify the scripts.
I have reinstate the normal name ``mv scaffolds.fasta scaffold.reduced.fa`

***repeating the above for assemblies_for_fp2min80***
```
sbatch redundans.sb "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min80/fq_fp1_clmp_fp2min80_fqscrn_rprd/Sde-CMat_061*.R*gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min80/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta" "redundans_fp2min80"
```

**BUSCO and QUAST Resulsts**

MINLEN |Library    | BUSCO Single Copy | contigs >50000    |Largest contig    |Total length    |% Genome size completeness (830000000)    |N50    |L50    |Ns per 100 kbp   
-------| ------  |------  |------ |------ |------ |------  |------ |------ |------
140 (before Redundans) | allLibs| 32.1% | 2 | 85042       |347842987       |49.1       |5471       |20780       |4.44
140 (after Redundans) | allLibs| 34%| 8 |79798 |428076144| 51.6%| 6040| 22193| 2.7
