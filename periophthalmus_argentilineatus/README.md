# Periopthalmus argentilineatus: SSL_assemby

Keenan Larriviere

Steps below followed preprocessing protocol on [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) under guidance of Dr. Bird

> To do: move .out files to logs dir!

## Step 1 FASTQC

Multi_FASTQC.sh in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on all raw PAR data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

## Step 2 Clumpify

runCLUMPIFY_r1r2_array.bash in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on fq.gz files

Files and results output to fq_fp1_clmparray_fp2

Results reported in multiqc_report_fq.gz.html
- There were consistent abnormalities in the %GC of the 1st 15 bp when data was viewed in MultiQC

Clumpify was then run a second time, trimming the first 15 bp

Files and results output to fq_fp1_clmparray_fp2b

Results reported in 2nd_fastp_report.html

## Step 3 Screening

Moved forward with both f2p (untrimmed) and f2pb (trimmed) data for screening

runFQSCRN_6.bash in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on all f2p and f2pb files

Files output to fq_fp1_clmparray_fp2b_fqscrn for trimmed and fq_fp1_clmparray_fp2_fqscrn for untrimmed

## Step 4 Repair

runREPAIR.sbatch in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on all screened files by Dr. Bird

Files output to fq_fp1_clmparray_fp2b_fqscrn_repaired for trimmed and fq_fp1_clmparray_fp2_fqscrn_repaired for untrimmed

read_calculator_ssl.sh was then run in the Par home dir as per repo instructions
- However, this script doesn't work with our situation where we have fp2 and fp2b, so Dr. Bird suggested skipping it

## Step 5 Genome Properties

Steps below followed protocol on [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) under the guidance of Dr. Bird

- genomesize.com had no data available for Par

runJellyfish.sbatch in [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) was run on trimmed files first and then untrimmed files

Files output to fq_fp1_clmparray_fp2b_fqscrn_repaired_jfsh and fq_fp1_clmparray_fp2_fqscrn_repaired_jfsh, respectively

Uploaded fp2 and fp2b hito files to GenomeScope v1.0 and v2.0

Genome stats for Par (fp2) from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions
- [v1.0 link](http://genomescope.org/analysis.php?code=6ie1xZrvsS5m4MXxhSqg)
- [v2.0 link](http://genomescope.org/genomescope2.0/analysis.php?code=CkFpsIcRUMVJ3IOYxV5M)
- fp2 data not being used for SPAdes as of yet

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.200501%       |0.220126%
2  |Heterozygosity  |1.34838%       |1.37913%
1  |Genome Haploid Length   |1,080,169,607 bp |1,086,129,363 bp
2  |Genome Haploid Length   |579,496,721 bp |581,452,675 bp
1  |Model Fit       |93.0612%         |95.2325%
2  |Model Fit       |81.8756%       |94.1884%

Genome stats for Par (fp2b) from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions
- [v1.0 link](http://genomescope.org/analysis.php?code=I9puLlREIec3rYyYvB6G)
- [v2.0 link](http://genomescope.org/genomescope2.0/analysis.php?code=LxzqHbceNr3VM8DPraVU)
- v1.0 was originaly used for assembly since it had a better mean average model fit.
- Looking at the Genomescope results again, the two results are very different. The v2.0 result is likely more accurate here. Note that the second higher peak (homozygous kmers) aligns with the second vertical dotted line in the plot (2x coverage) - this is what you would expect for a diploid genome. For v1 this peak is between the 3rd and 4th lines - this could possibly indicate a polyploid genome but the more likely reason is that the model fit was off for some reason. Also note that the peak to the left (heterozygous kmers) is almost as high as the peak to the right, suggesting high heterozgosity - v2.0 estimates heterozygosity on the high range of species we have assembled so far, while v1 estimates low heterozygosity. Take the "Model Fit" values reported by Genomescope with a grain of salt. Model fits from v2 might be more variable simply because v2 is exploring a wider range of parameters. As such, max might be a better metric than average fit.
- Going forward, we should use the smaller v2 estimate (584 Mbp).

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |0.200879%       |0.218052%
2  |Heterozygosity  |1.35285%       |1.38177%
1  |Genome Haploid Length   |1,087,172,270 bp |1,092,732,992 bp
2  |Genome Haploid Length   |582,562,839 bp |584,432,399 bp
1  |Model Fit       |93.555%       |95.6701%
2  |Model Fit       |82.1948%       |94.844%

## Step 6 Genome Assembly

runSPADEShimem_R1R2_noisolate.sbatch in [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) on fq_fp1_clmparray_fp2b_fqscrn_repaired using 1.093 Bbp as size estimate
- Library 1 ran first
- Library 2 ran second
- Library 3 ran third
- All 3 libraries ran together last

072822 - Brendan Reid running BUSCO on the Par assemblies to find the best for use in PSMC

Running SPAdes for contaminated assembly (using fq_fp1_clmparray_fp2b data) - library 1/A

Par-CPas-A_contam looks like the best assembly!

091322 - Brendan Reid resuming probe development. Use best decontam assembly (the "A" assembly, but folder is named SPAdes_Par-CPas_decontam_R1R2_noIsolate).

## C. Probe design

### 10. Identifying regions for probe development.

Make a directory for probe design in periophthalmus_argentilineatus, copy assembly fasta and needed scripts.

```
mkdir probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_Par-CPas_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
```

Modify the probe scripts to work in Eric's dir (add `export SINGULARITY_BIND=/home/e1garcia`).

Move to probe design folder and rename the assembly.

```
cd probe_design
mv scaffolds.fasta Par_scaffolds_CPas-A_decontam_R1R2_noIsolate.fasta
```

Execute the first script.

```
sbatch WGprobe_annotation.sb "Par_scaffolds_CPas-A_decontam_R1R2_noIsolate.fasta"
```

Execute the second script.

```
sbatch WGprobe_bedcreation.sb "Par_scaffolds_CPas-A_decontam_R1R2_noIsolate.fasta"
```

Check upper limit.

11. Closest relatives with available genome.

Plenty of genomes in Oxudercidae (P. magnuspinnatus is the most complete).

```
1. Periophthalmus magnuspinnatus
https://www.ncbi.nlm.nih.gov/genome/35290
2. Periophthalmus modestus
https://www.ncbi.nlm.nih.gov/genome/104952
3. Periophthalmodon schlosseri
https://www.ncbi.nlm.nih.gov/genome/35291
4. Scartelaos histophorus
https://www.ncbi.nlm.nih.gov/genome/13887
5. Boleophthalmus pectinirostris
https://www.ncbi.nlm.nih.gov/genome/11967
```
