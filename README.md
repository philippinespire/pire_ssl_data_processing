# SHOTGUN DATA PROCESSING & ANALYSIS

---

The purpose of this repo is to document the processing and analysis of `Shotgun Sequencing Libraries - SSL data` for probe development which then will be processed according to the [Capture Shotgun Sequencing Libraries- CSSL repo](https://github.com/philippinespire/pire_cssl_data_processing). 
 Both SSL and CSSL pipelines use scripts from the (Pre-Processing PIRE Data)[https://github.com/philippinespire/pire_fq_gz_processing] repo at the beginning of files processing. 

Each species will get it's own directory within this repo.  Try to avoing putting dirs inside dirs inside dirs. 

The Sgr dir will serve as the example to follow in terms of both directory structure and documentation of progress in `README.md`.

If this is your first time working on wahab/turing or want to check out some tips see the [Working on ODU's HPC repo](https://github.com/philippinespire/denovo_genome_assembly/tree/main/working_in_Turing-Wahab)

Contact Dr. Eric Garcia for questions or if you are having issues running scripts (e1garcia@odu.edu)

---

## Use Git/GitHub to Track Progress

To process a species, begin by cloning this repo to your working dir. I recommend setting up a `shotgun_PIRE` sub-dir in your home dir if you have not done something similar already

Example: `/home/youruserID/shotgun_PIRE/`

Clone this repo
```
cd ~ 	# this will take you to your home dir
cd shotgun_PIRE
git clone https://github.com/philippinespire/pire_ssl_data_processing.git
```

The data will be processed and analyzed in the repo.  There is a `.gitignore` file that lists files and directories to be ignored by git.  It includes large files that git cannot handle (fq.gz, bam, etc) and other repos that might be downloaded into this repo. 
For example, the BUSCO outdir contains several large files that will cause problems for git so `busco_*/` occurs in  `.gitignore` so that it is not uploaded to github in this repo.

Because large data files will not be saved to github, they will reside in an individual's copy of the repo or somewhere on the HPC. You should provide paths (absolute/full paths are probably best) or info that make it clear where the files reside. Most of these large intermediate files should be deleted once it is confirmed that they worked. For example, we don't ultimately need the intermedate files produced by fastp, clumpify, fastq_screen.

---

## Maintaining Git Repo

You must pull down the latest version of the repo everytime you sit down to work and push the changes you made everytime you walk away from the terminal.  The following order of operations when you sync the repo will minimize problems.

From your species directory, execute these commands manually or run the `runGit.sh` script (see bellow) 
```
git pull
git add ./*
git commit -m "$1"
git push -u origin main
```

This code has been compiled into the script `runGIT.bash` thus you can just run this script BEFORE and AFTER you do anything in your species repo.
You will need to provide the message of your commit in the command line. Example:
```sh
bash ../runGIT.bash "initiated Sgr repo"
```
You will need to enter your git credentials multiple times each time you run this script

If you should be met with a conflict screen, you are in the archane `vim` editor.  You can look up instructions on how to interface with it. I typically do the following:

* hit escape key twice
* type the following
  `:quit!`
 
If you had to delete files for whatever reason, 
these deletions occurred in your local directory but these files will remain in the git memory if they had already enter the system.

If you are in this situation, run these git commands manually, AFTER running the runGIT.bash as describe above.

`add -u` will stage your deleled files, then you can commit and push

Run this from the directory where you deleted files:
```sh
git add -u .
git commit -m "update deletions"
git push -u origin main
```
___

## Data Processing Roadmap

### Pre-Process

Clone this repo to your working dir
*(already done above)*

#### 0. Set up directories and data

Check your raw files: given that we use paired-end sequencing, you should have one pair of files (1 forward and 1 reverse) per library. This  means that you should have the same number of foward (1.fq.gz or f.fq.gz) and reverse sequence files (2.fq.gz or r.fq.gz).
 If you don't have equal numbers for foward and reverse files, check with whoever provided the data to make sure there was no issues while transferring.

You will likely get 2 or 3 libraries (4 or 6 files total). Sgr example:
```sh
ls -l /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq

-rwxrwx--- 1 e1garcia carpenter         248 Jul 27 12:37 README
-rwxrwx--- 1 e1garcia carpenter 15652747635 Jul 22 17:19 SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_1.fq.gz
-rwxrwx--- 1 e1garcia carpenter 16902243089 Jul 22 17:27 SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_2.fq.gz
-rwxrwx--- 1 e1garcia carpenter 13765701672 Jul 22 17:32 SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_1.fq.gz
-rwxrwx--- 1 e1garcia carpenter 14786676970 Jul 22 17:39 SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_2.fq.gz
-rwxrwx--- 1 e1garcia carpenter 16465437932 Jul 22 17:46 SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_1.fq.gz
-rwxrwx--- 1 e1garcia carpenter 17698149145 Jul 22 17:54 SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_2.fq.gz
```

Make a copy of your raw files in the longterm carpenter RC dir **ONLY** if one doesn't exits already (if you copied your data from the RC, a long-term copy already exists)
```sh
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/
mkdir <species_name>
mkdir <species_name>/shotgun_raw_fq
cp <source of files> /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<species_name>/shotgun_raw_fq
```
*The RC drive is only available from the login node (you won't find it after getting a working node, i.e. `salloc`)*

Create your `species dir` and and subdirs `logs` and `shotgun_raw_fq`. Transfer your raw data into `shotgun_raw_fq`  (your data will most likely be avaliable in the RC)
*(can take several hours)*

```sh
cd pire_ssl_data_processing
mkdir spratelloides_gracilis 
mkdir spratelloides_gracilis/logs
mkdir spratelloides_gracilis/shotgun_raw_fq
cp <source of files> spratelloides_gracilis/shotgun_raw_fq  # scp | cp | mv
```

Now create a `README` in the `shotgun_raw_fq` dir with the full path to the original copies of the raw files and necessary decoding info to find out from which individual(s) these sequence files came from.


This information is usually provied by Sharon Magnuson in species [slack](https://app.slack.com/client/TMJJ06SH0/CMPKY5C81/thread/CQ9GAAYGY-1627263374.002300) channel

```sh
cd spratelloides_gracilis/shotgun_raw_fq
nano README
```

Example:
```sh
RC to e1garcia
scp <source of files> /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq

All 3 library sets are from the same individual: Sgr-CMvi_007_Ex1
```

*I like to update my git repo regularly, especially before and after lengthly steps. This keeps a nice record of the commits and prevents loss of data/effor. Feel free to repeat this at any step*

```sh
bash ../../runGIT.bash "README of raw data"
```

***You are ready to start processing files***

Complete the pre-processing of your files following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo
* This includes running FASTQC, FASTP1, CLUMPLIFY, FASTP2, FASTQ SCREEN, and file repair scripts from the pre-processing repo


Move the `.out` files into the `logs` dir after each step is completed:
```sh
mv *out /home/youruserID/shotgun_PIRE/pire_ssl_data_processing/yourspecies/logs
```


#### 1. Execute [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh)
From `yourspecies/shotgun_raw_fq/`
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "."
```

Download and review the Multiqc report for issues. 


Create a species specific README.md to track the species progress. You can create a brand new README or you can use the Sgr [README.md](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/spratelloides_gracilis) as a template and fill in as steps are accomplished for your species (this way you will have all the necessary formatting already)
```sh
nano ../README.md

or 

cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/README.md ..
```

* Update your species README, i.e. provide a link to the report and list the highlights.
* Update the species  README and the slack species channel after every step

Move your `.out` files into your `logs` dir

#### 2. Execute [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
From `yourspecies/shotgun_raw_fq/`
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

Move your `.out` files into your `logs` dir

#### 3. Execute [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) on Wahab.  

Before running, modify the `<tempdir>` and `max # of nodes to use at once` in the code below.

Use your user ID in the `<tempdir>` and the `max # of nodes to use at once` should not exceed the number of pair of r1-r2 files to be processed. If you have many sets of files, you could also limit the number of nodes to the number of nodes in `idle` in the main partiton i.e. run sinfo and look for `idle`

For Sgr, I had 6 r1 and 6 r2 files, or 3 sets of pairs so I used 3 nodes for clumpify.
```sh
# Navigate to your species home dir
cd ..

# Execute with:
#runCLUMPIFY_r1r2_array.bash <indir> <outdir> <tempdir> <max # of nodes to use at once>
# do not use trailing / in paths. Example
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/e1garcia 3
```

After completion, run `checkClumpify_EG.R` to see if any files failed
```
# load the container with R
enable_lmod
module load container_env mapdamage2

# If you have not previously install tidyverse do the following:
crun R				# you have entered R

install.packages('tidyverse')	# intall tidyverse. Can take several minutes
# type "yes" if it asks you if you would like a personal library
# if it asks you to select a CRAN mirror, enter the two digit code for a US mirror

quit()
# R:save session?
yes

# If you already have tidyverse do this:
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```
If all files were successful, `checkClumpify_EG.R` will return "Clumpify Successfully worked on all samples". 

If some failed, the script will also let you know. Copy the `runCLUMPIFY_r1r2_array.bash` script to your species dir and try raising "-c 20" to "-c 40" and run clumplify again

Also open the out files and look for this error "OpenJDK 64-Bit Server VM warning:
INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not enough space' (errno=12)"


When completed, move your log files into the `logs` dir
```sh
mv *out logs
```

#### 4. Execute [runFASTP_2_ssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch)

From your species dir:
```
#runFASTP_2.sbatch <indir> <outdir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
```

**These are your "contaminated" files, which will be used whenever you see the "cotam" treatment**

* Update your species README, i.e. provide a link to the report and list the highlights

Move your out file
```
mv *out logs
```

#### 5. Execute [runFQSCRN_6.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash)

Check the number of available nodes with `sinfo` (i.e. nodes in idle in the main partition).
 Try running one node per fq.gz file if possilbe or how many nodes are available.
 Yet, the number of nodes running simultaneously should not exceed that number of fq.gz files.
* ***NOTE: you are executing the bash not the sbatch script***
* ***This can take up to several days depending on the size of your dataset. Plan accordingly

From your species dir:
```sh 
#runFQSCRN_6.bash <indir> <outdir> <number of nodes running simultaneously>
# do not use trailing / in paths. Example:
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
```

Confirm that all files were successfully completed
```sh
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for each input fq.gz file
#check that all 5 files were created for each file: 
ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

# for each, you should have the same number as the number of input files

# You should also check for errors in the *out files:
# this will return any out files that had a problem

#do all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# or check individuals files <replace JOBID with your actual job ID>
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```
If you see missing individuals or categories in the multiqc output, there was likely a ram error.  I'm not sure if the "error" search term catches it.

Run the files that failed again.  This seems to work in most cases
```sh
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 LlA01010*r1.fq.gz
...
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01005*r2.fq.gz
```

After confirming that all files worked. Move your out files
```
mv *out logs
```

Since we are running Fastq Screen as an array. I have set Multiqc to be ran seperately for this step.


**Get the multiqc report**

In this case, you will run the MultiQC script from the SSLrepo. From your species dir:
```sh
#runMULTIQC.sbatch <INDIR> <Report name>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

* Update your species README, i.e. provide a link to the report and list the highlights. 
* Update Slack


#### 6. Execute [runREPAIR.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch)

From your species dir:
```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

**These are your "decontaminated" files, which will be used whenever you see the "decotam" treatment**

**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh). From your species dir:
```sh
#read_calculator_ssl.sh <Species home dir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

`read_calculator_ssl.sh` counts the number of reads before and after each step in the pre-process of ssl data and creates the dir `preprocess_read_change` with the following 2 tables:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

**Report the total number of reads retained in your species README, i.e. "#reads_repr" column in the readLoss_table.tsv** You might also comment on other info from the tables.

After processing 7 species, 40-50% read lost is common (up to 60%s) but we still retaining a range of 60-150 million reads. 
Inspect these tables for red flags. Specifically, check the total number of reads remaining after the 6 steps ("#reads_repr" column in the `readLoss_table.tsv`). If this is less than 60M, check which step(s) have too much data was lost and try to resolve the issue.. 

___

### Assembly

#### 7. Genome Properties

Fetch the genome properties for your species
* From the literature or other sources
	* [genomesize.com](https://www.genomesize.com/)
	* search the literature
* Estimate properties with `jellyfish` and `genomescope`
	* More details [here](https://github.com/philippinespire/denovo_genome_assembly/blob/main/jellyfish/JellyfishGenomescope_procedure.md)

**Execute [runJellyfish.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runJellyfish.sbatch) using decontaminated files**
```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir> 
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sgr" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```

Jellyfish will create a histogram file (.hito) with kmer frequencies. 
Download this file into your local computer and upload it in [GenomeScope v1.0](http://qb.cshl.edu/genomescope/) and and [Genomescope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/)
* Add a proper description to both of your runs. Example "Sgr_ssl_decontam"
* For version 1, Adjust the read lenght to that of in the Fastp2 trimming, 140 (unless you had to modify this in Fastp2)
* Leave all other parameters with default settings for both versions. 
* Submit (takes only few minutes)
 
Complete the following table in your Species README. You can copy and paste this table straight into your README (no need to enclose it with quotes, i.e. a code block) and just substitute values.
```sh
Genome stats for Sgr from Jellyfish/GenomeScope v1.0 and v2.0, k=21 for both versions

version    |stat    |min    |max
------  |------ |------ |------
1  |Heterozygosity  |1.32565%       |1.34149%
2  |Heterozygosity  |1.32975%       |1.35795%
1  |Genome Haploid Length   |693,553,516 bp |695,211,827 bp
2  |Genome Haploid Length   |851,426,393 bp |853,706,410 bp
1  |Model Fit       |97.6162%       |98.7154%
2  |Model Fit       |65.11692%       |96.0314%
```
Provide a link to both reports in your README. See other species READMEs for examples.

**Choose a Genome Scope version**

Inspect your table and reports for red flags.
* In your table, check the heterozygosity (values around 1% are common) and check for good model fit (>90%) in the max values (sometimes the min value might have a low fit but th$
* In your reports, check for a tight relationship between the "observed", "full model" and "unique sequences" lines in the first graph.

If values in your table are relative similar for v1 and v2 and you found no red flags in reports, then use v2 estimates.

** Please use the "Genome Haploid Length" max value rounded up or down to the nearest million.** In the above example, this number is 853706410 for v2. Thus, 854000000 will be used in following steps

Most of the time v1-2 perform very similar. However, sometimes the two reports give contrasting values such as very different genome sizes or unrealistic estimates of heterozygosity. For example:
* In Sob, the [Sob_GenScp_v1](http://qb.cshl.edu/genomescope/analysis.php?code=zQRfOkSqbDYAGYJrs7Ee) report estimates a genome of 532 Mbp and 0.965 for H. On the other hand,  [Sob_GenScp_v2](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=5vZKBtdSgiAyFvzIusxT) reports a genome size of 259 Mbp (which is small for a fish) and it actually fails to estimate heterozygosity. Thus, version 1 was used for Sob. 
* In Hte, the [Hte_GenScp_v1](http://qb.cshl.edu/genomescope/analysis.php?code=tHzBW2RjBK00gQMUSfl4) appears to have no red flags with a genome size of 846 Mbp and 0.49 for H but inspecting the first graph, you can see that the "uniqu sequence" line behaves diffently from the others. In contrast, [Hte_GenScp_v2](http://qb.cshl.edu/genomescope/genomescope2.0/analysis.php?code=8eVzhAQ8zSenObScLMGC) restores a tight relationship between lines with no red flags in estimates either (H=2.1, GenSize= 457 Mbp)

Note the source and genome size (if you found one already availble) or the Genome Scope version and rounded genome size estimate (if you had to run jellyfish) in your species README. You will use this info later


#### 8. Assemble the genome

Congrats! You are now ready to assembly the genome of your species!

After de novo assembler comparisons,  we decided to move forward using SPADES (isolate and covcutoff flags off). 
For the most part, we obtained better assemblies using single libraries (a library consists of one forward *r1.fq.gz and reverse file *r2.fq.gz) but in few instances using all the libraries was better.
In addition, we also noted that assembling contaminated data (i.e. files in the `fq_fp1_clmparray_fp2` dir)  produced better results for nDNA and decontaminated (i.e. files in the `fq_fp1_clmparray_fp2_fqscrn_repaired` dir) was better for mtDNA. 

Thus, use the contaminated files to run one assembly for each of your libraries independently and then one combining all.
1. **You need to be in Turing for this step.** SPAdes requires high memory nodes (only avail in Turing)
2. Get the genome size of your species, or Jellyfish estimate, in bp from the previous step
 

We produced 3 libraries (from the same individual) for the last 5 spp with ssl data resulting in 3 sets of files. Sgr example:
```sh
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq

SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_1.fq.gz
SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_2.fq.gz
SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_1.fq.gz
SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_2.fq.gz
SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_1.fq.gz
SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_2.fq.gz
```
Yet, every now and then one library can fail and you might end up with only 2 sets of files. 
Thus, the following SPAdes script is optimized to run the first 3 libraries independently and 2 or 3 libraries together for your "all" assembly.
. 
Note: If your species has 4 or more libraries, you will need to modify the script to run the 4th,5th,.. library and so on (you'll only need to add the necessary libraries to the SPAdes command)
No changes necessary for running the first, second, thrid, or all the libraries together (if you have 2 or 3 libraries only).  

**Use the contaminated files to run one assembly for each of your libraries independently and then one combining all**

**Execute [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch). Example using the 1st library***
```sh
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all_2libs | all_3libs | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Run 2 more assemblies with the contaminated data for the second and  third library by rreplacing the "1", with "2" and  "3". 
Then, check the number of libraries you have and run a job combining all libraries together by choosing the appropiate "all_2libs" or "all_3libs" from the library options.

Next, you need to determine the best assembly to use the decontaminated data. Go on and complete step 9 (below) and come back here after.

**After step 9**

Assuming you have completed step 9, you now know what library(ies) produced the best assembly. Compare your BUSCO values with that other species (for example, you can check the ["best assembly table"](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv).
If BUSCO values are too low, it might be worth trying the `covcutoff auto` (by changing the datatype variable from "contam" to "contam_covAUTO")

Example:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam_covAUTO" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Finally, run one more assembly using the decontaminated data from the same library(or all together) that produced the best assembly (with or without the covcutoff flag). Sgr example:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "3" "decontam" "854000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

#### 9 Determine the best assembly

`QUAST` was automatically ran by the SPAdes script. Look for the `quast_results` dir and for each of your assemblies note the: 
1. Number of contigs in assembly (this is the last contig column in quast report with the name "# contigs")
2. the size of the largest contig
3. total length of assembly
4. N50
5. L50 

*Tip: you can align the columns of any .tsv for easy viewing with the comand `column` in bash. Example:
```sh
bash
cat quast-reports/quast-report_scaffolds_Sgr_spades_contam_R1R2_21-99_isolate-off.tsv | column -ts $'\t' | less -S
```

Enter your stats in the table below

Those are basic assembly statistics but we still need to run BUSCO to know how many expected (i.e. highly conserved) genes were recovered by the assembly. 

**Execute [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files for each assembly**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths. Example using contigs:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" "contigs"
```
Repeat the comand using scaffolds.

`runBUSCO.sh` will generate a new dir per run. Look for the `short_summary.txt` file and note the percentage of `Complete and single-copy BUSCOs (S)` genes


Fill in this table with your QUAST and BUSCO values in your species README. 

Few notes:

* Library name can be obtained from file names
* covcutoff is "off" as a default in this pipeline. This is "on" only if you ran an extra assembly with ""contam_covAUTO" trying to improve busco values
* No. of contigs is the last contig column in quast report with the name "# contigs"
* % Genome size completeness = "Total lenght"/genome size(or rounded genome max value) *100
* **For QUAST, only report the row for the actual assembly (i.e. report "scaffolds" not "scaffolds_broken"**
* **For BUSCO, only report the "Complete and single-copy BUSCOs (S)"

```sh
Species    |Library    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total lenght    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------ 
Sgr  |allLibs  |contam       |contigs       |off       |1       |2253577  |309779       |489995603       |70.5%       |5515       |28571       |0       |29.9%
Sgr  |allLibs  |contam       |scaffolds       |off       |1       |2237565  |309779       |517068774       |74.5%       |5806       |28041       |147.59       |29.9%
Sgr  |SgC0072B  |contam       |contgs       |off       |2       |82681  |68606       |441333876       |51.7%       |5405       |26613       |0   |29.2%
Sgr  |SgC0072B  |contam       |scaffolds       |off       |2       |84110  |68606       |460942092       |54%       |5587       |26490       |147.59   |31.3%
Sgr  |SgC0072C  |contam       |contgs       |off       |2       |85876  |105644       |531350946       |62.2%       |6617       |24450       |0   |37.9%
Sgr  |SgC0072C  |contam       |scaffolds       |off       |2       |85997  |105644       |536156621       |62.8%       |6686      |24304       |14.73   |38.4%
Sgr  |SgC0072D  |contam       |contgs       |off       |2       |83191  |68563       |441118097       |51.7%       |5352      |26844       |0   |29.7%
Sgr  |SgC0072D  |contam       |scaffolds       |off       |2       |84615  |120121       |462780087       |54.2%       |5570      |26612       |167.75   |31.5%
Sgr  |SgC0072C  |decontam       |contgs       |off       |2       |69371  |103720       |395865756       |46.6%       |5946     |21196       |0   |32.2%
Sgr  |SgC0072C  |decontam       |scaffolds       |off     |2       |69932  |103720       |406306057       |47.6%       |6080      |21004       |42.77   |33.2%
```

---


**Determine the best assembly**

We assess quality across multiple metrics since we don't use a golden rule/metric for determing the best assembly. 
Often, it is clear that single libray is relatively better than the others as it would have better results across metrics. Yet, sometimes this is not soo clear as different assemblies might be better in different metrics. Use the following table to help you decide:

Importance    |Metric    |Direction    |Description
------  |------  |------ |------ 
1st  |BUSCO  | Bigger is better  | % of expected genes observed in your assembly
2nd  |N50  |Bigger is better  | Lenght of the smaller contig from the set of contigs needed to reach half of your assembly
3rd  |Genome size completeness  |Bigger is better  |Lenght of assembly divided by estimated genome lenght
4th  |L50  | Smaller is better  | Number of contigs needed to reach half of your assembly
5th  |Largest contig  |Bigger is better  | Lenght of largest contig
 
If you are still undecided on which is the best assembly, post the best candidates on the species slack channel and ask for opinions

Now, go back to step 8 and run decontaminated data for library that produced the best assembly

---

#### Update the main assembly stats table with your species

Add a new record for your species/assembly to the [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) file

Please note that you cannot paste a tab in nano as it interprets tabs as spaces. This means that you will have to manually enter each column one by one, or copy and paste multiple columns but then change the spaces by a single column to restore the tsv format.

Once done, push your changes to GitHub and confirm the that tsv format is correct by opening the [best_ssl_assembly_per_sp.tsv](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/best_ssl_assembly_per_sp.tsv) that your browser is displaying code but a nice looking table (aligned columns, etc). 

```sh
# add your info in a new row
nano ../best_ssl_assembly_per_sp.tsv
```

---
### Probe Design

In this section you will identify contigs and regions within contigs to be used as candidate regions to develop the probes from.

Among other output, you will create the following 4 files:
1. *.fasta.masked: The masked fasta file 
2. *.fasta.out.gff: The gff file created from repeat masking (identifies regions of genome that were masked)
3. *_augustus.gff: The gff file created from gene prediction (identifies putative coding regions)
4. *_per10000_all.bed: The bed file with target regions (1 set of 2 probes per target region).

This instructions have been modified from Rene's [de novo assembly probe repo](https://github.com/philippinespire/denovo_genome_assembly/tree/main/WGprobe_creation) 
to best fit this repo

#### 10 Identifying regions for probe development 

From your species directory, make a new dir for the probe design
```sh
mkdir probe_design
```

Copy necessary scripts and the best assembly (i.e. scaffolds.fasta from contaminated data of best assembly) into the probe_design dir (you had already selected the best assembly previously to run the decontaminated data) 

Example:
```sh
cp ../scripts/WGprobe_annotation.sb probe_design
cp ../scripts/WGprobe_bedcreation.sb probe_design
cp SPAdes_SgC0072C_contam_R1R2_noIsolate/scaffolds.fasta probe_design
```

Rename the assembly to reflect the species and parameters used. Format to follows:

<3-letter species code>_scaffolds_<library>_<cotam|decontam>_R1R2_noIsolate_<other treatments, if any>.fasta

To get this info, I usually copy and paste the parameter info from the busco directory:
```sh
# list the busco dirs
ls -d busco_*
# identify the busco dir of the best assembly, copy the treatments (starting with the library)
# Example,the busco dir for the best assembly for Sgr is `busco_scaffolds_results-SPAdes_SgC0072C_contam_R1R2_noIsolate`
# I then provide the species 3-letter code, scaffolds, and copy and paste the parameters from the busco dir after "SPAdes_" 
cd probe_design
mv scaffolds.fasta Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta
```

Execute the first script. Example for Sgr:
```sh
#WGprobe_annotation.sb <assembly name> 
sbatch WGprobe_annotation.sb "Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta"
```

This will create: 
1. a repeat-masked fasta and gff file (.fasta.masked & .fasta.out.gff)
2. a gff file with predicted gene regions (augustus.gff), and 
3. a sorted fasta index file that will act as a template for the .bed file (.fasta.masked.fai)

I have modified the bed script to set the upper limit automatically. The longest scaffold and upper limit will  printed in the out file after execution.


Execute the second script. Example for Sgr:
```sh
#WGprobe_annotation.sb <assembly base name> 
sbatch WGprobe_bedcreation.sb "Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta"
```

This will create a .bed file that will be sent for probe creation.
 The bed file identifies 5,000 bp regions (spaced every 10,000 bp apart) in scaffolds > 10,000 bp long.


**Check Upper Limit**

Open your out file and check that the upper limit was set correctly. Record the longest contig, uppper limit used in loop, and the number of identified regions and scaffolds  in your species README. 

The upper limit should be XX7500 (just under longest scaffold length). Ex: if longest scaffold is 88,888, then the upper limit should be 87,500; if longest scaffold is 87,499, then the upper limit should be 77,500.  

Sgr example:
```sh
cat BEDprobes-415039.out


The longest scaffold is 105644
The uppper limit used in loop is 97500
A total of 13063 regions have been identified from 10259 scaffolds
```

Move out files into your species logs dir
```sh
mv *out ../logs
```

#### 11 Closest relatives with available genomes

The last thing to do is to create a text file with links to available genomes from the 5 most closely-related species.

Most likely there won't be genomes available for your targeted species or even genus thus, the easiest way to search is probably to start with the family.
Go to the [NCBI Genome repository](https://www.ncbi.nlm.nih.gov/genome/) and search for the family of your species. If you get more than 5 genomes then search for the genus, but if  you don't, search higher classifications till you get them (i.e. order, class, etc)

Once you get at least 5 genomes, you'll need to figure out the phylogenetic relationships to lists the genomes in order from closest to farthest. 

Seach for phylogenies especific to your group. 
I have uploaded the phylogenies from Betancur et al. BMC Evolutionary Biology (2017) 17:162 for [fish phyla](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/Betancur2017_phyla.pdf)
 and [fish families](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/Betancur2017_families.pdf)
 in the scripts repo for your convenience.
These are an excellent resource for high taxonomic groups but only a few species per family are represented. 
Thus, you should also seach for phylogenies especific to your group. If these are not available, use Betancur 


Once your list is ready, create a file in your `probe_design` dir. Example for Sgr:
```sh
nano closest_relative_genomes_Spratelloides_gracilis.txt

1.- Clupea harengus
https://www.ncbi.nlm.nih.gov/genome/15477
2.- Sardina pilchardus
https://www.ncbi.nlm.nih.gov/genome/8239
3.- Tenualosa ilisha
https://www.ncbi.nlm.nih.gov/genome/12362
4.- Coilia nasus
https://www.ncbi.nlm.nih.gov/genome/2646
5.- Denticeps clupeoides
https://www.ncbi.nlm.nih.gov/genome/7889
```

## Files to Send

Share the following files with Arbor Bio to aid in probe creation:

1. The repeat-masked fasta file (.fasta.masked)
2. The gff file with repeat-masked regions (.fasta.out.gff)
3. The gff file with predicted gene regions (.augustus.gff)
4. The bed file (.bed)
5. The text file with links to available genomes from the 5 most closely-related species.

Make a dir name "files_for_ArborSci" inside your probe_design dir and move these files there:
```sh
mkdir files_for_ArborSci
mv *.fasta.masked *.fasta.out.gff *.augustus.gff *bed closest* files_for_ArborSci
```

Finally, notify Eric by email (e1garcia@odu.edu)  saying that your files are ready and post a message in the slack species channel with the probe region and scaffold info (from your BEDprobe*out file), and the full path to your files. Sgr example:
```sh
Probe Design Files Ready

A total of 13063 regions have been identified from 10259 scaffolds. The longest scaffold is 105644. 

Files for Arbor Bio:
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/probe_design/files_for_ArborSci

Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta.augustus.gff
Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta.masked
Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate.fasta.out.gff
Sgr_scaffolds_SgC0072C_contam_R1R2_noIsolate_great10000_per10000_all.bed
closest_relative_genomes_Spratelloides_gracilis.txt
```

Eric will then share these with Arbor BioSciences.

#### **Finito!!!**

#### **Contrats! You have finished the ssl processing pipeline. Go ahead, give yourself a pat on the back!**

---

## Cleaning Up

The SSL pipeline creates multiple copies of your data in the form of intermediate files. Assuming that you have finished the pipeline
 (have checked your files and send probe info to Arbor Bio), it is now time to do some cleaning up

Document the size of directories and files before cleaning up and save this to a file name <your species 3-letter ID>_ssl_beforeDeleting_IntermFiles 

From your species dir:
```sh
du -h | sort -rh > <yourspecies>_ssl_beforeDeleting_IntermFiles
# Sgr example Sgr_ssl_beforeDeleting_IntermFiles
```

### Make a copy of important files 
Before deleting files, make a copy of important files in the RC (only available in the login node):

1. raw sequence files (this should had been done already but check again)
2. "contaminated" files (fq_fp1_clmparray_fp2)
3. "decontaminated" files (fq_fp1_clmparray_fp2_fqscrn_repaired)
4. best assembly (probably just the contigs.fasta and scaffolds.fasta for contam and decontam of best assembly)

Example for Sgr
```sh
# check for copy of raw files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq/

# make copy of contaminated and decontaminated files
cp -R fq_fp1_clmparray_fp2 /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/
cp -R fq_fp1_clmparray_fp2_fqscrn_repaired /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/               

# make a copy of fasta files for best assembly (SgC0072C for Sgr)
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_contam_R1R2_noIsolate
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_decontam_R1R2_noIsolate
cp SPAdes_SgC0072C_contam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_contam_R1R2_noIsolate
cp SPAdes_SgC0072C_decontam_R1R2_noIsolate/[cs]*.fasta /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<your species>/SPAdes_SgC0072C_decontam_R1R2_noIsolate
```

### Delete unneeded files
Delete raw sequence files and other sequence files (fq.gz | fastq.gz) from intermediate processes (Fastp1, Clumpify, and Fastq Screen; steps 0, 2, and 5). Keep files from fq_fp1_clmparray_fp2 and fq_fp1_clmparray_fp2_fqscrn_repaired for now.

It is a good idea to keep track of the files you are deleting

An easy way to do this is to list files to be deleted, copy the info and paste it into log file tracking the files you are deleting
```sh
ls -l shotgun_raw_fq/*fq.gz
# copy from the line of the command to the last file and paste it while creating the log file 
nano deleted_files_log
# paste
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq/
-rwxr-x--- 1 e1garcia carpenter  15G Aug  2 12:12 SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_1.fq.gz
-rwxr-x--- 1 e1garcia carpenter  16G Aug  2 12:30 SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_2.fq.gz
-rwxr-x--- 1 e1garcia carpenter  13G Aug  2 12:45 SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_1.fq.gz
-rwxr-x--- 1 e1garcia carpenter  14G Aug  2 13:01 SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_2.fq.gz
-rwxr-x--- 1 e1garcia carpenter  16G Aug  2 13:19 SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_1.fq.gz
-rwxr-x--- 1 e1garcia carpenter  17G Aug  2 13:36 SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_2.fq.gz
```

Append the info of the rest of files to be deleted into the same file. At the end you'll have something similar to the Sgr [deleted_files_log]() 


Finally, document the new size of your directories

From your species dir:
```sh
du -h | sort -rh > <yourspecies>_ssl_afterDeleting_IntermFiles
```

For Sgr, I deleted about 1Tb of data! (I create many treatments while making the SSL pipeline. You will likely delete less than that but still a substancial amount)


Move the cleaning files into the logs dir
```sh
mv Sgr_ssl* logs
mv deleted_files_log logs
```

