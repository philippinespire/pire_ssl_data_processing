# Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

## Step 1.  1st fastp

Locate data location in slack channel for this species to get the indir.  The outdir should be `/home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR`

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
#runFASTP_1.sbatch <indir> <outdir>
# do not use trailing / in paths
sbatch ../scripts/runFASTP_1.sbatch /home/e1garcia/shotgun_PIRE/Lle/fq_raw fq_fp1
```

[Report](https://github.com/philippinespire/pire_cssl_data_processing/blob/main/leiognathus_leuciscus/fq_fp1/1st_fastp_report.html), download and open in web browser. You can either scp it to your local computer or copy the raw file, paste it into notepad++ and save as html.  

Potential issues:  
* % duplication - high for albatross, 
  * alb:70s, contemp: 50s
* gc content - reasonable
* passing filter - good
* % adapter - high, but that was expected, 
  * alb: 80s, contemp: 40s
* number of reads - decent
  * generally more for albatross than contemp, as we attempted to do
  * alb: 30mil, contemp: 8 mil
 
---

## Step 2. Clumpify

something odd happened here, so I'm running it again.
```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
#runCLUMPIFY_r1r2.sbatch <indir> <outdir> <tempdir>
# do not use trailing / in paths
sbatch ../scripts/runCLUMPIFY_r1r2.sbatch fq_fp1 fq_fp1_clmp /scratch-lustre/cbird
#when complete, search the *out file for `java.lang.OutOfMemoryError`.  If this occurs, then increase ram, set groups to 1 in script
# no matches found
# I deleted the out file because it was causing a git problem, I added file to .gitignore to avoid future issues
```

this runs clumpify in an array, but the script is running out of memory

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
#runCLUMPIFY_r1r2_array.bash <indir> <outdir> <tempdir> <num nodes>
# do not use trailing / in paths
bash ../scripts/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/cbird 20
```
---

## Step 3. Run fastp2

