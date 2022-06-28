# *Halichoeres miniatus* log
***

The purpose of this log is to create replicable steps for de novo genome assembly of *H. miniatus* as outlined by Dr. Eric Garcia in the [PIRE Shotgun Data Processing and Analysis Page](https://github.com/philippinespire/pire_ssl_data_processing) of the [PhilippinesPIRE](https://github.com/philippinespire) repository.
***

I cloned the repository, copied the data and followed all steps up to line 124 of the instructions on the [PIRE Shotgun Data Processing and Analysis Page](https://github.com/philippinespire/pire_ssl_data_processing).  I created a README in the *Halichoeres miniatus* directory.  I created this log.
***

#Preprocessing (steps 1-6)

### 1

The following commands were executed on the command line:

```sh
pwd
/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/shotgun_raw_fq
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "."
The script failed as it is written in the home directory.  The out file stated the following error: /bin/bash: crun: command not found
cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh ../../scripts
nano ../../scripts/Multi_FASTQC.sh
```

I made necessary corrections to the SLURM commands as follows:
```sh
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```
I ran the command:
```sh
sbatch ../../scripts/Multi_FASTQC.sh "fq.gz" "."
```
The script failed again.
I tried inputing an absolute path for the second argument and the script failed again.

I ran the following command.
This instruction to leave the repo and follow the steps in another are not clear.  I deleted the logs and moved to complete the instruction s in the pire_fq_gz_processing.
As per the instruction on the pire_fq_gz_processing repo I entered the following commands:
```sh
enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/shotgun_raw"
```
The script failed.
I edited the script to delete all the comments and remove a two sets of three ` that were commenting out parts of the script.  The script now reads as follows:
```sh
#!/bin/bash -l

#SBATCH --job-name=SgrMulti_fastqc
#SBATCH -o SgrMulti_fastqc-%j.out
#SBATCH -p main
#SBATCH -c 4
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL

enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc

cd $2

ls *$1 | parallel "crun fastqc {}" &&

crun multiqc . -n multiqc_report_$1.html -o ../Multi_FASTQC &&

ls *fastqc.html | parallel "mv {} ../Multi_FASTQC" &&
ls *fastqc.zip | parallel "mv {} ../Multi_FASTQC"
mv *out ../logs
```

I ran the following commands:
```sh
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/ilope002/shotgun_PIRE/halichoeres_miniatus/shotgun_raw_fq"
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.  I opened the MultiQC report, however, I am not trained to interpret the data. The data displayed by the report and the data requested do not coincide literraly.  I updated the main README.MD as per the instructions.
I read the instructions to sbatch runFASTP_1st_trim.sbatch.
Imodified the script as follows:
```sh
#SBATCH -o ../logs/fastp_1st_-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

### 2

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/shotgun_raw_fq
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.  I opened the 1st_fastp_report, however, I am not trained to interpret the data. The data displayed by the report and the data requested do not coincide literraly.  I updated the main README.MD as per the instructions.

### 3

I read the instructions to sbatch runCLUMPIFY_r1r2_array.bash
Imodified the script as follows:
```sh
#SBATCH --job-name=CLUMPIFY
#SBATCH -o ./logs/Clumpify_r1r2-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/ilope002 3
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.
I read the outfile and observed runCLUMPIFY failed.
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/ilope002 3
```

The job ran.
The job completed.
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
crun R
install.packages('tidyverse')
yes
yes
82
```

The install returned the following message:
```sh
Warning message:
In doTryCatch(return(expr), name, parentenv, handler) :
  unable to load shared object '/opt/mapdamage2/lib/R/modules//R_X11.so':
  libXt.so.6: cannot open shared object file: No such file or directory
```

I ran the following commands:
```sh
q()
y
crun R < \/home/ilope002/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify Successfully worked on all samples.
I moved to *out files to ./logs
I pushed the changes to the repository to GitHub.

### 4

I read the instructions to sbatch runFASTP_2_ssl.sbatch
I modified the script as follows:
```sh
#SBATCH -o ../logs/fastp_2nd_-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I deleted the line:
```sh
export SINGULARITY_BIND=/home/e1garcia
```
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2 
```

The job ran.
The job completed.

### 5

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
```

On the script if $4 = *.fq.gz do not type anyhting.  Only enter $4 when the end of file pattern is not *.fq.gz
The job ran.
The job completed.
I verified 5 files for the 4 files analyzed as per the instructions.
I ran the following commands:
```sh
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out
```

Nothing was returned.  All files ran correctly.  I moved all out files to logs/
I read the instruction to get the multiqc report.  I noted that it may work better to have all scripts for this pipeline in one directory vs having them in multiple directories.

I modified the script as follows:
```sh
#SBATCH -o ./logs/mqc_-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I deleted the line:
```sh
export SINGULARITY_BIND=/home/e1garcia
```
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```
The script failed.

I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

The script generated an out file with a warning that a new version of MultiQC is available and a list of python errors.  No out dir was generated.  The script failed.

I ran the following commands:
```sh
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch .
less runMULTIQC.sbatch
rm runMULTIQC.sbatch
```

I verified the script was the same.  The .out file makes the following reports:  There is a new version of MultiQC.  There are several python 3.7 errors in the MultiQC program.

I pushed the changes to the repository to GitHub.
Eric corrected the runMULTIQC.sbatch script by adding the line:
```sh
module load multiqc
```

The report worked.
I pushed the changes to the repository to GitHub.

### 6

I read the instructions to sbatch runREPAIR.sbatch
I modified the script as follows:
```sh
#SBATCH -o ../logs/repr-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I deleted the line:
```sh
export SINGULARITY_BIND=/home/e1garcia
```

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

The job failed right away.
I ran the following commands:
```sh
cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch .
nano runREPAIR.sbatch
```

The scripts was the same as the one I used.
I ran the following commands:
```sh
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

The script failed.

I ran the following commands:
```sh
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn_repaired
```

The job failed.

I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

The job ran.
The job completed.
I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.

***

#Assembly and Evaluation (Steps 7-11)

### 7

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Hmi" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```

The job ran.
The job completed.

I created a report on [Genomescope v1.0](http://qb.cshl.edu/genomescope/): [Report](http://genomescope.org/analysis.php?code=KhfDGA5uYzhqhMDcvWdd).

I used the following data to created this table:

Genome stats for *Halichoeres miniatus* from Jellyfish/GenomeScope v1.0 k=21

stat|min|max|average
------|------|------|------
Heterozygosity |1.16164% |1.17048% |
Genome Haploid Length |603,130,409 bp |603,766,833 bp |
Model Fit |96.7109% |97.7415% |

Average values are not listed in the report. I noted that in other assemblies in this project researchers arrived at the following:
(min+max)/2 = average = true average for the stat
Average values are being fed into the pipeline downstream.
While averaging probabilities is unsound. I do not know that this not correct with respect to the genome haploid length.  Since the values are weighted a caluclation to arrive at the true average of these stat values must consider the weight used to arrive at min and max.  It is difficult to arrive at these necessary values just looking at the algorithm used to calculate the min and max.
However min and max are weighted values arrived at by a formula shown on the report.  These weighted values are based on probabilities and very likely calculated from a t score.  Two t values or calculated probabilities cannot be averaged to determine a "mid-point" of equal probability.  As an example, imagine we are flipping a deck of alphabet cards.  We calculated the t value of the probability of the next flip will be the letter "C" or the letter "W".  It is unsound to gamble that the next letter to come up will be A, Z or M.  Another example, in a curriculum mandatory class, a student gets a 66 on a test and a 74 on a quiz.  The student says "(66=74)/2 = 70. Hooray, my average is 70.  I wont have to repeat the class!"  The student could be correct if the assumption that the values were weighted equally is correct.  Please see the documentation for [GenomeScope](https://github.com/schatzlab/genomescope)

After consultation with Dr. Garcia, Dr. Reid, Dr. Bird and Dr. Pinsky, they were in consensus that this getting the mid point for min and max without rounding would provide a valid result in the rest of the pipeline.  I calculated the value to be: 603448621

The instructions for Spades are not clear.  The script for Spades must be executed on one library at a time.  A library consists of a file of forward reads and a file with the complamentary reverse reads. These files have similar names and are often differentiated in the naming scheme, for example SOME_FILE_NAME_r1.* SOME_FILE_NAME_r2.*.  For the purpose of the script created, the argument for the library input requires the entry of a single digit, such as 1, or 2, depending on the number of libraries present, or the text all.  The understanding is that the script created was written at the convenience of the author with the intent of creating a smooth easy to follow pipeline.

At this point I sought clarification of the arguments to be entered for the Spades script from Dr. Garcia.  I observed that one library only contained forward reads.  Dr. Garcia indentified this library as incomplete and pulled the missing file to the ODU HPC.  Dr. Garcia instructed me on the proper use of the script and suggested I move forward with Spades.

I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPaDEShimem_R1R2_noisolate.batch "ilope002" "Hmi" "1" "contam" "603448621" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPaDEShimem_R1R2_noisolate.batch "ilope002" "Hmi" "2" "contam" "603448621" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.

***

# Preprocessing (steps 1-6)

Since one library was incomplete, it was not processed.  I am returning to step on to process the library for reads: HmC0451A_CKDL210018111-1a-5UDI301-7UDI304_HH72GDSX2_L1_1.fq.gz
HmC0451A_CKDL210018111-1a-5UDI301-7UDI304_HH72GDSX2_L1_2.fq.gz

### 1
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/
mkdir hmi
cd hmi
mkdir logs
mkdir shotgun_raw_fq
cd shotgun_raw_fq
cp /home/e1garcia/HmC0451A_CKDL210018111-1a-5UDI301-7UDI304_HH72GDSX2_L1_1.fq.gz .
cp /home/e1garcia/HmC0451A_CKDL210018111-1a-5UDI301-7UDI304_HH72GDSX2_L1_2.fq.gz .
cd ../
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi/shotgun_raw_fq"
```

The job ran.
The job completed.

### 2

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi/shotgun_raw_fq
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

The job ran.
The job completed.

### 3

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi
salloc
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/ilope002 3
enable_lmod
module load container_env mapdamage2
crun R < \/home/ilope002/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

The job ran.
The job completed.
Clumpify worked on the sample.

### 4

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
```

The job ran.
The job completed.

### 5

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
```

The job ran.
The job completed.
I verified 5 files for the 4 files analyzed as per the instructions.
I ran the following commands:
```sh
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out
```

Nothing was returned.  All files ran correctly.  I moved all out files to logs/
I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

The script failed.
I reviewed the original script which has typographical errors which will cause it to crash.  I edited the scritp as follows:
```sh
#!/bin/bash -l

#SBATCH --job-name=mqc
#SBATCH -o mqc-%j.out
#SBATCH --time=00:00:00
#SBATCH --cpus-per-task=40
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
module load multiqc

DIR=$1
REPORTNAME=$2

srun crun multiqc $DIR -n $DIR/$REPORTNAME
```

I ran the following commands:
```sh
sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi/fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

The job ran.
The job completed.

### 6

I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi/fq_fp1_clmparray_fp2_fqscrn /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi/fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

The job ran.
The job completed.

I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi"
```

The job ran.
The job completed.

#Assembly and Evaluation (Steps 7-11)

### 7

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/hmi
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Hmi" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```

The job ran.
The job completed.

I created a report on [Genomescope v1.0](http://qb.cshl.edu/genomescope/): [Report](http://genomescope.org/analysis.php?code=7VuM61PauIP6FBZxHoPz).


Genome stats for single library

stat|min|max|average
------|------|------|------
Heterozygosity |1.22946% |1.23251% |
Genome Haploid Length |602,263,751 bp |602,564,366 bp |
Model Fit |98.2985% |99.4717% |

Upon analizing this data I felt the libraries should be combined and this step repeated on all.  I renamed files as appropriate and merged the hmi dir into the halichores_miniatus/ dir.

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Hmi" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```

The job ran.
The job completed.

I created a report on [Genomescope v1.0](http://qb.cshl.edu/genomescope/): [Report](http://genomescope.org/analysis.php?code=RV3Qm2ESrB5kIKmxZVvU).


Genome stats for all libraries

stat|min|max|average
------|------|------|------
Heterozygosity |1.1754% |1.19961%  |
Genome Haploid Length |592,484,550 bp |594,056,703 bp |593,270,627 bp
Model Fit |95.4277%  |96.3268% |

I will use 593000000 as the genome size estimate for all libraries and run Spades again.

I pushed all changes to GitHub.

### 8

I read the instructions for step 8.  I logged in to Turing.

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "1" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "2" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "3" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "all" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
```

The jobs failed.
The error output was as follows:
```sh
ls: cannot access /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/fq_fp1_clmparray_fp2/*1.fq.gz: No such file or directory
mkdir: cannot create directory `/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/SPAdes__contam_R1R2_noIsolate': No such file or directory
mkdir: cannot create directory `/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/SPAdes__contam_R1R2_noIsolate/quast_contigs_report': No such file or directory
mkdir: cannot create directory `/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/SPAdes__contam_R1R2_noIsolate/quast_scaffolds_report': No such file or directory
ls: cannot access /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/fq_fp1_clmparray_fp2/*1.fq.gz: No such file or directory
ls: cannot access /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/fq_fp1_clmparray_fp2/*2.fq.gz: No such file or directory
SPAdes genome assembler v3.15.2
```

The script is looking for *1.fq.gz files in the dir /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichores_miniatus/fq_fp1_clmparray_fp2/.  Files with these numbered extensions were not created by previous scripts.  I noticed I made a typo in the dir name.

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "1" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "2" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "3" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "all" "contam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
```

The jobs ran.
The jobs completed.
I pushed changes to Github.

### 9

I read the instructions for step 9.
I ran the following commads:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_decontam_R1R2_noIsolate" "contigs"
cat quast-reports/quast-report_scaffolds_Hmi_spades_contam_R1R2_21-99_isolate-off.tsv | column -ts $'\t' | less -S
```

The job failed.
The cat command returned illegal variable name.
The file name is incorrect. I forgot to enter the bash command, however after entering bash and correcting the file name, no output was generated.  For reasons I don't understand, bash ls will return the files in the dir when searching for quast-report_scaffolds*, but it will not find the files for the pipes below.
```sh
cat quast-reports/quast-report_scaffolds_Hmi_spades_*_contam_*.tsv | column -ts $'\t' | less -S
```
I opened the files one by one, but the information on the quast reports does not coincide with the information requested for this data table.  Some of the data for this table appears to be retrieved from busco reports.

Species|Library|DataType|SCAFIG|covcutoff|No. of contigs|Largest contig|Total lenght|% Genome size completeness|N50|L50|BUSCO single copy
------|------|------|------|------|------|------|------|------|------|------|-----

It would be helpful to describe which data is requested from which part of which report.
I left this task for now.

I ran the following commads:
```sh
cat quast-reports/quast-report_scaffolds_Hmi_spades_*_contam_*.tsv > /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/quasttable.tsv
The pipeline requires clarification.  The scripts will not work from the main species dir.  QUAST reports are three lines max.  The data table is useless because it clutters all the data into one hard to read file.  All the lines are unidentifed so it is not possible to know which library is referenced.

I ran the following commands:
```sh
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh .
```

The script inputs the second argument as SPAdesDIR.  The directories created are not named as in the example.  The script will not loop through the directories, so it must be run on each directory created by spades.  I modified the example script with my directory names.  My directory names are as follows:
SPAdes_HmC0451A_contam_R1R2_noIsolate
SPAdes_HmC0451B_contam_R1R2_noIsolate
SPAdes_HmC0451C_contam_R1R2_noIsolate
SPAdes_allLibs_contam_R1R2_noIsolate

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_HmC0451A_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_HmC0451B_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_HmC0451C_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_HmC0451A_contam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_HmC0451B_contam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_HmC0451C_contam_R1R2_noIsolate" "scaffolds"
```

The jobs ran.
I pushed changes to GitHub.
The jobs completed.
All libraries completed on Turing.
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_allLibs_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus" "SPAdes_allLibs_contam_R1R2_noIsolate" "scaffolds"
```

The jobs ran.
I pushed changes to GitHub.

Revisiting the table.  I highly recommend navigating to and viewing the reports in the appropriate directories
The guide requests the following data from QUAST

Library and contig or scaff
1 # of contigs (QUAST presents many variables for this.  I used # contigs (>=0))
2 largest contig
3 Length of assembly (this is not a stat in QUAST. QUAST presents many variables for this. I used total length)
4 N50
5 L50

Busco Reports
Complete BUSCOs (C)
Complete and single-copy BUSCOs (S)
Complete and duplicated BUSCOs (D)
Fragmented BUSCOs (F)
Missing BUSCOs (M)
Total BUSCO groups searched (n)

Hmi A contig
1059314
125732
434260664
6716
19242
C:47.6%[S:46.6%,D:1.0%],F:16.7%,M:35.7%,n:3640

Hmi B contig
1152395
94343
435308849
6809
18997
C:49.3%[S:48.5%,D:0.8%],F:16.3%,M:34.4%,n:3640

Hmi C contig
1151936
71699
409046162
6513
18731
C:46.2%[S:45.2%,D:1.0%],F:16.0%,M:37.8%,n:3640

Hmi allLibs contig
1178612
99674
416912122
6609
18668
C:47.0%[S:45.5%,D:1.5%],F:16.1%,M:36.9%,n:3640

Hmi A scaffolds
1012225
165936
511942208
9996
14062
C:61.1%[S:60.1%,D:1.0%],F:13.5%,M:25.4%,n:3640

Hmi B scaffolds
1106460
200054
511188068
10051
13877
C:62.4%[S:61.5%,D:0.9%],F:12.9%,M:24.7%,n:3640

Hmi C scaffolds
1102909
131151
492541584
9800
13726
C:59.4%[S:58.5%,D:0.9%],F:13.7%,M:26.9%,n:3640

Hmi allLibs scaffolds
1128280
171801
502459845
10188
13331
C:60.5%[S:59.1%,D:1.4%],F:13.4%,M:26.1%,n:3640

I created a table and posted it on the main *H. miniatus* README.md.
After confering with colleagues I picked Hmi B for the decontam assembly.

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "2" "decontam" "593000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
```

The job ran.

due to a problem in the assembly of another species Dr. Garcia asked me to run Genomescope V2.
I created a report on [Genomescope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/): [Report](http://genomescope.org/genomescope2.0/analysis.php?code=ZiuyUi6puHvBqiz4BSQ1).


Genome stats for all libraries

stat|min|max|average
------|------|------|------
Heterozygosity |1.22796% |1.2388%  |
Genome Haploid Length |631,820,236 bp  |632,395,858 bp |632,108,047 bp
Model Fit |87.7119%  |99.3197% |

I will run QUAST on the libraries with a new genome length of 632000000 bp.

I updated the best_ssl_assembly_per_sp.tsv

I logged in to Turing
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "ilope002" "Hmi" "2" "decontam" "632000000" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus"
```

The job ran.
The job completed.

***

# Probe design

### 10

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
mkdir probe_design
cp ../scripts/WG* probe_design
cp SPAdes_HmC0451B_contam_R1R2_noIsolates/scaffolds.fasta probe_design
cd probe_design
mv probe_design Hmi_scaffolds_HmC0451B_contam_R1R2_noIsolate.fasta
sbatch WGprobe_annotation.sb "Hmi_scaffolds_HmC0451B_contam_R1R2_noIsolate.fasta"
sbatch WGprobe_bedcreation.sb "Hmi_scaffolds_HmC0451B_contam_R1R2_noIsolate.fasta"
```

The jobs ran.
WGprobe\_bedcreation.sb failed.  This script must be lauched after the WGprobe\_annotation.sb script completes.
The job completed.

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/probe_design
sbatch WGprobe_bedcreation.sb "Hmi_scaffolds_HmC0451B_contam_R1R2_noIsolate.fasta"
```

The job ran.
The job completed.

The out file read as follows:
```sh
The longest scaffold is 172983
The uppper limit used in loop is 167500
A total of 20731 regions have been identified from 13397 scaffolds
```

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/probe_design
mv *out ../logs
```

I informed Dr. Garcia the pipeline for probe creation for *H. miniatus* was complete.
I pushed all changes to GitHub.

***

# Clean up

I cleaned up the *Halichoeres miniatus* directories as follows.

```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/
cp -R fq_fp1_clmparray_fp2/ /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/
cp -R fq_fp1_clmparray_fp2_fqscrn_repaired/ /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/SPAdes_HmC0451B_decontam_R1R2-noIsolate/
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/SPAdes_HmC0451B_contam_R1R2-noIsolate/
cp SPAdes_HmC451B_decontam_R1R2_noIsolate/*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/SPAdes_HmC0451B_decontam_R1R2-noIsolate/
cp SPAdes_HmC451B_contam_R1R2_noIsolate/*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/SPAdes_HmC0451B_contam_R1R2-noIsolate/
```

The clean up instructions are not quite clear.  While the instructions do say delete the files from step such and such, the steps themselves do not identify outtput.  This output would only be known to someone intimately familiar with the scripts.  I recommend updating the README or the scripts so that intermediate files for deletiong are easily identified.
I ran the following command:

```sh
cd ../
cp -R halichoeres_miniatus/ /home/e1garcia/shotgun_PIRE/Ivans_pire_ssl
```



