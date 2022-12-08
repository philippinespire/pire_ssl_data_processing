# Eps Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Run from /scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/shotgun_raw_fq

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/encrasicholina_pseudoheteroloba/Multi_FASTQC/multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUPRYBB4LKD3R5VCJGYYTMRXZA) (copy and paste into a text editor locally, save and open in your browser to view)
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/shotgun_raw_fq" 
```

Potential issues:

* low duplication
* 21.4-23.3%
* GC content
* 46-47%
* good sequence quality
* !!high adapter content - lots of overrepresented sequences!

## Step 2. 1st fastp

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/encrasicholina_pseudoheteroloba/fq_fp1/1st_fastp_report.html?token=GHSAT0AAAAAABHRMAUOT6S7S7CDFSEDOILOYTP5RWQ)

```sh
sbatch runFASTP_1st_trim.sbatch /scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/shotgun_raw_fq /scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1
```

* duplication 14.8% - 18.2%
* GC content 45% - 45.2%
* 94.9%-95.8% passed filter
* 22% - 32.4% adapter (still a bit high?)
* ~ 430 / 475 / 560 M reads

## Step 3. Clumpify

```sh
bash runCLUMPIFY_r1r2_array.bash /scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1 /scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp /scratch/breid 20
```

Checked with checkClumpify_EG.R, all run successfully.

After this step moved all files to /home/e1garcia/shotgun_pire/pire_ssl_data_processing/encrasicholina_pseudoheteroloba

## Step 4. fastp2

Running run_FASTP_2_ssl.sbatch. Since it seems like we are getting a weird (potentially adapter-related) sequence in the first 15 bases I am hard-trimming those bases. 

```sh
sbatch runFASTP_2_ssl.sbatch /home/e1garcia/shotgun_pire/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp /home/e1garcia/shotgun_pire/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp_fp2 15
```

Add a link to report when we can push to Git again! 

* low duplication (3.4-4.2%)
* GC content 44.2-44.4%
* 61.8-70.4% passed filter
* 20 - 28.5% adapter-trimmed
* many reads removed bc too short; still 225-275M reads / library
* still see "sawtooth" pattern in GC content! we'll see if this is a problem

## Step 5. Decontaminate

Run runFQSCRN_6.bash

```sh
bash runFQSCRN_6.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp_fp2 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp_fp2_fqscrn 20
```

All output files present, no errors or "no read" messages

## Step 6. Repair

Run runREPAIR.sbatch

```sh
sbatch runREPAIR.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp_fp2_fqscrn /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/fq_fp1_clmp_fp2_fqscrn_repaired 40
```

## Percent reads lost at each step

[Read loss](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/encrasicholina_pseudoheteroloba/preprocess_read_change/readLoss_table.tsv) and [reads remaining](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/encrasicholina_pseudoheteroloba/preprocess_read_change/readsRemaining_table.tsv)

39.6-46.4% of reads retained

## ASSEMBLy

## Step 7. Genome properties

Closest matches in genome size database are other fish in Engraulidae (no genus or species-level match).

Range from c value 1.4 (Engraulis japonica) to 1.9 (Engraulis mordax / Anchoa delicatissima)

Genomescope1 results:

http://genomescope.org/analysis.php?code=LnG0WgSew2VMbAkXr6Up

Genome stats for Eps from Jellyfish/GenomeScope v1.0 (run with k=21, read length=135 since we trimmed): 
stat	|min	|max	|average	
------	|------	|------	|------	
Heterozygosity	|4.14483%	|4.22689%	|4.18676%	
Genome Haploid Length	|1,140,911,740 bp	|1,149,163,333 bp	|1,145,037,537 bp	
Model Fit	|93.2582%	|97.0717%	|95.16495 %	

Genomescope2 results:

http://genomescope.org/genomescope2.0/analysis.php?code=GRrkvjLqtPAQ9giDuooI

Genome stats for Eps from Jellyfish/GenomeScope v2.0 with the following default settings:
* K-mer length: 21
* Ploidy: 2
* Max k-mer coverage: -1
* Average k-mer coverage for polyploid genome: -1

stat    |min    |max    |average
------  |------ |------ |------
Heterozygosity  |4.14183%      |4.28808%|      4.21496%
Genome Haploid Length   |1,386,198,038 bp |1,405,138,860 bp |1,395,668,479 bp
Model Fit       |60.0146%       |95.4693%       |77.742%


v2 result is larger than v1; both are relatively large, high heterozygosity, low unique content. Maybe weird GC content has something to do with lots of repetitive sequence?

Go with v1 result (~1,145,000,000) because better model fit?

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 1149000000

C-value from genomesize.com 1n: 1.44-1.90 (for Engraulis japonica - Engraulis mordax / Anchoa delicatissima)

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. Ojima, Y. and K. Yamamoto (1990). Cellular DNA contents of fishes determined by flow cytometry. La Kromosomo II 57: 1871-1888. and Hinegardner, R. (1968). Evolution of cellular DNA content in teleost fishes. American Naturalist 102: 517-523. (from genomesize.com) (note: these values were taken from the previous section and is from the family Engraulidae)
