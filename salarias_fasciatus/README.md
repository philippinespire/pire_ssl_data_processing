# Sfa Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/salarias_fasciatus/Multi_FASTQC/multiqc_report_fq.gz.html) Download to view

Potential issues:  
* % duplication - low
  * 20s-26s
* gc content - reasonable
  * 45-47%
* quality - good
  * sequence quality and per sequence qual both good
* % adapter - good and low
  * ~4s
* number of reads - good
  * ~216M

## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/salarias_fasciatus/fq_fp1/1st_fastp_report.html)

Potential issues:  
* % duplication - low
  * 17-23%
* gc content - reasonable
  * ~45%
  * more variable at pos 1-70 than in 70-150 
* passing filter - good
  * ~95-96%
* % adapter - not too bad
  * 6-8.5%
* number of reads - good
  * ~324-504M

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus/shotgun_raw_fq
#runFASTP_1.sbatch <indir> <outdir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

Multiqc was ran seperately bc it was not working as set up in the runFASTP_1st_trim.sbatch.
 Other users, except for Eric, were automatically loading different versions of dependencies.

log for multiqc: mqc_fastp1-345231.out

Long-term solution:
added `module load multiqc` and run multiqc with `srun crun multiqc ....` in the runFASTP_1st_trim.sbatch script

---

## Step 3. Clumpify

Ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array in Wahab

```
#navigate to species' home dir 
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/jbald004 3
```

Out files were moved to the `logs` dir

Ran [checkClumpify_EG.R] (https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R) to see if any files failed.

```
#navigate to out dir for clumpify
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus/fq_fp1_clmparray
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
  * 3-6%
* gc content - reasonable
  * ~45% 
* passing filter - good
  * 87-89% 
* % adapter - good
  * 0.1-0.2%
* number of reads
  * 241-358M

---

## Step 5. Run fastq_screen

Ran on Turing.

```
#navigate to species dir
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus/
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
```

Confirmed that all files were successfully completed
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
Potential issues:
* 4 files failed: "No reads" in the following:
  * SfC0281G_CKDL210013395-1a-AK3911-AK845_HF33GDSX2_L4_clmp.fp2_r1.fq.gz
  * SfC0281G_CKDL210013395-1a-AK3911-AK845_HF33GDSX2_L4_clmp.fp2_r2.fq.gz
  * SfC0282A_CKDL210013395-1a-AK8593-7UDI304_HF33GDSX2_L4_clmp.fp2_r1.fq.gz
  * SfC0282A_CKDL210013395-1a-AK8593-7UDI304_HF33GDSX2_L4_clmp.fp2_r2.fq.gz

Re-run the 4 files that failed:
```
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 SfC0281G_CKDL210013395-1a-AK3911-AK845_HF33GDSX2_L4_clmp.fp2_r1.fq.gz
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 SfC0281G_CKDL210013395-1a-AK3911-AK845_HF33GDSX2_L4_clmp.fp2_r2.fq.gz
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 SfC0282A_CKDL210013395-1a-AK8593-7UDI304_HF33GDSX2_L4_clmp.fp2_r1.fq.gz
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 SfC0282A_CKDL210013395-1a-AK8593-7UDI304_HF33GDSX2_L4_clmp.fp2_r2.fq.gz
```

All files went through. 

Ran MultiQC separately:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

[Report](), download and open in web browser

Potential issues:
  * One hit, one genome ~96%

Cleanup logs
```
mv *out logs
```

## Step 6. Repair fastq_screen paired end files

Went through
```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh]()
```sh
#read_calculator_ssl.sh <Species home dir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
```

Based on the 2 files:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

Reads lost:
* Reads lost per step were between 3 to 19%
* Highest % lost was between 14-19% during clumpify step
* Overall, total read lost was between 34-36%

Reads remaining:
* Per step: 81%-97%
* Total reads remaining: 63-66%

---
### Assembly section

## Step 7. Genome properties

I found the genome size of Sfa in the [genomesize.com](https://www.genomesize.com/) database. It can be found [here] (https://www.genomesize.com/result_species.php?id=2683)

```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runJellyfish.sbatch "Sfa" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish__decontam"
```
This jellyfish kmer-frequency [histogram file]() was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=zwj01qbRCNCZ9oF2N8RV)

Description: Sfa_ssl_decontam
Kmer length: 21
Read length: 140
Max kmer coverage: 1000

Genome stats for Sfa from Jellyfish/GenomeScope v1.0 k=21
stat    |min    |max    |average
------  |------ |------ |------
Heterozygosity  |1.05362%       |1.08527%       |1.069445%
Genome Haploid Length   |577,799,589 bp    |579,898,449 bp | 578,849,019 bp
Model Fit       |90.9818%       |92.2968%       |91.6393%

---
## Step 8. Assemble the genome using SPAdes

Assembling contaminated data produced better results for nDNA and decontaminated was better for mtDNA.

Thus, run one assembly using your contaminated data and one with the decontaminated files.

This step was run in Turing. SPAdes requires high memory nodes (only avail in Turing)
Based on the min & max genome size of Sfa estimated by Jellyfish, in bp from the previous step, average was determined.

Execute runSPADEShimem_R1R2_noisolate.sbatch*
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "contam" "578849019" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "contam" "578849019" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
```

Repeat running the decontaminated data:
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "decontam" "578849019" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
```
---
## Step 9. Determine the best assembly

This SPAdes scripts automatically runs `QUAST` but runs `BUSCO` separately

**Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths:
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_contam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_decontam_R1R2_noIsolate" "scaffolds"
```

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total length of assembly, (4) N50, and (5) L50 for eac$

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the following:
```
bash
cat quast-reports/quast-report_contigs_Sfa_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Sfa_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

Then, to fill in the BUSCO single copy column, open the following files & look for S%:
Contam, contigs:
Contam, scaffolds:
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST & BUSCO Results

Species    |DataType    |SCAFIG    |covcutoff    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single co$
------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------
Sfa  |contam       |contigs       |off       |96125  |236270       |745725175       |39.43%       |9041       |24287       |50.7%
Sfa  |contam       |scaffolds       |off       |74846  |320496       |812404903       |39.43%       |14515       |15479       |64.7%
Sfa  |decontam       |contigs       |off       |94520  |100990       |657658468       |39.44%       |7749       |24786       |47.9%
Sfa  |decontam       |scaffolds       |off       |80472  |144523       |739361830       |39.40%       |11593       |17523       |61.4%



