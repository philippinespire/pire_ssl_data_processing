# Shotgun Data Processing Log - SSL data

Copy and paste this into a new species dir and fill in as steps are accomplished.

Following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) and [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmaps.

---

## **A. Pre-Processing Section**

## Step 0. Rename the raw fq.gz files

Used decode file from Sharon Magnuson.

```
salloc
bash

cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#run renameFQGZ.bash first to make sure new names make sense
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_ProbeDevelopmentLibraries_SequenceNameDecode.tsv

#run renameFQGZ.bash again to actually rename files
#need to say "yes" 2x
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```

---

## Step 1. Check quality of data with fastqc

Ran [`Multi_FASTQC.sh`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh). Specify out directory to write the output to.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/shotgun_raw_fq

#Multi_FastQC.sh "<indir>" "file extension"
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/shotgun_raw_fq" "fq.gz"
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/shotgun_raw_fq/fastqc_report.html) written out to `shotgun_raw_fq` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:  
  * % duplication - Medium to High
    * 41.7-52%
  * gc content - good
    * 41-42%
  * quality - good
    * Phred score around 35
  * % adapter - nice and low
    * up to 5-6%
  * number of reads - good amount
    * 164-184 M

---

## Step 2.  First trim with fastp

Ran [`runFASTP_1st_trim.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#sbatch runFASTP_1st_trim.sbatch <INDIR/full path to files> <OUTDIR/full path to desired outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1/1st_fastp_report.html) written out to `fq_fp1` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:  
  * % duplication -  medium to high
    * 39.3-47.8%
  * gc content - good
    * 41.5-41.7%
  * passing filter - good
    * 98.4-98.5%
  * % adapter -  good
    * 4.7-8.4%
  * number of reads - good amount
    * 324-362M

---

## Step 3. Clumpify

Ran [`runCLUMPIFY_r1r2_array.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array on Wahab.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/aethr001 3
```

Checked the output with [`checkClumpify_EG.R`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

salloc
enable_lmod
module load container_env mapdamage2

crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify worked succesfully!

Moved all `*out` files to the `logs` directory.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

mv *out logs
```

---

## Step 4. Run fastp2

Ran [`runFASTP_2_ssl.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runFASTP_2_ssl.sbatch <indir> <outdir> 
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2/2nd_fastp_report.html) written out to `fq_fp1_clmp_fp2` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:  
  * % duplication - low
    * 8.4-12.4%
  * gc content - good
    * 41.3-41.5%
  * passing filter - good
    * 85.5-87.6%
  * % adapter - good
    * 0.3%
  * number of reads - good amount 
    * 177-203M

---

## Step 5. Run fastq_screen

Ran [`runFQSCRN_6.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash).

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
#do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 6
```

Checked output for errors.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

ls fq_fp1_clmp_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmp_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.html | wc -l

#checked for errors in all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

#No errors!
```

Have to run Multiqc separately.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runMULTIQC.sbatch <indir> <report name>
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastqc_screen_report
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2_fqscrn/fastqc_screen_report.html) written out to `fq_fp1_clmp_fp2_fqscrn` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:
  * one hit, one genome, no ID 95.19-95.6% - good
  * no one hit, one genome to any potential contaminators (bacteria, virus, human, etc)  ~2%

Cleaned-up logs again.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

mv *out logs/
```

---

## Step 6. Repair fastq_screen paired end files

Ran [`runREPAIR.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch).

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runREPAIR.sbatch <indir> <outdir> <threads>
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

This went smoothly.

Have to run Fastqc-Multiqc separately.

```
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#Multi_FastQC.sh "<indir>" "file_extension"
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/fq_fp1_clmp_fp2_fqscrn_repaired" "fq.gz" 
```

[Report](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2_fqscrn_repaired/fastqc_report.html) written out to `fq_fp1_clmp_fp2_fqscrn_repaired` directory. *To visualize, click "view raw" and then add "[https://htmlpreview.github.io/?](https://htmlpreview.github.io/?)" to the beginning of the URL.*

Potential issues:  
  * % duplication - low
    * 9-12.9%
  * gc content - good
    * 40-41%
  * number of reads
    * 71-85M

---

## Step 7. Calculate the percent of reads lost in each step

Ran [`read_calculator_ssl.sh`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh).

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#sbatch read_calculator_ssl.sh <species home dir> 
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/"
```

Generated the [percent_read_loss](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/preprocess_read_change/readLoss_table.tsv) and [percent_reads_remaining](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/preprocess_read_change/readsRemaining_table.tsv) tables.

Reads lost:
  * fastp1 dropped 1.46-1.63% of the reads
  * 34.43-40.66% of reads were duplicates and were dropped by clumpify
  * fastp2 dropped 12.38-14.5% of the reads after deduplication

Reads remaining:
  * Total reads remaining: 47.04-51.03% 

---

## **B. Genome Assembly Section**

## Step 1. Genome Properties

*Species name* does (or does not) have a genome available at either genomesize.com or NCBI Genome databases. 
 
We will still estimate the genome size of *Species name* using Jellyfish to remain consistent with all the other species.

Executed `runJellyfish.sbatch` using the decontaminated files.

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runJellyfish.sbatch <Species 3-letter ID> <indir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sin" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/fq_fp1_clmp_fp2_fqscrn_repaired"
```

