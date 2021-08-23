# Pli Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/plotosus_lineatus/Multi_FASTQC/multiqc_report_fq.gz.html) Download to view

Potential issues:  
* % duplication - not bad
  * 21s-31s
* gc content - reasonable
  * 43-44%
* quality - good
  * sequence quality and per sequence qual both good
  * stable from 10 bp
* % adapter - good and low
  * ~2s
* number of reads - good
  * ~212M

## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/plotosus_lineatus/fq_fp1/1st_fastp_report.html)

Potential issues:  
* % duplication - not bad 
  * 20-31%
* gc content - reasonable
  * ~42%
  * more variable in pos 1-70 than in 70-150 
* passing filter - good
  * ~94-96%
* % adapter - not too bad 
  * 3.4-5.1%
* number of reads - good
  * ~296-515M

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus/shotgun_raw_fq
#runFASTP_1.sbatch <indir> <outdir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

---

## Step 3. Clumpify

Ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array in Wahab

```
#navigate to species' home dir
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/jbald004 3
```

Out files were moved to the `logs` dir

Ran [checkClumpify_EG.R] (https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R) to see if any files failed.

```
#navigate to out dir for clumpify
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus/fq_fp1_clmparray
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

All files were successful!
---

## Step 4. Run fastp2

```
#runFASTP_2.sbatch <indir> <outdir>
# do not use trailing / in paths
#navigate to species dir
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray/ fq_fp1_clmparray_fp2
```

[Report](), download and open in web browser

Potential issues:  
* % duplication - good  
  * 5-8%
* gc content - reasonable
  *  ~42%
* passing filter - good
  *  88-90%
* % adapter - good
  * 0.1%
* number of reads - good
  *  222-342M


---

## Step 5. Run fastq_screen

Ran on wahab.

```
3navigate to species dir
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
```

Checked output for errors:

```
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for each input fq.gz file
#check that all 5 files were created for each file: 
ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

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

Failed - "No reads in PlC0351F_CKDL210013395-1a-AK9144-AK7549_HF33GDSX2_L4_clmp.fp2_r1.fq.gz"

Ran this file again:

```
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 PlC0351F_CKDL210013395-1a-AK9144-AK7549_HF33GDSX2_L4_clmp.fp2_r1.fq.gz
```

Checked using the grep commands above. This file went through!

Ran MultiQC separately:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

[Report](), download and open in web browser

Potential issues:
* 96-9% alignment "One Hit, One Genome"


Cleanup logs
```
mv *out logs
```

---

## Step 6. Repair fastq_screen paired end files

This went smoothly.

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
# runREPAIR.sbatch <indir> <outdir> <threads>
sbatch ../scripts/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh]()
```sh
#read_calculator_ssl.sh <Species home dir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus"
```

Based on the 2 files:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

Reads lost:
* Varying percentage of reads lost per step, across all steps, % loss was between 4 to 25%
* The biggest read loss across all individuals was the Clumpify step, which was 16-25%.
* Total % reads lost was between 36-43%

Reads remaining:
* Conversely, reads remaining per step were generally 75 to 96%
* Total reads remaining for 3 individuals ranged between 57-64%

---
### Assembly section

## Step 7. Genome properties

I found the genome size of Sfa in the [genomesize.com](https://www.genomesize.com/) database. Here is the link to that [page] (https://www.genomesize.com/result_species.php?id=2683)

From species home directory: Executed runJellyfish.sbatch using decontaminated files
```sh
#runJellyfish.sbatch <Species 2-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Pli" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish__decontam"
```
This jellyfish kmer-frequency [histogram file]() was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=URnqm6DaJIVyouKPOCOI)

Description: Pli_ssl_decontam
Kmer length: 21
Read length: 140
Max kmer coverage: 1000

Genome stats for Pli from Jellyfish/GenomeScope v1.0 k=21
stat    |min    |max    |average
------  |------ |------ |------
Heterozygosity  |0.702616%         |0.7111730.9%       |0.7068945%
Genome Haploid Length   |737,279,443 bp    |738,434,396 bp     |737,856,920 bp
Model Fit       |95.7689%       |97.9334%       |96.85115%

---
## Step 8. Assemble the genome using SPAdes

Assembling contaminated data produced better results for nDNA and decontaminated was better for mtDNA.

Thus, run one assembly using your contaminated data and one with the decontaminated files.

This step was run in Turing. SPAdes requires high memory nodes (only avail in Turing)
Based on the min & max genome size of Pli estimated by Jellyfish, in bp from the previous step, average was determined.

Execute runSPADEShimem_R1R2_noisolate.sbatch*
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pli" "contam" "737856920" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus"
```
Repeat running the decontaminated data:
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Pli" "decontam" "737856920" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus"

---

## Step 9. Determine the best assembly

This SPAdes scripts automatically runs `QUAST` but runs `BUSCO` separately

**Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths:
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus" "SPAdes_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus" "SPAdes_contam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus" "SPAdes_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/plotosus_lineatus" "SPAdes_decontam_R1R2_noIsolate" "scaffolds"
```

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total length of assembly, (4) N50, and (5) L50 for eac$

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the following:
```
bash
cat quast-reports/quast-report_contigs_Pli_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Pli_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Pli_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Pli_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

Then, to fill in the BUSCO single copy column, open the following files & look for S%:
Contam, contigs:
Contam, scaffolds:
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST & BUSCO Results

Species    |DataType    |SCAFIG    |covcutoff    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single co$
------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------
Pli  |contam       |contigs       |off       |126462  |1070312       |952740157       |41.11%       |8730       |34786       |%
Pli  |contam       |scaffolds       |off       |125095  |1070312       |960099166       |41.11%       |8957       |34066       |%
Pli  |decontam       |contigs       |off       |126080  |66692       |813845906       |41.15%       |7085       |37545       |%
Pli  |decontam       |scaffolds       |off       |125228  |94589       |840397753       |41.15%       |7471       |36480       |%


