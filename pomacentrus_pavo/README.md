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

Executed read_calculator_ssl.sh to generate the [percent read loss](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pomacentrus_pavo/preprocess_read_change/readLoss_table.tsv) and [percent reads remaining](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pomacentrus_pavo/preprocess_read_change/readsRemaining_table.tsv) tables

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

QUAST + BUSCO outputs:

| Species | Library    | DataType | SCAFIG    | covcutoff | genome scope v. | No. of contigs | Largest contig | Total length | % Genome size completeness | N50   | L50   | Ns per 100 kbp | BUSCO single copy |
| ------- | ---------- | -------- | --------- | --------- | --------------- | -------------- | -------------- | ------------ | -------------------------- | ----- | ----- | -------------- | ----------------- |
| Ppa     | Ppa-CPnd-A | contam   | contigs   | off       | 2               | 85987          | 220339         | 574892803    | 0.768573266                | 7270  | 22131 | 0              | 33.20%            |
| Ppa     | Ppa-CPnd-A | decontam | contigs   | off       | 2               | 86314          | 167369         | 633073709    | 0.846355226                | 8387  | 21264 | 0              | 36.30%            |
| Ppa     | Ppa-CPnd-B | contam   | contigs   | off       | 2               | 51328          | 396078         | 776417466    | 1.037991265                | 24616 | 8200  | 0              | 67.30%            |
| Ppa     | Ppa-CPnd-B | decontam | contigs   | off       | 2               | 56561          | 259206         | 752121288    | 1.005509743                | 20205 | 10258 | 0              | 65.20%            |
| Ppa     | Ppa-CPnd-C | contam   | contigs   | off       | 2               | 83823          | 196085         | 687031522    | 0.91849134                 | 9902  | 19299 | 0              | 41.20%            |
| Ppa     | Ppa-CPnd-C | decontam | contigs   | off       | 2               | 63299          | 211566         | 760151846    | 1.016245783                | 17293 | 11908 | 0              | 61.30%            |
| Ppa     | allLibs    | contam   | contigs   | off       | 2               | 76931          | 411169         | 510079556    | 0.68192454                 | 7114  | 40053 | 0              | 27.10%            |
| Ppa     | allLibs    | decontam | contigs   | off       | 2               | 79932          | 136603         | 526298487    | 0.703607603                | 7122  | 39524 | 0              | 27.70%            |
| Ppa     | Ppa-CPnd-A | contam   | scaffolds | off       | 2               | 78050          | 225206         | 654682731    | 0.875244293                | 10206 | 17105 | 696.03         | 43.20%            |
| Ppa     | Ppa-CPnd-A | decontam | scaffolds | off       | 2               | 75252          | 205029         | 698628125    | 0.93399482                 | 11844 | 15906 | 567.48         | 47.40%            |
| Ppa     | Ppa-CPnd-B | contam   | scaffolds | off       | 2               | 50256          | 396078         | 778765731    | 1.041130656                | 25611 | 7864  | 15.77          | 68.00%            |
| Ppa     | Ppa-CPnd-B | decontam | scaffolds | off       | 2               | 53606          | 297238         | 756964735    | 1.01198494                 | 22188 | 9202  | 21.08          | 66.50%            |
| Ppa     | Ppa-CPnd-C | contam   | scaffolds | off       | 2               | 71970          | 206581         | 733138963    | 0.980132303                | 13563 | 14704 | 443.38         | 50.90%            |
| Ppa     | Ppa-CPnd-C | decontam | scaffolds | off       | 2               | 58879          | 227231         | 768016435    | 1.02675994                 | 19762 | 10465 | 70.28          | 64.10%            |
| Ppa     | allLibs    | contam   | scaffolds | off       | 2               | 65683          | 560907         | 622383722    | 0.832063799                | 12625 | 12169 | 1064.71        | 40.50%            |
| Ppa     | allLibs    | decontam | scaffolds | off       | 2               | 68583          | 204492         | 632629902    | 0.845761901                | 12048 | 13662 | 974.22         | 40.50%            |

Scaffolds better than contigs; contam better than decontam overall. Assemblies from Ppa-CPnd-B library generally look like they are the best for most metrics - higest BUSCO, highest N50, lowest L50, genome size close too expected (slightly larger!). allLibs contam assemblies do have the largest contig but are worse for other metrics.

Verdict - best assembly overall is Ppa-CPnd-B_contam_scaffolds. For doing probe design use Ppa-CPnd-B_decontam_scaffolds just so we are not making probes for potential contaminants.

## Probe design

Setting up.

```
mkdir probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_Ppa-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
cd probe_design
mv scaffolds.fasta Ppa_scaffolds_CPnd-B_decontam_R1R2_noIsolate.fasta
```

Execute the first script.

```
sbatch WGprobe_annotation.sb "Ppa_scaffolds_CPnd-B_decontam_R1R2_noIsolate.fasta"
```

Execute the second script.

```
sbatch WGprobe_bedcreation.sb "Ppa_scaffolds_CPnd-B_decontam_R1R2_noIsolate.fasta"
```

Check upper limit.

