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
* one hit, one genome, no ID: 97.05-97.26%%
* no one hit, one genome to any potential contaminators (bacteria, virus, human, etc) - 0-1.88%


============================
## STEP 6 runREPAIR.sbatch

```sh
sbatch runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

The multiqc [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1_clmp_fp2_fqscrn_rprd/fqc_rprd_report.html) here.

Potential issues:
* % duplication - 8.7-9.8%
* GC content - 42-43%
* number of reads - 39.9-47.5 M

=============================
## STEP 7 Clean up

Moved any .out files to logs directory
``sh
mv *.out logs/
```
=============================
## Genome Assembly
## STEP 8 Genome Properties

The [genome.size](https://www.genomesize.com/) showed 2 estimates of C value for Dascyllus aruanus. I chose the C-value provided by the two Hardie papers because these were more recent, used a few other outgroup species and listed D. aruanus specifically. Citations of both are here:
* Hardie, D.C. and P.D.N. Hebert (2003). The nucleotypic effects of cellular DNA content in cartilaginous and ray-finned fishes. Genome 46: 683-706.
* Hardie, D.C. and P.D.N. Hebert (2004). Genome-size evolution in fishes. Canadian Journal of Fisheries and Aquatic Sciences 61: 1636-1646.

C-value for D. aruanus based on [genomesize.com](genomesize.com) is  0.87 pg

Then I estimated genome properties using jellyfish:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Dar" "fq_fp1_clmp_fp2_fqscrn_rprd"
```
Resulting histogram files from Jellyfish were uploaded to GenomeScope 1.0 and Genomescope 2.0.                    

Results for GenomeScope are here for [v1.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1_clmp_fp2_fqscrn_rprd/GenomeScopev1_Dar.pdf) and [v2.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1_clmp_fp2_fqscrn_rprd/GenomeScopev2_Dar.pdf)
```
Genome stats for Dar from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

Reports are here for [v1.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1_clmp_fp2_fqscrn_rprd/GenomeScopev1_Dar.pdf) and [v2.0](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1_clmp_fp2_fqscrn_rprd/GenomeScopev2_Dar.pdf)

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |2.12%       |2.14%
2  |Heterozygosity  |2.08%       |2.14%
1  |Genome Haploid Length   |733,431,964 bp |735,359,939 bp
2  |Genome Haploid Length   |776,256,569 bp |781,687,328 bp
1  |Model Fit       |98.09%       |99.58%
2  |Model Fit       |84.45%       |99.55%

=============================
## STEP 9 Assembling the genome using SPADES
NEXT STEP:
Executed runSPADEShimem_R1R2_noisolate.sbatch on Turing
```sh
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Dar" "1" "decontam" "782000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus" "fq_fp1_clmp_fp2_fqscrn_rprd"

#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Dar" "2" "decontam" "782000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus" "fq_fp1_clmp_fp2_fqscrn_rprd"

#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Dar" "3" "decontam" "782000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus" "fq_fp1_clmp_fp2_fqscrn_rprd"

#all 3 libs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Dar" "all_3libs" "decontam" "782000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus" "fq_fp1_clmp_fp2_fqscrn_rprd"

```
Job IDs:
```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          10454748     himem     Sp8s jbald004  R       0:04      1 coreV4-21-himem-003
          10454747     himem     Sp8s jbald004  R       0:11      1 coreV4-21-himem-002
          10454746     himem     Sp8s jbald004  R       0:19      1 coreV2-23-himem-004
          10454745     himem     Sp8s jbald004  R       0:28      1 coreV2-23-himem-003
 
```
Libraries for each assembly:
A	7A
B	8A
C	9A

Quast & BUSCO Scores are as follows:
```
Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
Dar  |Dar-CJol-A  |decontam       |contigs       |off       |2       |78766  |73498       |626581216       |41.06%       |9455       |20068       |0.00       |54.8%
Dar  |Dar-CJol-A  |decontam       |scaffolds       |off       |2       |77742  |87229       |631623247       |41.05%       |9755       |19509       |10.30       |55.6%

Dar  |Dar-CJol-B  |decontam       |contigs       |off       |2       |77882  |99877       |645190608       |41.01%       |10030       |19156       |0.00       |57.1%
Dar  |Dar-CJol-B  |decontam       |scaffolds       |off       |2       |76890  |99877       |649177190       |41.01%       |10322       |18640       |9.12       |57.8%

Dar  |Dar-CJol-C  |decontam       |contigs       |off       |2       |72129  |126737       |667894582       |40.97%       |11762       |16600       |0.00        |62.4%
Dar  |Dar-CJol-C  |decontam       |scaffolds       |off       |2       |71022  |126737       |671296441       |40.97%       |12119       |16083       |9.58       |62.9%

Dar  |all_3libs  |decontam       |contigs       |off       |2       |76146  |125988       |454159430       |40.75%       |6088       |20911       |0.00       |33.7%
Dar  |all_3libs  |decontam       |scaffolds       |off       |2       |74736  |125988       |527468322       |40.80%       |7901       |18104       |690.87       |42.3%
```

The best library was Dar-CJol-C so I assembled a genome with contaminated files:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Dar" "3" "contam" "782000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus"
```



