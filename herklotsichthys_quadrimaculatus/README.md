# Hqu Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/herklotsichthys_quadrimaculatus/Multi_FASTQC/multiqc_report_fq.gz.html) Download to view

Potential issues:  
* % duplication - not bad
  * 29s-38s
* gc content - reasonable
  * 46-51%
* quality - good
  * sequence quality and per sequence qual both good
* % adapter - good and low
  * ~2s
* number of reads - good
  * ~216M


## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/herklotsichthys_quadrimaculatus/fq_fp1/1st_fastp_report.html)

Potential issues:  
* % duplication - not bad 
  * 22-37%
* gc content - reasonable
  * ~44%
  * more variable in pos 1-72 than in 73-150 
* passing filter - good
  * ~84-90%
* % adapter - not too bad 
  * 6-10%
* number of reads - good
  * ~309-442M

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus/shotgun_raw_fq
#runFASTP_1.sbatch <indir> <outdir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

Multiqc was ran seperately bc it was not working as set up in the runFASTP_1st_trim.sbatch.
 Other users, except for Eric, were automatically loading different versions of dependencies.

log for multiqc: mqc_fastp1-345230.out

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
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing//herklotsichthys_quadrimaculatus/fq_fp1_clmparray
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
  * 7-12%
* gc content - reasonable
  * ~44% 
* passing filter - good
  * ~81-82% 
* % adapter - very good
  * 0.1%
* number of reads - good
  * ~212-260M
---

## Step 5. Run fastq_screen

Ran on Turing
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus/
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
```

Confirmed whether all files where successful:

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

[Report](), download and open in web browser

Potential issues:
* 2 missing files
  * "No reads in HqC0021A_CKDL210013395-1a-5UDI301-7UDI304_HF33GDSX2_L4_clmp.fp2_r1, skipping"
  * "No reads in HqC0021A_CKDL210013395-1a-5UDI301-7UDI304_HF33GDSX2_L4_clmp.fp2_r2, skipping"

Fixed errors by running files again that returned the "No reads in" error and they worked fine

```
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 2 HqC0021A_CKDL210013395-1a-5UDI301-7UDI304_HF33GDSX2_L4_clmp.fp2_r1.fq.gz
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 2 HqC0021A_CKDL210013395-1a-5UDI301-7UDI304_HF33GDSX2_L4_clmp.fp2_r2.fq.gz
```

Ran MultiQC separately:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

[Report](), download and open in web browser

Potential errors:
* ~86% alignment to "One hit, one genome
* Low alignments with Bacteria_24k, Bird, Coral, Fungi, Human, Plant, Protists, Vectors & Viruses

Cleaned up logs
```
mv *out logs
```

---

## Step 6. Repair fastq_screen paired end files

Went through smoothly
```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```
**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh]()
```sh
#read_calculator_ssl.sh <Species home dir>
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus/
"
```

Based on the 2 files:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

Reads lost:
* For each step, reads lost ranged between 10 to 27%
* Total read loss was 56 to 61% for all 3 individuals

Reads remaining:
* For each step, ranged between 72 to 90%
* Total reads remaining ranged between 39-44%

---
### Assembly section

## Step 7. Genome properties

I found the genome size of Hqu in the [genomesize.com](https://www.genomesize.com/) database. It can be found [here] (https://www.genomesize.com/result_species.php?id=2074)

```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runJellyfish.sbatch "Hqu" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish__decontam"
```
This jellyfish kmer-frequency [histogram file]() was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=tHzBW2RjBK00gQMUSfl4)

Description: Hqu_ssl_decontam
Kmer length: 21
Read length: 140
Max kmer coverage: 1000

Genome stats for Hqu from Jellyfish/GenomeScope v1.0 k=21
stat    |min    |max    |average
------  |------ |------ |------
Heterozygosity  |0.449245%       |0.459506%       |0.4543755%
Genome Haploid Length   |843,747,830 bp    |845,694,580 bp |844,721,205 bp
Model Fit       |95.034%       |97.832%       |96.433%

---
## Step 8. Assemble the genome using SPAdes

Assembling contaminated data produced better results for nDNA and decontaminated was better for mtDNA.

Thus, run one assembly using your contaminated data and one with the decontaminated files.

This step was run in Turing. SPAdes requires high memory nodes (only avail in Turing)
Based on the min & max genome size of Hqu estimated by Jellyfish, in bp from the previous step, average was determined.

Execute runSPADEShimem_R1R2_noisolate.sbatch*
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "contam" "844721205" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
```
Repeat running the decontaminated data:
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "decontam" "844721205" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"

