## Blobtools analysis, Sde minlen140 assembly

Location of assembly and read data:
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta

/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140_fqscrn_rprd
```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBLAST_forblob.sb .

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBWA_forblob.sb .
``` 

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/fq_fp1_clmp_fp2min140_fqscrn_rprd fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140 Sde_minlen140
```

Create the Blobtools analysis directory for the assembly and add BLAST hits/BUSCO/coverage:

```
salloc --ntasks=1 --job-name=blob
enable_lmod
module load container_env/0.1
module load busco/5.0.0
module load container_env blobtoolkit
bash
export SINGULARITY_BIND=/home/e1garcia
crun blobtools create \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
crun blobtools add \
    --hits /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/blastn.out  \
    --taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
    --taxrule bestsumorder \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
crun blobtools add \
	--busco /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/assemblies_for_fp2min140/busco_scaffolds_results-SPAdes_allLibs_decontam_R1R2_noIsolate/run_actinopterygii_odb10/full_table.tsv \
	/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
crun blobtools add \
	--cov /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_minlen140_redundans.sort.filt.bam \
	/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_delicatulus/blobtools_min140/Sde_min140_blobplot
```
