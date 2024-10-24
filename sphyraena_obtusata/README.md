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

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 280000000

C-value from genomesize.com 1n: 0.54

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources: 
1. Hardie, D.C. and P.D.N. Hebert (2003). The nucleotypic effects of cellular DNA content in cartilaginous and ray-finned fishes. Genome 46: 683-706. (from genomesize.com)

---

### 2. Assembly

runSPADEShimem_R1R2_noisolate.sbatch in [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) on fq_fp1_clmparray_fp2b_fqscrn_repaired using 280 Mbp as size estimate

Try allLibs first.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Sob" "all" "decontam" "280000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

Followed by individual libraries:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Sob" "1" "decontam" "280000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Sob" "2" "decontam" "280000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Sob" "3" "decontam" "280000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

SPAdes completed successfully for allLibs + library C but failed for libraries A+B, with a "too many erroneous k-mers" warning. Not sure if anyone else has encountered this - could be related to very high heterozygosity + somewhat lower than average # of reads/library for this species. For the successful allLibs assembly length is at least in the right ballpark and higher than the Genomescope estimate (~434Mb).

Running contam version of allLibs.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Sob" "all" "contam" "280000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "fq_fp1_clmp_fp2"
```

### 3. QUAST

The assemblies that worked seem to be decent - allLibs has longest scaffold 201016, N50 24215, total size 434625263.

### 4. BUSCO

Running BUSCO on successful assemblies.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "SPAdes_allLibs_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "SPAdes_Sob-CKal-C_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "SPAdes_Sob-CKal-C_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "SPAdes_allLibs_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata" "SPAdes_allLibs_contam_R1R2_noIsolate" "scaffolds"
```

QUAST + BUSCO results:

| Species | Library | DataType | SCAFIG    | covcutoff | genomescope v. | \# contigs | Largest contig | Total length | Estimated reference length | N50   | L50   | \# N's per 100 kbp | BUSCO single copy |
| ------- | ------- | -------- | --------- | --------- | -------------- | ---------- | -------------- | ------------ | -------------------------- | ----- | ----- | ------------------ | ----------------- |
| Sob     | CKal-C  | decontam | contigs   | off       | 2              | 41958      | 93110          | 364758673    | 280000000                  | 10891 | 10047 | 0                  | 65.30%            |
| Sob     | allLibs | decontam | contigs   | off       | 2              | 31061      | 180634         | 431987988    | 280000000                  | 22437 | 5408  | 0                  | 80.00%            |
| Sob     | CKal-C  | decontam | scaffolds | off       | 2              | 40738      | 93110          | 371366462    | 280000000                  | 11606 | 9493  | 15.65              | 67.20%            |
| Sob     | allLibs | decontam | scaffolds | off       | 2              | 29803      | 201016         | 434625263    | 280000000                  | 24215 | 5031  | 8.51               | 81.00%            |
| Sob     | allLibs | contam | contigs | off       | 2              | 19645      | 473359         | 485868572    | 280000000                  | 59992 | 2196  | 0.00               | 90.00%            |
| Sob     | allLibs | contam | scaffolds | off       | 2              | 19205      | 473359         | 486474762    | 280000000                  | 62835 | 2118  | 4.66               | 90.40%            |

allLibs is a substantial improvement over CKal-C. contam is also a fairly big improvement over decontam! However, I am moving forward with allLibs_decontam for probe development.

To check assembly I am BLAST-ing five of the single-copy BUSCO sequences to see if they hit relatives of Sob.
NODE_2529_length_34939_cov_9.600574:6701-24519: top hits = Xiphias gladius / Toxotes jaculatrix
NODE_1245_length_48332_cov_8.951631:24573-30109: top hits = Xiphias gladius / Lates calcarifer
NODE_2401_length_35850_cov_12.339291:10652-34777: top hits = Toxotes jaculatrix / Caranx melampygus
NODE_7575_length_17308_cov_10.329304:14068-16920: top hits = Sander lucioperca/ Perca fluviatalis
NODE_4107_length_26878_cov_10.366294:897-2285: top hits = Lates calcarifer / Toxotes jaculatrix

