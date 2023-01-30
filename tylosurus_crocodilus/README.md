## Tylosurus crocodilus SSL pipeline

### 0. Rename the raw fq.gz files an make a copy on /RC

Renaming files based on decode file.
Check proposed renaming scheme first.
```
cd shotgun_raw_fq
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Tcr_ProbeDevelopmentLibraries_SequenceNameDecode.tsv
```  
Looks good to me - proceeding to rename:
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Tcr_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```

Making a backup copy.
```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/tylosurus_crocodilus
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/tylosurus_crocodilus/fq_raw_ssl
cp *.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/tylosurus_crocodilus/fq_raw_ssl
```

### 1. Check the quality of the data - run fastqc

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/tylosurus_crocodilus/shotgun_raw_fq" "fq.gz"
```

First fastQC overview:
* 5.2-6 million sequence pairs per library - low for SSL?
* % duplication 19% - 20% (likely will be reduced after clumpify
* Sequence quality looks good (>35 mostly)
* Motif evident in first 9 bp
* GC content 45%
* N content and sequence length distributions good
* flagged for adapter content

### 2. 2. 1st fastp / trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/tylosurus_crocodilus/shotgun_raw_fq /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/tylosurus_crocodilus/fq_fp1
```

>96% of reads passed filter.
