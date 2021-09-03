# Tzo Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/taeniamia_zosterophora/Multi_FASTQC/multiqc_report_fq.gz.html) Download to view

Potential issues:  
* % duplication - reasonable for 2/3 pairs
  * 1 F & R pair that has above 58%
  * 35s-67s
* gc content - reasonable
  * 41-43%
  * 2 samples failed per sequence GC content
* quality - good
  * sequence quality and per sequence qual both good
* % adapter - good and low
  * ~1s
* number of reads - good
  * ~184M

## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/taeniamia_zosterophora/fq_fp1/1st_fastp_report.html)

Potential issues:  
* % duplication - not bad for 2 individuals, but very high for 1
  * 42-44% for 2 and 81% for 1 indvidual
* gc content - reasonable
  * ~40%
  * more variable in pos 1-70 than in 70-150 
* passing filter - very good
  * ~95-97%
* % adapter - low 
  * 3-5%
* number of reads - good
  * ~302-411M

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora/shotgun_raw_fq
#runFASTP_1.sbatch <indir> <outdir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

Multiqc was ran seperately bc it was not working as set up in the runFASTP_1st_trim.sbatch.
 Other users, except for Eric, were automatically loading different versions of dependencies.

log for multiqc: mqc_fastp1-345222.out

Long-term solution:
added `module load multiqc` and run multiqc with `srun crun multiqc ....` in the runFASTP_1st_trim.sbatch script

---

## Step 3. Clumpify

Ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array in Wahab

```
#navigate to species' home dir
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/jbald004 3
```

Out files were moved to the `logs` dir

Ran [checkClumpify_EG.R] (https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R) to see if any files failed.

```
#navigate to out dir for clumpify
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora/fq_fp1_clmparray
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```
All files were successful!

---

## Step 4. Run fastp2

Ran on Wahab 

```
#runFASTP_2_ssl.sbatch <indir> <outdir>
# do not use trailing / in paths
#navigate to species dir
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora/
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray/ fq_fp1_clmparray_fp2
```

[Report](), download and open in web browser

Potential issues:  
* % duplication - good for 2
  * 12-13% for 2, 38% for 1
* gc content - reasonable
  *  40%
* passing filter - good
  *  80-89%
* % adapter - good
  * 0.1-0.2%
* number of reads
  * 98-187M

---

## Step 5. Run fastq_screen

Ran on Wahab
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing//herklotsichthys_quadrimaculatus/
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
```

Confirmed that all files were completed

```
# check output for errors
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for each input fq.gz file
#check that all 5 files were created for each file: 
ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

#You should also check for errors in the *out files:
# this will return any out files that had a problem

#do all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# or check individuals files <replace JOBID with your actual job ID>
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```

Ran MultiQC separately:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

[Report](), download and open in web browser

Potential issues:
* 96-97% alignment "One Hit, One Genome" 


Cleanup logs
```
mv *out logs
```

---

## Step 6. Repair fastq_screen paired end files

```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh]()
```sh
#read_calculator_ssl.sh <Species home dir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

Based on the 2 files:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

Reads lost:
* Varying percentage of reads lost per step
* Individual TzC0402F_CKDL210013395-1a-AK7758-GD07_HF33GDSX2_L4 had significantly lost ~78% of reads vs the 2 other individuals that only lost ~49% of reads
* The biggest read loss for TzC0402F was in the clumpify step ~70% vs 36% for 2 individuals
* At fp2 stage, 20% were lost for TzC0402F vs 10% for the 2 other individuals

Reads remaining:
* Conversely, reads remaining per step were generally 80-97%, except for the clumpify step where TzC0402F only retained 30% of its reads
* Total reads remaining: 21% for TzC0402F and 51% for the 2 other individuals

---
### Assembly section

## Step 7. Genome properties

I could not find Tzo in the [genomesize.com](https://www.genomesize.com/) database, thus I estimated the genome size of Sgr using jellyfish

From species home directory: Executed runJellyfish.sbatch using decontaminated files
```sh
#runJellyfish.sbatch <Species 2-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Tzo" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish__decontam"
```
This jellyfish kmer-frequency [histogram file]() was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=KfPRFUXJmbrA0rouEvNx). Highlights:

Description: Tzo_ssl_decontam
Kmer length: 21
Read length: 140
Max kmer coverage: 1000

Genome stats for Tzo from Jellyfish/GenomeScope v1.0 k=21
stat    |min    |max    |average
------  |------ |------ |------
Heterozygosity  |0.915939%       |0.920206%       |0.9180725%
Genome Haploid Length   |817,498,230 bp    |818,019,292 bp |817,758,761 bp
Model Fit       |97.6439%       |99.4735%       |98.5587%

---
## Step 8. Assemble the genome using SPAdes

Assembling contaminated data produced better results for nDNA and decontaminated was better for mtDNA.

Thus, run one assembly using your contaminated data and one with the decontaminated files.

This step was run in Turing. SPAdes requires high memory nodes (only avail in Turing)
Based on the min & max genome size of Tzo estimated by Jellyfish, in bp from the previous step, average was determined. 

Execute runSPADEShimem_R1R2_noisolate.sbatch*
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "contam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```
Repeat running the decontaminated data:
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "decontam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

