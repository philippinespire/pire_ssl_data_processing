All three sequence sets are from individual xxxxxx

===============

## Parupeneus barberinus: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Pbb_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Pbb data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/parupeneus_barberinus/shotgun_raw_fq"
```
[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/shotgun_raw_fq/fqc_raw_report.html)

Potential issues:

* duplication - low to moderate, 16.3-27.8%
* gc content: 48-50% 
* number of sequences: 34.8-53.6 M

===============
## Step 2 FASTP - 1st trim

``sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
``

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/fq_fp1/1st_fastp_report.html)

Potential issues:
* % duplication - moderate 17.5-24.8%
* gc content - reasonable 47.8-48.3% more variable in pos 1-11 than in 11-150
* passing filter - very good ~91.7-94.7%
* % adapter - low 7.6-12.1%
* number of reads - ~63.7-101.6 M

===============
## Step 3 Remove duplicates through Clumpify

runCLUMPIFY_r1r2_array.bash in https://github.com/philippinespire/pire_fq_gz_processing was run on fq.gz files

```sh
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/jbald004 20
```

Checked whether clumpify was successful by navigating to the output folder and executing

```sh
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_qz_processing/checkClumpify_EG.R --no-save
```

Clumpify was successful!

Generated metadata on deduplicated FASTQ files:

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
```

(Report)[https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/fq_fp1_clmp/fqc_clmp_report.html]
Potential issues:

* duplication - moderate, 7-10.4%
* gc content - normal, 47-48%
* number of sequences - 27.8 - 42.2 M

===============
## Step 4 FASTP 2nd trim

To assemble genome using this data, runFASTP_2_ssl.sbatch was used

```sh
sbatch ../../pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/fq_fp1_clmp_fp2/2nd_fastp_report.html)

Potential issues:

* % duplication - good, 6.7-10.9%
* gc content - reasonable, 47.7-48.2%
* passing filter - fair, 83.2-85.6%
* % adapter - good, 0.1-0.2%
* number of reads - fair, 46-72M

===============
===============
## Step 5 Decontaminate files FQSCRN

Ran on Wahab and used 6 nodes since there were 6 files

```sh
#navigate to species dir
bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runFQSCRN_6.$
```

Checked output for errors

```sh
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.htm$
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

No files failed so I proceeded to the next step.

```
sbatch ../../pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
```

Potential issues:
* one hit, one genome, no ID: 93.57-93.88%
* no one hit, one genome to any potential contaminators (bacteria, virus, human, etc) - very low, <0.8%

====================
## STEP 6 Execute runREPAIR.sbatch

```
sbatch ../../pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 40
```

Once the job finished, I ran MultiQC
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_$
```

Potential issues:
* % duplication -
* GC content -
* number of reads -

