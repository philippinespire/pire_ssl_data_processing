# Sgr Shotgun Data Processing Log -SSL data

copy and paste this into a new species dir and fill in as steps are accomplished.

---

Following the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) roadmap 

and [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing)

## Step 1. Fastqc

Ran the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script. [Report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/Multi_FASTQC/multiqc_report_fq.gz.html) (copy and paste into a text editor locally) Save and open in your browser to view

Potential issues:  
* % duplication - not bad
  * 30s-40s
* gc content - reasonable
  * 46-48%
* quality - good
  * sequence quality and per sequence qual both good
* % adapter - good and low
  * ~2s
* number of reads - good
  * ~200M



## Step 2.  1st fastp

Used [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1/1st_fastp_report.html)

Potential issues:  
* % duplication - not bad 
  * 31-46%
* gc content - reasonable
  * ~44%
  * more variable in pos 1-72 than in 73-150 
* passing filter - good
  * ~91%
* % adapter - not too bad 
  * 6-7.5%
* number of reads - good
  * ~340-414M (per pair of r1-r2 files)

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash ../fq_fp1 ../fq_fp1_clmparray /scratch/e1garcia 6
```

---

## Step 3. Clumpify

Ran [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) in a 3 node array in Wahab
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/e1garcia 3
```

Checked the output with `checkClumpify_EG.R`
```
enable_lmod
module load container_env mapdamage2
crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
```

*I couldn't pass the arguments from the terminal to R correcty so I commented out few lines in checkClumpify.R to bypass this*

Clumpify worked succesfully!

Out files were moved to the `logs` dir
```
mv *out logs
```


---

## Step 4. Run fastp2

Executed `runFASTP_2_ssl.sbatch` to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1_clmparray_fp2/2nd_fastp_report.html)
```
#runFASTP_2_ssl.sbatch <indir> <outdir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2_ssl.sbatch fq_fp1_clmparray/ fq_fp1_clmparray_fp2
```

Potential issues:  
* % duplication - low
  * 8-14%
* gc content - reasonable
  * 44s 
* passing filter - good
  * 83-85%s 
* % adapter - virtually noned
  * 0.1%
* number of reads - lost alot for albatross
  * 205-213M (per pair of r1-r2 files)

---


## Step 5. Run fastq_screen

Executed `runFQSCRN_6.bash` to generate this [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1_clmparray_fp2_fqscrn/fastqc_screen_report.html)

```
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 6
``

Checked output for errors
``
ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

# all returned 6

#checked for errors in all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# No errors!
```

However, `runFQSCRN_6.bash` was running multiqc several times generating reports with not all the files and making many outputs. I deleted all of this and re-run multiqc with `runMULTIQC.sbatch`

I modified `runFQSCRN_6.bash` by commenting out the original execution of multiqc and added the format we are running in the trims

```sh
#runMULTIQC.sbatch <INDIR> <Report name>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runMULTIQC.sbatch "fq_fp1_clmparray_fp2_fqscrn" "fqsrn_report"
```

Highlights from [report](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/fq_fp1_clmparray_fp2_fqscrn/fastqc_screen_report.html):
* about 90% of reads were retained


Cleanup logs
```
mkdir logs
mv *out logs
```

---

## Step 6. Repair fastq_screen paired end files

```sh
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

This went smoothly.

---


## Calculated the percent of reads lost in each step

Executed [read_calculator_ssl.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh)
to generate the [percent read loss](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/preprocess_read_change/readLoss_table.tsv) and
 [percent reads remaining](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/preprocess_read_change/readsRemaining_table.tsv) tables

```sh
#read_calculator_ssl.sh <Species home dir> 
# do not use trailing / in paths
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Highlights:
* 25-38% of reads were duplicates and were dropped by clumpify
* fastp2 dropped 14-17% of the reads after deduplication (lower min read lenght?)
* Total accumulative read loss is 50-60%, which results in 86-94 M reads still remaining (loss seems pretty high but we still ~90M read left!)


---

### Assembly section

## Step 7. Genome properties