Top hits tend to be related species based on published phylogeny (esp Xiphias + Jaculatrix should be sister groups). Note coverage (9-12x) is lower than expected based on Genomescope. Contigs >100Kbp seem to be in this range too.

## C. Probe development

Setting up.

```
mkdir probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
cd probe_design
mv scaffolds.fasta Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta
```

Execute the first script.

```
sbatch WGprobe_annotation.sb "Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta"
```

```
sbatch WGprobe_bedcreation.sb "Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta"
```

Check upper limit.

```
cat BEDprobes-1121350.out 

The longest scaffold is 201016
The upper limit used in loop is 197500
A total of 30906 regions have been identified from 12970 scaffolds
```

Move log files to logs directory.

```
mv *.out ../logs
```

### Closest relatives

No genomes for any species in Sphyraenidae. Looks like Sphyraenidae was considered part of Istiophoriformes but is now considered sister to a group containing other Istiophorids and some additional groups (incl. Toxotidae) based on Betancur et al. 2017. This makes sense given best Blast hits were often to Xiphias or Toxotes.

Five close(ish) relatives - prioritizing chromosome-level assemblies.

Istiophoriformes-
Xipihas glaudius 
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_016859285.1/
Istiophorus platypterus 
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCA_016859345.1/

Toxotidae-
Toxotes jaculatrix 
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_017976425.1/

Carangiformes-
Trachurus trachurus
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCA_905171665.2/

Pleuronectiformes-
Hippoglossus hippoglossus
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_009819705.1/

Creating file.

```
vi closest_relative_genomes_Sphyraena_obtusata.txt

1. Xipihas glaudius 
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_016859285.1/
2. Istiophorus platypterus 
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCA_016859345.1/
3. Toxotes jaculatrix 
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_017976425.1/
4. Trachurus trachurus
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCA_905171665.2/
5. Hippoglossus hippoglossus
https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_009819705.1/
```

Folder of files for Arbor.
```
mkdir files_for_ArborSci
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Message for Eric:

```
Probe design files ready.

A total of 30906 regions have been identified from 12970 scaffolds

ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/probe_design/files_for_ArborSci

Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.augustus.gff
Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.masked
Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.out.gff
Sob_scaffolds_allLibs_decontam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_Sphyraena_obtusata.txt
```
## Cleaning & backing up

Before cleaning up:
```
du -sh
#172G	.
du -h | sort -rh > Sob_ssl_beforeDeleting_IntermFiles
```

Making copies of important files.

```
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/
# exists!

# make copy of contaminated and decontaminated files
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2 /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata

# make a copy of fasta files for best assembly (allLibs for Sob)
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/SPAdes_allLibs_contam_R1R2_noIsolate /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/SPAdes_allLibs_decontam_R1R2_noIsolate /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata
```
Delete unneeded files. Make a log of deletions first.

```
# create log file before removing
ls -ltrh *raw*/*fq.gz > deleted_files_log
ls -ltrh *fp1/*fq.gz >> deleted_files_log
ls -ltrh *clmp/*fq.gz >> deleted_files_log
ls -ltrh *fqscrn/*fastq.gz >> deleted_files_log
#remove unneeded files
rm *raw*/*fq.gz
rm *fp1/*fq.gz
rm *clmp/*fq.gz
rm *fqscrn/*fastq.gz
```

Document size after deleting files.

```
du -sh
#91G	.
du -h | sort -rh > Sob_ssl_afterDeleting_IntermFiles
```

Move log files into logs.

```
mv Sob_ssl* logs
mv deleted_files_log logs
```

Done!

### MitoFinder

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata Sob SPAdes_allLibs_decontam_R1R2_noIsolate Sphyraenidae
```
