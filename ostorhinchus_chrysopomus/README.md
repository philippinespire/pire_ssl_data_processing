# Sfa Shotgun Data Processing Log - SSL data

Copy and paste this into a new species dir and fill in as steps are accomplished.

Following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) and [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmaps.

---

## **A. Pre-Processing Section**

Pathway to copy scripts from: 
ls /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/

## Step 0. Rename the raw fq.gz files

Used decode file from Sharon Magnuson.

```
salloc
bash

cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#run renameFQGZ.bash first to make sure new names make sense
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Och_CTum_001_Ex1-1D_L4_1.fq.gz 

#run renameFQGZ.bash again to actually rename files
#need to say "yes" 2X
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Och_CTum_001_Ex1-1D_L4_1.fq.gz rename
```

---

## Step 1. Check quality of data with fastqc

Ran [`Multi_FASTQC.sh`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus/shotgun_raw_fq

#Multi_FastQC.sh "<indir>" "file extension"
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus/shotgun_raw_fq/" "fq.gz"
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/shotgun_raw_fq/fastqc_report.html) written out to `shotgun_raw_fq` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*
file:///Users/Eryka/Desktop/fastqc_report.html

Potential issues:  
  * % duplication - low
    * 20.9% - 30%
	* 24.9% average
  * gc content - reasonable
    * 41%
	* 41% average
  * quality - good
    * sequence quality and per sequence qual both good
  * % adapter - good and low
    * ~exponentially increases as bp positions increase 
  * number of reads - good
    * ~133 M unique, 47 M duplicates

---

## Step 2.  First trim with fastp

Ran [`runFASTP_1st_trim.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#sbatch runFASTP_1st_trim.sbatch <INDIR/full path to files> <OUTDIR/full path to desired outdir>
sbatch runFASTP_1st_trim.sbatch fq_raw_shotgun fq_fp1
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1/1st_fastp_report.html) written out to `fq_fp1` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*
file:///Users/Eryka/Desktop/1st_fastp_report.html 

Potential issues:  
  * % duplication - low 
    * 18.4% - 24.4% 
	* 20.97%
  * gc content - reasonable
    * 40.8% - 41.2%
      * 40.9 average
  * passing filter - good
    * 97.7% - 97.9%
	* 97.8 average 
  * % adapter - not too bad 
    * 8.8% - 13.5%
  * number of reads - good
    * 353 M passed filter

---

## Step 3. Clumpify

Ran [`runCLUMPIFY_r1r2_array.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array on Wahab.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/r3clark 3
```

Checked the output with [`checkClumpify_EG.R`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

salloc
enable_lmod
module load container_env mapdamage2

crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify worked succesfully!

Moved all `*out` files to the `logs` directory.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

mv *out logs
```

---

## Step 4. Run fastp2

Ran [`runFASTP_2_ssl.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runFASTP_2_ssl.sbatch <indir> <outdir> 
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2/2nd_fastp_report.html) written out to `fq_fp1_clmp_fp2` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*
file:///Users/Eryka/Desktop/2nd_fastp_report.html 

Potential issues:  
  * % duplication - good
    * 4.0 % - 5.1%
	* 4.46% average
  * gc content - reasonable
    * 40.5% - 40.8% 
	* 40.6% average
  * passing filter - good
    * 81.6% - 84.9% 
	* 83.7% average
  * % adapter - virtually none
    * 0.2%
  * number of reads
    * 240 M average passed filter, 46 M too short

---

## Step 5. Run fastq_screen

Ran [`runFQSCRN_6.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
#do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 6
```

Checked output for errors.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

ls fq_fp1_clmp_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmp_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.html | wc -l

#all returned 6 (good)

#checked for errors in all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

#No errors!
```

Have to run Multiqc separately.

```
cd /home/e1garcia/shotgun_PIRE/2022_PIRE_omics_workshop/salarias_fasciatus

#runMULTIQC.sbatch <indir> <report name>
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastqc_screen_report
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2_fqscrn/fastqc_screen_report.html) written out to `fq_fp1_clmp_fp2_fqscrn` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:
  * one hit, one genome, no ID 95.8% - fine
  * 0.28% one hit, one genome to any potential contaminators (protist) - good

Cleaned-up logs again.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

mv *out logs/
```

---

## Step 6. Repair fastq_screen paired end files

Ran [`runREPAIR.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch).

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runREPAIR.sbatch <indir> <outdir> <threads>
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

This went smoothly.

Have to run Fastqc-Multiqc separately.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus/fq_fp1_clmp_fp2_fqscrn_repaired

#Multi_FastQC.sh "<indir>" "file_extension"
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus/fq_fp1_clmp_fp2_fqscrn_repaired" "fq.gz" 
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2_fqscrn_repaired/fastqc_report.html) written out to `fq_fp1_clmp_fp2_fqscrn_repaired` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:  
  * % duplication - fine
    * 6.8% - 12.1%
    * 9.11% average
  * gc content - reasonable
    * 40% 
  * number of reads
    * 81.4 M - 156.8 M

---

## Step 7. Calculate the percent of reads lost in each step

Ran [`read_calculator_ssl.sh`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh).

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#sbatch read_calculator_ssl.sh <species home dir> 
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus"
```

Generated the [percent_read_loss](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/preprocess_read_change/readLoss_table.tsv) and [percent_reads_remaining](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/preprocess_read_change/readsRemaining_table.tsv) tables.

Reads lost:
  * fastp1 dropped 15.15% - 18.43% of the reads
  * 4% - 4.46% of reads were duplicates and were dropped by clumpify
  * fastp2 dropped 2.63% - 2.77% of the reads after deduplication

Reads remaining:
  * Total reads remaining: 
  * 62.4% - 64.5%
---

## **B. Genome Assembly Section**

## Step 1. Genome Properties

Executed `runJellyfish.sbatch` using the decontaminated files.

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runJellyfish.sbatch <Species 3-letter ID> <indir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Och" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

The Jellyfish kmer-frequency [histogram file](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2_fqscrn_repaired/Sfa_all_reads.histo) 
was uploaded into [GenomeScope v1.0](http://qb.cshl.edu/genomescope/) and [GenomeScope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/) to generate the [v1.report](http://genomescope.org/analysis.php?code=0nqHEIiWdjCKP6MJQHHn) and [v2.report](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=wL2ctgUZTUE3acgbyYJe). 

Genome stats for Sfa from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions:

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.736891%       |0.740914%
2  |Heterozygosity  |0.734481%       |0.752477%
1  |Genome Haploid Length   |795,543,026 bp |796,105,407 bp
2  |Genome Haploid Length   |894,230,151 bp |895,735,417 bp
1  |Model Fit       |97.2945%       |99.2807%
2  |Model Fit       |79.4023%       |98.9884%

No red flags. We will use the max value from V2 rounded up to 896,000,000 bp.

---

## Step 2. Assemble the Genome Using [SPAdes](https://github.com/ablab/spades#sec3.2)

Executed [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch) for each library and for all the libraries combined.

```sh
#new window
ssh emoli004@turing.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
#do not use trailing / in paths

#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "emoli004" "Och" "1" "decontam" "896000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "fq_fp1_clmp_fp2_fqscrn_repaired"

#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "emoli004" "Och" "2" "decontam" "896000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "fq_fp1_clmp_fp2_fqscrn_repaired"

#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "emoli004" "Och" "3" "decontam" "896000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "fq_fp1_clmp_fp2_fqscrn_repaired"

#all libraries combined
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "emoli004" "Och" "all_3libs" "decontam" "896000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "fq_fp1_clmp_fp2_fqscrn_repaired"
```
 
JOB IDs:

```
[emoli004@turing1 ostorhinchus_chrysopomus]$ sq
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           9767803     himem     Sp8s emoli004  R       0:01      1 coreV4-21-himem-003
           9767802     himem     Sp8s emoli004  R       0:16      1 coreV4-21-himem-002
           9767801     himem     Sp8s emoli004  R       0:27      1 coreV2-23-himem-004
           9784068     himem     Sp8s emoli004  R       1:11      1 coreV2-23-himem-003
```

Libraries for each assembly:

Assembly  |  Library
--- | ---
A | 1G
B | 1H
C | 2A

This SPAdes scripts automatically runs `QUAST` but have to run `BUSCO` separately.

## Step 3. Running BUSCO

Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on both the `contigs` and `scaffolds` files.

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
#do not use trailing / in paths

#1st library - contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino//ostorhinchus_chrysopomus" "SPAdes_Och-A_decontam_R1R2_noIsolate" "contigs"

#2nd library -contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "SPAdes_Och-B_decontam_R1R2_noIsolate" "contigs"

#3rd library - contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "SPAdes_Och-C_decontam_R1R2_noIsolate" "contigs"

#all libraries - contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "SPAdes_allLibs_decontam_R1R2_noIsolate" "contigs"

#1st library -scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "SPAdes_Och-A_decontam_R1R2_noIsolate" "scaffolds"

#2nd library - scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "SPAdes_Och-B_decontam_R1R2_noIsolate" "scaffolds"

#3rd library - scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "SPAdes_Och-C_decontam_R1R2_noIsolate" "scaffolds"

#all libraries - scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/2022_PIRE_omics_workshop/salarias_fasciatus" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
```

## Step 4. Fill in QUAST and BUSCO Values

### Summary of QUAST (using GenomeScope v.2 635000000 estimate) and BUSCO Results

Species    |Assembly    |Data Type    |SCAFIG    |Covcutoff    |Genome Scope v.    |No. of Contigs    |Largest Contig    |Total Length    |% Genome Size Completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO Single Copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------
Och  |A  |decontam       |contigs       |off       |2       |  81865  | 168825  | 817740343  | 38.84 % | 13163  |  17352  |  0  | 63.63%
Och  |A  |decontam       |scaffolds       |off       |2    |  79271  |  199604 |    825105417  |  38.84 % | 14040  | 16206  | 20.53  | 65%
Och  |B  |decontam       |contigs       |off       |2       |  84901  |  182776  |   802206314  |  38.83 % |  12200  |  18516  |  0  | 61.98%
Och  |B  |decontam       |scaffolds       |off       |2    |  82315  |  191507  |   810219895  |  38.83 % |  12992  |  17358  |  19.79  | 63.19%
Och  |C  |decontam       |contigs       |off       |2       |  85612  |  191640  |  823945406  | 38.77 % | 12468  | 18377  |  0  |  61.57%
Och  |C  |decontam       |scaffolds       |off       |2    |  78378  |  276968  |   847729770  | 38.80 % |  14799  |  15555 | 177.47 | 67.03%
Och  |allLibs  |decontam       |contigs       |off       |2    |  84458  |  179505 |   855174075  |  38.85 % |  13388  | 17693  |  0  | 54.07%
Och  |allLibs  |decontam       |scaffolds       |off       |2   |  75507  |  277781  |   878447116  |  38.88 % |  16447  |  14525  | 195.13 | 68.96%

## Step 5. Identify Best Assembly

Scaffold assembly of all libraries created the best assembly based on its highest BUSCO score and N50 score. 

## Step 6. Assemble Contaminated Data From the Best Library

``sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all_2libs | all_3libs | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
#do not use trailing / in paths

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "erykamolino" "Och" "2" "contam" "896000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

## Skipping Steps 7-9 for the workshop BUT please do clean-up:

Move your out files into the `logs` directory

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

mv *out logs
```

--- 

## **C. Probe Design - Regions for Probe Development**

From the species directory: made probe directory, renamed assembly, and copied scripts.

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/erykamolino/ostorhinchus_chrysopomus

mkdir probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_annotation.sb probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_bedcreation.sb probe_design
cp /home/e1garcia/shotgun_PIRE/2022_PIRE_omics_workshop/salarias_fasciatus/SPAdes_Sfa-CBas-B_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
# list the busco dirs
ls -d busco_*
# identify the busco dir of best assembly, copy the treatments (starting with the library)
# Example,the busco dir for the best assembly for Sgr is `busco_contigs_results-SPAdes_Sfa-CBas-B_decontam_R1R2_noIsolate`
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_" 
cd probe_design
mv scaffolds.fasta Sgr_scaffolds_B_decontam_R1R2_noIsolate.fasta

mv scaffolds.fasta Ppa_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta
```

Execute the first script
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb "Sgr_scaffolds_B_decontam_R1R2_noIsolate.fasta"
```

Execute the second script
```sh
#WGprobe_annotation.sb <assembly base name> 
sbatch WGprobe_bedcreation.sb "Sgr_scaffolds_B_decontam_R1R2_noIsolate.fasta"
```

The longest scaffold is 105644

The upper limit used in loop is 97500

A total of 13063 regions have been identified from 10259 scaffolds


Moved out files to logs
```sh
mv *out ../logs
```

## Step 12. Fetching genomes for closest relatives

```sh
nano closest_relative_genomes_salarias_fasciatus.txt

Closest genomes:
1. Salarias fascistus - https://www.ncbi.nlm.nih.gov/genome/7248
2. Parablennius parvicornis - https://www.ncbi.nlm.nih.gov/genome/69445
3. Petroscirtes breviceps - https://www.ncbi.nlm.nih.gov/genome/7247
4. Ecsenius bicolor - https://www.ncbi.nlm.nih.gov/genome/41373
5. Gouania willdenowi - https://www.ncbi.nlm.nih.gov/genome/76090

Used Betancour et al. 2017 (All Blenniiformes)

---

**NOTE:** Sfa has a genome available in GenBank. 
