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
The job completed.
I pushed the changes to the repository to GitHub.  I opened the MultiQC report, however, I am not trained to interpret the data. The data displayed by the report and the data requested do not coincide literraly.  I updated the main README.MD as per the instructions.
I read the instructions to sbatch runFASTP_1st_trim.sbatch.
Imodified the script as follows:
```sh
#SBATCH -o ../logs/fastp_1st_-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus/shotgun_raw_fq
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch "." "../fq_fp1"
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.  I opened the 1st_fastp_report, however, I am not trained to interpret the data. The data displayed by the report and the data requested do not coincide literraly.  I updated the main README.MD as per the instructions.
I read the instructions to sbatch runCLUMPIFY_r1r2_array.bash
Imodified the script as follows:
```sh
#SBATCH --job-name=CLUMPIFY
#SBATCH -o ./logs/Clumpify_r1r2-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/ilope002 3
```

The job ran.
The job completed.
I pushed the changes to the repository to GitHub.
I read the outfile and observed runCLUMPIFY failed.
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/ilope002 3
```

The job ran.
The job completed.
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
salloc
crun R
install.packages('tidyverse')
yes
yes
82
```

The install returned the following message:
```sh
Warning message:
In doTryCatch(return(expr), name, parentenv, handler) :
  unable to load shared object '/opt/mapdamage2/lib/R/modules//R_X11.so':
  libXt.so.6: cannot open shared object file: No such file or directory
```

I ran the following commands:
```sh
q()
y
crun R < \/home/ilope002/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

Clumpify Successfully worked on all samples.
I moved to *out files to ./logs
I pushed the changes to the repository to GitHub.

I read the instructions to sbatch runFASTP_2_ssl.sbatch
I modified the script as follows:
```sh
#SBATCH -o ../logsfastp_2nd_-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I deleted the line:
```sh
export SINGULARITY_BIND=/home/e1garcia
```
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2 
```

The job ran.
The job completed.
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
bash /home/ilope002/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 4
```

On the script if $4 = *.fq.gz do not type anyhting.  Only enter $4 when the end of file pattern is not *.fq.gz
The job ran.
The job completed.
I verified 5 files for the 4 files analyzed as per the instructions.
I ran the following commands:
```sh
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out
```

Nothing was returned.  All files ran correctly.  I moved all out files to logs/
I read the instruction to get the multiqc report.  I noted that it may work better to have all scripts for this pipeline in one directory vs having them in multiple directories.

I modified the script as follows:
```sh
#SBATCH -o ./logs/mqc_-%j.out
#SBATCH --mail-user=ilopez@odu.edu
#SBATCH --mail-type=ALL
```

I deleted the line:
```sh
export SINGULARITY_BIND=/home/e1garcia
```
I ran the following commands:
```sh
cd /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/halichoeres_miniatus
sbatch /home/ilope002/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```
The script failed.

I ran the following commands:
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

The script generated an out file with a warning that a new version of MultiQC is available and a list of python errors.  No out dir was generated.  The script failed.

I ran the following commands:
```sh
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch .
less runMULTIQC.sbatch
rm runMULTIQC.sbatch
```

I verified the script was the same.  The .out file makes the following reports:  There is a new version of MultiQC.  There are several python 3.7 errors in the MultiQC program.

I pushed the changes to the repository to GitHub.

