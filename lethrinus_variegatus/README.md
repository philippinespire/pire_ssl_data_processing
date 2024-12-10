# *Lethrinus variegatus*

---

Short-read data from Shotgun Sequencing LIbraries (SSL) of *Lethrinus variegatus*.

```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
```

Jordan Rodriguez

---

<details><summary>A. Pre-processing</summary>

## A. Pre-processing

---

Pre-processing Lva fq files for Shotgun Sequencing Libraries - SSL data

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

### 6. Repair Files
---

I ran `runREPAIR.sbatch` in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) 

```bash
Done on User@wahab.hpc.odu.edu
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
sbatch ../pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired
```
Files output to fq_fp1_clmparray_fp2b_fqscrn_repaired for trimmed and fq_fp1_clmparray_fp2_fqscrn_repaired for untrimmed 

---

</p>
</details>

<details><summary>B. Genome Assembly</summary>

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

| version    |stat    |min    |max |
| ------  |------ |------ |------|
| 1  |Heterozygosity  |0.596741%       |0.609334% | 
| 2  |Heterozygosity  |0.62143%       |0.635333% |
| 1  |Genome Haploid Length   |867,877,709 bp |869,278,859 bp |
| 2  |Genome Haploid Length   |899,850,172 bp |900,696,415 bp |
| 1  |Model Fit       |93.9719%       |94.8156% |
| 2  |Model Fit       |88.2079%      |95.4316% |