The Jellyfish kmer-frequency [histogram file](https://github.com/philippinespire/2022_PIRE_omics_workshop/blob/main/salarias_fasciatus/fq_fp1_clmp_fp2_fqscrn_repaired/Sfa_all_reads.histo) 
was uploaded into [GenomeScope v1.0](http://qb.cshl.edu/genomescope/) and [GenomeScope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/) to generate the [v1.report](**insert file**) and [v2.report](**insert file**). 

Genome stats for Sfa from Jellyfish/GenomeScope v1.0 & v2.0
stat    |min    |max    
------  |------ |------
Heterozygosity v1.0|2.19%       |2.21%       
Heterozygosity v2.0|2.25%       |2.28%       
Genome Haploid Length v1.0|637,291,583 bp    |639,392,195 bp 
Genome Haploid Length v2.0|672,451,551 bp    |674,735,358 bp 
Model Fit   v1.0|95.98%       |97.3287%       |XX%
Model Fit   v2.0|83.09%       |98.08%       |XX%

*Mention any red flags here, otherwise state "No red flags".* We will use the max value from V2 rounded up to ***675,000,000*** bp.

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 675000000

C-value from genomesize.com 1n: not_found

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. 

---

## Step 2. Assemble the Genome Using [SPAdes](https://github.com/ablab/spades#sec3.2)

Executed [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch) for each library and for all the libraries combined.

```sh
#new window
ssh aethr001@turing.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
#do not use trailing / in paths

#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "aethr001" "Sin" "1" "decontam" "675000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "fq_fp1_clmp_fp2_fqscrn_repaired"

#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "aethr001" "Sin" "2" "decontam" "675000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "fq_fp1_clmp_fp2_fqscrn_repaired"

#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "aethr001" "Sin" "3" "decontam" "675000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "fq_fp1_clmp_fp2_fqscrn_repaired"

#all libraries combined
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "aethr001" "Sin" "all_3libs" "decontam" "675000000" "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "fq_fp1_clmp_fp2_fqscrn_repaired"
```
 
JOB IDs:

```
[e1garcia@turing1 salarias_fasciatus]$ sq
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           9767803     himem     Sp8s e1garcia  R       0:01      1 coreV4-21-himem-003
           9767802     himem     Sp8s e1garcia  R       0:16      1 coreV4-21-himem-002
           9767801     himem     Sp8s e1garcia  R       0:27      1 coreV2-23-himem-004
           9767800     himem     Sp8s e1garcia  R       1:11      1 coreV2-23-himem-003
```

Libraries for each assembly:

Assembly  |  Library
--- | ---
A | 1G
B | 2F
C | 3E

This SPAdes scripts automatically runs `QUAST` but have to run `BUSCO` separately.

## Step 3. Running BUSCO

Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on both the `contigs` and `scaffolds` files.

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta/

#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
#do not use trailing / in paths

#1st library - contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate" "contigs"

#2nd library -contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_Sin-CPnd-B_decontam_R1R2_noIsolate" "contigs"

#3rd library - contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_Sin-CPnd-C_decontam_R1R2_noIsolate" "contigs"

#all libraries - contigs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_allLibs_decontam_R1R2_noIsolate" "contigs"

#1st library -scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate" "scaffolds"

#2nd library - scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_Sin-CPnd-B_decontam_R1R2_noIsolate" "scaffolds"

#3rd library - scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_Sin-CPnd-C_decontam_R1R2_noIsolate" "scaffolds"

#all libraries - scaffolds
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
```

## Step 4. Fill in QUAST and BUSCO Values

### Summary of QUAST (using GenomeScope v.2 <enter genome length> estimate) and BUSCO Results

Species    |Assembly    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------
Sin  |A  |decontam       |contgs       |off       |2       |  69126  |  150657  |  583970986  |  87% |  10319  |  15699  |  0  | 62%
Sin  |A  |decontam       |scaffolds       |off       |2    |  66358  |  156265  |  594601111  |  88% |  11303  |  14290  |  86  |  64%
Sin  |B  |decontam       |contgs       |off       |2       |  69634 |  150819  |  579984097  |  86% |  10094  |  15982  |  0  | 62%
Sin  |B  |decontam       |scaffolds       |off       |2    |  66872  |  176262  |  590947710  |  88%  |  11039  |  14518  |  89  |  65%
Sin  |C  |decontam       |contgs       |off       |2       |  67590  |  130976  |  344743603  |  51%  |  5055  |  22374  |  0  |  31%
Sin  |C  |decontam       |scaffolds       |off       |2    |  69302  |  158888  |  401718557  |  60%  |  5936  |  20361  | 613 |  38%
Sin  |allLibs  |decontam       |contigs       |off       |2    |  63103  |  135104  |  307932117  |  46% |  4743  |  21357  |  0  |  25%
Sin  |allLibs  |decontam       |scaffolds       |off       |2   |  66165  |  207211  |  372871799  |  55%  |  5629  |  19212  |  762  |  32%
Sin | A | contam | contigs | off | 2 | 69146 | 150657 | 583952407 | 87% | 10298 | 15714 | 0 | 62.1%
Sin | A | contam | scaffolds | off | 2 | 66368 | 156256 | 594609150 | 88% | 11279 | 14293 | 0 | 64.3%

## Step 5. Identify Best Assembly

What is the best assembley? Assembly A Library 1G

## Step 6. Assemble Contaminated Data From the Best Library

```sh
cd /home/e1garcia/shotgun_PIRE/REUs/2022_REU/Abby_Ethridge/stethojulis_interrupta

#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all_2libs | all_3libs | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
#do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sfa" "2" "contam" "635000000" "/home/e1garcia/shotgun_PIRE/2022_PIRE_omics_workshop/salarias_fasciatus" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

--- 

## **C. Probe Design - Regions for Probe Development**

Species directory copied over to Eric's dir - doing probe design from there.

```sh
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta

mkdir probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_annotation.sb probe_design
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta probe_design #copy best assembly
 
 # I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_" 
cd probe_design
mv scaffolds.fasta Sin_scaffolds_CPndA_decontam_R1R2_noIsolate.fasta
```

Execute the first script
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb "Sin_scaffolds_CPndA_decontam_R1R2_noIsolate.fasta"
```

Execute the second script
```sh
#WGprobe_annotation.sb <assembly base name> 
sbatch WGprobe_bedcreation.sb "Sin_scaffolds_CPndA_decontam_R1R2_noIsolate.fasta"
```

The longest scaffold is 156265

The upper limit used in loop is 147500

A total of 28546 regions have been identified from 17211 scaffolds


Move out files to logs
```sh
mv *out ../logs
```

## Step 12. Fetching genomes for closest relatives

Thanks John Whalen!

```
Closest relative genome
1. Thalassoma bifasciatum
https://www.ncbi.nlm.nih.gov/genome/83707
2. Cheilinus undulatus
https://www.ncbi.nlm.nih.gov/genome/9358
3.- Notolabrus celidotus
https://www.ncbi.nlm.nih.gov/assembly/GCF_009762535.1/
4.- Labrus bergylta
https://www.ncbi.nlm.nih.gov/assembly/GCF_900080235.1/
5.- Symphodus melops
https://www.ncbi.nlm.nih.gov/assembly/GCA_002819105.1/
```

## Files to send

```
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Message for Eric and Slack.

```
Probe Design Files Ready

A total of 28546 regions have been identified from 17211 scaffolds

Files for Arbor Bio:
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/probe_design/files_for_ArborSci/

Sin_scaffolds_CPndA_decontam_R1R2_noIsolate.fasta.augustus.gff
Sin_scaffolds_CPndA_decontam_R1R2_noIsolate.fasta.masked
Sin_scaffolds_CPndA_decontam_R1R2_noIsolate.fasta.out.gff
Sin_scaffolds_CPndA_decontam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_Stethojulis_interrupta.txt
```
## Cleaning up directory + backing up important files

Before cleaning up:
```
du -sh
#540G	.
du -h | sort -rh > Sin_ssl_beforeDeleting_IntermFiles
```

Making copies of important files.

```
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/
# does not exist - make a folder!
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/
# make copy of raw files
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/
# make copy of contaminated and decontaminated files
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/fq_fp1_clmp_fp2 /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/fq_fp1_clmp_fp2_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta

# make a copy of fasta files for best assembly (CPnd-A for Sin)
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_contam_R1R2_noIsolate /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta
```

Delete unneeded files. Make a log of deletions first.

```
# create log file before removing
ls -ltrh *raw*/*fq.gz > deleted_files_log
ls -ltrh *fp1/*fq.gz >> deleted_files_log
ls -ltrh *clmp/*fq.gz >> deleted_files_log
ls -ltrh *fqscrn/*fastq.gz >> deleted_files_log
#remove unneeded files
rm *raw*/*fq.gz
rm *fp1/*fq.gz
rm *clmp/*fq.gz
rm *fqscrn/*fastq.gz
```

Document size after deleting files.

```
du -sh
#231G	.
du -h | sort -rh > Sin_ssl_afterDeleting_IntermFiles
```

Move log files into logs.

```
mv Sin_ssl* logs
mv deleted_files_log logs
```

Done!
