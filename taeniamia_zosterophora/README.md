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

## Step 4. Run fastq_screen

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

## Step 5. Repair fastq_screen paired end files

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

## Step 6. Genome properties

I could not find Tzo in the [genomesize.com](https://www.genomesize.com/) database, thus I estimated the genome size of Sgr using jellyfish

From species home directory: Executed runJellyfish.sbatch using decontaminated files
```sh
#runJellyfish.sbatch <Species 2-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Tzo" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellfish_out"
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
## Step 7. Assemble the genome using SPAdes


