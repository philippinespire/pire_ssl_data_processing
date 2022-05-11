# Lethrinus variegatus

---

Jordan Rodriguez

---

## Pre-processing Lva fq files for Shotgun Sequencing Libraries - SSL data

---

Steps below followed preprocessing protocol on [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

### 1. FASTQC: Checking the quality of Lva data
---
I ran Fastqc and Multiqc simultneously using the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. This ran for ~1hr.

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_varigatus/fq_raw_shotgun"  
```

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

---

### 2. First Trim: FastP
---
I ran [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch) using the following code:

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
sbatch ../pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw_shotgun fq_fp1
```
---

### 3. Remove Duplicates: Clumpify
---
I ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) using the following code:

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
bash ../pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/j1rodrig 12 
```

Files and results output to fq_fp1_clmparray_fp2

---

### 4. Second Trim: FastP2 
---
I ran [runFASTP_2_ssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch) using the following code:

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
sbatch ../pire_fq_gz_processing/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

Files and results output to fq_fp1_clmp_fp2

FastP2 was then run a second time, trimming the first 15 bp. I used the following code:

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
sbatch ../pire_fq_gz_processing/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2b 15
```

Files and results output to fq_fp1_clmp_fp2b

---

### 5. Decontaminate Files: FastQScreen 
---

*Note: runFQSCRN_6.bash was executed for both f2p (untrimmed) and f2pb(trimmed) data 

I ran [runFQSCRN_6.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash) using the following code:

f2p:
```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
bash ../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 12
```
*Note: the number of nodes running simultaneously should not exceed that number of fq.gz files. For Lva, there is a total of 6 fq.gz files, so I ran this on 6 nodes.

f2pb:
```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
bash ../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2b fq_fp1_clmp_fp2b_fqscrn 12
```

Files output to fq_fp1_clmparray_fp2b_fqscrn for trimmed and fq_fp1_clmparray_fp2_fqscrn for untrimmed

---

### Repair Files
---

I ran `runREPAIR.sbatch` in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) 

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
sbatch ../pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired
```
Files output to fq_fp1_clmparray_fp2b_fqscrn_repaired for trimmed and fq_fp1_clmparray_fp2_fqscrn_repaired for untrimmed 

---

## B. Genome Assembly

---

Steps below followed genome assembly protocol on [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing)

---

### 1. Genome properties

I used [genomesize.com](https://www.genomesize.com/) to find the genome size of Lethrinus genus. 

I executed runJellyfish.sbatch using the decontaminated files. 

runJellyfish.sbatch in https://github.com/philippinespire/pire_fq_gz_processing was run on trimmed files first and then untrimmed files

Files output to fq_fp1_clmp_fp2b_fqscrn_rprd_jfsh and fq_fp1_clmp_fp2_fqscrn_rprd_jfsh respectively

Genome stats for Lva from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions:

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.596741%       |0.609334% 
2  |Heterozygosity  |0.62143%       |0.635333%
1  |Genome Haploid Length   |867,877,709 bp |869,278,859 bp
2  |Genome Haploid Length   |899,850,172 bp |900,696,415 bp
1  |Model Fit       |93.9719%       |94.8156%
2  |Model Fit       |88.2079%      |95.4316%

Links to reports:
[GenomeScopev1.0](http://qb.cshl.edu/genomescope/analysis.php?code=yxsG2k3Q7PEZzj0M1YdO)
[GenomeScopev2.0](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=mnBW14oWFT18lpGP8HSx)

I chose GenomeScope v2.0 due to the higher model fit percentage. Genome size estimate can be rounded to 901,000,000bp.

### 2. Assembling the Genome with SPAdes

```bash
Done on User@turing.hpc.odu.edu
sbatch /home/j1rodrig/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "j1rodrig" "Lva" "1" "decontam" "901000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus" "fq_fp1_clmp_fp2b_fqscrn_repaired"
```

### 3. Reviewing Info on Assembly Quality from Quast Output

For each assembly, I viewed the quast results in `quast_results` and noted the following information: 

- No. of contigs,
- Largest contig, 
- Total Length,
- N50,
- L50, 
- N's per 100kbp.
 
I calculated % Genome size completeness by dividing the total length by the estimated reference length (found in the quast report) and then multiplying by 100. You will need this information to complete the table below.

```bash
done on User@turing.hpc.odu.edu
cat quast-reports/quast-report_contigs_Lva_spades_Lva-CPnd-B_decontam_R1R2_21-99_isolateoff-covoff.tsv | column -ts $'\t' | less -S
```

### 4. Running BUSCO 

I executed the [runBUSCO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) script on the `contigs` and `scaffolds` files for each assembly.

```bash 
# Done on user@wahab.hpc.odu.edu
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths. Example using contigs:
sbatch ../scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus" "SPAdes_Lva-CPnd-B_decontam_R1R2_noIsolate" "contigs"
```
Repeat the comand using scaffolds.

Repeat both commands for each SPAdes dir. 

`runBUSCO.sh` will generate a new dir per run. Look for the `short_summary.txt` file and note the percentage of `Complete and single-copy BUSCOs (S)` genes. You will need this to complete the table below. 

Using the data from above, I made this table:

```bash
Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
Lva  |Lva-CPnd-B  |decontam       |contigs       |off       |2       |81782  |205109       |842406872       |57.7%       |13481       |18196       |0       |93.5%
Lva  |Lva-CPnd-C  |decontam       |contigs       |off       |2       |71611  |166815       |880930890       |%       |16921       |15664       |0       |97.8%
Lva  |Lva-CPnd  |decontam       |contigs       |off       |2       |79048  |140523       |862567727       |63.0%       |14385       |18050       |0   |95.7%
Lva  |allLibs  |decontam       |contigs       |off       |2       |84469  |183959       |831737405       |55.0%       |12642       |19055       |0   |92.3%
Lva  |Lva-CPnd-B  |decontam       |scaffolds       |off       |2       |53255  |243289       |893236349       |73.1%       |25591       |10131       |536.62   |99.1%
Lva  |Lva-CPnd-C  |decontam       |scaffolds       |off       |2       |58626  |200252       |899066362       |73.4%       |22598      |11820       |169.71   |99.8%
Lva  |Lva-CPnd  |decontam       |scaffolds       |off       |2       |66925  |171724       |884881423       |68.0%       |18509      |14293       |185.93   |98.2%
Lva  |allLibs  |decontam       |scaffolds       |off       |2       |50571  |257232       |892987832       |73.5%       |27568      |9390       |648.17   |99.1%
```

*note: For Quast, only report the row for the actual assembly (i.e. report "scaffolds" not "scaffolds_broken". 
*note: For BUSCO, only report the "Complete and single-copy BUSCOs (S)"

### 5. Determining the best assembly 

I referenced the metric importance table in the `pire_ssl_data_processing` repo to determine the best assembly for Lva.

*note: if you are still undecided on which is the best assembly, post the best candidates on the species slack channel and ask for opinions

Current step: I am trying to get BUSCO to run for Lva-CPnd-C on the contigs, then I will determine best assembly :)