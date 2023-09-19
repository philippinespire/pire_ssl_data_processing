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
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot
crun blobtools add \
    --hits /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/blastn.out  \
    --taxdump /home/e1garcia/shotgun_PIRE/denovo_genome_assembly/Blobtools/taxdump \
    --taxrule bestsumorder \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot
crun blobtools add \
    --busco /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/busco_scaffolds_results-SPAdes_Abu-CPnd-B_decontam_R1R2_noIsolate/run_actinopterygii_odb10/full_table.tsv \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot
crun blobtools add \
    --cov /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu.sort.filt.bam \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot
```

Filter by GC and cov only.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

mv scaffolds.filtered.fasta scaffolds_filterGCcov.fasta
```

Trying a filter: using max GC of 0.5, min cov 17 (~1/3 of avg depth), max cov 100 (~2x avg depth), and exclude Chordata.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Chordata \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keysChordata_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

mv scaffolds.filtered.fasta scaffolds_filterGCcov_keysChordata.fasta
```

--Keys will exclude - try --invert instead
fasta file must be input, not out??

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Inv=Chordata \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGC5_invChordata_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filterGCcov_invChordata.fasta
```

INV does not seem to be working!

Try Chordata | no hit - again keeps all.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Inv="Chordata|no-hit" \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_Chordata_nohit_GC5_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

mv scaffolds.filtered.fasta scaffolds_Chordata_nohit_GC5.fasta
```

Try no hit - again keeps all.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Inv="no-hit" \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_nohit_GC5_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

mv scaffolds.filtered.fasta scaffolds_nohit_GC5.fasta
```

Try filtering out taxonIDs not filtered by GC + cov 


```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda \
    --param bestsumorder_phylum--Keys=Annelida \
    --param bestsumorder_phylum--Keys=Mollusca \
    --param bestsumorder_phylum--Keys=Porifera \
    --param bestsumorder_phylum--Keys=Bryozoa \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keysArthropodaAnellidaMolluscaPoriferaBryozoa_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keysArthropodaAnellidaMolluscaPoriferaBryozoa.fasta
```

Only excludes final Key (Bryozoa).

Try a Boolean "or" list.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys="Arthropoda|Annelida|Mollusca|Porifera|Bryozoa" \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keysBoolArthropodaAnellidaMolluscaPoriferaBryozoa_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keysBoolArthropodaAnellidaMolluscaPoriferaBryozoa.fasta
```

Not working.

Try a query string.

```
crun blobtools filter \
    --query-string "gc--Max=0.5&Abu.sort.filt_cov--Min=17&Abu.sort.filt_cov--Max=100&bestsumorder_phylum--Keys=Arthropoda&bestsumorder_phylum--Keys=Annelida&bestsumorder_phylum--Keys=Mollusca&bestsumorder_phylum--Keys=Porifera&bestsumorder_phylum--Keys=Bryozoa" \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_query \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_query.fasta
```

Still only excludes Bryozoa.

Try a comma-separated list.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keysCommaArthropodaAnellidaMolluscaPoriferaBryozoa_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keysCommaArthropodaAnellidaMolluscaPoriferaBryozoa.fasta
```


WORKS!

Name by hits kept.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keepChordatanohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keepChordatanohit.fasta
```

Just keep Chordata, name by hits kept.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa,no-hit \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keepChordata_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keepChordata.fasta
```

Just keep Actinopteri and no-hit, name by hits kept.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa \
    --param bestsumorder_class--Keys=Amphibia,Aves,Cladistia,Mammalia,Lepidosauria \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keepActinopterinohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keepActinopterinohit.fasta
```

Just keep Actinopteri, name by hits kept.

```
crun blobtools filter \
    --param gc--Max=0.5 \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa,no-hit \
    --param bestsumorder_class--Keys=Amphibia,Aves,Cladistia,Mammalia,Lepidosauria \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filterGCcov_keepActinopteri_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtGCcov_keepActinopteri.fasta
```

No GC filter, just keep Chordata + no-hit, name by hits kept.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Pseudomonadota,Porifera,Platyhelminthes,Bacteria-undef,Bryozoa,Bacteroidota,Microsporidia,Myxococcota,Endomyxa,Acidobacteriota,Streptophyta,Nematoda,Actinomycetota,Bacillota \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filtercov_keepChordatanohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtcov_keepChordatanohit.fasta
```

No GC filter, just coverage, no taxon filtering.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filtercov_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtcov.fasta
```

No GC filter, just keep Chordata, name by hits kept.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=no-hit,Arthropoda,Annelida,Mollusca,Pseudomonadota,Porifera,Platyhelminthes,Bacteria-undef,Bryozoa,Bacteroidota,Microsporidia,Myxococcota,Endomyxa,Acidobacteriota,Streptophyta,Nematoda,Actinomycetota,Bacillota \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filtercov_keepChordata_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtcov_keepChordata.fasta
```

No GC filter, just keep Actinopteri, name by hits kept.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa,no-hit \
    --param bestsumorder_class--Keys=Amphibia,Aves,Cladistia,Mammalia,Lepidosauria \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filtercov_keepActinopteri_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv 

mv scaffolds.filtered.fasta scaffolds_filtcov_keepActinopteri.fasta
```

No GC filter, just keep Actinopteri + no-hit, name by hits kept.

```
crun blobtools filter \
    --param Abu.sort.filt_cov--Min=17 \
    --param Abu.sort.filt_cov--Max=100 \
    --param bestsumorder_phylum--Keys=Arthropoda,Annelida,Mollusca,Porifera,Bryozoa \
    --param bestsumorder_class--Keys=Amphibia,Aves,Cladistia,Mammalia,Lepidosauria \
    --output /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_filtercov_keepActinopterinohit_blobplot \
    --fasta /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/scaffolds.fasta \
    /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/ambassis_buruensis/blobtools_B_decontam/Abu_ssl_blobplot

# Default name is "[input prefix].filtered.fasta"... change to more descriptive name

mv scaffolds.filtered.fasta scaffolds_filtcov_keepActinopterinohit.fasta
```
