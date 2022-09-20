## Sphyraena obstusata SSL pipeline
### 0. Rename the raw fq.gz files an make a copy on /RC

Renaming files based on decode file.
Check proposed renaming scheme first.
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sob_ProbeDevelopmentLibraries_SequenceNameDecode.tsv
```  
Looks good to me - proceeding to rename:
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sob_ProbeDevelopmentLibraries_SequenceNameDecode.tsv rename
```
NOTE - renameFQGZ.bash is behaving strangely. Sometimes one or more of the names will be wrong - this appears to be somewhat random. I ran with 'rename' but did not proceed with the changes until it produced the correct names.

Making a backup copy.
```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_raw_ssl
cp *.fq.gz /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_raw_ssl
```
Moving renamed data to `shotgun_raw_fq`.
```
mkdir shotgun_raw_fq
mv *.fq.gz shotgun_raw_fq
```

### 1. Check the quality of the data - run fastqc

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq" "fq.gz"
```
