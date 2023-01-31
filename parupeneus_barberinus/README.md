All three sequence sets are from individual xxxxxx

===============

## Parupeneus barberinus: SSL_assembly by Jem Baldisimo

Steps below followed preprocessing protocol on https://github.com/philippinespire/pire_fq_gz_processing under guidance of Dr. Bird

bash pire_fq_gz_processing/renameFQGZ.bash Pbb_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename

===============
## Step 1 FASTQC

Multi_FASTQC.sh in https://github.com/philippinespire/pire_fq_gz_processing was run on all raw Pbb data

Files output to and results reported in multiqc_report_fq.gz.html in Multi_FASTQC dir

```sh
sbatch ../pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/parupeneus_barberinus/shotgun_raw_fq"
```
[Report](xxx) CURRENTLY RUNNING

Potential issues: ENTER VALUES HERE 

* duplication - low to moderate % - %
* gc content:%
* sequence quality 
* adapter content: 
* sequences for all libraries, M

===============

