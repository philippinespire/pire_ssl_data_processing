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
MultiQC [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/fq_fp1_clmp_fp2_fqscrn/fastq_screen_report.html)

Potential issues:
* % duplication - 6.1-8.7%
* GC content - 47-48%
* number of reads - 20.8-32.5 M

=============================
## STEP 7 Clean up        

Moved any .out files to logs directory
``sh
mv *.out logs/
```
=============================

## Genome Assembly
## STEP 8 Genome Properties


```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Pbb" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Resulting histogram files from Jellyfish were uploaded to GenomeScope 1.0 and Genomescope 2.0.                    

Reports are here for GenomeScope [v1.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/fq_fp1_clmp_fp2_fqscrn_rprd/GenomeScopev1_Pbb.pdf) and [v2.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/parupeneus_barberinus/fq_fp1_clmp_fp2_fqscrn_rprd/GenomeScopev2_Pbb.pdf)
```
Genome stats for Pbb from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |2.36%       |2.46%
2  |Heterozygosity  |2.37%       |2.64%
1  |Genome Haploid Length   |475,159,090 bp |482,007,373 bp
2  |Genome Haploid Length   |493,648,332 bp |514,541,162 bp
1  |Model Fit       |98.21%       |99.73%
2  |Model Fit       |83.12%       |99.47%


=============================
## STEP 9 Assembling the genome using SPADES
NEXT STEP:
Executed runSPADEShimem_R1R2_noisolate.sbatch on Turing
```sh
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" “Pbb” "1" "decontam" "515000000” "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/parupeneus_barberinus” "fq_fp1_clmp_fp2_fqscrn_rprd"

#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" “Pbb” "2" "decontam" "515000000” "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/parupeneus_barberinus” "fq_fp1_clmp_fp2_fqscrn_rprd"

#all 2 libs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" “Pbb” “all_2libs” "decontam" "515000000” "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/parupeneus_barberinus” "fq_fp1_clmp_fp2_fqscrn_rprd"

```

Job IDs:
```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          10455560     himem     Sp8s jbald004 PD       0:00      1 (Resources)
          10457199     himem     Sp8s jbald004 PD       0:00      1 (Priority)
          10455559     himem     Sp8s jbald004  R       0:22      1 coreV4-21-himem-003
```

Libraries for each assembly:
A	1A
B	3A

QUAST & BUSCO Results:
```
Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
Pbb  |Pbb-CGal-A  |decontam       |contigs       |off       |2       |47451 |32823       |226253942       |46.43%       |4753       |16999       |0.00       |32.6%
Pbb  |Pbb-CGal-A  |decontam       |scaffolds       |off       |2       |48533 |32823       |234028647       |46.41%       |4813       |17238       |28.21       |33.3%

Pbb  |Pbb-CGal-B  |decontam       |contigs       |off       |2       |65150 |80987       |386376190       |45.39%       |6264       |19999       |0.00       |49.0%
Pbb  |Pbb-CGal-B  |decontam       |scaffolds       |off       |2       |65407 |80987       |397441158       |45.39%       |6474       |19715       |36.79       |50.7%

Pbb  |Pbb-allLibs  |decontam       |contigs       |off       |2       |66124 |92752       |479993197       |45.18%       |8302       |17761       |0.00       |58.0%
Pbb  |Pbb-allLibs  |decontam       |scaffolds       |off       |2       |65592 |92752       |486262446       |45.19%       |8554       |17380       |15.76       |59.0%
```

Best library was Pbb-allLibs scaffodlds, so I assembled a genome using the contaminated files:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pbb" "all_2libs" "contam" "515000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/parupeneus_barberinus"
```
