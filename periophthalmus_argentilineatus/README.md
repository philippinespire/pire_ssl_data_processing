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

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 1093732992

C-value from genomesize.com 1n: not_found

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. 

---

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

Original attempt failed - had to modify the sbatch scripts to work properly with Augustus config file in Eric's directory. Working now!

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

Check upper limit - looks good (longest scaffold = 189908, upper limit = 187500).

Par folder didn't have a "logs" subdirectory, so making one and moving logs there.

```
mkdir ../logs
mv *out ../logs
```

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

## Files to Send

Making subdirectory within probe design containing the files to send to Arbor.

```
mkdir files_for_ArborSci
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Message to Slack / Eric:

```
Probe Design Files Ready

A total of 30947 regions have been identified from 17256 scaffolds. The longest scaffold is 189908. 

Files for Arbor Bio:
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/probe_design/files_for_ArborSci

Par_scaffolds_CPas-A_decontam_R1R2_noIsolate.fasta.augustus.gff
Par_scaffolds_CPas-A_decontam_R1R2_noIsolate.fasta.masked
Par_scaffolds_CPas-A_decontam_R1R2_noIsolate.fasta.out.gff
Par_scaffolds_CPas-A_decontam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_periophthalmus_argentilineatus.txt
```

## Cleaning up directory / backing up files

Documenting directory sizes/files.

```
du -sh
274G	.
du -h | sort -rh > Par_ssl_beforeDeleting_IntermFiles
```

Making copies of important files.

```
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/fq

## no raw backup there yet - making directory and copying from the RC backup.
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/fq
cp /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/periophthalmus_argentilineatus/fq_raw_shotgun/*_1.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/fq
cp /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/periophthalmus_argentilineatus/fq_raw_shotgun/*_2.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/fq

# make copy of contaminated and decontaminated files - using fp2b/trimmed data since this was used for assembly
cp -R /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/periophthalmus_argentilineatus/fq_fp1_clmparray_fp2b /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/
cp -R /RC/tmp/sysadma_recover_files_may_27_2022_2_56_pm/pire_ssl_data_processing_Recovered_05272022/periophthalmus_argentilineatus/fq_fp1_clmparray_fp2b_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/               

# make a copy of fasta files for best assembly (CPas-A for Par)
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/SPAdes_Par-CPas-A_contam_R1R2_noIsolate
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/SPAdes_Par-CPas-A_decontam_R1R2_noIsolate
cp SPAdes_Par-CPas-A_contam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/SPAdes_Par-CPas-A_contam_R1R2_noIsolate
cp SPAdes_Par-CPas_decontam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus/SPAdes_Par-CPas-A_decontam_R1R2_noIsolate
```

Delete unneeded files. Make a log of deletions first.

```
# create log file before removing
ls -ltrh *raw*/*fq.gz > deleted_files_log
ls -ltrh *fp1/*fq.gz >> deleted_files_log
ls -ltrh *clmp/*fq.gz >> deleted_files_log
ls -ltrh *fqscrn/*fq.gz >> deleted_files_log
#remove unneeded files
rm *raw*/*fq.gz
rm *fp1/*fq.gz
rm *clmp/*fq.gz
rm *fqscrn/*fq.gz
```

Document size after deleting files.

```
du -sh
224G	.
du -h | sort -rh > Abu_ssl_afterDeleting_IntermFiles
```

Move log files into logs.

```
mv Par_ssl* logs
mv deleted_files_log logs
```

Done!

### MitoFinder

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/periophthalmus_argentilineatus Par SPAdes_Par-CPas_decontam_R1R2_noIsolate Oxudercidae
```
