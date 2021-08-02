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

0. Make a copy of your raw files in the longterm carpenter RC dir
```sh
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/
mkdir <species_name>
mkdir <species_name>/shotgun_raw_fq
cp <source of files> /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/<species_name>/shotgun_raw_fq
```
*The RC drive is only available from the login node (you won't find it after getting a working node, i.e. `salloc`*


1. Clone this repo to your working dir
*(already done above)*

2. Create your `species dir` and and subdirs `logs` and `shotgun_raw_fq`. Transfer your raw data into `shotgun_raw_fq` 
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

3. Complete the pre-processing of your files following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo

This includes running FASTQC, FASTP1, CLUMPLIFY, FASTP2, FASTQ SCREEN, and file repair

Execute FASTQC
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
	* Update this README and the slack species channel after every step


Execute FASTP1
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

Move the `.out` files into the `logs` dir
```sh
mv *out ../logs
```
Repeat this AFTER each step is completed


Execute `runCLUMPIFY_r1r2_array.bash` on Wahab.  

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
# look for this error "OpenJDK 64-Bit Server VM warning: INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not enough space' (errno=12)"
```
enable_lmod
module load container_env mapdamage2
crun R < ../../pire_fq_gz_processing/checkClumpify_EG.R --no-save
```
If all files were successful, `checkClumpify_EG.R` will return "Clumpify Successfully worked on all samples". 

If some failed, the script will also let you know. Try raising "-c 20" to "-c 40" in `runCLUMPIFY_r1r2_array.bash` and run clumplify again

When completed, move your log files into the `logs` dir
```sh
mv *out logs
```




### Assembly

5. Fetch the genome properties for your species
	* from the literature or other sources
	* estimate properties with *jellyfish* and *genomescope*


6. Assemble the genome
*


5. Rename files to follow the `ddocent` naming convention
   * `population_indivdual.R1.fq.gz`

5. Map processed reads against best reference genome
    * Best genome can be found by running [`wrangleData.R`](https://github.com/philippinespire/denovo_genome_assembly/tree/main/compare_assemblers), sorting tibble by busco or n50, and filtering by species 
    * Use [dDocentHPC mkBAM](https://github.com/cbirdlab/dDocentHPC) to map reads to ref
      * Use [`config.5.cssl`](https://github.com/cbirdlab/dDocentHPC/blob/master/configs/config.5.cssl) when running dDocentHPC as a starting point for the settings

6. Filter the `bam` files
    * Use [dDocentHPC fltrBAM](https://github.com/cbirdlab/dDocentHPC)
    * visualize results with IGV or equivalent on a local computer to look for mapping artifacts
      * look at both contemp and albatross (that goes for anything that follows)
    * compare the filtered (`RG.bam`) to unfiltered (`RAW.bam`) files
      * were a lot of reads lost?

7. Genotype the `bam` files
    * Use [`dDocentHPC mkVCF`](https://github.com/cbirdlab/dDocentHPC) 

8. Filter the `vcf` files
    * Use [`fltrVCF`](https://github.com/cbirdlab/fltrVCF)
      * Use [`config.fltr.ind.cssl`](https://github.com/cbirdlab/fltrVCF/blob/master/config_files/config.fltr.ind.cssl) as a starting point for filter settings