Ran invidual libararies through these:
```
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "1" "contam" "817758761" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ta$
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "2" "contam" "844721205" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "3" "contam" "844721205" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
```
---

## Step 9. Determine the best assembly

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total len$

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the follow$
```
bash
cat quast-reports/quast-report_contigs_Hqu_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Hqu_spades_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Hqu_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Hqu_spades_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

To get summary for individual libraries, I did the ff:
```
bash
#1st library only
cat quast-report_contigs_Hqu_spades_HqC0021A_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Hqu_spades_HqC0021A_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
#2nd library only
cat quast-report_contigs_Hqu_spades_HqC0021B_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Hqu_spades_HqC0021B_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
#3rd library only
cat quast-report_contigs_Hqu_spades_HqC0021C_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Hqu_spades_HqC0021C_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

This SPAdes scripts automatically runs `QUAST` but runs `BUSCO` separately

**Executed [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths:
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_contam_R1R2_noIsolate" "scaffolds"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_decontam_R1R2_noIsolate" "scaffolds"
```

For the individual libraries, I did the following to run BUSCO:
```
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths:
#1st library
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_HqC0021A_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_HqC0021A_contam_R1R2_noIsolate" "scaffolds"
#2nd library
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_HqC0021B_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_HqC0021B_contam_R1R2_noIsolate" "scaffolds"
#3rd library
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_HqC0021C_contam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus" "SPAdes_HqC0021C_contam_R1R2_noIsolate" "scaffolds"
```

Then, to fill in the BUSCO single copy column, open the following files & look for S%:
Contam, contigs:
Contam, scaffolds:
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST & BUSCO Results

EDIT THIS:
Species    |Library    |DataType    |SCAFIG    |covcutoff    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------
Hqu  |allLibs    |contam       |contigs       |off	 |126462  |1070312       |952740157       |41.11%       |8730	|34786       |%
Hqu  |allLibs    |contam       |scaffolds     |off	 |125095  |1070312       |960099166	|41.11%       |8957	  |34066       |%


Hqu  |HqC0021A   |contam       |contigs       |off	 |65176  |227579       |830651102	|39.20%       |18737    |11972         |%
Hqu  |HqC0021A   |contam       |scaffolds     |off	 |64301  |340415       |832616461	|39.20%       |19199    |11686       |%
Hqu  |HqC0021B   |contam       |contigs       |off	 |84668  |48595        |466349924	|39.35%       |5684     |27045
Hqu  |HqC0021B   |contam       |scaffolds     |off	 |86989  |69417        |506992391	|39.33%       |6119	  |26533         |%
Hqu  |HqC0021C   |contam       |contigs       |off	 |64326  |252063       |833348334	|39.20%        |19230       |11742         |%
Hqu  |HqC0021C   |contam       |scaffolds     |off	 |63527  |252063       |834945222	|39.21%        |19682       |11491         |%

Hqu  |allLibs    |decontam	 |contigs	|off	   |94520  |126080  |66692       |813845906       |41.15%       |7085	|37545       |%
Hqu  |allLibs    |decontam	 |scaffolds	|off	   |125228  |94589       |840397753	|41.15%       |7471	  |36480       |%

