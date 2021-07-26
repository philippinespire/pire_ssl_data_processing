# Generic Data Processing Log

copy and paste this into a new species dir and fill in as steps are accomplished.

---

## Step 1.  1st fastp

Locate data location in slack channel for this species to get the indir.  The outdir should be `/home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR`

```
# repalce YOURUSERNAME and SPECIESDIR in paths
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR

#runFASTP_1.sbatch <indir> <outdir>
# do not use trailing / in paths
sbatch ../scripts/runFASTP_1.sbatch /home/e1garcia/shotgun_PIRE/SPECIESDIR/fq_raw fq_fp1
```

[Report](fill in url to multiqc report here), download and open in web browser. You can either scp it to your local computer or copy the raw file, paste it into notepad++ and save as html.  

Potential issues:  
* % duplication - ____  
  * alb:__s, contemp: __s
* gc content - ______
  * alb: __s, contemp: __s 
* passing filter - ____
  * alb: __s, contemp: __s 
* % adapter - ______
  * alb: __s, contemp: __s
* number of reads - ________
    * alb: __ mil, contemp: __ mil

---

## Step 2. Clumpify

Clumpify can use a lot of ram, and if it runs out, you will loose files. 

There are two ways to run, either as a normal sbatch script on a turing himem node:
```
# run clumpify as normal sbatch on turing
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
#runCLUMPIFY_r1r2.sbatch <indir> <outdir> <tempdir>
# do not use trailing / in paths
sbatch ../scripts/runCLUMPIFY_r1r2.sbatch fq_fp1 fq_fp1_clmp /scratch-lustre/YOURUSERNAME
#when complete, search the *out file for `java.lang.OutOfMemoryError`.  If this occurs, then increase ram, set groups to 1 in script
```

or as an array on multiple wahab nodes simultaneously (faster):

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
#runCLUMPIFY_r1r2_array.bash <indir> <outdir> <tempdir>
# do not use trailing / in paths
bash ../scripts/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/YOURUSERNAME 20
#after completion, run checkClumpify.R to see if any files failed
# look for this error "OpenJDK 64-Bit Server VM warning: INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not e
nough space' (errno=12)"
# if some fail, try this: Then just raise "-c 20" to "-c 40".
```

Cleanup logs
```
mkdir logs
mv *out logs
```

---

## Step 3. Run fastp2

Insert notes here

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
#runFASTP_2.sbatch <indir> <outdir> 
# do not use trailing / in paths
sbatch ../scripts/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2
```

[Report](insert url to report here), download and open in web browser

Potential issues:  
* % duplication - ____  
  * alb:__s, contemp: __s
* gc content - ______
  * alb: __s, contemp: __s 
* passing filter - ____
  * alb: __s, contemp: __s 
* % adapter - ______
  * alb: __s, contemp: __s
* number of reads - ________
    * alb: __ mil, contemp: __ mil

---

## Step 4. Run fastq_screen

Insert notes here

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
#runFQSCRN_6.bash <indir> <outdir> <number of nodes running simultaneously>
# do not use trailing / in paths
bash ../scripts/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 20

#confirm that all files were successfully completed
# this will return any out files that had a problem, replace JOBID with your jobid
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
# if you see missing indiviudals or categories in the multiqc output, there was likely a ram error.  I'm not sure if the "error" search term catches it.

# run the files that failed again.  This seems to work in most cases
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
# do not use trailing / in paths
bash ../scripts/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01010*r1.fq.gz
...
bash ../scripts/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01005*r2.fq.gz
```

[Report](), download and open in web browser

Potential issues:


Cleanup logs
```
mkdir logs
mv *out logs
```

---

## Step 5. Repair fastq_screen paired end files

Insert notes here

`repair.sh` will work with both zipped or unzipped files.  It will look at the names of in and out files to determine whether or not to zip/unzip.

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
# runREPAIR.sbatch <indir> <outdir> <threads>
sbatch runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
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

If you don't have the decode file, it should be in with the raw fqgz files.  If not it can be obtained from Sharon Magnuson or Chris Bird

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
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

Clone dDocentHPC repo (this is on the .gitignore list, so nothing inside it will be added to the present repo) and move the cssl config file to `mkBAM` dir

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/scripts
git clone git@github.com:cbirdlab/dDocentHPC.git

cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR
cp ../scripts/dDocentHPC/configs/config.5.cssl mkBAM
```

If you have a shotgun ref genome, the best genome can be found by running [`wrangleData.R`](https://github.com/philippinespire/denovo_genome_assembly/tree/main/compare_assemblers), sorting tibble by busco single copy complete, quast n50, and filtering by species in Rstudio.

Then copy best ref genome to your dir.  The correct dir can be inferred from the busco tibbles.  For reference, the best assembly for Lle is as follows:

```bash
# the destination reference fasta should be named as follows reference.<assembly type>.<unique assembly info>.fasta
# <assembly type> is `ssl` for denovo assembled shotgun library or `rad` for denovoe assembled rad library
# this naming is a little messy, but it makes the ref 100% tracable back to the source
# it is critical not to use `_` in name of reference for compatibility with ddocent and freebayes
# you will use cbird dir, but likely a different specific path
cp /home/cbird/pire_shotgun/lle_spades/out_Lle-C_3NR_R1R2ORPH_contam_noisolate_covcutoff-off/scaffolds.fasta mkBAM/reference.ssl.Lle-C-3NR-R1R2ORPH-contam-noisolate-off.fasta
```

Update the config file with the ref genome info

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR/mkBAM
nano config.5.cssl
```

Insert `<assembly type>` into `Cutoff1` variable and `<unique assembly info>` into `Cutoff2` variable.  Here I use Lle as an example, you need to insert the correct info based on your ref name (`reference.<assembly type>.<unique assembly info>.fasta`)
 
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

Add notes here

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR/mkBAM
# this has to be run from dir with fq.gz files to be mapped and the ref genome
# this script is preconfigured to run mapping, filtering of the maps, and genotyping in 1 shot
sbatch ../../scripts/dDocentHPC.sbatch config.5.cssl

# troubleshooting may be necessary, don't rerun steps that worked previously (i.e. copy and paste sbatch to local dir and modify for troubleshooting).
```

---

## Step 9. Filter VCF Files

Clone fltrVCF and rad_haplotyper repos

```
cd /home/YOURUSERNAME/pire_cssl_data_processing/scripts
git clone git@github.com:cbirdlab/fltrVCF.git
git clone git@github.com:cbirdlab/rad_haplotyper.git

cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR/
mkdir frVCF

cp
```



```
cd /home/YOURUSERNAME/pire_cssl_data_processing/SPECIESDIR/mkBAM
# this has to be run from dir with fq.gz files to be mapped and the ref genome
# this script is preconfigured to run mapping, filtering of the maps, and genotyping in 1 shot
sbatch ../../scripts/dDocentHPC.sbatch config.5.cssl

# troubleshooting may be necessary, don't rerun steps that worked previously (i.e. copy and paste sbatch to local dir and modify for troubleshooting).
```

