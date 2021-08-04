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
  * ~340-414M

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
  * 205-213M

---


## Step 5. Run fastq_screen

Executed `runFQSCRN_6.bash` to generate this [report]()

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


Potential issues from report:
* job 9 failed
  * [out file](./logs/LlA01005_CKDL210012719-1a-AK6260-7UDI308_HF5TCDSX2_L1_clmp_fp2_r2.fq.gz)
  * "No reads in LlA01005_CKDL210012719-1a-AK6260-7UDI308_HF5TCDSX2_L1_clmp_fp2_r2.fq.gz, skipping" 
  * I checked this file, there are plenty of reads


Fix errors: all I had to do was run the files again that returned the "No reads in" error and they worked fine

```
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
# do not use trailing / in paths
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01010*r1.fq.gz
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01005*r2.fq.gz
```

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

