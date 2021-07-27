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

1. Clone this repo to your working dir (already done above)

2. Create your `species dir` and and subdirs `logs` and `shotgun_raw_fq`. Transfer your raw data into `shotgun_raw_fq`

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

**I like to update my git repo regularly, especially before and after lengthly steps. This keeps a nice record of the commits and prevents loss of data/effor. Feel free to repeat this at any step**

```sh
bash ../../runGIT.bash
```



3. Run `fastqc`  **(about 2 hours for 6 files totaling 128GB)**
    * review results with `multiqc` output

Fastqc and Multiqc can be run simultaneously using the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/Multi_FASTQC.sh) script in the `scripts` repo

Execute `Multi_FASTQC.sh` while providing, in quotations and in this order, 
(1) a suffix that will identify the files to be processed, and (2) the FULL path to these files. 

Example:
```sh
sbatch ../../scripts/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq"  
```

If you get a message about not finding "crun" then load the containers in your current session and run `Multi_FASTQC.sh` again

```sh
enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc
sbatch ../../scripts/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq"
```


3. Trim, deduplicate, and decontaminate the raw `fq.gz` files
    * [`denovo_genome_assembly/pre-assembly_processing`](https://github.com/philippinespire/denovo_genome_assembly/tree/main/pre-assembly_processing)
    * review the outputs from `fastp` and `fastq_screen` with `multiqc` output

4. Rename files to follow the `ddocent` naming convention
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

