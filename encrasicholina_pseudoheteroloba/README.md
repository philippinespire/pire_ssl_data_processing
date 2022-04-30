# Eps Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Run from /scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/shotgun_raw_fq

[Report](https://raw.githubusercontent.com/philippinespire/pire_ssl_data_processing/main/encrasicholina_pseudoheteroloba/Multi_FASTQC/multiqc_report_fq.gz.html?token=GHSAT0AAAAAABHRMAUPRYBB4LKD3R5VCJGYYTMRXZA) (copy and paste into a text editor locally, save and open in your browser to view)
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/scratch/breid/pire_ssl_data_processing/encrasicholina_pseudoheteroloba/shotgun_raw_fq" 
```

Potential issues:

* low duplication
* 21.4-23.3%
* GC content
* 46-47%
* good sequence quality
* !!high adapter content - lots of overrepresented sequences!
