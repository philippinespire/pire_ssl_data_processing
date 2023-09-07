## Blobtools analysis, Abu ssl assembly

Location of assembly and read data:
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired

```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBLAST_forblob.sb .
# changed to -C 32

#no BWA yet
#cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBWA_forblob.sb .
``` 

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/ scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2_fqscrn_repaired fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools Abu
```

Create the Blobtools analysis directory for the assembly and add BLAST hits / BUSCO results / coverage:

```
salloc --ntasks=1 --job-name=blob
enable_lmod
module load container_env/0.1
module load busco/5.0.0
module load container_env blobtoolkit
bash
export SINGULARITY_BIND=/home/e1garcia
crun blobtools create \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_ssl_blobplot
crun blobtools add \
    --hits /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/blastn.out  \
    --taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
    --taxrule bestsumorder \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_ssl_blobplot
crun blobtools add \
    --busco /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/busco_scaffolds_results-SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/run_actinopterygii_odb10/full_table.tsv \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_ssl_blobplot
crun blobtools add \
    --cov /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_redundans.sort.filt.bam \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_ssl_blobplot
```

Viewing outputs (on old laptop):

```
conda activate btk_env
~/blobtoolkit/blobtools2/blobtools view --remote /Users/nerdbrained/Desktop/Abu_ssl_blobplot
```

I accidentally used all of the reads (not just library B), so coverages are higher than in the SPAdes scaffold names.

Trying a filter: using max GC of 0.5, min cov 17 (~1/3 of avg depth), max cov 100 (~2x avg depth), and just hits to Chordata.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu_redundans.sort.filt_cov--Min=17 \
    --param Abu_redundans.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Chordata \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_filter_out \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/scaffolds_filtered.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools/Abu_ssl_blobplot
```
