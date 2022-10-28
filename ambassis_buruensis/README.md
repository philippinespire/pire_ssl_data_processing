## Ambassis buruensis SSL pipeline

### 0. Rename the raw fq.gz files an make a copy on /RC

Renaming files based on decode file.
Check proposed renaming scheme first.
```
cd shotgun_raw_fq
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Abu_ProbeDevelopmentLibraries_SequenceNameDecode.tsv
```  
Looks good to me - proceeding to rename:
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Abu_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```

Making a backup copy.
```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_raw_ssl
cp *.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_raw_ssl
```

### 1. Check the quality of the data - run fastqc

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/shotgun_raw_fq" "fq.gz"
```

First fastQC overview:
* 32 - 56.3 million sequence pairs per library
* % duplication 20.3% - 24.4% (likely will be reduced after clumpify
* Sequence quality looks good (>30 on average)
* Motif evident in first 10 bp
* GC content 43%, slightly non-normal distribution ("bump" around 65-70% - bacterial contam?)
* N content and sequence length distributions good
* no red flags!

### 2. 2. 1st fastp / trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1
```