Ran invidual libararies through these:
```
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "1" "contam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "2" "contam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "3" "contam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

Because the 3rd library had the highest QUAST & BUSCO scores, I ran decontam w/ it too.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "3" "decontam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

---
## Step 9. Determine the best assembly

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total length of assembly, (4) N50, and (5) L50 for each of your assemblies. This info will be entered in the table below.

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the following:
```
bash
cat quast-reports/quast-report_contigs_Tzo_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Tzo_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Tzo_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Tzo_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

To get summary for individual libraries, I did the ff:
```
bash
#2nd library only
cat quast-report_contigs_Tzo_spades_TzC0402F_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Tzo_spades_TzC0402F_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
#3rd library only
cat quast-report_contigs_Tzo_spades_TzC0402G_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Tzo_spades_TzC0402G_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
#1st library only
cat quast-report_contigs_Tzo_spades_TzC0402E_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Tzo_spades_TzC0402E_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

This SPAdes scripts automatically runs `QUAST` but not BUSCO.

**Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths:
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_contam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_decontam_R1R2_noIsolate" "scaffolds"
```

For the individual libraries, I did the following to run BUSCO:
```
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths:
#1st library
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402E_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402E_contam_R1R2_noIsolate" "scaffolds"
#2nd library
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402F_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402F_contam_R1R2_noIsolate" "scaffolds"
#3rd library
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402G_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402G_contam_R1R2_noIsolate" "scaffolds"
```


Then, to fill in the BUSCO single copy column, open the following files & look for S%:

Contam, contigs:
Contam, scaffolds:
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST & BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------
Tzo  |allLibs    |contam       |contigs       |off	 |96125  |236270       |745725175	|39.43%       |9041	  |24287       |50.7%
Tzo  |allLibs    |contam       |scaffolds     |off	 |74846  |320496       |812404903	|39.43%       |14515	   |15479	|64.7%
Tzo  |TzC0402E   |contam       |contigs       |off	 |65176  |227579       |830651102       |39.20%       |18737	|11972         |70.0%
Tzo  |TzC0402E   |contam       |scaffolds     |off	 |64301  |340415       |832616461       |39.20%       |19199    |11686       |70.1%
Tzo  |TzC0402F   |contam       |contigs       |off	 |84668  |48595        |466349924       |39.35%       |5684     |27045		|35.5
Tzo  |TzC0402F   |contam       |scaffolds     |off	 |86989  |69417        |506992391       |39.33%       |6119       |26533         |39.0%
Tzo  |TzC0402G   |contam       |contigs       |off	 |64326  |252063       |833348334       |39.20%        |19230       |11742         |70.8%
Tzo  |TzC0402G   |contam       |scaffolds     |off	 |63527  |252063       |834945222       |39.21%        |19682       |11491         |71.1%

Tzo  |allLibs    |decontam	 |contigs	|off	   |94520  |100990	 |657658468	  |39.44%	|7749       |24786	 |47.9%
