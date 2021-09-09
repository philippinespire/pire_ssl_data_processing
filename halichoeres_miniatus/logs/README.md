# *Halichoeres miniatus* log
***

The purpose of this log is to create replicable steps for de novo genome assembly of *H. miniatus* as outlined by Dr. Eric Garcia in the [PIRE Shotgun Data Processing and Analysis Page](https://github.com/philippinespire/pire_ssl_data_processing) of the [PhilippinesPIRE](https://github.com/philippinespire) repository.
***

I cloned the repository, copied the data and followed all steps up to line 124 of the instructions on the [PIRE Shotgun Data Processing and Analysis Page](https://github.com/philippinespire/pire_ssl_data_processing).  I created a README in the *Halichoeres miniatus* directory.  I created this log.
***

The following commands were executed on the command line:

```sh
pwd
/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/shotgun_raw_fq
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "."
The script failed as it is written in the home directory.  The out file stated the following error: /bin/bash: crun: command not found
cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh ../../scripts
nano ../../scripts/Multi_FASTQC.sh
```

I made necessary corrections to the SLURM commands as follows:
```sh
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```
I ran the command:
```sh
sbatch ../../scripts/Multi_FASTQC.sh "fq.gz" "."
```
The script failed again.
I tried inputing an absolute path for the second argument and the script failed again.

I ran the following command.
This instruction to leave the repo and follow the steps in another are not clear.  I deleted the logs and moved to complete the instruction s in the pire_fq_gz_processing.
As per the instruction on the pire_fq_gz_processing repo I entered the following commands:
```sh
enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/shotgun_raw"
```
The script failed.
I edited the script to delete all the comments and remove a two sets of three ` that were commenting out parts of the script.  The script now reads as follows:
```sh
#!/bin/bash -l

#SBATCH --job-name=SgrMulti_fastqc
#SBATCH -o SgrMulti_fastqc-%j.out
#SBATCH -p main
#SBATCH -c 4
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL

enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc

cd $2

ls *$1 | parallel "crun fastqc {}" &&

crun multiqc . -n multiqc_report_$1.html -o ../Multi_FASTQC &&

ls *fastqc.html | parallel "mv {} ../Multi_FASTQC" &&
ls *fastqc.zip | parallel "mv {} ../Multi_FASTQC"
mv *out ../logs
```

I ran the following commands:
```sh
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq.gz" "/home/ilope002/shotgun_PIRE/halichoeres_miniatus/shotgun_raw_fq"
```
The job ran.
