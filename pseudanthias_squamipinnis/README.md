oAll  sequence sets are from individual xxxxxx

===============

## Pseudanthias squamipinnis: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Psq-ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Dar data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pseudanthias_squamipinnis/shotgun_raw_fq"
```
[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias_squamipinnis/shotgun_raw_fq/fqc_raw_report.html)

Potential issues:

* duplication - moderate 36.7-43.8%
* gc content - normal, 42%
* number of reads - 50.6-66.0 M

===============
## Step 2 FASTP - 1st trim

``sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
``

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias_squamipinnis/fq_fp1/1st_fastp_report.html)

Potential issues:
* % duplication - moderate 36.9-39.3%
* gc content - reasonable 41.7-41.8% more variable in pos 1-11 than in 11-150
* passing filter - very good ~95.7-96.5%
* % adapter - low 7.9-8.8%
* number of reads - ~96.8-127 M

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
[Report] (https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias_squamipinnis/fq_fp1_clmp/fqc_clmp_report.html)
Potential issues:

* duplication - moderate, 10.9-12.1%
* gc content - normal, 41%
* number of sequences - 34.7 - 44.5 M
===============               
## Step 4 FASTP 2nd trim

To assemble genome using this data, runFASTP_2_ssl.sbatch was used

```sh
sbatch ../../pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias_squamipinnis/fq_fp1_clmp_fp2/2nd_fastp_report.html)

Potential issues:

* % duplication - good, 12.3-13.8%
* gc content - reasonable, 41.4-41.5%
* passing filter - fair, 85-86.8%
* % adapter - good, 0.1%
* number of reads - good, 60-75.5 M

===============
## Step 5 Decontaminate files FQSCRN

Ran on Wahab and used 6 nodes since there were 6 files

```sh
#navigate to species dir
bash ../../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 20
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

No files failed so I proceeded to the next step.

```
sbatch ../../pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
```

Potential issues:
* one hit, one genome, no ID: 94.82-95.84%%
* no one hit, one genome to any potential contaminators (bacteria, virus, human, etc) - 0-2.94%

====================
## STEP 6 Execute runREPAIR.sbatch

```
sbatch ../../pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 40
```

Once the job finished, I ran MultiQC
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" "fq.gz"
```

MultiQC [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias_squamipinnis/fq_fp1_clmp_fp2_fqscrn_rprd/fqc_rprd_report.html)

Potential issues:
* % duplication - 9.3-10.5%
* GC content - 40-41%
* number of reads - 27.7-35.1 M

=============================
## STEP 7 Clean up        

Moved any .out files to logs directory
``sh
mv *.out logs/
```
=============================
## Genome Assembly
## STEP 8 Genome Properties

There were no genomesize.com estimates for Pseudanthias squamipinnis so these genome properties were estimated using jelyfish and genomescope.

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Psq" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Resulting histogram files from Jellyfish were uploaded to GenomeScope 1.0 and Genomescope 2.0.
Reports are here for [v1.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias$

```
Genome stats for Psq from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |2.73%       |2.84%
2  |Heterozygosity  |2.20%       |3.54%
1  |Genome Haploid Length   |645,720,680 bp |653,788,079 bp
2  |Genome Haploid Length   |664,252,616 bp |724,828,529 bp
1  |Model Fit       |97.87%       |99.54%
2  |Model Fit       |79.72%       |99.18%


=============================
## STEP 9 Assembling the genome using SPADES
NEXT STEP:
Executed runSPADEShimem_R1R2_noisolate.sbatch on Turing
```sh
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" “Psq” "1" "decontam" "725000000” "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pseudanthias_squamipinnis” "fq_fp1_clmp_fp2_fqscrn_rprd"

#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" “Psq” “2” "decontam" "725000000” "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pseudanthias_squamipinnis” "fq_fp1_clmp_fp2_fqscrn_rprd"

#all 2 libs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" “Psq” “all_2libs” "decontam" "725000000” "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pseudanthias_squamipinnis” "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Job IDs:
```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          10454749     himem     Sp8s jbald004 PD       0:00      1 (Resources)
          10454750     himem     Sp8s jbald004 PD       0:00      1 (Priority)
          10454751     himem     Sp8s jbald004 PD       0:00      1 (Priority)
```

Libraries for each assembly:
A	4A
B	5A

