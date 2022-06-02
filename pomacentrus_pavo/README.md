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

stat	|min	|max	|average	
------	|------	|------	|------	
Heterozygosity	|1.2034%	|1.21234%	|1.20787%	
Genome Haploid Length	|747,146,143 bp	|748,154,376 bp	|747,650,260 bp	
Model Fit	|95.9552%	|97.162%	|96.5586 %	

Genomescope v2 results:

http://genomescope.org/genomescope2.0/analysis.php?code=aqJsqhKkeyMtnuYSrxSL

~748M

stat	|min	|max	|average	
------	|------	|------	|------	
Heterozygosity	|1.19383 %	|1.2075 %	|1.2007 %	
Genome Haploid Length	|781,630,399 bp	|782,635,299 bp	|782132849 bp	
Model Fit	|86.0907 %	|96.5185 %	|91.3046 %	

## Step 8. Assemble the genome using SPAdes

Edited the runSPAdes script (I was running from a different directory and it was expecting me to run from the species directory I think).

Ran comibinations on Turing  using the following:

```
sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "1" "decontam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "2" "decontam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "3" "decontam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "all_3libs" "decontam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "1" "contam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "2" "contam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "3" "contam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2"

sbatch runSPADEShimem_R1R2_noisolate.sbatch "breid" "Ppa" "all_3libs" "contam" "748000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "fq_fp1_clmp_fp2"
```

Ran BUSCO using the following scripts:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-A_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-A_contam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-A_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-A_decontam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-B_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-B_contam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-B_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-B_decontam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-C_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-C_contam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-C_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_Ppa-CPnd-C_decontam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_allLibs_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_allLibs_contam_R1R2_noIsolate" "scaffolds"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_allLibs_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pomacentrus_pavo" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
```

Table goes here: 
