## Sphyraena obtusata SSL pipeline
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

First fastQC overview/potential issues:
* 36.7 - 42.4 million sequence pairs per library
* % duplication 19.8% - 23.2% (likely will be reduced after clumpify
* Sequence quality looks good (>30 on average)
* Motif evident in first 10 bp
* GC content 47-48%, slightly non-normal distribution ("bump" around 65-70% - bacterial contam?)
* N content and sequence length distributions good
* flagged for overrepresented sequences + adapter content

### 2. 1st fastp / trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/shotgun_raw_fq /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1
```

Results:
* 19.3 - 21% duplication
* GC content ~46.4% (lower)
* ~94% passing filter
* 10.6 - 15.4% adapter (Sob-CKal_018_Ex2-9F-ssl_L2_fastp higher than others)
* ~65 million to 80 million read pairs (maybe a little low compared to other species? but OK for assembly?)
* motif still present, otherwise no big red flags

### 3. Remove duplicates - run CLUMPIFY

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1 /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp /scratch/breid 20
```

Ran checkClumpify_EG.R, Clumpify worked successfully!

## Second fastp trim

sbatch /home/e1garcia/shotgun_pire/pire_fq_gz_processing/runFASTP_2_ssl.sbatch /home/e1garcia/shotgun_pire/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp /home/e1garcia/shotgun_pire/pire_ssl_data_processing/sphyraena_obtusata/fq_fp1_clmp_fp2



