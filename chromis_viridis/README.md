## Chromis viridis SSL data processing

### Download data from TAMUCC

Make directory and download data using gridDownloader.sh

```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/gridDownloader.sh . https://gridftp.tamucc.edu/genomics/20230425_PIRE-Cvi-ssl/
```

### Backup raw data

```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
screen cp ./* /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
```

### Rename files

Dry run.

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Cvi_SSL_SequenceNameDecode.tsv
```

Looks good - do it for real!

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Cvi_SSL_SequenceNameDecode.tsv rename
```

### Run first MultiQC

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"
```

Summary:

* 55.9 - 63.8 M seqs / library
* Duplication fairly low (10.3% - 15.5%)
* GC content stable across libraries at 41%
* Quality looks good
* High adapter content, hopefully will be fixed in trim

### Run first trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1 
```

~95% of reads passed filter, % adapter down to 14-23%

### Run Clumpify

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/breid 3
```

Check Clumpify output.

```
salloc
enable_lmod
module load container_env mapdamage2

crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
# Clumpify Successfully worked on all samples
exit #to relinquish the interactive node
```

Run MultiQC

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
```

### Second trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

Summary:
* duplication 5% or less
* adapter content <2%
* decent # of reads filtered for length but still >60M per library

### Decontaminate

Run fqscreen.

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 3
```

Check output.

```
ls fq_fp1_clmp_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmp_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.html | wc -l
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```

Run multiQC again.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
```

Vast majority (~98%) one hit one genome / no hit, small number of protist/human/fungi hits.

### Run re-pair

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 6
```

MultiQC.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" "fq.gz"
```

Summary: final QC looks good!
* <5% duplication
* 40% GC
* 30.7 - 33.7 M seqs/ library
* no red flags

### Clean up

```
mv *.out logs
```

### Genome properties

Genomesize.com estimate: Chromis viridis c-value = 0.93

NCBI Chromis chromis assembly size: 834,429,411

Run Jellyfish k-mer count.

```
#sbatch runJellyfish.sbatch <Species 3-letter ID> <indir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Cvi" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Genomescope v1 [result](http://genomescope.org/analysis.php?code=jl3dfLRRl4YgSqTx4w1t)
Genomescope v2 [result](http://genomescope.org/genomescope2.0/analysis.php?code=OD2lxlaVfynmxQbzvRT0)

GenomeScope estimates (all look reasonable, good model fit):

```
version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |1.37513%        |1.37886% 
2  |Heterozygosity  |1.40601%        |1.44311%
1  |Genome Haploid Length   |740,904,905 bp |741,346,357 bp 
2  |Genome Haploid Length   |775,328,245 bp |776,489,822 bp 
1  |Model Fit       |98.0426%       |99.5204%
2  |Model Fit       |86.0532%      |98.9842%
```

Use 776 Mbp (v2 estimate) moving forward.

### Assemble with SPAdes

On Turing:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Cvi" "1" "decontam" "776000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "fq_fp1_clmp_fp2_fqscrn_rprd"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Cvi" "2" "decontam" "776000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "fq_fp1_clmp_fp2_fqscrn_rprd"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Cvi" "3" "decontam" "776000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "fq_fp1_clmp_fp2_fqscrn_rprd"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Cvi" "all_3libs" "decontam" "776000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Run BUSCO.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-A_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-A_decontam_R1R2_noIsolate" "contigs"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-B_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-B_decontam_R1R2_noIsolate" "contigs"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-C_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-C_decontam_R1R2_noIsolate" "contigs"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_allLibs_decontam_R1R2_noIsolate" "contigs"
```

Cvi-CPal-A scaffolds looks best (fill in table later).

Running contam version:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Cvi" "1" "contam" "776000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

SPAdes failed for some reason - trying with continue option:

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Cvi" "continue" "contam" "776000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Continue script worked - note however that QUAST did not run properly afterwards. Run BUSCO and QUAST. runQUASTonly script did not work so I am just running manually on a node.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-A_contam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis" "SPAdes_Cvi-CPal-A_contam_R1R2_noIsolate" "contigs"

cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/SPAdes_Cvi-CPal-A_contam_R1R2_noIsolate

salloc
enable_lmod
module load container_env pire_genome_assembly/2021.03.25
crun quast.py scaffolds.fasta -o Cvi-CPal-A_contam_scaffolds_QUAST --est-ref-size 776000000 -s --eukaryote --large
crun quast.py contigs.fasta -o Cvi-CPal-A_contam_contigs_QUAST --est-ref-size 776000000 -s --eukaryote --large
```

Final result: Cvi-CPal-A best, decontam slightly better than contam for BUSCO + N50.

| Species | Library    | DataType | SCAFIG    | covcutoff | genomescope v. | No. of contigs | Largest contig | Total length | % Genome size completeness | N50  | L50   | N's per 100k | BUSCO single copy |
|---------|------------|----------|-----------|-----------|----------------|----------------|----------------|--------------|----------------------------|------|-------|--------------|-------------------|
| Cvi     | Cvi-Cpal-A | decontam | contigs   | off       | 2              | 74500          | 100176         | 566961056    | 0.730619918                | 8974 | 18736 | 0            | 53.10%            |
| Cvi     | Cvi-Cpal-B | decontam | contigs   | off       | 2              | 74817          | 100187         | 563349103    | 0.725965339                | 8822 | 19070 | 0            | 52.90%            |
| Cvi     | Cvi-Cpal-C | decontam | contigs   | off       | 2              | 74517          | 92152          | 563493759    | 0.726151751                | 8903 | 18829 | 0            | 52.70%            |
| Cvi     | allLibs    | decontam | contigs   | off       | 2              | 74611          | 70596          | 459087978    | 0.591608219                | 6538 | 20563 | 0            | 36.50%            |
| Cvi     | Cvi-Cpal-A | decontam | scaffolds | off       | 2              | 74065          | 116598         | 569904460    | 0.734412964                | 9117 | 18446 | 4.74         | 53.50%            |
| Cvi     | Cvi-Cpal-B | decontam | scaffolds | off       | 2              | 74492          | 123252         | 565999297    | 0.729380537                | 8945 | 18842 | 4.26         | 53.30%            |
| Cvi     | Cvi-Cpal-C | decontam | scaffolds | off       | 2              | 73935          | 92152          | 567070627    | 0.730761117                | 9113 | 18461 | 6.3          | 53.00%            |
| Cvi     | allLibs    | decontam | scaffolds | off       | 2              | 71054          | 94555          | 518784204    | 0.668536345                | 8540 | 17045 | 608.58       | 44.70%            |
| Cvi     | Cvi-Cpal-A | contam   | contigs   | off       | 2              | 74525          | 100176         | 567009362    | 0.730682168                | 8959 | 18740 | 0            | 53.00%            |
| Cvi     | Cvi-Cpal-A | contam   | scaffolds | off       | 2              | 74099          | 116598         | 569978022    | 0.73450776                 | 9104 | 18453 | 4.73         | 53.40%            |

