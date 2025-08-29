<img src="https://fishbase.mnhn.fr/images/species/Hytem_u1.jpg" alt="Hte" width="400"/>

# *Hypoatherina temminckii* SSL Analysis 

```
/archive/carpenterlab/pire/pire_ssl_data_processing/hypoatherina_temminckii/3rd_sequencing_run/
```

Analysis of SSL data for *Hypoatherina temminckii* from Jolo Market (CJol) and Masinloc Public Market (CMvi). 

One contemporary individual from each site has been sequenced to generate a better reference genome that would enable mapping success in the future.

fq.gz processing done by Gianna Mazzei (July 2025).

---
	
## fq.gz Pre-processing

This portion follows the instructions on [this repo](https://github.com/philippinespire/pire_fq_gz_processing).

→ (*) _denotes steps with MultiQC Report Analyses_
<details><summary>0. Set-up</summary>

## 0. Set-up

Make a sequencing run directory to transfer the raw data to. The directory holding the data is called `3rd_sequencing_run`, so I'll maintain the same convention.
```
cd /archive/carpenterlab/pire/pire_ssl_data_processing/hypoatherina_temminckii

[hpc-0373@wahab-01 hypoatherina_temminckii]$ mkdir 3rd_sequencing_run
```
---
</details>

<details><summary>1. Get raw data</summary>

## 1. Get raw data

```
[hpc-0373@wahab-01 hypoatherina_temminckii]$ cp -r /archive/carpenterlab/pire/downloads/hypoatherina_temminckii/3rd_sequencing_run/* 3rd_sequencing_run/
```

---
</details>

<details><summary>2. Proofread the decode file</summary>

## 2. Proofread the decode file

```
cd 3rd_sequencing_run/fq_raw/

[hpc-0373@wahab-01 fq_raw]$ cat Hte_SSL_SequenceNameDecode.tsv 
```
Checked that I have sequencing data for all individuals in the decode file
```
[hpc-0373@wahab-01 fq_raw]$ ls *1.fq.gz | wc -l
4
[hpc-0373@wahab-01 fq_raw]$ ls *2.fq.gz | wc -l
4
```
Number of lines (there's a line for header):
```
[hpc-0373@wahab-01 fq_raw]$ wc -l Hte_SSL_SequenceNameDecode.tsv 
3 
```
There is an issue. Each individual was sequenced across two different lanes, and the decode file wants to rename both of these files with the same name, which would write over one of them. Typically, this is resolved with more complex methods, but since there are only a few files, I'll just manually alter the decode file.
```
[hpc-0373@wahab-01 fq_raw]$ ls -1
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L4_1.fq.gz
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L4_2.fq.gz
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L5_1.fq.gz
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L5_2.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L4_1.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L4_2.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L5_1.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L5_2.fq.gz

[hpc-0373@wahab-01 fq_raw]$ cat Hte_SSL_SequenceNameDecode.tsv 
Sequence_Name	Extraction_ID
HtC0608702H	Hte-CJol_087-Ex1-2H-SSL-1-1
HtC0200803H	Hte-CMvi_008-Ex1-3H-SSL-1-1

[hpc-0373@wahab-01 fq_raw]$ nano Hte_SSL_SequenceNameDecode.tsv
Sequence_Name	Extraction_ID
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L4	Hte-CMvi_008-Ex1-3H-SSL-1-1
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L5	Hte-CMvi_008-Ex1-3H-SSL-1-1
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L4	Hte-CJol_087-Ex1-2H-SSL-1-1
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L5	Hte-CJol_087-Ex1-2H-SSL-1-1
```

Now, I can move forward.

---
</details>

<details><summary>3. Rename raw files</summary>

## 3. Rename raw files

First, perform a renaming dry run with the new decode file.

Instead of `renameFQGZ.bash`, I will use the script `renameFQGZ_keeplane2.bash` to rename the files because the lane ID needs to be maintained between the original file name and the new file name. 
```
[hpc-0373@wahab-01 fq_raw]$ salloc
[hpc-0373@d1-w6420a-03 fq_raw]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ_keeplane2.bash Hte_SSL_SequenceNameDecode.tsv
preview of orig and new R1 file names...
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L4_1.fq.gz Hte-CMvi_008-Ex1-3H-SSL-1-1-L4-1.fq.gz
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L5_1.fq.gz Hte-CMvi_008-Ex1-3H-SSL-1-1-L5-1.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L4_1.fq.gz Hte-CJol_087-Ex1-2H-SSL-1-1-L4-1.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L5_1.fq.gz Hte-CJol_087-Ex1-2H-SSL-1-1-L5-1.fq.gz
preview of orig and new R2 file names...
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L4_2.fq.gz Hte-CMvi_008-Ex1-3H-SSL-1-1-L4-2.fq.gz
HtC0200803H_CKDL250011451-1A_22W2WGLT4_L5_2.fq.gz Hte-CMvi_008-Ex1-3H-SSL-1-1-L5-2.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L4_2.fq.gz Hte-CJol_087-Ex1-2H-SSL-1-1-L4-2.fq.gz
HtC0608702H_CKDL250011451-1A_22W2WGLT4_L5_2.fq.gz Hte-CJol_087-Ex1-2H-SSL-1-1-L5-2.fq.gz
```
Looks good!

Now, rename for real.
```
[hpc-0373@e3-w6420b-01 fq_raw]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ_keeplane2.bash Hte_SSL_SequenceNameDecode.tsv rename
```

---
</details>

<details><summary>4. Check the quality of raw data (*)</summary>

## 4. Check the quality of raw data (*)

Execute `Multi_FASTQC.sh`:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"
Submitted batch job 4627394
```

### MultiQC output (fq_raw/fqc_raw_report.html):
* About half of reads for CJol were duplicates
* Reverse reads (r2) failing GC Content
* Overrepresented sequences in forward reads (r1)

```
‣ % duplication - 
    • CMvi: 18.0 - 18.8%
    • CJol: 45.2 - 47.0%
‣ GC content - 
    • CMvi: 44 - 45%
    • CJol: 50 - 53%
‣ number of reads - 
    • CMvi: 3.5 mil
    • CJol: 34.7 - 34.8 mil
```
---
</details>

<details><summary>5. First trim (*)</summary>

## 5. First trim (*)

Run `runFASTP_1st_trim.sbatch`:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1
Submitted batch job 4627397
```
### Review the FastQC output (fq_fp1/1st_fastp_report.html):
* Sequence Quality improves after filtering
* GC Content improves after filtering, but unstable before read 10

```
‣ % duplication - 
    • CMvi: 14.9 - 15.1%
    • CJol: 36.1 - 36.2%
‣ GC content -
    • CMvi: 41.9%
    • CJol: 47.1 - 47.2%
‣ passing filter - 
    • CMvi: 94.1%
    • CJol: 88.7 - 88.8%
‣ % adapter - 
    • CMvi: 12.9%
    • CJol: 27.2 - 27.3%
‣ number of reads - 
    • CMvi: 6.7 mil
    • CJol: 61.7 - 61.8 mil
```
---
</details>

<details><summary>6. Remove duplicates with clumpify (*)</summary>

## 6. Remove duplicates with clumpify (*)

<details><summary>6a. Remove duplicates</summary>
	
### 6a. Remove duplicates

```
[hpc-0373@wahab-01 3rd_sequencing_run]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/hpc-0373 20
Submitted batch job 4627402
```
</details>

<details><summary>6b. Check duplicate removal success</summary>
	
### 6b. Check duplicate removal success

Check if clumpify worked:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ salloc
[hpc-0373@d1-w6420a-16 3rd_sequencing_run]$ enable_lmod
[hpc-0373@d1-w6420a-16 3rd_sequencing_run]$ module load container_env R/4.3 
[hpc-0373@d1-w6420a-16 3rd_sequencing_run]$ crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save

Clumpify Successfully worked on all samples

[hpc-0373@d1-w6420a-16 3rd_sequencing_run]$ exit
```
</details> 

<details><summary>6c. Clean the scratch drive</summary>
	
### 6c. Clean the scratch drive
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/cleanSCRATCH.sbatch /scratch/hpc-0373 "*clumpify*temp*"
Submitted batch job 4627407
```

Check:
```
ls /scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/
```
Nothing printed, so its cleared.

</details>

<details><summary>6d. Generate metadata on deduplicated FASTQ files (*)</summary>

### 6d. Generate metadata on deduplicated FASTQ files (*)
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
Submitted batch job 4627408
```

**Results** (fq_fp1_clmp/fqc_clmp_report.html): 
* All passing Per Sequence GC Content
* CJol.r2 warnings for overrepresented sequences
* No samples found with any adapter contamination > 0.1%

```
‣ % duplication - 
    • CMvi: 4.9 - 5.5%
    • CJol: 10.5 - 12.3%
‣ GC content - 
    • CMvi: 41 - 42%
    • CJol: 47%
‣ length - 
    • CMvi: 144 bp
    • CJol: 133 bp
‣ number of reads -
    • CMvi: 2.9 mil
    • CJol: 19.9 mil
```
</details>

---
</details>

<details><summary>7. Second trim (*)</summary>

## 7. Second trim (*)

For SSL, set the Minimum Sequence Length to 140 bp. 
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2 140
Submitted batch job 4627411
```
Lets see how many reads are lost at this cutoff. 
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ cp ../../../pire_fq_gz_processing/read_length_counter.bash .
[hpc-0373@wahab-01 3rd_sequencing_run]$ bash read_length_counter.bash -n 1000 fq_fp1 > fq_fp1/read_length_counts.tsv
[hpc-0373@wahab-01 3rd_sequencing_run]$ awk '$2 >= 140 {sum += $3} END {print "Reads >=140bp:", sum}' fq_fp1/read_length_counts.tsv
Reads >=140bp: 6430
[hpc-0373@wahab-01 3rd_sequencing_run]$ awk '{sum += $3} END {print "Total reads:", sum}' fq_fp1/read_length_counts.tsv
Total reads: 8000
```
About 80% of reads are retained.

### Review the FastQC output (fq_fp1_clmp_fp2/2nd_fastp_report.html):
* Duplication went down
* Many short reads were filtered out
 	* 16% (1 mil reads) from CMvi	
	* 33% (13 mil reads) from CJol

```
‣ % duplication -
    • CMvi: 2.6%
    • CJol: 7.0%
‣ GC content -
    • CMvi: 41.4%
    • CJol: 46.4%
‣ passing filter -
    • CMvi: 84%
    • CJol: 67%
‣ % adapter -
    • CMvi: 0.3%
    • CJol: 0.4%
‣ number of reads -
    • CMvi: 4.9 mil
    • CJol: 26.7 mil
```

---
</details>

<details><summary>8. Decontaminate files (*)</summary>

## 8. Decontaminate files (*)

<details><summary>8a. Run fastq_screen</summary>
	
### 8a. Run fastq_screen

```
[hpc-0373@wahab-01 3rd_sequencing_run]$ bash
[hpc-0373@wahab-01 3rd_sequencing_run]$ fqScrnPATH=/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash
[hpc-0373@wahab-01 3rd_sequencing_run]$ indir=fq_fp1_clmp_fp2
[hpc-0373@wahab-01 3rd_sequencing_run]$ outdir=/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 3rd_sequencing_run]$ nodes=20
[hpc-0373@wahab-01 3rd_sequencing_run]$ bash $fqScrnPATH $indir $outdir $nodes
```
JobID: 4627446

</details>

<details><summary>8b. Check for Errors</summary>
	
### 8b. Check for Errors

```
[hpc-0373@wahab-01 3rd_sequencing_run]$ bash
[hpc-0373@wahab-01 3rd_sequencing_run]$ outdir=/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/validateFQ.sbatch $outdir "*filter.fastq.gz"
Submitted batch job 4632231
```

When complete check the $outdir/fqValidateReport.txt file
```
less -S $outdir/fqValidationReport.txt file
```
**Confirm files were succesfully completed:**

Check that all 5 files were created for each fqgz file:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ outdir=/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 3rd_sequencing_run]$ ls $outdir/*r1.tagged.fastq.gz | wc -l
					ls $outdir/*r2.tagged.fastq.gz | wc -l
					ls $outdir/*r1.tagged_filter.fastq.gz | wc -l
					ls $outdir/*r2.tagged_filter.fastq.gz | wc -l 
					ls $outdir/*r1_screen.txt | wc -l
					ls $outdir/*r2_screen.txt | wc -l
					ls $outdir/*r1_screen.png | wc -l
					ls $outdir/*r2_screen.png | wc -l
					ls $outdir/*r1_screen.html | wc -l
					ls $outdir/*r2_screen.html | wc -l
4
4
4
4
4
4
4
4
4
4
```
For each, you should have the same number as the number of input files (number of fq.gz files):
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ indir=fq_fp1_clmp_fp2
[hpc-0373@wahab-01 3rd_sequencing_run]$ ls $indir/*r1.fq.gz | wc -l
                                        ls $indir/*r2.fq.gz | wc -l
4
4
```
Check the `*out` files: (no results)
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ grep 'error' slurm-fqscrn.*out
                                        grep 'No reads in' slurm-fqscrn.*out
                                        grep 'FATAL' slurm-fqscrn.*out
```
Check for any unzipped files with the word temp, which means that the job didn't finish and needs to be rerun: 
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ ls $outdir/*temp*
ls: cannot access '/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/*temp*': No such file or directory
```

No errors!

---
</details>

<details><summary>8c. Move output files</summary>

### 8c. Move output files

```
[hpc-0373@wahab-01 3rd_sequencing_run]$ mkdir fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 3rd_sequencing_run]$ mv /scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/* /archive/carpenterlab/pire/pire_ssl_data_processing/hypoatherina_temminckii/3rd_sequencing_run/fq_fp1_clmp_fp2_fqscrn
```
Check to see if `/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/` was cleared:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ ls /scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
#nothing printed
```
---
</details>

<details><summary>8d. Run MultiQC (*)</summary>

### 8d. Run MultiQC (*)

```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
Submitted batch job 4632234
```
#### Review the MultiQC output (fq_fp1_clmp_fp2_fqscrn/fastq_screen_report.html): 
* No apparent sources of contamination

```
‣ no hits -
    • CMvi: 97%
    • CJol: 94%
```
</details>

---

</details>

<details><summary>9. Repair FASTQ Files Messed Up by FASTQ_SCREEN (*)</summary>

## 9. Repair FASTQ Files Messed Up by FASTQ_SCREEN (*)

#### Execute `runREPAIR.sbatch`

Next we need to re-pair our reads. `runREPAIR.sbatch` matches up forward (r1) and reverse (r2) reads so that the `*1.fq.gz` and `*2.fq.gz` files have reads in the same order
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 5
Submitted batch job 4633991
```
#### Confirm that the paired end fq.gz files are complete and formatted correctly:

Start by running the script:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ bash
[hpc-0373@wahab-01 3rd_sequencing_run]$ SCRIPT=/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/validateFQPE.sbatch 
                                        DIR=fq_fp1_clmp_fp2_fqscrn_rprd
                                        fqPATTERN="*fq.gz"
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch $SCRIPT $DIR $fqPATTERN
Submitted batch job 4633992
```

Check the SLURM `.out` file and `fqValidationReport.txt` to determine if all of the fqgz files are valid:
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ cat valiate_FQ_-4633992.out
PAIRED END FASTQ VALIDATION REPORT

Directory: fq_fp1_clmp_fp2_fqscrn_rprd
File Pattern: *fq.gz
File extensions found: .R1.fq.gz .R2.fq.gz

Number of paired end fq files evaluated: 4
Number of paired end fq files validated: 4

Errors Reported:
```

#### Run `Multi_FASTQC`
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" "fq.gz"
Submitted batch job 4634304
```

#### Review MultiQC output (fq_fp1_clmp_fp2_fqscrn_rprd/fqc_rprd_report.html):
* Still some duplicate reads in CJol libraries
* Per Sequence GC Content: All passing and peaks have normalized; Jol and Mvi have slightly different curves
* All samples had less than 1% of reads made up of overrepresented sequences
* No samples found with any adapter contamination > 0.1%

```
‣ % duplication - 
    • CMvi: 4.7%
    • CJol: 10.9 - 13.4%
‣ GC content -
    • CMvi: 41%
    • CJol: 45%
‣ length -
    • CMvi: 150 bp
    • CJol: 150 bp
‣ number of reads -
    • CMvi: 2.3 mil
    • CJol: 12.2 mil
```

---
</details>

<details><summary>10. Clean Up</summary>

## 10. Clean Up

Move any .out files into the logs dir
```
[hpc-0373@wahab-01 3rd_sequencing_run]$ mkdir logs
[hpc-0373@wahab-01 3rd_sequencing_run]$ mv *out logs/
```

---
</details>


## SSL pipeline

Brendan taking over for genome assembly 8/29/25

Before running assembly, splitting the reads from the two individuals sequenced out into separate dirs.

```
cd /archive/carpenterlab/pire/pire_ssl_data_processing/hypoatherina_temminckii/3rd_sequencing_run/
mv fq_fp1_clmp_fp2_fqscrn_rprd fq_fp1_clmp_fp2_fqscrn_rprd_CJol
mkdir fq_fp1_clmp_fp2_fqscrn_rprd_CMvi
mv fq_fp1_clmp_fp2_fqscrn_rprd_CJol/*Mvi* fq_fp1_clmp_fp2_fqscrn_rprd_CMvi
```

Run Jellyfish.

```
#sbatch runJellyfish.sbatch <Species 3-letter ID> <indir>
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Hte" "fq_fp1_clmp_fp2_fqscrn_rprd_CJol"
sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts/runJellyfish.sbatch "Hte" "fq_fp1_clmp_fp2_fqscrn_rprd_CMvi"
```
