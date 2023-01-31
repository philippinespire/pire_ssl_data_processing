## Gma shotgun data processing

### 0. Rename the raw fq.gz files an make a copy on /RC

Renaming files based on decode file.
Check proposed renaming scheme first.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_macracanthus/shotgun_raw_fq
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Gma_ProbeDevelopmentLibraries_SequenceNameDecode.tsv
```  
Looks good to me - proceeding to rename:
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Gma_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```

Making a backup copy.
```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_macracanthus
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_macracanthus/fq_raw_ssl
cp *.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/gerres_macracanthus/fq_raw_ssl
```

### 1. Check the quality of the data - run fastqc

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_macracanthus/shotgun_raw_fq" "fq.gz"
```

Results:
* Lots of sequences (51.3 - 63.7M)
* Duplication high (50% - 64%)
* Quality good (mostly >35)
* GC content 44-45%; 4 of the libraries flagged, maybe a bit of contam?
* motif in first 9 bases
* mostly flagged for duplication but we might have enough seqs that it doesn't matter...

### 2. 1st FastP
