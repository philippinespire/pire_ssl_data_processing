## Ambassis buruensis SSL pipeline

### 0. Rename the raw fq.gz files an make a copy on /RC

Renaming files based on decode file.
Check proposed renaming scheme first.
```
cd shotgun_raw_fq
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Abu_ProbeDevelopmentLibraries_SequenceNameDecode.tsv
```  
Looks good to me - proceeding to rename:
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Abu_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```

Making a backup copy.
```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_raw_ssl
cp *.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_raw_ssl
```

### 1. Check the quality of the data - run fastqc

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq" "fq.gz"
```

First fastQC overview:
* 32 - 56.3 million sequence pairs per library
* % duplication 20.3% - 24.4% (likely will be reduced after clumpify
* Sequence quality looks good (>30 on average)
* Motif evident in first 10 bp
* GC content 43%, slightly non-normal distribution ("bump" around 65-70% - bacterial contam?)
* N content and sequence length distributions good
* no red flags!

### 2. 2. 1st fastp / trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1
```

>96% of reads passed filter.

### 3. Remove duplicates - run CLUMPIFY

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp /scratch/breid 20
```

Run checkClumpify_EG.R when finished.

```
cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R .
salloc #because R is interactive and takes a decent amount of memory, we want to grab an interactive node to run this
enable_lmod
module load container_env mapdamage2
crun R < checkClumpify_EG.R --no-save
```

Clumpify Successfully worked on all samples!

### 4. Second trim.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2
```

Results:
* duplication <5%
* GC content down slightly (42%)
* >80% passed filter, mostly for length. Still 42M - 75M read pairs.
* very low adapter content (0.2%)

### 5. Decontaminate

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn 20 
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastqc_screen_report
```

Mostly no hit!

### 6. Re-pair

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

Re-run MultiQC.

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired" "fq.gz" 
```

18.9-33.4 M read pairs retained - low duplication, stable GC content ~41%.

Calculate reads lost. Need to edit the read_calculator script to remove "array" from folder names.

```
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh .
vi read_calculator_ssl.sh
sbatch read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis"
```

Most reads lost in clumpify + 2nd trim. ~60% of reads remained for all libraries.

## GENOME ASSEMBLY

### 1. Genome properties.

Related species:

Ambassis elongatus c-value = 0.56. From Hardie and Hebert 2004.

Run Jellyfish.
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Abu" "fq_fp1_clmp_fp2_fqscrn_rprd"
```

Genomescope results:
-Genomescope v1 [result](http://qb.cshl.edu/genomescope/analysis.php?code=f02v4LzpVhHzg2Rx38CZ)
-Genomescope v2 [result](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=6f5djAcXk7w94nybWnD1)
-Both seem to fit well. Similar values, all reasonable - slightly larger genome size and lower heterozygosity for estimates from v2. Use 457M (v2 estimate) for genome size!

version | stat | min | max
-------| ----- | ----- | ------
1 | Heterosygosity | 0.823% | 0.817% | 0.829%
2 | Heterosygosity | 0.785% | 0.771% | 0.798%
1 | Haploid length | 438,652,102 | 438,324,664 | 438,979,540
2 | Haploid length | 456,636,665 | 456,078,394 | 457,194,935
1 | Model fit | NA | 97.2881% | 98.5199%
2 | Model fit | NA | 87.994% | 98.2931 %

---

### Genome Size (1n bp)

Jellyfish genome size 1n: 457000000

C-value from genomesize.com 1n: 0.56 (for Ambassis elongatus)

GenBank chromosome-scale genome size 1n: not_found

Genome size from other sources 1n: not_found

Sources:
1. Hardie, D.C. and P.D.N. Hebert (2004). Genome-size evolution in fishes. Canadian Journal of Fisheries and Aquatic Sciences 61: 1636-1646. (from genomesize.com)
---

### 2. Assembly

runSPADEShimem_R1R2_noisolate.sbatch in [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) on fq_fp1_clmparray_fp2b_fqscrn_repaired using 457 Mbp as size estimate

Try allLibs first.

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Abu" "all" "decontam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

Followed by individual libraries:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Abu" "1" "decontam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Abu" "2" "decontam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "fq_fp1_clmp_fp2_fqscrn_repaired"

sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Abu" "3" "decontam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "fq_fp1_clmp_fp2_fqscrn_repaired"
```

### 3. QUAST

allLibs_scaffolds slightly better than B_scaffolds, but similar in terms of N50/completeness/largest scaffold.

### 4. BUSCO

Running BUSCO

```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_allLibs_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_allLibs_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-A_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-A_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate" "scaffolds"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-C_decontam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-C_decontam_R1R2_noIsolate" "scaffolds"
```

B_scaffolds slightly better than allLibs_scaffolds.

Going with B for probe development and contam assembly as we are prioritizing BUSCO!

Contam assembly for B:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "breid" "Abu" "2" "contam" "457000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "fq_fp1_clmp_fp2"
```
Busco for contam assembly:
```
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate" "contigs"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis" "SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate" "scaffolds"
```

Final assembly table:

| Species | Library | Data Type | SCAFIG    | covcutoff | genomescope v. | # contigs | Largest contig | Total length | Estimated reference length | N50   | L50  | # N's per 100 kbp | BUSCO complete single copy % |
|---------|---------|-----------|-----------|-----------|----------------|-----------|----------------|--------------|----------------------------|-------|------|-------------------|------------------------------|
| Abu     | CPnd-B  | contam    | contigs   | off       | 2              | 19071     | 514517         | 425129420    | 457000000                  | 53057 | 2158 | 0                 | 84.9                         |
| Abu     | CPnd-B  | contam    | scaffolds | off       | 2              | 18751     | 514517         | 425495853    | 457000000                  | 54943 | 2084 | 3.2               | 85.1                         |
| Abu     | CPnd-A  | decontam  | contigs   | off       | 2              | 37424     | 101948         | 352037590    | 457000000                  | 12163 | 8512 | 0                 | 71.1                         |
| Abu     | CPnd-A  | decontam  | scaffolds | off       | 2              | 36887     | 106444         | 354204660    | 457000000                  | 12499 | 8285 | 8.4               | 71.6                         |
| Abu     | CPnd-B  | decontam  | contigs   | off       | 2              | 31166     | 186760         | 385231391    | 457000000                  | 18371 | 5929 | 0                 | 77.2                         |
| Abu     | CPnd-B  | decontam  | scaffolds | off       | 2              | 30373     | 186760         | 387111354    | 457000000                  | 19137 | 5682 | 7.68              | 77.7                         |
| Abu     | CPnd-C  | decontam  | contigs   | off       | 2              | 33661     | 135417         | 373748205    | 457000000                  | 15570 | 6940 | 0                 | 74.8                         |
| Abu     | CPnd-C  | decontam  | scaffolds | off       | 2              | 32928     | 135417         | 375687409    | 457000000                  | 16223 | 6676 | 7.83              | 75.3                         |
| Abu     | allLibs | decontam  | contigs   | off       | 2              | 39712     | 101403         | 376042053    | 457000000                  | 12204 | 9034 | 0                 | 66.5                         |
| Abu     | allLibs | decontam  | scaffolds | off       | 2              | 28354     | 213921         | 395577898    | 457000000                  | 22182 | 5066 | 481.22            | 77                           |

Notably, the contam assemblies were quite a bit better than decontam.

### Extracting mitochondrial genome

Copy scripts from the denovo repo - modifying so it should work better with SSL directory structure/naming.

```
cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/mitofinder/run_mitofinder.sbatch .
mv run_mitofinder.sbatch run_mitofinder_ssl.sbatch 
vi run_mitofinder_ssl.sbatch 
```

Test run sbatch with arguments for SSL directory, species code, assembly, and family. 

```
sbatch run_mitofinder_ssl.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis  Abu SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate Atherinidae
```

Successfully ran - 1 full-length mtgenome contig + one with only one gene (probably NUMT).

BLAST did not return particularly close hits - closest is a filefish (82.7% match). Check against Kent's Atherindae COI sequences.

## C. Probe development!

Setting up.

```
mkdir probe_design
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
cd probe_design
mv scaffolds.fasta Abu_scaffolds_CPnd-B_decontam_R1R2_noIsolate.fasta
```

Execute the first script.

```
sbatch WGprobe_annotation.sb "Abu_scaffolds_CPnd-B_decontam_R1R2_noIsolate.fasta"
```

Execute the second script.

```
sbatch WGprobe_bedcreation.sb "Abu_scaffolds_CPnd-B_decontam_R1R2_noIsolate.fasta"
```

Check upper limit.

```
cat BEDprobes-1153270.out

The longest scaffold is 186760
The upper limit used in loop is 177500
A total of 25655 regions have been identified from 12481 scaffolds
```

Move log files to logs directory.

### Closest relatives

One species in Ambassidae with a genome = [Parambassis ranga](https://www.ncbi.nlm.nih.gov/genome/76088)

Ambassidae is sister to a number of other percomorph clades, so taking a sampling of those as more distantly related relatives.

Pomacentridae = [Dascyllus trimaculatus](https://www.ncbi.nlm.nih.gov/genome/116835)
Embiotocidae = [Embiotoca jacksoni](https://www.ncbi.nlm.nih.gov/genome/43884)
Mugilidae = [Mugil cephalus](https://www.ncbi.nlm.nih.gov/genome/7162)
Gobiesocidae = [Gouania willdenowi](https://www.ncbi.nlm.nih.gov/genome/76090)

Creating file.

```
vi closest_relative_genomes_Ambassis_buruensis.txt

1. Parambassis ranga
https://www.ncbi.nlm.nih.gov/genome/76088
2. Dascyllus trimaculatus
https://www.ncbi.nlm.nih.gov/genome/116835
3. Embiotoca jacksoni
https://www.ncbi.nlm.nih.gov/genome/43884
4. Mugil cephalus
https://www.ncbi.nlm.nih.gov/genome/7162
5. Gouania willdenowi
https://www.ncbi.nlm.nih.gov/genome/76090
```

Folder of files for Arbor.

```
mkdir files_for_ArborSci
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Message for Eric:

```
Probe design files ready.

A total of 25655 regions have been identified from 12481 scaffolds

ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/probe_design/files_for_ArborSci/

Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.augustus.gff
Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.masked
Sob_scaffolds_allLibs_decontam_R1R2_noIsolate.fasta.out.gff
Sob_scaffolds_allLibs_decontam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_Sphyraena_obtusata.txt
```

## Cleaning up directory/backing up files

Before cleaning up:
```
du -sh
#178G	.
du -h | sort -rh > Abu_ssl_beforeDeleting_IntermFiles
```

Making copies of important files.

```
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_raw_ssl/
# exists!
# make copy of contaminated and decontaminated files
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2 /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis

# make a copy of fasta files for best assembly (CPas-A for Par)
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis
cp -R /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis
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
#88G	.
du -h | sort -rh > Abu_ssl_afterDeleting_IntermFiles
```

Move log files into logs.

```
mv Abu_ssl* logs
mv deleted_files_log logs
```

Done!


Manually created the `old_new_config.log` in `/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq/`
```
cat /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq/newFileNames.txt
Abu-CPnd_051_Ex1-9C-ssl.
Abu-CPnd_051_Ex1-9D-ssl.
Abu-CPnd_051_Ex1-9E-ssl.

cat /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq/origFileNames.txt
AbC0205109C_CKDL220019624-1A_H7TTHDSX5_L2_
AbC0205109D_CKDL220019624-1A_H7TTHDSX5_L2_
AbC0205109E_CKDL220019624-1A_H7TTHDSX5_L2_
```
Make `old_new_config.log` file in `/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq/`

```
nano /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq/old_new_config.log

AbC0205109C_CKDL220019624-1A_H7TTHDSX5_L2_1.fq.gz Abu-CPnd_051_Ex1-9C-ssl.1.fq.gz
AbC0205109D_CKDL220019624-1A_H7TTHDSX5_L2_1.fq.gz Abu-CPnd_051_Ex1-9D-ssl.1.fq.gz
AbC0205109E_CKDL220019624-1A_H7TTHDSX5_L2_1.fq.gz Abu-CPnd_051_Ex1-9E-ssl.1.fq.gz
AbC0205109C_CKDL220019624-1A_H7TTHDSX5_L2_2.fq.gz Abu-CPnd_051_Ex1-9C-ssl.2.fq.gz
AbC0205109D_CKDL220019624-1A_H7TTHDSX5_L2_2.fq.gz Abu-CPnd_051_Ex1-9D-ssl.2.fq.gz
AbC0205109E_CKDL220019624-1A_H7TTHDSX5_L2_2.fq.gz Abu-CPnd_051_Ex1-9E-ssl.2.fq.gz
```
