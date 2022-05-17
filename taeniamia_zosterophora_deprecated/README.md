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

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/taeniamia_zosterophora/fq_fp1_clmparray_fp2/2nd_fastp_report.html), download and open in web browser

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

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/taeniamia_zosterophora/fq_fp1_clmparray_fp2_fqscrn/fqsrn_report.html), download and open in web browser

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
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Tzo" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```
This jellyfish kmer-frequency [histogram file](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/taeniamia_zosterophora/jellyfish_decontam/Tzo_all_reads.histo) was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=KfPRFUXJmbrA0rouEvNx). Highlights:

Description: Tzo_ssl_decontam
Kmer length: 21
Read length: 140
Max kmer coverage: 1000

There may be differences in GenomeScope results, depending on the version. As such, we uploaded the same file to the [GenomesScope v2.0 website](http://qb.cshl.edu/genomescope/genomescope2.0/) too, with the following input:

Description: Tzo_ssl_decontam2
Kmer length: 21
Ploidy: 2
Max kmer coverage: -1
Average k-mer coverage for polyploid genome: -1

The report generated for v2.0 is [here](http://genomescope.org/genomescope2.0/analysis.php?code=iYAXsA0hmMtIMGeLX19n)

Genome stats for Tzo from Jellyfish/GenomeScope v1.0 & v2.0
stat    |min    |max    |
------  |------ |------ |
Heterozygosity v1.0 |0.915939%       |0.920206%
Heterozygosity v2.0 |0.911721%       |0.928177%    
Genome Haploid Length v1.0   |817,498,230 bp    |818,019,292 bp 
Genome Haploid Length v2.0   |882,851,069 bp    |884,000,000 bp
Model Fit v1.0      |97.6439%       |99.4735%     
Model Fit v2.0      |82.422%       |99.3423%    
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
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "contam" "884000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```
Repeat running the decontaminated data:
```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "decontam" "884000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

Ran invidual libraries through these:
```
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "1" "contam" "884000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "2" "contam" "884000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "3" "contam" "884000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

Because the 3rd library had the highest QUAST & BUSCO scores, I ran decontam w/ it too.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Tzo" "3" "decontam" "884000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora"
```

---
## Step 9. Determine the best assembly

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total length of assembly, (4) N50, and (5) L50 for each of your assemblies. This info will be entered in the table below.

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the following:
```
bash
cat quast-reports/quast-report_contigs_Tzo_spades_allLibs_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Tzo_spades_allLibs_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
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
#decontam for 3rd library
cat quast-report_contigs_Tzo_spades_TzC0402G_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-report_scaffolds_Tzo_spades_TzC0402G_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
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
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402G_decontam_R1R2_noIsolate" "contigs"
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/taeniamia_zosterophora" "SPAdes_TzC0402G_decontam_R1R2_noIsolate" "scaffolds"
```

Then, to fill in the BUSCO single copy column, open the following files & look for S%:

Contam, contigs:
Contam, scaffolds:
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST (using Genome Scope v.1 817758761 estimate) & BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v. |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------|-------
Tzo  |allLibs    |contam       |contigs       |off	 |1     |96125  |236270       |745725175	|91.19%       |9041	  |24287       |50.7%
Tzo  |allLibs    |contam       |scaffolds     |off	 |1     |74846  |320496       |812404903	|99.35%       |14515	   |15479	|64.7%
Tzo  |TzC0402E   |contam       |contigs       |off	 |1     |65176  |227579       |830651102       |101.58%       |18737	|11972         |70.0%
Tzo  |TzC0402E   |contam       |scaffolds     |off	 |1     |64301  |340415       |832616461       |101.82%       |19199    |11686       |70.1%
Tzo  |TzC0402F   |contam       |contigs       |off	 |1     |84668  |48595        |466349924       |57.03%       |5684     |27045		|35.5%
Tzo  |TzC0402F   |contam       |scaffolds     |off	 |1     |86989  |69417        |506992391       |62.00%       |6119       |26533         |39.0%
Tzo  |TzC0402G   |contam       |contigs       |off	 |1     |64326  |252063       |833348334       |101.91%        |19230       |11742         |70.8%
Tzo  |TzC0402G   |contam       |scaffolds     |off	 |1     |63527  |252063       |834945222       |102.10%        |19682       |11491         |71.1%
Tzo  |TzC0402G   |decontam     |contigs       |off	 |1     |74000  |170219       |787350440       |96.28%        |14381       |15216         |66.3%
Tzo  |TzC0402G   |decontam     |scaffolds     |off	 |1     |71206  |170219       |794560568	|97.16%        |15481       |14123         |67.6%

Summary of QUAST (using Genome Scope v.2 884000000 estimate) & BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v. |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp   |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------ |------- | ------
Tzo  |allLibs    |contam       |contigs       |off       |2     |96125    |236270     |745725175     |84.36%     |9041     |24287     |0.00     |50.7% 
Tzo  |allLibs    |contam       |scaffolds     |off       |2     |74846    |320496     |812404903     |91.90%     |14515    |15479     |636.61   |64.7%
Tzo  |TzC0402E   |contam       |contigs       |off       |2     |65176    |227579     |830651102     |93.97%     |18737    |11972     |0.00     |70.0%
Tzo  |TzC0402E   |contam       |scaffolds     |off       |2     |64301    |340415     |832616461     |94.19%     |19199    |11686     |6.81     |70.1%
Tzo  |TzC0402F   |contam       |contigs       |off       |2     |84668    |48595      |466349924     |52.75%     |5684     |27045     |0.00     |35.5
Tzo  |TzC0402F   |contam       |scaffolds     |off       |2     |86989    |69417      |506992391     |57.35%     |6119     |26533     |111.39   |39.0%
Tzo  |TzC0402G   |contam       |contigs       |off       |2     |64326    |252063     |833348334     |94.27%     |19230    |11742     |0.00     |70.8%
Tzo  |TzC0402G   |contam       |scaffolds     |off       |2     |63527    |252063     |834945222     |94.45%     |19682    |11491     |6.05     |71.1%
Tzo  |TzC0402G   |decontam     |contigs       |off       |2     |74000    |170219     |787350440     |89.07%     |14381    |15216     |0.00     |66.3%
Tzo  |TzC0402G   |decontam     |scaffolds     |off       |2     |71206    |170219     |794560568     |89.88%     |15481    |14123     |27.46    |67.6%

---

The best library was TzC0402G scaffolds.
#### Main assembly stats

New record of Tzo added to [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) file
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
Necessary scripts and the best assembly were copied (i.e. scaffolds.fasta from contaminated data of best assembly) into the probe_design dir (you had already selected the best assembly previously to run the decontaminated data)

```sh
cp SPAdes_TzC0402G_contam_R1R2_noIsolate/scaffolds.fasta probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
```

I renamed the assembly to reflect the species and parameters used. I copy and pasted the parameter info from the busco directory
```sh
# list the busco dirs by entering
ls -d busco_*
# identify the busco dir of the best assembly, copy the treatments (starting with the library)
# Since the busco dir for the best assembly for Tzo is the scaffolds for 'SPAdes_TzC0402G_contam_R1R2_noIsolate`
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_"
cd probe_design
mv ../SPAdes_TzC0402G_contam_R1R2_noIsolate/scaffolds.fasta Tzo_scaffolds_TzC0402G_contam_R1R2_noIsolate.fasta
```
Added this line to the WGprobe_annotation script so I could run it from my home directory:
export SINGULARITY_BIND=/home/e1garcia

Execute the first script:
```sh
#WGprobe_annotation.sb <assembly name>
sbatch WGprobe_annotation.sb "Tzo_scaffolds_TzC0402G_contam_R1R2_noIsolate.fasta"
```

This will create:
1. a repeat-masked fasta and gff file (.fasta.masked & .fasta.out.gff)
2. a gff file with predicted gene regions (augustus.gff), and
3. a sorted fasta index file that will act as a template for the .bed file (.fasta.masked.fai)

Execute the second script.
```sh
#WGprobe_annotation.sb <assembly base name>
sbatch WGprobe_bedcreation.sb "Tzo_scaffolds_TzC0402G_contam_R1R2_noIsolate.fasta"
```

This will create a .bed file that will be sent for probe creation.
 The bed file identifies 5,000 bp regions (spaced every 10,000 bp apart) in scaffolds > 10,000 bp long.

The longest scaffold is 252063

The uppper limit used in loop is 247500

A total of 55706 regions have been identified from 26210 scaffolds

Moved out files to logs
```sh
mv *out ../logs
```

## step 11. Fetching genomes for closest relatives

```sh
nano closest_relative_genomes_Taeniamia_zosterophora.txt

1. Sphaeramia orbicularis - https://www.ncbi.nlm.nih.gov/genome/82499
2. Bostrychus sinensis - https://www.ncbi.nlm.nih.gov/genome/13880
3. Chaenogobius annularis - https://www.ncbi.nlm.nih.gov/genome/96250
4. Mugilogobius chulae - https://www.ncbi.nlm.nih.gov/genome/36347
5. Periopthalmus modestus - https://www.ncbi.nlm.nih.gov/genome/104952
```

following Betancur et al. 2017, Mabuchi et al. 2014 and Thacker 2009.