I could not find Sgr in the [genomesize.com](https://www.genomesize.com/) database,
 thus I estimated the genome size of Sgr using jellyfish

From species home directory: Executed runJellyfish.sbatch using decontaminated files
```sh
#runJellyfish.sbatch <Species 3-letter ID> <indir> <outdir>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runJellyfish.sbatch "Sgr" "fq_fp1_clmparray_fp2_fqscrn_repaired" "jellyfish_decontam"
```
This jellyfish kmer-frequency [hitogram file](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/jellyfish_out/Sgr_all_reads.histo) 
was uploaded into [Genomescope v1.0](http://qb.cshl.edu/genomescope/) to generate this 
[report](http://genomescope.org/analysis.php?code=Bm6XRZmRpQ2dNxEo8fHs). Highlights:

Genome stats for Sgr from Jellyfish/GenomeScope v1.0 k=21
stat    |min    |max    |average
------  |------ |------ |------
Heterozygosity  |1.32565%       |1.34149%       |1.33357%
Genome Haploid Length   |693,553,516 bp |695,211,827 bp |694,382,672 bp
Model Fit       |97.6162%       |98.7154%       |98.1658 %

## Step 7. Assemble the genome using [SPAdes](https://github.com/ablab/spades#sec3.2)

In our previous tests, contaminated data has produced the best assemblies for nDNA but decontaminated assemblies were better for mtDNA. The effect of using merged files remains unclear

Thus, I ran 4 assembly treatments: Contam with and without merged files and the same for Decontam. See [SPADES_Test_info](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/spratelloides_gracilis/SPADES_Test_info) for more info

***CONCLUSION***
***Recommending running contam and decontam but skipping MRDG all together***

LOG:
Executed [runSPADEShimem_R1R2_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_R1R2_noisolate.sbatch). *Do this for other species*
```sh
#runSPADEShimem_R1R2_noisolate.sbatch <your user ID> <3-letter species ID> <contam | decontam> <genome size in bp> <species dir>
# do not use trailing / in paths. Example running contaminated data:
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "contam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "decontam" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

Testing the merging reads option. *Not needed to repeat this for other spp"
[runSPADEShimem_Onlymrgd_cont_noisolate.sbatch](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/scripts/runSPADEShimem_Onlymrgd_cont_noisolate.sbatch)
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_Onlymrgd_cont_noisolate.sbatch "e1garcia" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/pire_ssl_data_processing/blob/main/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_Onlymrgd_cont_noisolate.sbatch
```

Also testing the effect of `--cov-cutoff auto`. *Do this in other species if BUSCO values are too low with `--cov-cutoff off`*
```sh
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "contam_covAUTO" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runSPADEShimem_R1R2_noisolate.sbatch "e1garcia" "Sgr" "decontam_covAUTO" "694000000" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

This SPAdes scripts automatically runs `QUAST` but running `BUSCO` separately 



### Summary of QUAST and BUSCO Results

Species    |DataType    |SCAFIG    |covcutoff    |No. of contigs    |Largest contig    |Total lenght    |% Genome size completeness    |N50    |L50    |BUSCO single copy
------  |------ |------ |------ |------  |------ |------ |------ |------  |------ |------ 
Sgr  |contam       |contigs       |off       |2253577  |309779       |489995603       |70.5%       |5515       |28571       |29.9%       
Sgr  |contam       |scaffolds       |off       |2237565  |309779       |517068774       |74.5%       |5806       |28041       |29.9%
Sgr  |contam       |contigs       |auto       |2220821  |309779       |489827781       |70.6%       |5800       |28040       |30%
Sgr  |contam       |scaffolds       |auto       |2204948  |309779       |516942564       |74.5%       |5800       |28041       |32.2%
Sgr  |decontam       |contgs       |off       |2316449  |197090       |411716418       |59.3%       |5443       |24590       |27.1%
Sgr  |decontam       |scaffolds       |off       |2295872  |197090       |440572995       |63.5%       |5751       |24463       |29.5%
Sgr  |decontam       |contgs       |auto       |2290268  |197090       |411810888       |59.4%       |5442       |24601       |27.1%
Sgr  |decontam       |scaffolds       |auto       |2269777  |197090       |440612739       |63.5%       |5750       |24463       |29.5%

