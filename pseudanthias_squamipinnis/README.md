All  sequence sets are from individual xxxxxx

===============

## Pseudanthias squamipinnis: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Psq-ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Dar data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pseudanthias_squamipinnis/shotgun_raw_fq"
```
[Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/pseudanthias_squamipinnis/shotgun_raw_fq/fqc_raw_report.html)

Potential issues:

* duplication - moderate 36.7-43.8%
* gc content - normal, 42%
* number of reads - 50.6-66.0 M

===============
## Step 2 FASTP - 1st trim

``sh
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch shotgun_raw_fq fq_fp1
``

[Report](....) Running 1/31

Potential issues:ENTER VALUES
* % duplication - moderate 24.1-26.1%
* gc content - reasonable ~39.3-39.8% more variable in pos 1-11 than in 11-150
* passing filter - very good ~97.9-98.1%
* % adapter - moderate 16.7-20.3%%
*number of reads - good ~372-449M

