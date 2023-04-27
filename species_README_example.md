# Processing SSL data for *Genus species* 

The purpose of this repository is to generate a *de novo* genome assembly and develop probes for *Genus species* as outlined 
by the [PIRE Shotgun Data Processing and Analysis - SSL Repo](https://github.com/philippinespire/pire_ssl_data_processing) of the [Philippines PIRE Project - PPP](https://github.com/philippinespire).

All scripts and software used are explained on the SSL.  

This README documents all work done.

Bioinformatic work was performed by *project_owner* in the Old Dominion University High Performance Computing Cluster. 

---

## Pre-Processing


### 1. Set up directories and data

**Directories**

```sh
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing
mkdir <your_species> 
mkdir <your_species>/logs
mkdir <your_species>/shotgun_raw_fq
```

**Data**

SSL data files were downloaded using gridDownloader.sh

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/<species>/shotgun_raw_fq
sbatch gridDownloader.sh . <link_to_files>
```

All 3 library sets are from the same individual: <individual>

**Make a copy of your raw data in the RC**

I made a copy of the raw files in the RC
```
cd /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/
module load parallel
ls /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/<your_species>/shotgun_raw_fq/* | parallel --no-notice -kj 8 cp {} . &
```

### 2. Initial processing

Following the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repo to run FASTQC, FASTP1, CLUMPIFY, FASTP2, FASTQ SCREEN, and file repair scripts


