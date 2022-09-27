## Sphyraena obtusata SSL pipeline
### 0. Rename the raw fq.gz files an make a copy on /RC

Renaming files based on decode file.
Check proposed renaming scheme first.
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sob_ProbeDevelopmentLibraries_SequenceNameDecode.tsv
```  
Looks good to me - proceeding to rename:
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sob_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```
NOTE - renameFQGZ.bash is behaving strangely. Sometimes one or more of the names will be wrong - this appears to be somewhat random. I ran with 'rename' but did not proceed with the changes until it produced the correct names.

Making a backup copy.
```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_raw_ssl
cp *.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_raw_ssl
```
Moving renamed data to `shotgun_raw_fq`.
```
mkdir shotgun_raw_fq
mv *.fq.gz shotgun_raw_fq
```

### 1. Check the quality of the data - run fastqc

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq" "fq.gz"
```

First fastQC overview/potential issues:
* 36.7 - 42.4 million sequence pairs per library
* % duplication 19.8% - 23.2% (likely will be reduced after clumpify
* Sequence quality looks good (>30 on average)
* Motif evident in first 10 bp
* GC content 47-48%, slightly non-normal distribution ("bump" around 65-70% - bacterial contam?)
* N content and sequence length distributions good
* flagged for overrepresented sequences + adapter content

### 2. 1st fastp / trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1
```

Results:
* 19.3 - 21% duplication
* GC content ~46.4% (lower)
* ~94% passing filter
* 10.6 - 15.4% adapter (Sob-CKal_018_Ex2-9F-ssl_L2_fastp higher than others)
* ~65 million to 80 million read pairs (maybe a little low compared to other species? but OK for assembly?)
* motif still present, otherwise no big red flags

### 3. Remove duplicates - run CLUMPIFY

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp /scratch/breid 20
```

Ran checkClumpify_EG.R, Clumpify worked successfully!

### 4. Second fastp trim
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2
```

Looks good!
* duplication way down (~5.5-6%)
* GC content similar among libs (~46%)
* 74.7-78.7% passing filter
* % adapter very low (≤0.3%)

Since I am having trouble with fqscreen I am going to take a step back and re-create fp2 data, then try with that.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2
```

Number of lines in fp1_clmp_fp2b is _not_ identical to q_fp1_clmp_fp2! So possibly something went wrong with the original fp2, or fastp just does not behave reproducibly?

### 5. Decontaminate

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2_fqscrn 20 
```

One file failed (Sob-CKal_018_Ex2-9H-ssl_L2_clmp.fp2_r1.fq.gz) - re-running with just this file.

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2_fqscrn 1 Sob-CKal_018_Ex2-9H-ssl_L2_clmp.fp2_r1.fq.gz
```

Run `runMULTIQC.sbatch`.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastqc_screen_report
```

The .html does not provide much info. Based on the table though we mostly have "no hit" sequences (~92%)... hits for the other categories are <7%.

### 6. Repair

Re-pair reads.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

Re-run MultiQC.

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2_fqscrn_repaired
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2_fqscrn_repaired" "fq.gz" 
```

Calculate % reads lost.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata"
```

## ASSEMBLY

### 1. Genome properties

Related species:

Sphyraena obtusata c-value = 0.54. From Hardie and Hebert 2003/2004

Other Sphyraena species range from c = 0.66 to 1.2, though, based on genomesize.com.

Running jellyfish
```
#sbatch runJellyfish.sbatch <Species 3-letter ID> <indir>
#run from sphyraena_obtusata
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sob" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

Genomescope results:
-Genomescope v1 [result](http://qb.cshl.edu/genomescope/analysis.php?code=IwlrceOZN3AyM0YPXldP)
-Genomescope v2 [result](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=Z3FMY2e1lF4gkqUP4rgB)
-Both seem to fit well, but are also predicting a smaller than expected genome size (<300 Mb) and very high heterozygosity (>8%). Possible red flag - although Sob did have a lower c-value than other Sphyraenids? I am going to proceed to SPAdes assembly and see how things work. This might be a candidate for assessing polyploidy too since heterozygosity is so high.

version | stat | min | max
-------| ----- | ----- | ------
1 | Heterosygosity | 10.2% | 8.37% | 12.1%
2 | Heterosygosity | 8.74% | 8.6% | 8.88%
1 | Haploid length | 267,412,154 | 232,657,782 | 233,401,684
2 | Haploid length | 278,504,501 | 277,286,020 | 278,504,501
1 | Model fit | NA | 98.03% | 98.55%
2 | Model fit | NA | 90.78% | 98.1 %

### 2. Genome properties

runSPADEShimem_R1R2_noisolate.sbatch in [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) on fq_fp1_clmparray_fp2b_fqscrn_repaired using 1.093 Bbp as size estimate

Try allLibs first.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Sob" "all" "decontam" "280000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "fq_fp1_clmp_fp2_fqscrn_repaired"
```
