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

Ran [checkClumpify_EG.R](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R) to see if any files failed.

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

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/salarias_fasciatus/fq_fp1_clmparray_fp2/2nd_fastp_report.html), download and open in web browser

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

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/salarias_fasciatus/fq_fp1_clmparray_fp2_fqscrn/fqsrn_report.html?token=AJSZEDFXEVVIS5FTR5CBQKDBWOQMG), download and open in web browser

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
* Total reads remaining: 63-66% (112-165M reads)

---
### Assembly section

## Step 7. Genome properties

I found the genome size of Sfa in the [genomesize.com](https://www.genomesize.com/) database. It can be found [here] (https://www.genomesize.com/result_species.php?id=2683)

```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runJellyfish.sbatch "Sfa" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish__decontam"
```
This jellyfish kmer-frequency [histogram file](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/salarias_fasciatus/jellyfish_decontam/Sfa_all_reads.histo) was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=zwj01qbRCNCZ9oF2N8RV)

Description: Sfa_ssl_decontam
Kmer length: 21
Read length: 140
Max kmer coverage: 1000

There may be differences in GenomeScope results, depending on the version. As such, we uploaded the same file to the [GenomesScope v2.0 website](http://qb.cshl.edu/genomescope/genomescope2.0/) too, with the following input:

Description: Sfa_ssl_decontam2
Kmer length: 21
Ploidy: 2
Max kmer coverage: -1
Average k-mer coverage for polyploid genome: -1

The report generated for v2.0 is [here](http://genomescope.org/genomescope2.0/analysis.php?code=hGAiwIq4ab6yyLFhgOae)

Genome stats for Sfa from Jellyfish/GenomeScope v1.0 & v2.0
stat    |min    |max    
------  |------ |------
Heterozygosity v1.0|1.05362%       |1.08527%       
Heterozygosity v2.0|1.08056%       |1.10253%       
Genome Haploid Length v1.0|578,000,000 bp    |580,000,000 bp 
Genome Haploid Length v2.0|634,000,000 bp    |635,000,000 bp 
Model Fit   v1.0|90.9818%       |92.2968%       |91.6393%
Model Fit   v2.0|80.1744%       |93.4121%       |86.79325%


---
## Step 8. Assemble the genome using SPAdes

Assembling contamþinated data produced better results for nDNA and decontaminated was better for mtDNA.

Thus, run one assembly using your contaminated data and one with the decontaminated files.

This step was run in Turing. SPAdes requires high memory nodes (only avail in Turing)
Based on the min & max genome size of Sfa estimated by Jellyfish, in bp from the previous step, average was determined.

Execute runSPADEShimem_R1R2_noisolate.sbatch*
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "contam" "all" "635000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "contam" "635000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
```
Repeat running the decontaminated data:
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "decontam" "all" "635000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
```

Ran individual libraries:
```
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "1" "contam" "635000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "2" "contam" "635000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Sfa" "3" "contam" "635000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus"
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
#1st lib
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0281G_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0281G_contam_R1R2_noIsolate" "scaffolds"
#2nd lib
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0281H_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0281H_contam_R1R2_noIsolate" "scaffolds"
#3rd lib
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0282A_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0282A_contam_R1R2_noIsolate" "scaffolds"
#BUSCO for decontam of 3rd lib
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0282A_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/salarias_fasciatus" "SPAdes_SfC0282A_decontam_R1R2_noIsolate" "scaffolds"
```

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total length of assembly, (4) N50, and (5) L50 for eac$

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the following:
```
bash
cat quast-reports/quast-report_contigs_Sfa_spades_allLibs_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_allLibs_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
#for individual libraries:
cat quast-reports/quast-report_contigs_Sfa_spades_SfC0281G_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_SfC0281G_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Sfa_spades_SfC0281H_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_SfC0281H_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Sfa_spades_SfC0282A_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_SfC0282A_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
#for decontam of highest library
cat quast-reports/quast-report_contigs_Sfa_spades_SfC0282A_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Sfa_spades_SfC0282A_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S

```

Then, to fill in the BUSCO single copy column, open the following files & look for S%:
Contam, contigs:
Contam, scaffolds:
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST (using Genome Scope v.1 578849019 estimate) & BUSCO Results

Species    |DataType    |SCAFIG    |covcutoff    |genome scope v.  |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------ |------ |------ |------  |------ |------ |------|------ |------  |------ |------
Sfa  |allLibs    |contam       |contigs       |off       |1     |96125  |236270       |745725175       |128.83%       |9041       |24287       |50.7%
Sfa  |allLibs    |contam       |scaffolds       |off       |1     |74846  |320496       |812404903       |140.35%       |14515       |15479       |64.7%
Sfa  |SfC0281G   |contam      |contigs        |off       |1     |66551  |87063      |484209845        |83.65%      |8351      |17065      |52.6%
Sfa  |SfC0281G   |contam      |scaffolds      |off       |1     |47251  |206689     |549666344        |94.96%	    |17292     |8582      |70.3%
Sfa  |SfC0281H   |contam      |contigs        |off       |1     |64803  |119618     |510341019        |83.65%	    |9378      |15757      |57.0%
Sfa  |SfC0281H   |contam      |scaffolds      |off       |1     |45792  |356588     |563766158        |94.96%      |18875     |8063	   |73.0%
Sfa  |SfC0282A   |contam      |contigs        |off       |1     |66229  |97374      |490610142        |88.16%      |8579      |16761       |53.8%
Sfa  |SfC0282A   |contam      |scaffolds      |off	 |1     |46311  |221552     |555041474        |97.39%      |18095     |8177	   |71.2%
Sfa  |SfC0282A   |decontam      |contigs        |off	 |1     |65497  |92703      |489935535        |84.76%      |8715      |16767	   |55.5%
Sfa  |SfC0282A   |decontam      |contigs        |off	 |1     |51279  |140503     |539947694        |93.28%      |14718     |10321	   |69.5%

Summary of QUAST (using Genome Scope v.2 635000000 estimate) & BUSCO Results

Species    |Library     |DataType    |SCAFIG    |covcutoff    |genome scope v. |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp |BUSCO single copy 
------  |------ |------ |------ |------ |------  |------ |------ |------ |------  |------ |------ |----- |-----
Sfa  |allLibs    |contam       |contigs       |off       |2     |65925      |143244          |505647697     |79.63%     |9029     |16262     |0.00     |50.7%
Sfa  |allLibs    |contam       |scaffolds       |off       |2     |44568      |280192          |565789902   |89.10%     |19913    |7533      |866.33   |72.9%
Sfa  |SfC0281G   |contam      |contigs        |off       |2     |66496      |87063           |484063030     |76.23%     |8356     |17038     |0.00     |52.6%
Sfa  |SfC0281G   |contam      |scaffolds      |off       |2     |47190      |206530          |549551838     |86.54%     |17320    |8563      |899.99   |70.3%
Sfa  |SfC0281H   |contam      |contigs        |off       |2     |64803      |119618          |510341019     |80.37%     |9378     |15757     |0.00     |57.0%
Sfa  |SfC0281H   |contam      |scaffolds      |off       |2     |45792      |356588          |563766158     |88.78%     |18875    |8063      |765.81   |73.0%
Sfa  |SfC0282A   |contam      |contigs        |off       |2     |66229      |97374           |490610142     |77.26%     |8579     |16761     |0.00     |53.8%
Sfa  |SfC0282A   |contam      |scaffolds      |off       |2     |46311      |221552          |555041474     |87.41%     |18095    |8177      |892.51   |71.2%
Sfa  |allLibs   |decontam      |contigs        |off     |2     |updateALLcol      |92703           |489935535     |77.16%     |8715     |16767     |0.00     |55.5%
Sfa  |allLibs   |decontam      |contigs        |off     |2     |updateALLcol     |140503          |539947694     |85.03%     |14718    |10321     |643.68   |69.5%                             



---
The best library was allLibs contam scaffolds.
#### Main assembly stats

New record of Sfa added to [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) file
```sh
# add your info in a new row
nano ../best_ssl_assembly_per_sp.tsv
```

---
### Probe Design

In this section I identified contigs and regions within contigs to be used as candidate regions to develop the probes from.

The following 4 files were created at the end of this step:
1. *.fasta.masked: The masked fasta file
2. *.fasta.out.gff: The gff file created from repeat masking (identifies regions of genome that were masked)
3. *_augustus.gff: The gff file created from gene prediction (identifies putative coding regions)
4. *_per10000_all.bed: The bed file with target regions (1 set of 2 probes per target region).

#### 10 Identifying regions for probe development

From the species directory, a new dir was made for the probe design
```sh
mkdir probe_design
```
Necessary scripts and the best assembly were copied (i.e. scaffolds.fasta from contaminated data of best assembly) into the probe_design dir (you had already selected the best assembly) 

```sh
cp SPAdes_allLibs_contam_R1R2_noIsolate/scaffolds.fasta probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
```

I renamed the assembly to reflect the species and parameters used. I copy and pasted the parameter info from the busco directory
```sh
# list the busco dirs by entering
ls -d busco_*
# identify the busco dir of the best assembly, copy the treatments (starting with the library)
# Since the busco dir for the best assembly for Sfa is the scaffolds for allLibs
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_"
cd probe_design

```sh
mkdir probe_design
mv scaffolds.fasta Sfa_scaffolds_allLibs_contam_R1R2_noIsolate.fasta
```
Added this line to the WGprobe_annotation script so I could run it from my home directory:
export SINGULARITY_BIND=/home/e1garcia

Execute the first script:
```sh
#WGprobe_annotation.sb <assembly name>
sbatch WGprobe_annotation.sb "Sfa_scaffolds_allLibs_contam_R1R2_noIsolate.fasta"
```

This will create:
1. a repeat-masked fasta and gff file (.fasta.masked & .fasta.out.gff)
2. a gff file with predicted gene regions (augustus.gff), and
3. a sorted fasta index file that will act as a template for the .bed file (.fasta.masked.fai)

Execute the second script.
```sh
#WGprobe_annotation.sb <assembly base name>
sbatch WGprobe_bedcreation.sb "Sfa_scaffolds_allLibs_contam_R1R2_noIsolate.fasta"
```

This will create a .bed file that will be sent for probe creation.
 The bed file identifies 5,000 bp regions (spaced every 10,000 bp apart) in scaffolds > 10,000 bp long.

**Results**

The longest scaffold is 280192

The upper limit used in loop is 277500

A total of 37134 regions have been identified from 16894 scaffolds

Moved out files to logs
```sh
mv *out ../logs
```

## step 11. Fetching genomes for closest relatives

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

**NOTE:** Sfa had a genome available at GenBank. We download it and mapped our read to chromosome 1 (to speed up the process)
