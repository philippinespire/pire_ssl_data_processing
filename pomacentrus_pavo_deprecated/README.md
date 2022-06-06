# Ppa Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Run from /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/shotgun_raw_fq

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/pomacentrus_pavo/Multi_FASTQC/multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUOONAUBPX4L3XHKQ7WYTMR22Q) (copy and paste into a text editor locally, save and open in your browser to view)
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/shotgun_raw_fq" 
```

Potential issues:

* duplication - low to moderate
* 19.4% - 35.7%
* gc content:
* 40-41%
* sequence quality good
* low-moderate adapter content 
* no obvious read flags
* lots of sequences for some libraries
* *114.6M - 223.7M

## Step 2. 1st fastp

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/pomacentrus_pavo/fq_fp1/1st_fastp_report.html?token=GHSAT0AAAAAABHRMAUOHQO72K2XCSZB3CYGYTP5U3A)

```sh
sbatch runFASTP_1st_trim.sbatch /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/shotgun_raw_fq /scratch/breid/pire_ssl_data_processing/pomacentrus_pavo/fq_fp1
```

* 20.5%-34.6% duplication
* GC content 40.3%-41.1%
* 98.5% - 98.8% passed filter
* 3.9% - 11.5% adapter
* ~ 225 / 375 / 450 M reads 
