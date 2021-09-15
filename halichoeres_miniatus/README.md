# *Halichoeres miniatus*
***

The purpose of this repository is to provide replicable steps for de novo genome assembly of *H. miniatus* as outlined by Dr. Eric Garcia in the [PIRE Shotgun Data Processing and Analysis Page](https://github.com/philippinespire/pire_ssl_data_processing) of the [PhilippinesPIRE](https://github.com/philippinespire) repository.  All scripts and software used are explained on the PIRE Shotgun repository.  All bioinformatic work was performed on the Old Dominion University High Performance Computing Cluster.

The documents in this repository are written in [Markdown](https://www.markdownguide.org/basic-syntax/#links).

All work is done for the [Philippines PIRE Project](https://sites.wp.odu.edu/PIRE/), [NSF Award #1743711](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1743711).

See documentation for the Old Dominion University [High Performance Computing](https://www.odu.edu/facultystaff/research/resources/computing/high-performance-computing/user-documentation).

A complete log of all command line work can be found in the [README.md](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/logs) of this repository's subdirectory logs.
***

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/Multi_FASTQC/multiqc_report_fq.gz.html) (copy and paste into a text editor locally) Save and open in your browser to view

Potential issues:
* % duplication - 
  * 37.1%-48.2%s
* gc content - 
  * 49-58%
* quality - 
  * sequence quality and per sequence qual 
* % adapter - 
  * ~
* number of reads - 
  * 

## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1/1st_fastp_report.html)

Potential issues:
* % duplication -
  * 12-13.4%
* gc content -
  * ~42.5%
  * more variable in pos 1-14 than in 15-150 
* passing filter -
  * 
* % adapter -
  *
* number of reads -
  *

## Step 3. Clumpify

Ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array in Wahab

Checked the output with `/home/ilope002/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R`

Clumpify worked succesfully.

## Step 5. Run fastq_screen

Executed `runFQSCRN_6.bash` to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn/fastqc_screen_report.html)

Checked output for errors

ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

all returned 5

checked for errors in all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

No errors!

MultiQC failed due to python errors in the program.  No report was generated.  Please see the outfile in this repo's logs dir.
The script was corrected and the MultiQC report was generated.
Highlights from [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn/fastqc_screen_report.html):
* about 96% of reads were retained

## Step 6. Repair fastq_screen paired end files
