# Readme for Sde fp2_min140_contam

For more details on how to run blobtools see the decontaminated readme at ../blobtools_min140/README.md

copy files
```
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_contam_R1R2_noIsolate/scaffolds.fasta ./scaffolds.contam.fasta
cp runBWA_forblob.sb runBLAST_forblob.sb ../blobtools_min140_contam/
```

run BLAST
```
sbatch runBLAST_forblob.sb ./scaffolds.contam.fasta .
```

run BWA
```
sbatch runBWA_forblob.sb . scaffolds.contam.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140/ fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140_contam Sde_minlen140_contam
```
didn't find the fq files.

I had to modify the script so it would recognize the contam fq files (i.e. r instead of R)
```
#from
R1s=${FQDIR}/*R1.${FQFORMAT}
R2s=${FQDIR}/*R2.${FQFORMAT}
#to
R1s=${FQDIR}/*r1.${FQFORMAT}
R2s=${FQDIR}/*r2.${FQFORMAT}
```

run BWA again
```
sbatch runBWA_forblob.sb . scaffolds.contam.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140/ fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140_contam Sde_minlen140_contam
```
