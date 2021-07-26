# CAPTURE SHOTGUN DATA PROCESSING & ANALYSIS

---

The purpose of this repo is to document the processing and analysis of shotgun data for probe development which then will be process according to the [Capture Shotgun Sequencing Libraries- CSSL repo](https://github.com/philippinespire/pire_cssl_data_processing) 

Eeach species will get it's own directory within this repo.  Try to avoing putting dirs inside dirs inside dirs. 

The Sgr dir will serve as the example to follow in terms of both directory structure and documentation of progress in `README.md`.

---

## Use Git/GitHub to Track Progress

To process a species, begin by cloning this repo to your dir.

```
git clone <insert url here>
```

The data will be processed and analyzed in the repo.  There is a `.gitignore` file that lists files and directories to be ignored by git.  It includes large files that git cannot handle (fq.gz, bam, etc) and other repos that might be downloaded into this repo. 
***list actual example*** For example, the dir `dDocentHPC` contains the [dDocentHPC](https://github.com/cbirdlab/dDocentHPC) repo which you will be using, but we don't need to save that to this repo, so `dDocentHPC/` occurs in  `.gitignore` so that it is not uploaded to github in this repo.

Because large data files will not be saved to github, they will reside in an individual's copy of the repo or somewhere on the HPC. You should provide paths (absolute/full paths are probably best) or info that make it clear where the files reside. Most of these large intermediate files should be deleted once it is confirmed that they worked. For example, we don't ultimately need the intermedate files produced by fastp, clumpify, fastq_screen.

---

## Maintaining Git Repo

You must pull down the lated version of the repo everytime you sit down to work and push the changes you made everytime you walk away from the terminal.  The following order of operations when you sync the repo will minimize problems.

```
git pull
git add --all
git commit -m "insert message"
git pull
git push
```

If you should be met with a conflict screen, you are in the archane `vim` editor.  You can look up instructions on how to interface with it. I typically do the following:

* hit escape key twice
* type the following
  `:quit!`
  
___

## Data Processing Roadmap

1. Clone this repo to your working dir

2. Run [`fastqc`]()
    * review results with `multiqc` output
  
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

