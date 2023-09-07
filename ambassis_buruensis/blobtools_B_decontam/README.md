## Blobtools analysis, Abu ssl assembly

Location of assembly and read data:
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired

```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBLAST_forblob.sb .
# changed to -C 32

#no BWA yet
cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBWA_forblob.sb .
``` 

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/ scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam Abu
```

