# Cha Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## PREPROCESSING

## Step 1. Fastqc
Run from /scratch/breid/pire_ssl_data_processing/corythoichthys_haematoptera/shotgun_raw_fq
[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/corythoichthys_haematopterus/Multi_FASTQC/multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUO3M6TJIRDQAECASP2YTMRRUA) (copy and paste into a text editor locally, save and open in your browser to view)
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/scratch/breid/pire_ssl_data_processing/corythoichthys_haematoptera/shotgun_raw_fq" 
```

Potential issues:

* % duplication:
* >70% (high!!)
* gc content:
* 42% - 45%
* quality: good
* sequence quality and per sequence qual both good
* % adapter: low
* <2%
* number of reads: *110M - 136.4M
