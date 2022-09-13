# Sin Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Run from /scratch/breid/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/stethojulis_interrupta/Multi_FASTQC/multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUOQFOQ5ECVGZ22I7CQYTMR7EQ) (copy and paste into a text editor locally, save and open in your browser to view)
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/scratch/breid/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq" 
```

Potential issues:

* duplication moderate - high
* 41.7-52%
* GC content OK
* 41-42%
* adapter content not too bad
* good seqwuence #s
* 164.5 - 173.5M

## Step 2. 1st fastp

Run in Brendan Reid's directory - John Whalen taking over after this step

```sh
sbatch runFASTP_1st_trim.sbatch /scratch/breid/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq /scratch/breid/pire_ssl_data_processing/stethojulis_interrupta/fq_fp1
```
