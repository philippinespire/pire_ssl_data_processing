## Chromis viridis SSL data processing

### Download data from TAMUCC

Make directory and download data using gridDownloader.sh

```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/chromis_viridis/fq_raw
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/gridDownloader.sh . https://gridftp.tamucc.edu/genomics/20230425_PIRE-Cvi-ssl/
```
