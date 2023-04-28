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

### FASTQC

Running FASTQC on raw files (Multiple hours).
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"  
```

I pushed the results and view the MultiQC in  [html git preview page](https://htmlpreview.github.io/)

Potential issues:  
  * % duplication - 
	* Alb: XX%, Contemp: XX%
  * GC content - 
	* Alb: XX%, Contemp: XX%
  * number of reads - 
	* Alb: XX mil, Contemp: XX mil


### FASTP1

Running the first Trim
```
sbatch ../../pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1
```

Potential issues:  
  * % duplication - 
    * Alb: XX%, Contemp: XX%
  * GC content -
    * Alb: XX%, Contemp: XX%
  * passing filter - 
    * Alb: XX%, Contemp: XX%
  * % adapter - 
    * Alb: XX%, Contemp: XX%
  * number of reads - 
    * Alb: XX mil, Contemp: XX mil
