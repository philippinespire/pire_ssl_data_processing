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
[Report](xxx) CURRENTLY RUNNING

Potential issues: ENTER:

* duplication - low to moderate %%
* gc content: %%
* sequence quality 
* adapter content - , cumulative % is %
* sequences for all libraries, .M

===============

