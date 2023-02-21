scp /work/hobi/GCL/20220412_PIRE-Pba-shotgun/* e1garcia@turing.hpc.odu.edu:/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis

All three sequence sets are from individual Pba-CTat_001_Ex1

===================

# Pomacentrus brachialis: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing

bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/renameFQGZ.bash Pba_ProbeDevelopmentLibraries_SequenceNameDecode.tsv

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Pba data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/fq_raw_shotgun"
```
[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/pomacentrus_brachialis/Multi_FASTQC/Pba_multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUOONAUBP$

Potential issues:

* duplication - low to moderate
* 19.0% - 25.1%
* gc content:
* 42-43%
* sequence quality good
* moderate to high adapter content - 2 samples had warnings and 4 failed (D & E libraries). cumulative % is 7.8-17.6%
* lots of sequences for 2/3 libraries, 98.4 - 201 M

===============
## Step 2 FASTP - 1st trim

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw_shotgun fq_fp1
```
Used runFASTP_1st_trim.sbatch to generate this [report] <insert>

Potential issues:

% duplication - low
13.6-20.7%
gc content - reasonable
~41.8-42.0%
more variable in pos 1-11 than in 11-150
passing filter - very good
~98.0-98.2%
% adapter - moderate
11.5-22.6%
number of reads - good
~193-394M

==============
## Step 3 Clumpify

runCLUMPIFY_r1r2_array.bash in https://github.com/philippinespire/pire_fq_gz_processing was run on fq.gz files

```sh
bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/jbald004 20
```

Checked whether clumpify was successful by navigating to the output folder and excecuting

```sh
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify was successful!

===============
## Step 4 FASTP 2nd trim

To assemble genome using this data, runFASTP_2_ssl.sbatch was used

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report], download and open in web browser

Potential issues:

% duplication - very good
2.3-3.7%
gc content - reasonable
~41.5%
passing filter - good
77.3-84.4%
% adapter - good
0.2-0.3%
number of reads - good
134-258M

===============
## Step 5 Decontaminate files FQSCRN

Ran on Wahab and used 6 nodes since there were 6 files

```sh
#navigate to species dir
bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 6
```

Checked output for errors                   

```sh
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for e$
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

## Step 6 runREPAIR.sbatch

```sh
sbatch runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```
Ran MultiQC separately
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/pire_fq_gz_processing/runMULTIQC.sbatch "fq_fp1_clmp_fp2_fqscrn" "fqsrn_report"
```

Report, download and open in web browser.

Multiple hits, One Genome - 95-96%

Cleaned up logs

## STEP 7 Calculating % reads lost

Execute read_calculator_ssl.sh

```sh
#read_calculator_ssl.sh <Path to species home dir> 
# do not use trailing / in paths. Example:
sbatch pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis""
# or 
sbatch read_calculator_ssl.sh "."
```
read_calculator_ssl.sh counts the number of reads before and after each step in the pre-process of ssl data and creates the dir reprocess_read_change with the following 2 tables:
1. readLoss_table.tsv which reporsts the step-specific percent of read loss and final accumulative read loss
2. readsRemaining_table.tsv which reports the step-specific percent of read loss and final accumulative read loss

Inspect these tables and revisit steps if too much data was lost

Reads lost:
* Varying percentage of reads lost per step, across all steps, % loss was between 1.8 to 22.7%
* The biggest read loss across all individuals was the Fastp2 step, which was 15.6-22.7%
* Total % reads lost was between 36.5-40.9%

Reads remaining:
* Conversely, reads remaining per step were generally 77 to 98%
* Total reads remaining for 3 individuals ranged between 59.1-63.5%

## STEP 8 Clean Up

Moved the .out files into the logs dir after each step is completed:

```sh
mv *out /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis/logs

##### ASSEMBLY SECTION

## STEP 1 Genome Size

Genomesize.com has 0.8 pg as genome size for Pba but I proceeded with Jellyfish to estimate genome size since Hardie and Herbert 2004, which is the reference paper for the genome size, doesn't really list P. brachialis specifically.

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Pba" "fq_fp1_clmp_fp2_fqscrn_repaired" "fq_fp1_clmp_fp2_fqscrn_repaired_jfsh"
```

Genome stats for Pba from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |1.05409%       |1.07353%
2  |Heterozygosity  |0.99268%       |1.05366%
1  |Genome Haploid Length   |932,326,612 bp |936,757,548 bp
2  |Genome Haploid Length   |1,014,945,059 bp |1,023,258,882 bp
1  |Model Fit       |94.1608%       |96.9003%
2  |Model Fit       |77.3976%       |97.2423%

I am choosing Haploid lenghth from v. 2.0 since it has less errors and higher max model fit. Rounded up, haploid length is 1,023,000,000 

## STEP 2

```sh
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pba" "1" "decontam" "1023000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis" "fq_fp1_clmparray_fp2_fqscrn_repaired"
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pba" "2" "decontam" "1023000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis" "fq_fp1_clmparray_fp2_fqscrn_repaired"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pba" "3" "decontam" "1023000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis" "fq_fp1_clmparray_fp2_fqscrn_repaired"
#all 3 libs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pba" "all_3libs" "decontam" "1023000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis" "fq_fp1_clmparray_fp2_fqscrn_repaired"
```

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 1023000000 

C-value from genomesize.com 1n: 0.80

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. Hardie, D.C. and P.D.N. Hebert (2004). Genome-size evolution in fishes. Canadian Journal of Fisheries and Aquatic Sciences 61: 1636-1646. (from genomesize.com)

---

TO DO:
### Step 3 Review Assembly Quality

QUAST was automatically ran by the SPAdes script. Look for the quast_results dir and for each of your assemblies note the:

Number of contigs in assembly (this is the last contig column in quast report with the name "# contigs")
the size of the largest contig
total length of assembly
N50
L50
*Tip: you can align the columns of any .tsv for easy viewing with the comand column in bash. Example:

```sh
bash
cat quast-reports/quast-report_scaffolds_Sgr_spades_contam_R1R2_21-99_isolate-off.tsv | column -ts $'\t' | less -S
```
Enter your stats in the table below

### Step 4 BUSCO
Execute runBUCSO.sh on the contigs and scaffolds files for each assembly

```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths. Example using contigs:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" $

8/1/22 Brendan Reid taking over - running allLibs assembly on Turing

8/4/22 A/B/C and A contam have been run. A contam is the best, slightly smaller largest contig than A decontam but higher N50 and BUSCO. Will use this for PSMC
```
  
### MitoFinder

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_brachialis Pba SPAdes_Pba-CTat-A_decontam_R1R2_noIsolate Pomacentridae
```
