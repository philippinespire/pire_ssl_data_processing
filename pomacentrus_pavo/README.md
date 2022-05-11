# Ppa Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Run from /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/shotgun_raw_fq

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/pomacentrus_pavo/Multi_FASTQC/multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUOONAUBPX4L3XHKQ7WYTMR22Q) (copy and paste into a text editor locally, save and open in your browser to view)
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/shotgun_raw_fq" 
```

Potential issues:

* duplication - low to moderate
* 19.4% - 35.7%
* gc content:
* 40-41%
* sequence quality good
* low-moderate adapter content 
* no obvious read flags
* lots of sequences for some libraries
* 114.6M - 223.7M

## Step 2. 1st fastp

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/pomacentrus_pavo/fq_fp1/1st_fastp_report.html?token=GHSAT0AAAAAABHRMAUOHQO72K2XCSZB3CYGYTP5U3A)

```sh
sbatch runFASTP_1st_trim.sbatch /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/shotgun_raw_fq /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1
```

* 20.5%-34.6% duplication
* GC content 40.3%-41.1%
* 98.5% - 98.8% passed filter
* 3.9% - 11.5% adapter
* ~ 225 / 375 / 450 M reads 

## Step 3. Clumpify

```sh
bash runCLUMPIFY_r1r2_array.bash /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1 /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp /scratch/breid 20
```

Checked with checkClumpify_EG.R, all run successfully.

After this step moved all files to /home/e1garcia/shotgun_pire/pire_ssl_data_processing/pomacentrus_pavo

## Step 4. fastp2

Running run_FASTP_2_ssl.sbatch. Since it seems like we are getting a weird (potentially adapter-related) sequence in the first 15 bases I am hard-trimming those bases.

```sh
sbatch runFASTP_2_ssl.sbatch /home/e1garcia/shotgun_pire/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp /home/e1garcia/shotgun_pire/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp_fp2 15
```
Add a link to report when we can push to Git again!

* low duplication (4.0-7.8%)
* GC content 40.1-40.8%
* adapter signature gone after filtering, GC content stationary through reads
* 84.5-90.2% passed filter
* 4.2-11.8% adapter-trimmed
* 150-275M reads / library

## Step 5. Decontaminate

Run runFQSCRN_6.bash

```sh
bash runFQSCRN_6.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp_fp2 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp_fp2_fqscrn 20 
```

All output files present, no errors or "no read" messages

## Step 6. Repair

Run runREPAIR.sbatch

```sh
sbatch runREPAIR.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp_fp2_fqscrn /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1_clmp_fp2_fqscrn_repaired 40 
```

## Proportion of reads lost

-> add tables when I can push!

retained ~ 59.4-64.6% of reads

## ASSEMBLY

## Step 7. Genome properties

Multiple Pomacentrus species (but no P. pavo)  on genomesize.com

Range from  0.68 (P. auriventris) to 1.03 (P. chrysuris), average ~ 0.8-0.9?

Genomescope v1 results:

http://genomescope.org/analysis.php?code=W0J7SeTkKMz35DhMtrAM

~782M

Genomescope v2 results:

http://genomescope.org/genomescope2.0/analysis.php?code=aqJsqhKkeyMtnuYSrxSL

~748M