will need to run again with clumpify is done

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
#runFASTP_2.sbatch <indir> <outdir> 
# do not use trailing / in paths
sbatch ../scripts/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report](https://github.com/philippinespire/pire_cssl_data_processing/blob/main/leiognathus_leuciscus/fq_fp1_clmp_fp2/2nd_fastp_report_2.html), download and open in web browser

Potential issues:  
* % duplication - good  
  * alb:20s, contemp: 20s
* gc content - reasonable
  * alb: 40s, contemp: 40s 
* passing filter - good
  * alb: 90s, contemp: 90s 
* % adapter - good
  * alb: 2s, contemp: 2s
* number of reads - lost alot for albatross
  * generally more for albatross than contemp, as we attempted to do
  * alb: 7 mil, contemp: YY mil


---

## Step 4. Run fastq_screen

I edited runFQSCRN_6* to run on wahab.

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus

#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash ../scripts/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 20

# check output for errors
grep 'error' slurm-fqscrn.266713*out | less -S
grep 'No reads in' slurm-fqscrn.266713*out | less -S
```

[Report](https://github.com/philippinespire/pire_cssl_data_processing/blob/main/leiognathus_leuciscus/fq_fp1_clmp_fp2_fqscrn/fqscrn_report_1.html), download and open in web browser

Potential issues:
* job 9 failed
  * [out file](./logs/LlA01005_CKDL210012719-1a-AK6260-7UDI308_HF5TCDSX2_L1_clmp_fp2_r2.fq.gz)
  * "No reads in LlA01005_CKDL210012719-1a-AK6260-7UDI308_HF5TCDSX2_L1_clmp_fp2_r2.fq.gz, skipping" 
  * I checked this file, there are plenty of reads


Fix errors: all I had to do was run the files again that returned the "No reads in" error and they worked fine

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
# do not use trailing / in paths
bash ../scripts/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01010*r1.fq.gz
bash ../scripts/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01005*r2.fq.gz
```


Cleanup logs
```
mkdir logs
mv *out logs
```

---

## Step 5. Repair fastq_screen paired end files

This went smoothly.

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
# runREPAIR.sbatch <indir> <outdir> <threads>
sbatch ../scripts/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

---

## Step 6. Rename files for dDocentHPC and put into mapping dir

files names must be formatted as follows:
  * `population_individual.R1.fq.gz`
    * only 1 `_`
    * must end in `.R1.fq.gz` or `.R2.fq.gz`

The goal here is to convert the names from the seq facility, which are limited, to our sample name format.

It is desireable to keep seq name info that could be useful later on, like lane, R1, R2, processing, etc

I am taking advantage of the fact that when the seq names are sorted, their samp names are also sorted (I'm using order rather than the match between col 1 and 2 in the decode file).  Don't forget to remove the carriage returns `\r`.

I made a script to do all this, then we can replace old file names with new file names

If you don't have the decode file, it shoudl be in with the raw fqgz files.  If not it can be obtained from Sharon Magnuson or Chris Bird

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
#mkNewFileNames.bash <decode file name> <fqdir>, does not include path
bash ../scripts/mkNewFileNames.bash Lle_CaptureLibraries_SequenceNameDecode.tsv fq_fp1_clmp_fp2_fqscrn_repaired > decode_newnames.txt

#make old file names, will include path
ls fq_fp1_clmp_fp2_fqscrn_repaired/*fq.gz > decode_oldnames.txt

# triple check that the old and new files are aligned
module load parallel
bash #need for odu
parallel --no-notice --link -kj6 "echo {1}, {2}" :::: decode_oldnames.txt decode_newnames.txt > decode_translation.csv
less -S decode_translation.csv

# rename files and move to mapping dir
mkdir mkBAM
parallel --no-notice --link -kj6 "mv {1} mkBAM/{2}" :::: decode_oldnames.txt decode_newnames.txt

# confirm success
ls mkBAM
```

---

## Step 7.  Set up mapping dir and get reference genome

Clone dDocentHPC repo (this is on the .gitignore list, so nothing inside it will be added to the present repo)

```
cd /home/cbird/pire_cssl_data_processing/scripts
git clone git@github.com:cbirdlab/dDocentHPC.git
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus
cp ../scripts/dDocentHPC/configs/config.5.cssl mkBAM
```

The best genome can be found by running [`wrangleData.R`](https://github.com/philippinespire/denovo_genome_assembly/tree/main/compare_assemblers), sorting tibble by busco single copy complete, quast n50, and filtering by species in Rstudio.

Then copy best ref genome to your dir.  The correct dir can be inferred from the busco tibbles.  For reference, the best assembly for Lle is as follows:

```bash
# the destination reference fasta should be named as follows reference.<assembly type>.<unique assembly info>.fasta
# <assembly type> is `ssl` for denovo assembled shotgun library or `rad` for denovoe assembled rad library
# this naming is a little messy, but it makes the ref 100% tracable back to the source
# it is critical not to use `_` in name of reference for compatibility with ddocent and freebayes
cp /home/cbird/pire_shotgun/lle_spades/out_Lle-C_3NR_R1R2ORPH_contam_noisolate_covcutoff-off/scaffolds.fasta mkBAM/reference.ssl.Lle-C-3NR-R1R2ORPH-contam-noisolate-off.fasta
```

Update the config file with the ref genome info

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus/mkBAM
nano config.5.cssl
```

Insert `<assembly type>` into `Cutoff1` variable and `<unique assembly info>` into `Cutoff2` variable
 
```
----------mkREF: Settings for de novo assembly of the reference genome--------------------------------------------
PE              Type of reads for assembly (PE, SE, OL, RPE)                                    PE=ddRAD & ezRAD pairedend, non-overlapping reads; SE=singleend reads; OL=ddRAD & ezRAD overlapping reads, miseq; RPE=$0.9             cdhit Clustering_Similarity_Pct (0-1)                                                   Use cdhit to cluster and collapse uniq reads by similarity threshold
ssl               Cutoff1 (integer)                                                                                         Use unique reads that have at least this much coverage for making the reference     genome
Lle-C_3NR_R1R2ORPH_contam_noisolate_covcutoff-off               Cutoff2 (integer)
                Use unique reads that occur in at least this many individuals for making the reference genome
0.05    rainbow merge -r <percentile> (decimal 0-1)                                             Percentile-based minimum number of seqs to assemble in a precluster
0.95    rainbow merge -R <percentile> (decimal 0-1)                                             Percentile-based maximum number of seqs to assemble in a precluster
------------------------------------------------------------------------------------------------------------------

----------mkBAM: Settings for mapping the reads to the reference genome-------------------------------------------
Make sure the cutoffs above match the reference*fasta!
1               bwa mem -A Mapping_Match_Value (integer)
4               bwa mem -B Mapping_MisMatch_Value (integer)
6               bwa mem -O Mapping_GapOpen_Penalty (integer)
30              bwa mem -T Mapping_Minimum_Alignment_Score (integer)                    Remove reads that have an alignment score less than this.
5       bwa mem -L Mapping_Clipping_Penalty (integer,integer)
------------------------------------------------------------------------------------------------------------------ 
```
 
---

## Step 8. Map reads to reference - Filter Maps - Genotype Maps

Clone dDocentHPC repo

```
cd /home/cbird/pire_cssl_data_processing/leiognathus_leuciscus/mkBAM
#this has to be run from dir with fq.gz files to be mapped and the ref genome
# this script is preconfigured to run mapping, filtering of the maps, and genotyping in 1 shot
sbatch ../../scripts/dDocentHPC.sbatch config.5.cssl

# troubleshooting may be necessary, don't rerun steps that worked previously (i.e. copy and paste sbatch to local dir and modify for troubleshooting).
```

