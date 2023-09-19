## Blobtools analysis, Abu ssl assembly

Location of assembly and read data:
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate/scaffolds.fasta
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2

```

Make a folder for a blobtools analysis:
```
mkdir /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam
```

Copy scripts and move to blobtools directory (note - should have BUSCO and QUAST already, so just running BWA and BLAST). BR is editing file scripts to include variables for path to assembly file, read data files, and blobtools output directory.
```
cd /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam

cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBLAST_forblob.sb .
# changed to -C 32

#no BWA yet
cp /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/template_scripts/runBWA_forblob.sb .
```

Fixing the runBWA script so that arg #4 takes lower- or uppercase [R/r]1.[extension].

Run BLAST:
```
sbatch runBLAST_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate/scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam
```

Run BWA:
```
sbatch runBWA_forblob.sb /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate/ scaffolds.fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/fq_fp1_clmp_fp2 fq.gz /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam Abu
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
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_ssl_blobplot
crun blobtools add \
    --hits /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/blastn.out  \
    --taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
    --taxrule bestsumorder \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_ssl_blobplot
crun blobtools add \
    --busco /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/busco_scaffolds_results-SPAdes_Abu-CPnd-B_contam_R1R2_noIsolate/run_actinopterygii_odb10/full_table.tsv \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_ssl_blobplot
crun blobtools add \
    --cov /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu.sort.filt.bam \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_ssl_blobplot
```

Check the -tail of the bestsumorder_phylum.json file to find which non-Chordate contaminants are present. Add those as a comma-separated list to the `--param bestsumorder_phylum--Keys=` command.
No GC filter, mean depth of coverage ~50 so using depth of coverage min 1/3 (17x) - max 2x (100x), just keep Chordata + no-hit, name by hits kept.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Annelida,Arthropoda,Mollusca,Pseudomonadota,Porifera,Bryozoa,Bacteria-undef,Platyhelminthes,Gemmatimonadota,Bdellovibrionota,Bacteroidota,Planctomycetota,Actinomycetota,Nematoda,Ascomycota,Bacillota,Myxococcota,Microsporidia,Cnidaria,Thermodesulfobacteriota,Endomyxa,Eukaryota-undef,Acidobacteriota,Streptophyta,Uroviricota,Basidiomycota,Chloroflexota \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_filtercov_keepChordatanohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta Abu_scaffolds_filtcov_keepChordatanohit.fasta
```

Check bestsumorder_class.json from this filtering to find any non-Actinopteri contaminants. Add in a separate class filter command.
No GC filter, just keep Actinopteri + no-hit, name by hits kept.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Annelida,Arthropoda,Mollusca,Pseudomonadota,Porifera,Bryozoa,Bacteria-undef,Platyhelminthes,Gemmatimonadota,Bdellovibrionota,Bacteroidota,Planctomycetota,Actinomycetota,Nematoda,Ascomycota,Bacillota,Myxococcota,Microsporidia,Cnidaria,Thermodesulfobacteriota,Endomyxa,Eukaryota-undef,Acidobacteriota,Streptophyta,Uroviricota,Basidiomycota,Chloroflexota \
    --param bestsumorder_class--Keys=Amphibia,Mammalia,Aves,Cladistia,Lepidosauria \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_filtercov_keepActinopterinohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_contam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta Abu_scaffolds_filtcov_keepActinopterinohit.fasta
```

