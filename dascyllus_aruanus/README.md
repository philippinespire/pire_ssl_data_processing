All two  sequence sets are from individual xxxxxx

===============

## Dascyllus aruanus: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Dar_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Dar data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus/shotgun_raw_fq"
```
[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/shotgun_raw_fq/fqc_raw_report.html)

Potential issues:

* duplication - moderate, 31.6-38.8%%
* gc content - normal, 44%
* number of sequences - 65.6 - 78.4 M

===============               
## Step 2 FASTP - 1st trim

``sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
``

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1/1st_fastp_report.html)

Potential issues:
* % duplication - moderate 33.8-35.9%
* gc content - reasonable 43.3-4% more variable in pos 1-15 than in 15-150
* passing filter - very good ~95.7-96.7%
* % adapter - low 4-5.6%
*number of reads - ~125-150 M

===============
## Step 3 Remove duplicates through Clumpify

runCLUMPIFY_r1r2_array.bash in https://github.com/philippinespire/pire_fq_gz_processing was run on fq.gz files

```sh
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/jbald004 20
```

Checked whether clumpify was successful by navigating to the output folder and excecuting

```sh
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE//pire_fq_qz_processing/checkClumpify_EG.R --no-save
```

Clumpify was successful!

Generated metadata on deduplicated FASTQ files:

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
```
Potential issues:

* duplication - moderate, 9.8-11.4%
* gc content - normal, 43%
* number of sequences - 46.4 - 54.4 M

===============               
## Step 4 FASTP 2nd trim

To assemble genome using this data, runFASTP_2_ssl.sbatch was used

```sh
sbatch ../../pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1_clmp_fp2/2nd_fastp_report.html)

Potential issues:

* % duplication - good, 11.0-12.3%
* gc content - reasonable, 43.2-43.3%
* passing filter - good, 90-91.5%
* % adapter - good, 0.1%
* number of reads - good, 83-99M

===============

## Step 5 Decontaminate files FQSCRN

Ran on Wahab and used 6 nodes since there were 6 files

```sh
#navigate to species dir
bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_$
```

Checked output for errors

```sh
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for each input fq.gz file
#check that all 5 files were created for each file: 
ls fq_fp1_clmp_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.html | wc -l
# for each, you should have the same number as the number of input files

#You should also check for errors in the *out files:
# this will return any out files that had a problem

#do all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# or check individuals files <replace JOBID with your actual job ID>
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```

Dar-CJol_003-Ex1-8A-ssl-1-1.clmp.fp2_r2.fq.gz didn’t work 8a, so I did:
```
bash ../../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 Dar-CJol_003-Ex1-8A-ssl-1-1.clmp.fp2_r2.fq.gz
```

After this, I checked again & it all worked! So I proceeded to run MultiQC

```
sbatch ../../pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
```

Potential issues:
* one hit, one genome, no ID-
  * Alb: xx%, Contemp: XX%
* no one hit, one genome to any potential contaminators (bacteria, virus, human, etc) -
  * Alb: xx%, Contemp: xx%


============================
## STEP 6 runREPAIR.sbatch

```sh
sbatch runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```



