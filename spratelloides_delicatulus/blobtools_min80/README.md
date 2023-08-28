## Blobtools analysis, Sde minlen140 assembly

Location of assembly and read data:
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min80/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta

/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min80/fq_fp1_clmp_fp2min80_fqscrn_rprd
```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min80
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min80

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBLAST_forblob.sb .

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBWA_forblob.sb .
``` 

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min80/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min80
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min80/SPAdes_allLibs_decontam_R1R2_noIsolate scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min80_fqscrn_rprd fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min80 Sde_minlen80
```
