scp /work/hobi/GCL/20220408_PIRE-Sne-shotgun/* e1garcia@turing.hpc.odu.edu:/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera


All three sequence sets are from individual Sne-CTaw_051_Ex1

===============

## Sphaeramia nematoptera: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Sne_ProbeDevelopmentLibraries_SequenceNameDecode.tsv

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Sne data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/fq_raw_shotgun" 
```
[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/sphaeramia_nematoptera/Multi_FASTQC/Sne_multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUOONAUBPX4L3XHKQ7WYTMR22Q) (copy and paste into a text editor locally, save and open in your browser to view)

Potential issues:

* duplication - low to moderate
* 27.4% - 29.0%
* gc content:
* 40-41%
* sequence quality good
* high adapter content - all 6 samples failed, cumulative % is 12.6-15.8%
* lots of sequences for all libraries, 190 - 229.M

===============
## Step 2 FASTP - 1st trim

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw_shotgun fq_fp1
```
Used runFASTP_1st_trim.sbatch to generate this [report] <insert>

Potential issues:

* % duplication - moderate
24.1-26.1%
* gc content - reasonable
~39.3-39.8%
more variable in pos 1-11 than in 11-150
* passing filter - very good
~97.9-98.1%
* % adapter - moderate
16.7-20.3%%
* number of reads - good
~372-449M

===============
## Step 3 Remove duplicates through Clumpify

runCLUMPIFY_r1r2_array.bash in https://github.com/philippinespire/pire_fq_gz_processing was run on fq.gz files

```sh
bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/jbald004 20
```

Checked whether clumpify was successful by navigating to the output folder and excecuting

```sh
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify was successful

===============
## Step 4 FASTP 2nd trim

To assemble genome using this data, runFASTP_2_ssl.sbatch was used

```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report], download and open in web browser

Potential issues:

% duplication - good
5.4-6.2%
gc content - reasonable
~39.1-39.6%
passing filter - fair
76-77.6%
% adapter - good
0.2-0.3%
number of reads - good
221-263M

===============
## Step 5 Decontaminate files FQSCRN

Ran on Wahab and used 6 nodes since there were 6 files

```sh
#navigate to species dir
bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 6
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

## STEP 6 runREPAIR.sbatch

```sh
sbatch runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

Ran MultiQC separately
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/runMULTIQC.sbatch "fq_fp1_clmp_fp2_fqscrn" "fqsrn_report"
```

Report, download and open in web browser.

One Hit, One Gneome at 94-95%

Cleaned up logs

## STEP 7 Calculating % reads lost

Execute read_calculator_ssl.sh

```sh
#read_calculator_ssl.sh <Path to species home dir> 
# do not use trailing / in paths. Example:
sbatch pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera"
# or 
sbatch read_calculator_ssl.sh "."
```
read_calculator_ssl.sh counts the number of reads before and after each step in the pre-process of ssl data and creates the dir reprocess_read_change with the following 2 tables:
1. readLoss_table.tsv which reporsts the step-specific percent of read loss and final accumulative read loss
2. readsRemaining_table.tsv which reports the step-specific percent of read loss and final accumulative read loss

Inspect these tables and revisit steps if too much data was lost

Reads lost:
* Varying percentage of reads lost per step, across all steps, % loss was between 2 to 24%
* The biggest read loss across all individuals was the Clumpify & Fastp2 steps, which were 22.4-24%.
* Total % reads lost was between 46.6-47%

Reads remaining:
* Conversely, reads remaining per step were generally 75 to 96%
* Total reads remaining for 3 individuals ranged between 52.8-53.6%

## STEP 8 Clean Up

Moved the .out files into the logs dir after each step is completed:

```sh
mv *out /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/logs
```

##### ASSEMBLY SECTION

## STEP 1 Genome Properties

Genomesize.com did not have size for S. nematoptera

Proceeded with Jellyfish to estimate genome size
 
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sne" "fq_fp1_clmp_fp2_fqscrn_repaired" "fq_fp1_clmp_fp2_fqscrn_repaired_jfsh"
```

Genome stats for Sne from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.6251%       |0.6317%
2  |Heterozygosity  |0.6326%       |0.6527%
1  |Genome Haploid Length   |843,843,601 bp |844,754,148 bp
2  |Genome Haploid Length   |962,934,475 bp |964,616,341 bp
1  |Model Fit       |95.754%       |98.1905%
2  |Model Fit       |75.493%       |98.0265%

Values for heterozygosity for both Genome scope 1.0 & 2.0 are similar. The Haploid length is different, but I chose to go with vales for Genomescope 2.0 although results are very similar because there are more species in the Apogonidae family with 0.9 and 1.0 Mbp size. I am moving forward with rounding up the max Haploid length from GenomeScope 2.0, which is 965,000,000

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 965000000

C-value from genomesize.com 1n: not_found

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. 

---

### Step 2 Assembly w/ SPAdes

Assemble Genome using SPAdes

```sh
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sne" "1" "decontam" "965000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera" "fq_fp1_clmparray_fp2_fqscrn_repaired"
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sne" "2" "decontam" "965000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera" "fq_fp1_clmparray_fp2_fqscrn_repaired"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sne" "3" "decontam" "965000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera" "fq_fp1_clmparray_fp2_fqscrn_repaired"
#all libs
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sne" "all_3libs" "decontam" "965000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera" "fq_fp1_clmparray_fp2_fqscrn_repaired"
```
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
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" "contigs"
```

---
8/1/22: Brendan Reid taking over assembly, running 1/2/3/allLibs decontam assemblies

Scaffold assembly summaries:

| Species | Library | DataType | SCAFIG    | covcutoff | genomescope v. | # contigs | Largest contig | Total length | Est length | % Genome size completeness | N50   | L50   | BUSCO single copy |
|---------|---------|----------|-----------|-----------|----------------|-----------|----------------|--------------|------------|----------------------------|-------|-------|-------------------|
| Sne     | Ctaw-A  | decontam | scaffolds | off       | 2              | 99907     | 140168         | 803923447    | 965000000  | 0.833081292                | 9731  | 22969 | 58%               |
| Sne     | Ctaw-B  | decontam | scaffolds | off       | 2              | 100579    | 124630         | 805679160    | 965000000  | 0.834900684                | 9638  | 23340 | 56.90%            |
| Sne     | Ctaw-C  | decontam | scaffolds | off       | 2              | 96967     | 122898         | 780324776    | 965000000  | 0.808626711                | 9760  | 22606 | 54.30%            |
| Sne     | allLibs | decontam | scaffolds | off       | 2              | 99297     | 155721         | 817890798    | 965000000  | 0.847555231                | 10060 | 22244 | 58%               |

allLibs looks slightly better than the others. I attempted to run SPAdes on allLibs_contam but didn't successfully complete - since we don't need contam for probe development though the best usable assembly would be allLibs. 

---
9/13/22: Jem Baldisimo taking over probe development. Best decontam assembly done by B. Reid to be used for probe development
---
 
# Sphaeramia nematoptera: [Low coverage whole genome sequencing](https://github.com/philippinespire/pire_lcwgs_data_processing) 

---

Jordan Rodriguez

---

This species was ran through the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) pipeline by Jem Baldisimo. An outline of her efforts can be found above. Below is the roadmap for pushing *Sphaeramia nematoptera* through the [LCWGS pipeline](https://github.com/philippinespire/pire_lcwgs_data_processing).

---

To run Sne through the LCWGS pipeline, I started with locating the fltrd/repaired fq.gz files that had gone through the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) pipeline, and I picked up at step 3. of the [LCWGS](https://github.com/philippinespire/pire_lcwgs_data_processing) pipeline titled "Get your reference genome".

