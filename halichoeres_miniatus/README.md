# *Halichoeres miniatus*
***

The purpose of this repository is to provide replicable steps for de novo genome assembly of *H. miniatus* as outlined by Dr. Eric Garcia in the [PIRE Shotgun Data Processing and Analysis Page](https://github.com/philippinespire/pire_ssl_data_processing) of the [PhilippinesPIRE](https://github.com/philippinespire) repository.  All scripts and software used are explained on the PIRE Shotgun repository.  All bioinformatic work was performed on the Old Dominion University High Performance Computing Cluster.

The documents in this repository are written in [Markdown](https://www.markdownguide.org/basic-syntax/#links).

All work is done for the [Philippines PIRE Project](https://sites.wp.odu.edu/PIRE/), [NSF Award #1743711](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1743711).

See documentation for the Old Dominion University [High Performance Computing](https://www.odu.edu/facultystaff/research/resources/computing/high-performance-computing/user-documentation).

A complete log of all command line work can be found in the [README.md](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/logs) of this repository's subdirectory logs.

One library was incomplete.  The missing files were retireved and steps 1-8 were performed for this library separately.  Reports are attached at each step.

<a name="blank"> </a> Any "blanks" for steps that are completed in other pipelines are not out of laziness, but are left blank due to this author's inability to interpret the output.  Request a more experienced colaborator either train the author or complete the tables to satisfaction.
***

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/Multi_FASTQC/multiqc_report_fq.gz.html)

And the second [MultiQC report] (https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/Multi_FASTQC/multiqc_report2_fq.gz.html)

Potential issues:
* % duplication - 
  * 37.1%-48.2%sf
* gc content - 
  * 49-58%
* quality - 
  * sequence quality and per sequence qual 
* % adapter - 
  * ~
* number of reads - 
  * 

## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch) to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1/1st_fastp_report.html)

The second [fastp report] (https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1/1st_fastp_report2.html)


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

Clumpify worked succesfully on all libraries.

## Step 4. FASTP2

Ran [FASTP](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1_clmparray_fp2/2nd_fastp_report.html)

Second [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1_clmparray_fp2/2nd_fastp_report2.html)

Please review the reports directly using the links above.  I will not describe data I cannot accurately interpret as the output requested is not consistent with the program's output, see [above](#blank).

## Step 5. Run fastq_screen

Executed `runFQSCRN_6.bash` to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn/fqsrn_report.html)

Second [report](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/fq_fp1_clmparray_fp2_fqscrn/fqsrn_report2.html)

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

No errors.

MultiQC failed due to python errors in the program.  No report was generated.  Please see the outfile in this repo's logs dir.
The script was corrected and the MultiQC report was generated.
Highlights from report:
* about 96% of reads were retained

## Step 6. Repair fastq_screen paired end files

Executed `runREPAIR.sbatch`

### Calculated the percent of reads lost in each step

Executed [read_calculator_ssl.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh) to generate the [percent read loss](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/preprocess_read_change/readLoss_table.tsv) and [percent reads remaining](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/preprocess_read_change/readsRemaining_table.tsv) tables

The second reports are here [percent read loss](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/preprocess_read_change/readLoss_table2.tsv) and here [percent reads remaining] (https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/preprocess_read_change/readsRemaining_table2.tsv).

The script failed twice for reasons that time has eroded from my memory.  Dr. Garcia repaired this.
The third reports are here [percent read loss](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/preprocess_read_change/readLoss_table_EG.tsv) and here [percent reads remaining] (https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/preprocess_read_change/readsRemaining_table_EG.tsv).

95-135 million reads were retained after preprocessing

# Assembly section

## Step 7. Genome properties

The genome size of *Halichoeres miniatus* is not in the [genomesize.com](https://www.genomesize.com/) database.

This jellyfish kmer-frequency [hitogram file](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/halichoeres_miniatus/jellyfish_out/Hmi_all_reads.histo) was uploaded into [Genomescope v2.0](http://qb.cshl.edu/genomescope/genomescope2.0/) to generate this [report](http://genomescope.org/genomescope2.0/analysis.php?code=ZiuyUi6puHvBqiz4BSQ1). Highlights:

Genome stats for *Halichoeres miniatus* from Jellyfish/GenomeScope v2.0 k=21

stat|min|max|
------|------|------
Heterozygosity |1.22796% |1.2388%
Genome Haploid Length |631,820,236 bp  |632,395,858 bp
Model Fit |87.7119%  |99.3197%

I will use 632000000 as the genome size estimate.

## Step 8. Assemble the genome using [SPAdes](https://github.com/ablab/spades#sec3.2)

I ran SPAdes on contaminated libraries and assesed them with QUAST and Busco

## Step 9. Determine the best assembly

The table below shows the outcomes of the assemblies for Genomescope V1 estimate. 593000000 bp.  The value covcutoff is omitted as I cannot intrepret how to acquire it. I adjusted the value in a column to BUSCO complete & single copy.  See the reports for further information.

Species|Library|DataType|SCAFIG|No. of contigs|Largest contig|Total length|N50|L50|BUSCO complete & single copy|% Genome size completeness
------|------|------|------|------|------|------|------|------|------|------
Hmi|A|contam|contig|1059314|125732|434260664|6716|19242|46.6%|73.2%
Hmi|B|contam|contig|1152395|94343|435308849|6809|18997|48.5%|73.4%
Hmi|C|contam|contig|1151936|71699|409046162|6513|18731|45.2%|69.0%
Hmi|allLibs|contam|contig|1178612|99674|416912122|6609|18668|45.5%|70.3%
Hmi|A|contam|scaffolds|1012225|165936|511942208|9996|14062|60.1%|86.3%
Hmi|B|contam|scaffolds|1106460|200054|511188068|10051|13877|61.5%|86.2%
Hmi|C|contam|scaffolds|1102909|131151|492541584|9800|13726|58.5%|83.1%
Hmi|allLibs|contam|scaffolds|1128280|171801|502459845|10188|13331|59.1%|84.7%

After confering with colleagues I picked Hmi B for the decontam assembly.

The table below shows the outcomes of the assemblies for Genomescope V2 estimate. 632000000 bp.
Species|Library|DataType|SCAFIG|No. of contigs|Largest contig|Total length|N50|L50|BUSCO complete & single copy|% Genome size completeness
------|------|------|------|------|------|------|------|------|------|------
Hmi|A|contam|contig|1059314|125732|434260664|6716|19242|46.6%|73.2%
Hmi|B|contam|contig|1152395|94343|435308849|6809|18997|48.5%|73.4%
Hmi|C|contam|contig|1151936|71699|409046162|6513|18731|45.2%|69.0%
Hmi|allLibs|contam|contig|1178612|99674|416912122|6609|18668|45.5%|70.3%
Hmi|A|contam|scaffolds|1012225|165936|511942208|9996|14062|60.1%|86.3%
Hmi|B|contam|scaffolds|1106460|200054|511188068|10051|13877|61.5%|86.2%
Hmi|C|contam|scaffolds|1102909|131151|492541584|9800|13726|58.5%|83.1%
Hmi|allLibs|contam|scaffolds|1128280|171801|502459845|10188|13331|59.1%|84.7%

All values are the same.  Hmi B with be used for the decontam assembly.




