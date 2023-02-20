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

Ran [checkClumpify_EG.R](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R) to see if any files failed.

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

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/herklotsichthys_quadrimaculatus/fq_fp1_clmparray_fp2/2nd_fastp_report.html), download and open in web browser

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

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/herklotsichthys_quadrimaculatus/fq_fp1_clmparray_fp2_fqscrn/fqsrn_report.html), download and open in web browser

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

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/herklotsichthys_quadrimaculatus/fq_fp1_clmparray_fp2_fqscrn/fqsrn_report.html), download and open in web browser

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

Execute [read_calculator_ssl.sh]
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
* Total reads remaining ranged between 39-44%, **which translates into 81-98M reads remaining**

---
### Assembly section

## Step 7. Genome properties

I found the genome size of Hqu in the [genomesize.com](https://www.genomesize.com/) database. It can be found [here](https://www.genomesize.com/result_species.php?id=2074)

```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runJellyfish.sbatch "Hqu" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```
This jellyfish kmer-frequency [histogram file](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/herklotsichthys_quadrimaculatus/jellyfish_decontam/Hqu_all_reads.histo) was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this [report](http://qb.cshl.edu/genomescope/analysis.php?code=tHzBW2RjBK00gQMUSfl4)

Description: Hqu_ssl_decontam

Kmer length: 21

Read length: 140

Max kmer coverage: 1000

There may be differences in GenomeScope results, depending on the version. As such, we uploaded the same file to the [GenomesScope v2.0 website] (http://qb.cshl.edu/genomescope/genomescope2.0/) too, with the following inputs:

Description: Hqu_ssl_decontam2

Kmer length: 21

Ploidy: 2

Max kmer coverage: -1

Average k-mer coverage for polyploid genome: -1

The report generated for v2.0 is [here](http://genomescope.org/genomescope2.0/analysis.php?code=8eVzhAQ8zSenObScLMGC)

Genome stats for Hqu from Jellyfish/GenomeScope v1.0 & v2.0
stat    |min    |max    
------  |------ |------ 
Heterozygosity v1.0  |0.449245%       |0.459506%      
Heterozygosity v2.0  |2.03309%       |2.074009%      
Genome Haploid Length v1.0   |844,000,000 bp    |846,000,000 bp
Genome Haploid Length v2.0   |456,000,000 bp    |457,000,000 bp 
Model Fit v1.0       |95.034%       |97.832%      
Model Fit v2.0       |79.9163%      |92.0546%   
---

GenomeScope v1 showed potential issues as the unique sequence line did not track well the observed and full model lines. He was really low as well. In this case, we are moving forward with the default GenomeScope v2. 

**Using 457,000,000 as genome size for QUAST**

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 457000000

C-value from genomesize.com 1n: 0.76

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. Ojima, Y. and K. Yamamoto (1990). Cellular DNA contents of fishes determined by flow cytometry. La Kromosomo II 57: 1871-1888. (from genomesize.com)

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
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "contam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
```

Repeat running the decontaminated data:

```
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "decontam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
```

Ran individual libraries through these:
```
#1st library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "1" "contam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
#2nd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "2" "contam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
#3rd library
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "jbald004" "Hqu" "3" "contam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/herklotsichthys_quadrimaculatus"
```
---

## Step 9. Determine the best assembly

Look for the quast_results dir and note the (1) total number of contigs, (2) the size of the largest contig, (3) total length of assembly, (4) N50, and (5) L50 for each of your assemblies. This info will be entered in the table below.

To get summary for No. of contigs, largest contig, total length, % genome size completeness (GC), N50 & L50, do the follow$
```
bash
cat quast-reports/quast-report_contigs_Hqu_spades_allLibs_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Hqu_spades_allLibs_contam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_contigs_Hqu_spades_allLibs_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
cat quast-reports/quast-report_scaffolds_Hqu_spades_allLibs_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
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
Contam, scaffolds:c
Decontam, contigs:
Decontam, scaffolds:

Summary of QUAST (using Genome Scope v.1 844721205 estimate) & BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v. |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------
Hqu  |allLibs    |contam       |contigs       |off	 |1     |72680  |195361       |437705954       |51.82%       |6320	|21123       |36.3%
Hqu  |allLibs    |contam       |scaffolds     |off	 |1     |65871  |195361       |512737304	|60.70%       |9155	  |15571       |48.8%
Hqu  |HqC0021A   |contam       |contigs       |off	 |1     |65357   |147500       |366412508	|43.38%       |5733    |19934   |34.2%
Hqu  |HqC0021A   |contam       |scaffolds     |off	 |1     |63921   |149055       |434195608	|51.40%       |7527    |16539   |43.4%
Hqu  |HqC0021B   |contam       |contigs       |off	 |1     |67237  |189345        |384205692	|45.48%       |5883     |20200       |33.7%
Hqu  |HqC0021B   |contam       |scaffolds     |off	 |1     |64769  |321524        |454554704	|53.81%       |7881     |16436         |43.9%
Hqu  |HqC0021C   |contam       |contigs       |off	 |1     |64320  |216207       |357746760       |45.48%       |5662     |19659         |33.0%
Hqu  |HqC0021C   |contam       |scaffolds     |off	 |1     |63577  |242909       |427945810	|53.81%       |7423     |16491         |42.7%
Hqu  |allLibs    |decontam     |contigs       |off       |1     |61190  |165445       |350787873       |42.35%       |5950       |18553       |33.7%
Hqu  |allLibs    |decontam     |scaffolds     |off       |1     |60202  |195347       |404379681	|50.66%       |7442	  |16090       |42.6%

Summary of QUAST (using Genome Scope v.2  457000000 estimate) & BUSCO Results

Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v. |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp     |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------
Hqu  |allLibs    |contam       |contigs       |off       |2     |69666      |357053          |405555294     |88.74%     |6021     |20625     |0.00     |36.3%
Hqu  |allLibs    |contam       |scaffolds     |off       |2     |65472      |357053          |481801491     |105.43%    |8422     |16037     |843.69   |48.8%
Hqu  |allLibs    |decontam     |contigs       |off       |2     |61190      |165445          |350787873     |76.76%     |5950     |18553     |0.00     |33.7%
Hqu  |allLibs    |decontam     |scaffolds     |off       |2     |60202      |195347          |404379681     |88.49%     |7442     |16090     |533.73   |42.6%
Hqu  |HqC0021A   |contam       |contigs       |off       |2     |65367      |147500          |366461990     |80.19%     |5734     |19944     |0.00     |34.2%
Hqu  |HqC0021A   |contam       |scaffolds     |off       |2     |63940      |149059          |434260536     |95.02%     |7518     |16545     |770.66   |      |43.4%
Hqu  |HqC0021B   |contam       |contigs       |off       |2     |67217      |189345          |384117534     |84.05%     |5884     |20193     |0.00     |      |33.7%
Hqu  |HqC0021B   |contam       |scaffolds     |off       |2     |64766      |321524          |454430537     |99.04%     |7872     |16440     |785.39   |      |44.0%
Hqu  |HqC0021C   |contam       |contigs       |off       |2     |64351      |216207          |357793983     |78.29%     |5657     |19680     |0.00     |      |33.0%
Hqu  |HqC0021C   |contam       |scaffolds     |off       |2     |63614      |242909          |427983643     |93.65%     |7411     |16508     |798.19   |      |42.6%                            

---
The best library was allLibs scaffolds.

#### Main assembly stats

New record of Hqu added to [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) file
```sh
# add your info in a new row
nano ../best_ssl_assembly_per_sp.tsv
```

---

## Probe Design

In this section I identified contigs and regions within contigs to be used as candidate regions to develop the probes from.

The following 4 files were created at the end of this step:
1. *.fasta.masked: The masked fasta file
2. *.fasta.out.gff: The gff file created from repeat masking (identifies regions of genome that were masked)
3. *_augustus.gff: The gff file created from gene prediction (identifies putative coding regions)
4. *_per10000_all.bed: The bed file with target regions (1 set of 2 probes per target region).

## 10 Identifying regions for probe development

From the species directory, a new dir was made for the probe design
```sh
mkdir probe_design
```
Necessary scripts and the best assembly were copied (i.e. scaffolds.fasta from contaminated data of best assembly) into the probe_design dir (you had already selected the best assembly pr$

```sh
cp SPAdes_contam_R1R2_noIsolate/scaffolds.fasta probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
```

I renamed the assembly to reflect the species and parameters used. I copy and pasted the parameter info from the busco directory
```sh
# list the busco dirs by entering
ls -d busco_*
# identify the busco dir of the best assembly, copy the treatments (starting with the library)
# Since the busco dir for the best assembly for Hqu is SPAdes_contam_R1R2_noIsolate
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_"
cd probe_design
mv scaffolds.fasta Hqu_scaffolds_allLibs_contam_R1R2_noIsolate.fasta
```
Since I am working on Eric's home directory, I added this line to the WGprobe_annotation script, after the export SINGULARITY_BIND line for Rene, so I could run it from my home directory:
export SINGULARITY_BIND=/home/e1garcia

Execute the first script:
```sh
#WGprobe_annotation.sb <assembly name>
sbatch WGprobe_annotation.sb "Hqu_scaffolds_allLibs_contam_R1R2_noIsolate.fasta"
```

This will create:
1. a repeat-masked fasta and gff file (.fasta.masked & .fasta.out.gff)
2. a gff file with predicted gene regions (augustus.gff), and
3. a sorted fasta index file that will act as a template for the .bed file (.fasta.masked.fai)

Execute the second script.
```sh
#WGprobe_annotation.sb <assembly base name>
sbatch WGprobe_bedcreation.sb "Hqu_scaffolds_allLibs_contam_R1R2_noIsolate.fasta"
```

This will create a .bed file that will be sent for probe creation.
 The bed file identifies 5,000 bp regions (spaced every 10,000 bp apart) in scaffolds > 10,000 bp long.

The longest scaffold is 195361

The uppper limit used in loop is 187500

A total of 20336 regions have been identified from 13451 scaffolds

Moved out files to logs
```sh
mv *out ../logs
```

---

## step 11. Fetching genomes for closest relatives

```sh
nano closest_relative_genomes_Herklotsichthys_quadrimaculatus.txt

1. Alosa alosa - https://www.ncbi.nlm.nih.gov/genome/8249
2. Alosa sapidissima - https://www.ncbi.nlm.nih.gov/genome/9608
3. Limnothrissa miodon - https://www.ncbi.nlm.nih.gov/genome/100129
4. Tenualosa ilisha - https://www.ncbi.nlm.nih.gov/genome/12362
5. Clupea harengus - https://www.ncbi.nlm.nih.gov/genome/15477
```

Based on Betancur 2017, Lavoue et al 2007, Bloom and Egan 2018

## Mitofinder

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/herklotsichthys_quadrimaculatus Hqu SPAdes_allLibs_contam_R1R2_noIsolate Clupeidae

