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

## Step 4. Run fastq_screen

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

[Report](), download and open in web browser

Potential issues:
* job  failed
  * 

Cleanup logs
```
mkdir logs
mv *out logs
```

---

## Step 5. Repair fastq_screen paired end files

This went smoothly.

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
# runREPAIR.sbatch <indir> <outdir> <threads>
sbatch ../scripts/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

---

