## Blobtools analysis, Goy ssl assembly

Location of assembly and read data:
```
/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/probe_design/
/home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/fq_fp1_clmparray_fp2
```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools

cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/runBLAST_forblob.sb .

cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/runBWA_forblob.sb .
```

Fixing the runBWA script so that arg #4 takes lower- or uppercase [R/r]1.[extension].

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/probe_design/Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/probe_design/ Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.fasta /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/fq_fp1_clmparray_fp2 fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools Goy
```

Copying relevant files/folder to e1garcia so we can run blobtools:

```
cp -r /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/SPAdes_GyC0881E_contam_R1R2_noIsolate /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena
cp -r /home/jwhal002/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/busco_scaffolds_results-SPAdes_GyC0881E_contam_R1R2_noIsolate /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena
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
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/SPAdes_GyC0881E_contam_R1R2_noIsolate/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_ssl_blobplot
crun blobtools add \
    --hits /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/blastn.out  \
    --taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
    --taxrule bestsumorder \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_ssl_blobplot
crun blobtools add \
    --busco /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/busco_scaffolds_results-SPAdes_GyC0881E_contam_R1R2_noIsolate/run_actinopterygii_odb10/full_table.tsv \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_ssl_blobplot
crun blobtools add \
    --cov /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy.sort.filt.bam \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_ssl_blobplot
```

Check the -tail of the bestsumorder_phylum.json file to find which non-Chordate contaminants are present. Add those as a comma-separated list to the `--param bestsumorder_phylum--Keys=` command.
No GC filter, just keep Chordata + no-hit, name by hits kept.

```
crun blobtools filter \
    --param Goy.sort.filt_cov--Min=25 \
    --param Goy.sort.filt_cov--Max=140 \
    --param bestsumorder_phylum--Keys=Arthropoda,Cnidaria,Platyhelminthes,Pseudomonadota,Bryozoa,Bacteroidota,Annelida,Bacteria-undef,Mollusca,Actinomycetota,Oomycota,Verrucomicrobiota,Nematoda,Apicomplexa,Discosea,Ascomycota,Streptophyta,Rotifera,Duplornaviricota,Bacillota,Myxococcota,Chloroflexota,Microsporidia,Acidobacteriota,Basidiomycota \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_filtercov_keepChordatanohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.filtered.fasta Goy_scaffolds_filtcov_keepChordatanohit.fasta
```

Check bestsumorder_class.json from this filtering to find any non-Actinopteri contaminants. Add in a separate class filter command.
No GC filter, just keep Actinopteri + no-hit, name by hits kept.

```
crun blobtools filter \
    --param Goy.sort.filt_cov--Min=25 \
    --param Goy.sort.filt_cov--Max=140 \
    --param bestsumorder_phylum--Keys=Arthropoda,Cnidaria,Platyhelminthes,Pseudomonadota,Bryozoa,Bacteroidota,Annelida,Bacteria-undef,Mollusca,Actinomycetota,Oomycota,Verrucomicrobiota,Nematoda,Apicomplexa,Discosea,Ascomycota,Streptophyta,Rotifera,Duplornaviricota,Bacillota,Myxococcota,Chloroflexota,Microsporidia,Acidobacteriota,Basidiomycota \
    --param bestsumorder_class--Keys=Chordata-undef,Amphibia,Cladistia,Mammalia,Insecta \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_filtercov_keepActinopterinohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/gerres_oyena/blobtools/Goy_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv Goy_scaffolds_GyC0881E_contam_R1R2_noIsolate.filtered.fasta Goy_scaffolds_filtcov_keepActinopterinohit.fasta
```
