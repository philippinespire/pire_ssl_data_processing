All two  sequence sets are from individual xxxxxx

===============

## Dascyllus aruanus: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Dar_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Dar data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/dascyllus_aruanus/shotgun_raw_fq"
```
[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/shotgun_raw_fq/fqc_raw_report.html)

Potential issues:

* duplication - moderate, 31.6-38.8%%
* gc content - normal, 44%
* number of sequences - 65.6 - 78.4 M

===============               
## Step 2 FASTP - 1st trim

``sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
``

[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/dascyllus_aruanus/fq_fp1/1st_fastp_report.html)

Potential issues:
* % duplication - moderate 33.8-35.9%
* gc content - reasonable 43.3-4% more variable in pos 1-15 than in 15-150
* passing filter - very good ~95.7-96.7%
* % adapter - low 4-5.6%
*number of reads - ~125-150 M

===============
## Step 3 Remove duplicates through Clumpify - RUNNING

runCLUMPIFY_r1r2_array.bash in https://github.com/philippinespire/pire_fq_gz_processing was run on fq.gz files

```sh
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/jbald004 20
```

Checked whether clumpify was successful by navigating to the output folder and excecuting

```sh
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphaeramia_nematoptera/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify was successful??

