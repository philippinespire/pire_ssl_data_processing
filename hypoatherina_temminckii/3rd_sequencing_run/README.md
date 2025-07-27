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



[hpc-0373@d1-w6420a-16 3rd_sequencing_run]$ exit
```
</details> 
