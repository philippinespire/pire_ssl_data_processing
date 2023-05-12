## Chromis viridis SSL data processing

### Download data from TAMUCC

Make directory and download data using gridDownloader.sh

```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/gridDownloader.sh . https://gridftp.tamucc.edu/genomics/20230425_PIRE-Cvi-ssl/
```

### Backup raw data

```
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
screen cp ./* /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
```

### Rename files

Dry run.

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Cvi_SSL_SequenceNameDecode.tsv
```

Looks good - do it for real!

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Cvi_SSL_SequenceNameDecode.tsv rename
```

### Run first MultiQC

```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"
```

Summary:

* 55.9 - 63.8 M seqs / library
* Duplication fairly low (10.3% - 15.5%)
* GC content stable across libraries at 41%
* Quality looks good
* High adapter content, hopefully will be fixed in trim

### Run first trim

```
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1 
```

