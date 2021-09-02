# SHOTGUN DATA PROCESSING & ANALYSIS

---

The purpose of this repo is to document the processing and analysis of `Shutgun Sequencing Libraries - SSL data` for probe development which then will be processed according to the [Capture Shotgun Sequencing Libraries- CSSL repo](https://github.com/philippinespire/pire_cssl_data_processing) 

Each species will get it's own directory within this repo.  Try to avoing putting dirs inside dirs inside dirs. 

The Sgr dir will serve as the example to follow in terms of both directory structure and documentation of progress in `README.md`.

---

## Use Git/GitHub to Track Progress

To process a species, begin by cloning this repo to your working dir. I recommend setting up a `shotgun_PIRE` sub-dir in your home dir if you have not done something similar already

Example: `/home/e1garcia/shotgun_PIRE`

Clone the 
```
git clone https://github.com/philippinespire/pire_ssl_data_processing.git
```

The data will be processed and analyzed in the repo.  There is a `.gitignore` file that lists files and directories to be ignored by git.  It includes large files that git cannot handle (fq.gz, bam, etc) and other repos that might be downloaded into this repo. 
***list actual example*** For example, the dir `dDocentHPC` contains the [dDocentHPC](https://github.com/cbirdlab/dDocentHPC) repo which you will be using, but we don't need to save that to this repo, so `dDocentHPC/` occurs in  `.gitignore` so that it is not uploaded to github in this repo.

Because large data files will not be saved to github, they will reside in an individual's copy of the repo or somewhere on the HPC. You should provide paths (absolute/full paths are probably best) or info that make it clear where the files reside. Most of these large intermediate files should be deleted once it is confirmed that they worked. For example, we don't ultimately need the intermedate files produced by fastp, clumpify, fastq_screen.

---

## Maintaining Git Repo

You must pull down the latest version of the repo everytime you sit down to work and push the changes you made everytime you walk away from the terminal.  The following order of operations when you sync the repo will minimize problems.

```
git pull
git add --all
git commit -m "insert message"
git pull
git push
```

This code has been compiled into the script `runGIT.bash` thus you can just run this script BEFORE and AFTER you do anything in your species repo.
You will need to provide the message of your commit when running:
```sh
bash runGIT.bash "initiate Sgr repo"
```
You will need to enter your git credentials multiple times each time you run this script

If you should be met with a conflict screen, you are in the archane `vim` editor.  You can look up instructions on how to interface with it. I typically do the following:

* hit escape key twice
* type the following
  `:quit!`
  
___

## Data Processing Roadmap

### Pre-Process

Clone this repo to your working dir
*(already done above)*

#### 0. Set up directories and data

Make a copy of your raw files in the longterm carpenter RC dir
```sh
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/
mkdir <species_name>
mkdir <species_name>/shotgun_raw_fq
cp <source of files> /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<species_name>/shotgun_raw_fq
```
*The RC drive is only available from the login node (you won't find it after getting a working node, i.e. `salloc`*

Create your `species dir` and and subdirs `logs` and `shotgun_raw_fq`. Transfer your raw data into `shotgun_raw_fq` 
*(can take several hours)*

```sh
cd pire_ssl_data_processing
mkdir spratelloides_gracilis 
mkdir spratelloides_gracilis/logs
mkdir spratelloides_gracilis/shotgun_raw_fq
cp <source of files> spratelloides_gracilis/shotgun_raw_fq  # scp | cp | mv
```

Also create a `README` in the `shotgun_raw_fq` dir with the full path to the original copies of the raw files and necessary decoding info to find out for which individual(s) these sequence files belong to.


This information is usually provied by Sharon Magnuson in species [slack](https://app.slack.com/client/TMJJ06SH0/CMPKY5C81/thread/CQ9GAAYGY-1627263374.002300) channel

```sh
cd spratelloides_gracilis/shotgun_raw_fq
nano README
```

Example:
```sh
TAMUCC to ODU
scp /work/hobi/GCL/20210719_PIRE-Sgr-shotgun/ e1garcia@turing.hpc.odu.edu:/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq

All 3 sequence sets are for the same individual: Sgr-CMvi_007_Ex1
```

*I like to update my git repo regularly, especially before and after lengthly steps. This keeps a nice record of the commits and prevents loss of data/effor. Feel free to repeat this at any step*

```sh
bash ../../runGIT.bash
```

***You are ready to start processing files***
Complete the pre-processing of your files following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo
* This includes running FASTQC, FASTP1, CLUMPLIFY, FASTP2, FASTQ SCREEN, and file repair

#### 1. Execute [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh)
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "."
```

Download and review the Multiqc report for issues. 


Create a species specific README.md to track the species progress
```sh
nano ../README.md
```

You can use the Sgr [README.md](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/spratelloides_gracilis) as a template and fill in as steps are accomplished for your species `/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/README.md`

* Update your species README, i.e. provide a link to the report and list the highlights.
* Update the species  README and the slack species channel after every step


#### 2. Execute [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

Move the `.out` files into the `logs` dir
```sh
mv *out ../logs
```
Repeat this AFTER each step is completed


#### 3. Execute [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) on Wahab.  

The `max # of nodes to use at once` should not exceed the number of pair of r1-r2 files to be processed. If you have many sets of files, you could also limit the number of nodes to the number of nodes in `idle` in the main partiton i.e. run sinfo and look for `idle`

For Sgr, I had 6 r1 and 6 r2 files, or 3 sets of pairs so I used 3 nodes for clumpify
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
quit()
# R:save session?
yes

# If you already have tidyverse do this:
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```
If all files were successful, `checkClumpify_EG.R` will return "Clumpify Successfully worked on all samples". 

If some failed, the script will also let you know. Try raising "-c 20" to "-c 40" in `runCLUMPIFY_r1r2_array.bash` and run clumplify again

Also look for this error "OpenJDK 64-Bit Server VM warning:
INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not enough space' (errno=12)"


When completed, move your log files into the `logs` dir
```sh
mv *out logs
```

#### 4. Execute [runFASTP_2_ssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch)
```
#runFASTP_2.sbatch <indir> <outdir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
```
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

#You should also check for errors in the *out files:
# this will return any out files that had a problem

#do all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# or check individuals files <replace JOBID with your actual job ID>
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```
If you see missing indiviudals or categories in the multiqc output, there was likely a ram error.  I'm not sure if the "error" search term catches it.

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
```sh
#runMULTIQC.sbatch <INDIR> <Report name>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

* Update your species README, i.e. provide a link to the report and list the highlights. 
* Update Slack


#### 6. Execute [runREPAIR.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch)

```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh)
```sh
#read_calculator_ssl.sh <Species home dir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

`read_calculator_ssl.sh` counts the number of reads before and after each step in the pre-process of ssl data and creates the dir `reprocess_read_change` with the following 2 tables:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

Inspect these tables and revisit steps if too much data was lost

___

### Assembly

#### 7. Genome Properties

Fetch the genome properties for your species
* From the literature or other sources
	* [genomesize.com](https://www.genomesize.com/)
	* search the literature
* Estimate properties with `jellyfish` and `genomescope`
	* More details [heree](https://github.com/philippinespire/denovo_genome_assembly/blob/main/jellyfish/JellyfishGenomescope_procedure.md)

**Execute [runJellyfish.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runJellyfish.sbatch) using decontaminated files**
```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir> 
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Sgr" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```

Jellyfish will create a histogram file (.hito) with kmer frequencies. 
Download this file into your local computer and upload it in [GenomeScope v1.0](http://qb.cshl.edu/genomescope/)
* Add a proper description to your run. Example "Sgr_ssl_decontam"
* Adjust the read lenght to that of in the Fastp2 trimming, 140 (unless you had to modify this in Fastp2)
* Leave Max kmer coverage = 1000 
* Submit (takes only few minutes)
* *Note that GenomeScope v2.0 is also available and can "acount for different ploidy levels". However, when used with Sgr and others, the model performed very poorly. Explore v2.0 If you know or suspect your species is not diploid, otherwise is likely safe to stick to v1.0 
 
Complete the following table in your Species README. You can copy and paste this table straight into your README (no need to enclose it with quotes, i.e. a code block) and just substitute values. You'll have to calculate the average
```sh
Genome stats for Sgr from Jellyfish/GenomeScope v1.0 k=21
stat	|min	|max	|average	
------	|------	|------	|------	
Heterozygosity	|1.10243%	|1.10633%	|1.10438%	
Genome Haploid Length	|524,384,095 bp	|524,590,385 bp	|524,487,240 bp	
Model Fit	|97.6162%	|98.7154%	|98.1658 %	
```


Note the genome size (or estimate) in your species README. You will use this info later


#### 8. Assemble the genome

Congrats! You are now ready to assembly the genome of your species!

After de novo assembler comparisons,  we decided to move forward using SPADES (isolate and covcutoff flags off). 
For the most part, we obtained better assemblies using single libraries but in few instances using all the libraries was better.
In addition, we also noted that assembling contaminated data produced better results for nDNA and decontaminated was better for mtDNA. 

Thus, use the contaminated files to run one assembly for each of your libraries independently and then one combining all.
1. You need to be in Turing for this step. SPAdes requires high memory nodes (only avail in Turing)
2. Get the genome size of your species, or Jellyfish estimate, in bp from the previous step. Jellyfish gives an min an max: I have been using the average of both of these (rounding to the nearest million)


We produced 3 libraries (from the same individual) for the last 5 spp  with ssl data resulting in 3 sets of files. Sgr example:
```sh
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq
ls
SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_1.fq.gz
SgC0072B_CKDL210013395-1a-5UDI294-AK7096_HF33GDSX2_L4_2.fq.gz
SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_1.fq.gz
SgC0072C_CKDL210013395-1a-AK9146-7UDI286_HF33GDSX2_L4_2.fq.gz
SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_1.fq.gz
SgC0072D_CKDL210013395-1a-AK5577-AK7533_HF33GDSX2_L4_2.fq.gz
```
Thus, the following SPAdes script is optimized to run all and up to the first 3 libraries independently. 
If your species has 4 or more libraries, you will need to modify the script to run the 4th,5th,.. library and so on (you'll only need to add the necessary libraries to the SPAdes command)

No changes necessary for running the first, second, thrid, or all the libraries together.  

**Use the contaminated files to run one assembly for each of your libraries independently and then one combining all**

**Execute [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch). Example using the 1st library***
```sh
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <library: all | 1 | 2 | 3> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Run 3 more assemblies with the contaminated data for the second, third, and all libraries together (i.e. replace "1", with "2", "3", and "all")

After assessing the best library (you'll need to complete number 8 below), it might be worth trying the `covcutoff auto` (by changing the datatype variable from "contam" to "contam_covAUTO") if BUSCO values are too low try

Example:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "1" "contam_covAUTO" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Finally, run one more assembly using the decontaminated data from the same library(or all together) that produced the best assembly (with or without the covcutoff flag) with the contaminated files. Sgr example:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "3" "decontam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

#### 8. Determine the best assembly

`QUAST` was automatically ran by the SPAdes script. Look for the `quast_results` dir and for each of your assemblies note the: 
1. total number of contigs
2. the size of the largest contig
3. total lenght of assembly
4. N50
5. L50 

*Tip: you can align the columns of any .tsv for easy viewing with the comand `column` in bash. Example:
```sh
bash
cat quast-reports/quast-report_scaffolds_Sgr_spades_contam_R1R2_21-99_isolate-off.tsv | column -ts $'\t' | less -S
```

Enter your stats in the table below

Those are basic assembly statistics but we still need to know how many expected (i.e. highly conserved) genes were recovered by the assembly. 

**Execute [runBUCSO.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runBUSCO.sh) on the `contigs` and `scaffolds` files for each assembly**
```sh
#runBUSCO.sh <species dir> <SPAdes dir> <contigs | scaffolds>
# do not use trailing / in paths. Example using contigs:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runBUSCO.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis" "SPAdes_decontam_R1R2_noIsolate" "contigs"
```
Repeat the comand using scaffolds.

`runBUSCO.sh` will generate a new dir per run. Look for the `short_summary.txt` file and note the percentage of `Complete and single-copy BUSCOs` genes


Fill in this table with your values in your species README.

```sh
Species    |Library    |DataType    |SCAFIG    |covcutoff    |No. of contigs    |Largest contig    |Total lenght    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------ |------ |------ |------ |------  |------ |------ |------ |------  |------ |------ 
Sgr  |allLibs  |contam       |contigs       |off       |2253577  |309779       |489995603       |70.5%       |5515       |28571       |29.9%       
Sgr  |allLibs  |contam       |scaffolds       |off       |2237565  |309779       |517068774       |74.5%       |5806       |28041       |29.9%
Sgr  |allLibs  |contam       |contigs       |auto       |2220821  |309779       |489827781       |70.6%       |5800       |28040       |30%
Sgr  |allLibs  |contam       |scaffolds       |auto       |2204948  |309779       |516942564       |74.5%       |5800       |28041       |32.2%
Sgr  |allLibs  |decontam       |contgs       |off       |2316449  |197090       |411716418       |59.3%       |5443       |24590       |27.1%
Sgr  |allLibs  |decontam       |scaffolds       |off       |2295872  |197090       |440572995       |63.5%       |5751       |24463       |29.5%
Sgr  |allLibs  |decontam       |contgs       |auto       |2290268  |197090       |411810888       |59.4%       |5442       |24601       |27.1%
Sgr  |allLibs  |decontam       |scaffolds       |auto       |2269777  |197090       |440612739       |63.5%       |5750       |24463       |29.5%
```