Links to reports:
[GenomeScopev1.0](http://qb.cshl.edu/genomescope/analysis.php?code=yxsG2k3Q7PEZzj0M1YdO)
[GenomeScopev2.0](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=mnBW14oWFT18lpGP8HSx)

I chose GenomeScope v2.0 due to the higher model fit percentage. Genome size estimate can be rounded to 901,000,000bp.

---

### 2. Genome Size (1n bp)

Jellyfish genome size 1n: 901000000

C-value from genomesize.com 1n: 1.11-1.44 (for Lethrinus microdon - Lethrinus xanthochilus)

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. Hardie, D.C. and P.D.N. Hebert (2004). Genome-size evolution in fishes. Canadian Journal of Fisheries and Aquatic Sciences 61: 1636-1646. (from genomesize.com)
2. Hartley, S.E. (1990). Variation in cellular DNA content in Arctic charr, Salvelinus alpinus (L.). Journal of Fish Biology 37: 189-190. (from genomesize.com)

---

### 3. Assembling the Genome with SPAdes

```bash
Done on User@turing.hpc.odu.edu
sbatch /home/j1rodrig/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "j1rodrig" "Lva" "1" "decontam" "901000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus" "fq_fp1_clmp_fp2b_fqscrn_repaired"
```

### 4. Reviewing Info on Assembly Quality from Quast Output

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

### 5. Running BUSCO 

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

| Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy |
|------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ |
|Lva  |Lva-CPnd-B  |decontam       |contigs       |off       |2       |81782  |205109       |842406872       |57.7%       |13481       |18196       |0       |93.5% |
|Lva  |Lva-CPnd-C  |decontam       |contigs       |off       |2       |71611  |166815       |880930890       |%       |16921       |15664       |0       |97.8% |
|Lva  |Lva-CPnd  |decontam       |contigs       |off       |2       |79048  |140523       |862567727       |63.0%       |14385       |18050       |0   |95.7% |
|Lva  |allLibs  |decontam       |contigs       |off       |2       |84469  |183959       |831737405       |55.0%       |12642       |19055       |0   |92.3% |
|Lva  |Lva-CPnd-B  |decontam       |scaffolds       |off       |2       |53255  |243289       |893236349       |73.1%       |25591       |10131       |536.62   |99.1% |
|Lva  |Lva-CPnd-C  |decontam       |scaffolds       |off       |2       |58626  |200252       |899066362       |73.4%       |22598      |11820       |169.71   |99.8% |
|Lva  |Lva-CPnd  |decontam       |scaffolds       |off       |2       |66925  |171724       |884881423       |68.0%       |18509      |14293       |185.93   |98.2% |
|Lva  |allLibs  |decontam       |scaffolds       |off       |2       |50571  |257232       |892987832       |73.5%       |27568      |9390       |648.17   |99.1% |

* note: For Quast, only report the row for the actual assembly (i.e. report "scaffolds" not "scaffolds_broken". 
* note: For BUSCO, only report the "Complete and single-copy BUSCOs (S)".

### 6. Determining the best assembly 

I referenced the metric importance table in the `pire_ssl_data_processing` repo to determine the best assembly for Lva.

*note: if you are still undecided on which is the best assembly, post the best candidates on the species slack channel and ask for opinions

Current step: I am trying to get BUSCO to run for Lva-CPnd-C on the contigs, then I will determine best assembly :)

091322 - Brendan Reid taking over for probe development. Note - it looks like single-copy BUSCO and genome size completeness were switched in the above table - revise later. Based on BUSCO and QUAST allLibs is the best decontam assembly - will use this for probe development.

---

</p>
</details>

<details><summary>C. Probe Design</summary>

## C. Probe Design

### 1. Identifying regions for probe development

Original attempt failed - had to modify the sbatch scripts to work properly with Augustus config file in Eric's directory. Working now!

Making directory for probe design in lethrinus_variegatus and copying scripts/best assembly.

```
mkdir probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
```

Move to probe design directory and rename assembly.

```
cd probe_design
mv scaffolds.fasta Lva_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta
```

Execute the first script.

```
sbatch WGprobe_annotation.sb "Lva_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta"
```

Execute the second script.

```
sbatch WGprobe_bedcreation.sb "Lva_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta"
```

Check the upper limit / BED output. Looks good.

```
The longest scaffold is 257232
The upper limit used in loop is 247500
A total of 68912 regions have been identified from 28007 scaffolds
```

Move out files into logs dir.

```
mv *out ../logs
```

### 2. Closest relatives with available genomes.

No genomes in Lethrinidae, but 5 in Spariformes (all in Sparidae: Diplodus sargus, Spondyliosoma cantharus, Sparus aurata, Acanthopagrus latus, Pagrus major). Based on Betancur phylogeny Lethrinidae is sister to Sparidae, so all are equally close relatives to Lva. Sparus aurata and Acanthopagrus latus look like they are chromosome-level while others are drafts, so would prefer to use those.

```
1. Sparus aurata
https://www.ncbi.nlm.nih.gov/genome/11609
2. Acanthopagrus latus
https://www.ncbi.nlm.nih.gov/genome/8551
3. Diplodus sargus
https://www.ncbi.nlm.nih.gov/genome/92100
4. Spondyliosoma cantharus
https://www.ncbi.nlm.nih.gov/genome/69439
5. Pagrus major
https://www.ncbi.nlm.nih.gov/genome/7176
```

### 3. Files to Send

Making directory with files for Arbor.

```
mkdir files_for_ArborSci
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Message for Eric / Slack.

```
Probe Design Files Ready

A total of 68912 regions have been identified from 28007 scaffolds. The longest scaffold is 257232

Files for Arbor Bio:
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/probe_design/files_for_ArborSci

Lva_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.augustus.gff
Lva_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.masked
Lva_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.out.gff
Lva_scaffolds_allLibs_decontam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_Lethrinus_variegatus.txt
```

</p>
</details>

<details><summary>D. Cleaning Up</summary>

## D. Cleaning Up 

Cleaning up directory + backing up data

Documenting sizes of directories + files.

```
du -h | sort -rh > Lva_ssl_beforeDeleting_IntermFiles
```

Check for copy of raw files and back up contam/decontam files.

```
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq

# there was no backup of raw files in current pire_ssl but they are in the recovered files folder on RC- copying these to the correct RC backup
cp -R /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/lethrinus_variegatus/fq_raw_shotgun /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/

# make copy of contaminated and decontaminated files - also in RC recovered folder. Using the trimmed files (fp2b) since these were used for assembly
cp -R /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/lethrinus_variegatus/fq_fp1_clmp_fp2b /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/
cp -R /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/lethrinus_variegatus/fq_fp1_clmp_fp2b_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/

# make a copy of fasta files for best decontam assembly (allLibs for Lva)
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/SPAdes_allLibs_decontam_R1R2_noIsolate
cp SPAdes_allLibs_decontam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/SPAdes_allLibs_decontam_R1R2_noIsolate
```

At this point I am going to run a contam allLibs assembly just so we have it for Lva. Copying trimmed contam files back to the ssl directory.

```
cp -R /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/lethrinus_variegatus/fq_fp1_clmp_fp2b /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus
```

Running contam assembly (on Turing).

```
sbatch /home/e1garcia/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Lva" "all" "contam" "901000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus" "fq_fp1_clmp_fp2b"
```

Backing up contam files + assembly.

</p>
</details>

<details><summary>E. MitoFinder</summary>

## E. MitoFinder

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus Lva SPAdes_allLibs_decontam_R1R2_noIsolate Lethrinidae
```

</p>
</details>

<details><summary>F. Notes</summary>

## F. Notes

Unusual naming format for the SSL Lva files. It looks like the well ID and the individual ID were combined. It also looks like 
the extraction ID is missing from the new file names (_Ex1_). The file names will not be corrected at this point (11/7/24).

```
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/lethrinus_variegatus/fq_raw_shotgun/

ls Lva*.fq.gz

Lva-CPnd_006A_L3_1.fq.gz
Lva-CPnd_006A_L3_2.fq.gz
Lva-CPnd_006G_L3_1.fq.gz
Lva-CPnd_006G_L3_2.fq.gz
Lva-CPnd_006H_L3_1.fq.gz
Lva-CPnd_006H_L3_2.fq.gz

less Lva_ssl_decode.tsv

Sequence_Name   Extraction_ID
LvaC00610A      Lva-CPnd_006A
LvaC0069G       Lva-CPnd_006G
LvaC0069H       Lva-CPnd_006H

less origFileNames.txt

LvaC00610A_CKDL220006132-1a-AK6260-7UDI214_HK52YDSX3_L3_
LvaC0069G_CKDL220006132-1a-AK6881-GC12_HK52YDSX3_L3_
LvaC0069H_CKDL220006132-1a-AK6881-7UDI246_HK52YDSX3_L3_

less newFileNames.txt

Lva-CPnd_006A_L3_
Lva-CPnd_006G_L3_
Lva-CPnd_006H_L3_
```
Actual file names:

Lva-CPnd_006A_L3_1.fq.gz

Lva-CPnd_006A_L3_2.fq.gz

Lva-CPnd_006G_L3_1.fq.gz

Lva-CPnd_006G_L3_2.fq.gz

Lva-CPnd_006H_L3_1.fq.gz

Lva-CPnd_006H_L3_2.fq.gz

Correct file name:

Lva-CPnd_006_10A_L3_1.fq.gz

Lva-CPnd_006_10A_L3_2.fq.gz

Lva-CPnd_006_9G_L3_1.fq.gz

Lva-CPnd_006_9G_L3_2.fq.gz

Lva-CPnd_006_9H_L3_1.fq.gz

Lva-CPnd_006_9H_L3_2.fq.gz

</p>
</details>
