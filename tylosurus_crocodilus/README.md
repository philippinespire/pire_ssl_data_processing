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
* XX-XX million sequence pairs per library
* % duplication XX% - XX% (likely will be reduced after clumpify
* Sequence quality looks good (>XX on average)
* Motif evident in first XX bp
* GC content XX%, slightly non-normal distribution
* N content and sequence length distributions good?
* no red flags?
